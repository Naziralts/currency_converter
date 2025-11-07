import '../../../../core/usecase/usecase.dart';
import '../repositories/rate_repository.dart';

class GetLatestRate implements UseCase<double, GetLatestRateParams> {
  final RateRepository repo;
  GetLatestRate(this.repo);

  @override
  Future<double> call(GetLatestRateParams params) {
    return repo.getLatestRate(base: params.base, target: params.target);
  }
}

class GetLatestRateParams {
  final String base;
  final String target;

  GetLatestRateParams({required this.base, required this.target});
}
