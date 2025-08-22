// lib/services/oura_api_service.dart
import 'package:dio/dio.dart';

/// Serviço mínimo do Oura:
/// - Compila mesmo sem OAuth (se não tiver token, retorna { data: [] }).
/// - Quando você implementar o login, chame `OuraApiService.instance.setAccessToken('...')`.
class OuraApiService {
  OuraApiService._();
  static final OuraApiService instance = OuraApiService._();

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.ouraring.com'));
  String? _accessToken; // definido via setAccessToken

  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Busca daily_sleep para um dia. Se não houver token → retorna vazio.
  Future<Map<String, dynamic>> getDailySleep({required DateTime day}) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      // Sem token ainda: retorna vazio para não quebrar a UI
      return {'data': []};
    }

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    try {
      final resp = await _dio.get(
        '/v2/usercollection/daily_sleep',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        queryParameters: {
          'start_date': _fmt(start),
          'end_date': _fmt(end),
        },
      );
      // Esperado: { "data": [ { ... } ] }
      if (resp.data is Map<String, dynamic>) {
        return resp.data as Map<String, dynamic>;
      }
      return {'data': []};
    } on DioException {
      // Em erro de rede/token, devolve vazio para manter a tela estável
      return {'data': []};
    }
  }

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
