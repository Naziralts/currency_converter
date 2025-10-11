import 'package:equatable/equatable.dart';

/// Абстрактный класс всех событий конвертера валют.
/// События — это действия пользователя или системы,
/// которые могут вызвать изменение состояния BLoC.
abstract class ConverterEvent extends Equatable {
  const ConverterEvent();

  /// Список свойств, по которым происходит сравнение объектов
  /// Нужно для корректной работы Equatable (сравнение по содержимому)
  @override
  List<Object?> get props => [];
}

/// Событие инициализации конвертера (например, при открытии экрана)
class ConverterInit extends ConverterEvent {
  const ConverterInit();
}

/// Событие смены базовой валюты (например, USD → EUR)
class ConverterBaseChanged extends ConverterEvent {
  final String base; // выбранная базовая валюта

  const ConverterBaseChanged(this.base);

  @override
  List<Object?> get props => [base]; // участвует в сравнении
}

/// Событие смены валюты назначения (например, USD → KGS)
class ConverterTargetChanged extends ConverterEvent {
  final String target; // выбранная целевая валюта

  const ConverterTargetChanged(this.target);

  @override
  List<Object?> get props => [target]; // участвует в сравнении
}

/// Событие изменения суммы для конвертации
class ConverterAmountChanged extends ConverterEvent {
  final String amountText; // текстовая сумма, введённая пользователем

  const ConverterAmountChanged(this.amountText);

  @override
  List<Object?> get props => [amountText]; // участвует в сравнении
}

/// Событие нажатия кнопки "Конвертировать"
class ConverterConvertPressed extends ConverterEvent {
  const ConverterConvertPressed();
}
// Что такое события (Event):
// События — это входящие сигналы в BLoC: что пользователь сделал или что система запросила.
// Например, выбор валюты, ввод суммы, нажатие кнопки.
// Как события используются в BLoC:
// BLoC слушает события через on<EventType> и обновляет состояние (ConverterState) в ответ.
// Зачем нужен Equatable:
// Чтобы сравнивать события по содержимому (например, base или amountText), а не по ссылке.
// Это помогает BLoC понимать, произошло ли реальное изменение данных, и не делать лишние обновления UI.
// Примеры:
// Пользователь выбирает новую базовую валюту → создается ConverterBaseChanged → BLoC обновляет base в состоянии.
// Пользователь вводит сумму → создается ConverterAmountChanged → BLoC обновляет amountText.
// Нажимает кнопку → ConverterConvertPressed → BLoC делает конвертацию и обновляет result.