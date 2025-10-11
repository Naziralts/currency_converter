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
// Объяснение
// Что делает GetHistory:
// Это UseCase (слой бизнес-логики), который отвечает за получение истории курсов валют.
// Он вызывает метод getHistory репозитория и возвращает результат.
// Зачем нужны UseCase и параметры:
// UseCase отделяет бизнес-логику от UI и BLoC.
// GetHistoryParams позволяет передавать все необходимые данные (base, target, days) в один объект, что удобно и безопасно.