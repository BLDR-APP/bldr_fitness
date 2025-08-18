import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class ProgressService {
  static ProgressService? _instance;
  static ProgressService get instance => _instance ??= ProgressService._();

  ProgressService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Record user measurement
  Future<Map<String, dynamic>> recordMeasurement({
    required String measurementType,
    required double value,
    String unit = 'kg',
    DateTime? measuredAt,
    String? notes,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final response = await _client
          .from('user_measurements')
          .insert({
            'user_id': currentUser.id,
            'measurement_type': measurementType,
            'value': value,
            'unit': unit,
            'measured_at': (measuredAt ?? DateTime.now()).toIso8601String(),
            'notes': notes,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to record measurement: $error');
    }
  }

  /// Get user measurements
  Future<List<Map<String, dynamic>>> getUserMeasurements({
    String? userId,
    String? measurementType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;

      var query = _client
          .from('user_measurements')
          .select()
          .eq('user_id', targetUserId);

      if (measurementType != null) {
        query = query.eq('measurement_type', measurementType);
      }

      if (startDate != null) {
        query = query.gte('measured_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('measured_at', endDate.toIso8601String());
      }

      final response =
          await query.order('measured_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user measurements: $error');
    }
  }

  /// Get latest measurement by type
  Future<Map<String, dynamic>?> getLatestMeasurement({
    String? userId,
    required String measurementType,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;

      final response = await _client
          .from('user_measurements')
          .select()
          .eq('user_id', targetUserId)
          .eq('measurement_type', measurementType)
          .order('measured_at', ascending: false)
          .limit(1);

      return response.isNotEmpty ? response.first : null;
    } catch (error) {
      throw Exception('Failed to get latest measurement: $error');
    }
  }

  /// Get measurement progress (comparison over time)
  Future<Map<String, dynamic>> getMeasurementProgress({
    String? userId,
    required String measurementType,
    int daysPeriod = 30,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysPeriod));

      final measurements = await getUserMeasurements(
        userId: targetUserId,
        measurementType: measurementType,
        startDate: startDate,
        endDate: endDate,
      );

      if (measurements.isEmpty) {
        return {
          'has_data': false,
          'latest_value': null,
          'previous_value': null,
          'change': null,
          'change_percentage': null,
        };
      }

      // Sort by date to ensure proper ordering
      measurements.sort((a, b) => DateTime.parse(a['measured_at'])
          .compareTo(DateTime.parse(b['measured_at'])));

      final latestValue = (measurements.last['value'] as num).toDouble();
      final previousValue = measurements.length > 1
          ? (measurements.first['value'] as num).toDouble()
          : latestValue;

      final change = latestValue - previousValue;
      final changePercentage =
          previousValue != 0 ? (change / previousValue) * 100 : 0.0;

      return {
        'has_data': true,
        'latest_value': latestValue,
        'previous_value': previousValue,
        'change': change,
        'change_percentage': changePercentage,
        'measurement_count': measurements.length,
        'period_days': daysPeriod,
      };
    } catch (error) {
      throw Exception('Failed to get measurement progress: $error');
    }
  }

  /// Log water intake
  Future<Map<String, dynamic>> logWaterIntake({
    required int amountMl,
    DateTime? loggedAt,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final now = loggedAt ?? DateTime.now();
      final response = await _client
          .from('user_water_intake')
          .insert({
            'user_id': currentUser.id,
            'amount_ml': amountMl,
            'logged_at': now.toIso8601String(),
            'date_logged': now.toIso8601String().split('T')[0],
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to log water intake: $error');
    }
  }

  /// Get daily water intake
  Future<Map<String, dynamic>> getDailyWaterIntake({
    String? userId,
    required DateTime date,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _client
          .from('user_water_intake')
          .select()
          .eq('user_id', targetUserId)
          .eq('date_logged', dateStr)
          .order('logged_at', ascending: true);

      final logs = List<Map<String, dynamic>>.from(response);
      final totalAmount = logs.fold<int>(
        0,
        (sum, log) => sum + (log['amount_ml'] as int),
      );

      return {
        'date': dateStr,
        'total_amount_ml': totalAmount,
        'total_amount_liters': (totalAmount / 1000.0).toStringAsFixed(1),
        'logs': logs,
        'log_count': logs.length,
      };
    } catch (error) {
      throw Exception('Failed to get daily water intake: $error');
    }
  }

  /// Get workout progress statistics
  Future<Map<String, dynamic>> getWorkoutProgress({
    String? userId,
    int daysPeriod = 30,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated');
      }

      final targetUserId = userId ?? currentUser.id;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysPeriod));

      // Get workout counts
      final totalWorkoutsData = await _client
          .from('user_workouts')
          .select('id')
          .eq('user_id', targetUserId)
          .gte('started_at', startDate.toIso8601String())
          .count();

      final completedWorkoutsData = await _client
          .from('user_workouts')
          .select('id')
          .eq('user_id', targetUserId)
          .eq('is_completed', true)
          .gte('started_at', startDate.toIso8601String())
          .count();

      // Get total workout time
      final workoutTimeResponse = await _client
          .from('user_workouts')
          .select('total_duration_seconds')
          .eq('user_id', targetUserId)
          .eq('is_completed', true)
          .gte('started_at', startDate.toIso8601String())
          .not('total_duration_seconds', 'is', null);

      int totalWorkoutTime = 0;
      for (final workout in workoutTimeResponse) {
        totalWorkoutTime += (workout['total_duration_seconds'] as int?) ?? 0;
      }

      final totalWorkouts = totalWorkoutsData.count ?? 0;
      final completedWorkouts = completedWorkoutsData.count ?? 0;
      final completionRate = totalWorkouts > 0
          ? (completedWorkouts / totalWorkouts * 100).round()
          : 0;

      return {
        'period_days': daysPeriod,
        'total_workouts': totalWorkouts,
        'completed_workouts': completedWorkouts,
        'completion_rate': completionRate,
        'total_workout_time_seconds': totalWorkoutTime,
        'total_workout_time_hours':
            (totalWorkoutTime / 3600).toStringAsFixed(1),
        'average_workout_duration_minutes': completedWorkouts > 0
            ? ((totalWorkoutTime / completedWorkouts) / 60).round()
            : 0,
      };
    } catch (error) {
      throw Exception('Failed to get workout progress: $error');
    }
  }

  /// Update measurement
  Future<Map<String, dynamic>> updateMeasurement({
    required String measurementId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('user_measurements')
          .update(updates)
          .eq('id', measurementId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update measurement: $error');
    }
  }

  /// Delete measurement
  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _client.from('user_measurements').delete().eq('id', measurementId);
    } catch (error) {
      throw Exception('Failed to delete measurement: $error');
    }
  }
}
