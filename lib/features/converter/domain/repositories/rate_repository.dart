import '../entities/history_point.dart';

/// Абстрактный репозиторий для работы с курсами валют.
/// Репозиторий отвечает за получение данных — либо из API, либо из локального кэша.
/// Это часть слоя data/domain в чистой архитектуре.
abstract class RateRepository {
  /// Получение актуального курса валюты.
  ///
  /// [base] — базовая валюта (например, USD)
  /// [target] — валюта, в которую конвертируем (например, EUR)
  /// Возвращает курс обмена в виде double.
  Future<double> getLatestRate({
    required String base,
    required String target,
  });

  /// Получение истории курсов валют за определённое количество дней.
  ///
  /// [base] — базовая валюта
  /// [target] — целевая валюта
  /// [days] — количество дней истории (по умолчанию 7)
  /// Возвращает список объектов [HistoryPoint], каждый из которых содержит дату и курс.
  Future<List<HistoryPoint>> getHistory({
    required String base,
    required String target,
    int days = 7,
  });
}
