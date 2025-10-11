import '../../domain/entities/history_point.dart';
import '../../domain/repositories/rate_repository.dart';
import '../datasources/rate_remote_data_source.dart';

/// Реализация интерфейса [RateRepository].
/// Отвечает за получение данных о курсах валют из удалённого источника (API).
/// Это часть слоя Data в чистой архитектуре.
class RateRepositoryImpl implements RateRepository {
  /// Источник данных (API)
  final RateRemoteDataSource remote;

  /// Конструктор принимает источник данных
  RateRepositoryImpl(this.remote);

  /// Получение актуального курса валют
  /// Делегирует вызов соответствующему методу remote data source
  @override
  Future<double> getLatestRate({
    required String base,
    required String target,
  }) {
    return remote.getLatestRate(base: base, target: target);
  }

  /// Получение истории курсов валют за заданное количество дней
  /// Делегирует вызов remote data source
  @override
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days = 7,
  }) {
    return remote.getHistory(base: base, target: target, days: days);
  }
}
// Объяснение
// Что делает RateRepositoryImpl:
// Это конкретная реализация интерфейса RateRepository.
// Она делегирует все запросы к удалённому источнику данных (RateRemoteDataSource).
// BLoC или UseCase используют интерфейс RateRepository, а реализация скрыта за этим контрактом.
// Почему это важно:
// Позволяет легко заменить источник данных (например, API → локальная база), не меняя бизнес-логику.
// Следует принципу Dependency Inversion: слои высокого уровня (BLoC/UseCase) зависят от абстракций, а не от конкретной реализации.