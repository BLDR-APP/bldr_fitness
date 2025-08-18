import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*'
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        // Get the authorization token from the request headers
        const authHeader = req.headers.get('Authorization');
        if (!authHeader) {
            throw new Error('Missing Authorization header');
        }

        // Extract the token from the Authorization header
        const token = authHeader.replace('Bearer ', '');

        // Create a Supabase client using the token from the logged-in user
        const supabaseUrl = Deno.env.get('SUPABASE_URL');
        const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
        const supabase = createClient(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: authHeader } }
        });

        // Create a Stripe client
        const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
        const stripe = new Stripe(stripeKey);

        // Get the request body
        const requestData = await req.json();
        const { plan_id, billing_period, currency = 'brl', user_id } = requestData;

        // Validate input data
        if (!plan_id || !billing_period || !user_id) {
            throw new Error('Missing required parameters: plan_id, billing_period, user_id');
        }

        if (!['monthly', 'annual'].includes(billing_period)) {
            throw new Error('Invalid billing_period. Must be "monthly" or "annual"');
        }

        // Get user information from the JWT token
        const { data: { user }, error: userError } = await supabase.auth.getUser(token);
        if (userError || user?.id !== user_id) {
            throw new Error('Unauthorized: User ID mismatch');
        }

        // Get subscription plan details
        const { data: plan, error: planError } = await supabase
            .from('subscription_plans')
            .select('*')
            .eq('id', plan_id)
            .eq('is_active', true)
            .single();

        if (planError || !plan) {
            throw new Error('Subscription plan not found or inactive');
        }

        // Calculate amount based on billing period
        const amount = billing_period === 'annual' ? plan.annual_price : plan.monthly_price;
        
        // Create a Stripe payment intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // Convert to cents/centavos
            currency: currency,
            automatic_payment_methods: { enabled: true },
            description: `BLDR Fitness - ${plan.name} (${billing_period})`,
            metadata: {
                user_id: user.id,
                plan_id: plan_id,
                plan_name: plan.name,
                billing_period: billing_period,
                plan_type: plan.plan_type
            }
        });

        // Create payment intent record in database
        const { data: paymentRecord, error: paymentError } = await supabase
            .from('payment_intents')
            .insert({
                user_id: user.id,
                stripe_payment_intent_id: paymentIntent.id,
                amount: amount,
                currency: currency,
                status: 'pending',
                plan_type: plan.plan_type,
                billing_period: billing_period,
                metadata: {
                    plan_id: plan_id,
                    plan_name: plan.name
                }
            })
            .select()
            .single();

        if (paymentError) {
            console.error('Error creating payment record:', paymentError);
            // Continue anyway, as Stripe payment intent was created
        }

        // Return the payment intent client secret
        return new Response(JSON.stringify({
            client_secret: paymentIntent.client_secret,
            payment_intent_id: paymentIntent.id,
            payment_id: paymentRecord?.id || null,
            plan_name: plan.name,
            amount: amount,
            currency: currency,
            billing_period: billing_period
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200
        });

    } catch (error) {
        console.error('Create payment intent error:', error.message);
        return new Response(JSON.stringify({ 
            error: error.message || 'Internal server error'
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400
        });
    }
});