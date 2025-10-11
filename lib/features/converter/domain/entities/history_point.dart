import 'package:equatable/equatable.dart';

/// Класс, представляющий одну точку истории курса валют.
/// Используется, чтобы хранить значение курса на конкретную дату,
/// например, для построения графика изменений валюты.
class HistoryPoint extends Equatable {
  /// Дата, к которой относится курс валюты
  final DateTime date;

  /// Значение курса валюты на указанную дату
  final double rate;

  /// Конструктор класса с обязательными параметрами date и rate
  const HistoryPoint({
    required this.date,
    required this.rate,
  });

  /// Переопределение props для Equatable
  /// Позволяет сравнивать объекты по содержимому (date и rate), а не по ссылке.
  @override
  List<Object?> get props => [date, rate];
}
