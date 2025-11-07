import '../../domain/entities/history_point.dart';
import '../../domain/repositories/rate_repository.dart';
import '../datasources/rate_remote_data_source.dart';


class RateRepositoryImpl implements RateRepository {

  final RateRemoteDataSource remote;

 
  RateRepositoryImpl(this.remote);

  @override
  Future<double> getLatestRate({
    required String base,
    required String target,
  }) {
    return remote.getLatestRate(base: base, target: target);
  }

  
  @override
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days = 7,
  }) {
    return remote.getHistory(base: base, target: target, days: days);
  }
}
