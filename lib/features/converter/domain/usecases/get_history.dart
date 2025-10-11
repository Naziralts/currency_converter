import '../../../../core/usecase/usecase.dart';
import '../entities/history_point.dart';
import '../repositories/rate_repository.dart';

/// UseCase для получения истории курсов валют.
/// UseCase — это слой бизнес-логики в чистой архитектуре.
/// Он использует репозиторий, чтобы получить данные, и возвращает их вызывающему слою (например, BLoC).
class GetHistory implements UseCase<List<HistoryPoint>, GetHistoryParams> {
  final RateRepository repo; // репозиторий для получения данных

  /// Конструктор, принимает репозиторий
  GetHistory(this.repo);

  /// Основной метод UseCase
  /// [params] — параметры запроса истории (базовая валюта, целевая валюта, дни)
  /// Возвращает Future<List<HistoryPoint>>
  @override
  Future<List<HistoryPoint>> call(GetHistoryParams params) {
    return repo.getHistory(
      base: params.base,
      target: params.target,
      days: params.days,
    );
  }
}

/// Параметры для GetHistory UseCase
class GetHistoryParams {
  final String base;   // базовая валюта
  final String target; // целевая валюта
  final int days;      // количество дней для истории (по умолчанию 7)

  GetHistoryParams({
    required this.base,
    required this.target,
    this.days = 7,
  });
}
