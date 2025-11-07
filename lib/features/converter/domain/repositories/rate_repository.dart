import '../entities/history_point.dart';


abstract class RateRepository {

 
  /// [base]
  /// [target] 
 
  Future<double> getLatestRate({
    required String base,
    required String target,
  });

  
  /// [base
  /// [target
  /// [days 
  /// 
  /// Возвращает список объектов [HistoryPoint]
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days = 7,
  });
}
