import '../../../../core/usecase/usecase.dart';
import '../entities/history_point.dart';
import '../repositories/rate_repository.dart';

class GetHistory implements UseCase<List<HistoryPoint>, GetHistoryParams> {
  final RateRepository repo; 
  
  GetHistory(this.repo);


  /// [params] 
  
  @override
  Future<List<HistoryPoint>> call(GetHistoryParams params) {
    return repo.getHistory(
      base: params.base,
      target: params.target,
      days: params.days,
    );
  }
}


class GetHistoryParams {
  final String base;   
  final String target; 
  final int days;      

  GetHistoryParams({
    required this.base,
    required this.target,
    this.days = 7,
  });
}
