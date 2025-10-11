import 'package:equatable/equatable.dart';
import '../../../converter/domain/entities/history_point.dart';

/// Класс состояния конвертера валют.
/// Хранит все данные, которые нужны для отображения UI.
class ConverterState extends Equatable {
  /// Показывает, идет ли сейчас загрузка (например, при конвертации или получении истории)
  final bool loading;

  /// Базовая валюта (например, USD)
  final String base;

  /// Целевая валюта (например, EUR)
  final String target;

  /// Сумма для конвертации в текстовом формате (введённая пользователем)
  final String amountText;

  /// Результат конвертации (число)
  final double? result;

  /// История курса валют за последние N дней
  final List<HistoryPoint> history;

  /// Ошибка, если что-то пошло не так
  final String? error;

  /// Конструктор состояния с начальными значениями
  const ConverterState({
    this.loading = false,
    this.base = 'USD',
    this.target = 'EUR',
    this.amountText = '1',
    this.result,
    this.history = const [],
    this.error,
  });

  /// Метод для копирования состояния с возможностью обновления отдельных полей.
  /// Очень важно для BLoC: вместо изменения состояния напрямую создаем новое.
  ConverterState copyWith({
    bool? loading,
    String? base,
    String? target,
    String? amountText,
    double? result,
    List<HistoryPoint>? history,
    String? error,
  }) {
    return ConverterState(
      loading: loading ?? this.loading,
      base: base ?? this.base,
      target: target ?? this.target,
      amountText: amountText ?? this.amountText,
      result: result,                // при copyWith переданное result заменяет текущее
      history: history ?? this.history,
      error: error,                  // при copyWith переданное error заменяет текущее
    );
  }

  /// Список свойств, используемых Equatable для сравнения состояний.
  /// Нужно, чтобы BLoC понимал, что состояние изменилось и UI нужно обновить.
  @override
  List<Object?> get props => [loading, base, target, amountText, result, history, error];
}
// Объяснение
// Что делает ConverterState:
// Это «снимок» состояния конвертера в любой момент времени.
// Хранит все данные, которые UI использует для отображения: базу, цель, сумму, результат, историю и ошибки.
// Почему copyWith важен:
// В BLoC состояния не изменяются напрямую, а создаются новые с помощью copyWith.
// Пример: пользователь меняет сумму → создаём новое состояние с обновленным amountText, остальные поля остаются прежними.
// Почему используется Equatable:
// Чтобы сравнивать состояния по содержимому, а не по ссылке.
// Это позволяет UI перерисовываться только при реальном изменении данных.
