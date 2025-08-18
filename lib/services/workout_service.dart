import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class WorkoutService {
  static WorkoutService? _instance;
  static WorkoutService get instance => _instance ??= WorkoutService._();

  WorkoutService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get workout templates
  Future<List<Map<String, dynamic>>> getWorkoutTemplates({
    String? workoutType,
    int? difficultyLevel,
    bool publicOnly = false,
  }) async {
    try {
      var query = _client.from('workout_templates').select('''
            id, name, description, workout_type, estimated_duration_minutes,
            difficulty_level, is_public, created_at,
            user_profiles!created_by(full_name)
          ''');

      if (publicOnly) {
        query = query.eq('is_public', true);
      }

      if (workoutType != null) {
        query = query.eq('workout_type', workoutType);
      }

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get workout templates: $error');
    }
  }

  /// Get workout template with exercises
  Future<Map<String, dynamic>?> getWorkoutTemplateWithExercises(
      String templateId) async {
    try {
      final response = await _client.from('workout_templates').select('''
            id, name, description, workout_type, estimated_duration_minutes,
            difficulty_level, is_public, created_at,
            workout_template_exercises(
              id, order_index, sets, reps, duration_seconds, rest_seconds,
              weight_kg, distance_meters, notes,
              exercises(
                id, name, description, exercise_type, primary_muscle_group,
                secondary_muscle_groups, instructions, tips, image_url,
                equipment_needed
              )
            )
          ''').eq('id', templateId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get workout template: $error');
    }
  }

  /// Create workout template
  Future<Map<String, dynamic>> createWorkoutTemplate({
    required String name,
    String? description,
    required String workoutType,
    int? estimatedDurationMinutes,
    int? difficultyLevel,
    bool isPublic = false,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final response = await _client
          .from('workout_templates')
          .insert({
            'name': name,
            'description': description,
            'workout_type': workoutType,
            'estimated_duration_minutes': estimatedDurationMinutes,
            'difficulty_level': difficultyLevel,
            'is_public': isPublic,
            'created_by': currentUser.id,
          })
          .select()
          .single();

      // Add exercises if provided
      if (exercises != null && exercises.isNotEmpty) {
        final templateExercises = exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return {
            'workout_template_id': response['id'],
            'exercise_id': exercise['exercise_id'],
            'order_index': index + 1,
            'sets': exercise['sets'],
            'reps': exercise['reps'],
            'duration_seconds': exercise['duration_seconds'],
            'rest_seconds': exercise['rest_seconds'],
            'weight_kg': exercise['weight_kg'],
            'distance_meters': exercise['distance_meters'],
            'notes': exercise['notes'],
          };
        }).toList();

        await _client
            .from('workout_template_exercises')
            .insert(templateExercises);
      }

      return response;
    } catch (error) {
      throw Exception('Failed to create workout template: $error');
    }
  }

  /// Start a workout
  Future<Map<String, dynamic>> startWorkout({
    required String name,
    String? workoutTemplateId,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final response = await _client
          .from('user_workouts')
          .insert({
            'user_id': currentUser.id,
            'workout_template_id': workoutTemplateId,
            'name': name,
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to start workout: $error');
    }
  }

  /// Complete a workout
  Future<Map<String, dynamic>> completeWorkout({
    required String workoutId,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();

      // Get workout start time
      final workoutResponse = await _client
          .from('user_workouts')
          .select('started_at')
          .eq('id', workoutId)
          .single();

      final startedAt = DateTime.parse(workoutResponse['started_at']);
      final duration = now.difference(startedAt).inSeconds;

      final response = await _client
          .from('user_workouts')
          .update({
            'completed_at': now.toIso8601String(),
            'total_duration_seconds': duration,
            'notes': notes,
            'is_completed': true,
          })
          .eq('id', workoutId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to complete workout: $error');
    }
  }

  /// Log exercise set
  Future<Map<String, dynamic>> logExerciseSet({
    required String userWorkoutId,
    required String exerciseId,
    required int setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    double? distanceMeters,
    int? restSeconds,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('workout_exercise_sets')
          .insert({
            'user_workout_id': userWorkoutId,
            'exercise_id': exerciseId,
            'set_number': setNumber,
            'reps': reps,
            'weight_kg': weightKg,
            'duration_seconds': durationSeconds,
            'distance_meters': distanceMeters,
            'rest_seconds': restSeconds,
            'notes': notes,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to log exercise set: $error');
    }
  }

  /// Get user workouts
  Future<List<Map<String, dynamic>>> getUserWorkouts({
    String? userId,
    bool completedOnly = false,
    int limit = 20,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;

      var query = _client.from('user_workouts').select('''
            id, name, started_at, completed_at, total_duration_seconds,
            notes, is_completed,
            workout_templates(name, workout_type)
          ''').eq('user_id', targetUserId);

      if (completedOnly) {
        query = query.eq('is_completed', true);
      }

      final response =
          await query.order('started_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user workouts: $error');
    }
  }

  /// Get workout details with exercise sets
  Future<Map<String, dynamic>?> getWorkoutDetails(String workoutId) async {
    try {
      final response = await _client.from('user_workouts').select('''
            id, name, started_at, completed_at, total_duration_seconds,
            notes, is_completed,
            workout_templates(name, workout_type),
            workout_exercise_sets(
              id, set_number, reps, weight_kg, duration_seconds,
              distance_meters, rest_seconds, completed_at, notes,
              exercises(name, primary_muscle_group)
            )
          ''').eq('id', workoutId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get workout details: $error');
    }
  }
}
