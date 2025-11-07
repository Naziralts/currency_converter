import 'package:dio/dio.dart';
import '../../domain/entities/history_point.dart';


abstract class RateRemoteDataSource {
  Future<double> getLatestRate({required String base, required String target});
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days,
  });
}

class RateRemoteDataSourceImpl implements RateRemoteDataSource {
  final Dio dio; 
  final String freeCurrencyApiKey; 

  RateRemoteDataSourceImpl({
    required this.dio,
    required this.freeCurrencyApiKey,
  });

 
  @override
  Future<double> getLatestRate({
    required String base,
    required String target,
  }) async {
 
    if (base == target) return 1.0;

    final url =
        'https://api.freecurrencyapi.com/v1/latest'
        '?apikey=$freeCurrencyApiKey'
        '&currencies=$base,$target';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data is Map) {
        final data = (response.data as Map)['data'] as Map?;
        if (data == null) throw Exception('Malformed response: no data');

       
        if (base == 'USD') {
          final r = (data[target] as num?)?.toDouble();
          if (r == null) throw Exception('No rate for $target');
          return r;
        }

        final usdToTarget = (data[target] as num?)?.toDouble();
        final usdToBase = (data[base] as num?)?.toDouble();
        if (usdToTarget == null || usdToBase == null) {
          throw Exception('No rate for $base or $target');
        }
        return usdToTarget / usdToBase;
      }


      final code = response.statusCode;
      final msg = (response.data is Map && (response.data as Map)['message'] != null)
          ? (response.data as Map)['message'].toString()
          : 'Failed to fetch latest rate';
      throw Exception('HTTP $code: $msg');
    } on DioException catch (e) {
  
      final status = e.response?.statusCode;
      final bodyMsg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : null;
      throw Exception('Network error${status != null ? " ($status)" : ""}'
          '${bodyMsg != null ? ": $bodyMsg" : ""}');
    }
  }

  @override
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days = 7,

  }) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    String d(DateTime dt) =>
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

    final url =
        'https://api.frankfurter.app/${d(start)}..${d(now)}?from=$base&to=$target';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data is Map) {
        final ratesMap = Map<String, dynamic>.from(response.data['rates'] ?? {});
        if (ratesMap.isEmpty) {
       
          return const <HistoryPoint>[];
        }

        final points = ratesMap.entries.map((e) {
          final date = DateTime.parse(e.key);
          final value = e.value[target];
          final rate = (value as num).toDouble();
          return HistoryPoint(date: date, rate: rate);
        }).toList()
          ..sort((a, b) => a.date.compareTo(b.date)); 

        return points;
      }

      final code = response.statusCode;
      final msg = (response.data is Map && (response.data as Map)['error'] != null)
          ? (response.data as Map)['error'].toString()
          : 'Failed to fetch history';
      throw Exception('HTTP $code: $msg');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final bodyMsg = (e.response?.data is Map && e.response?.data['error'] != null)
          ? e.response?.data['error'].toString()
          : null;
      throw Exception('Network error${status != null ? " ($status)" : ""}'
          '${bodyMsg != null ? ": $bodyMsg" : ""}');
    }
  }
}
