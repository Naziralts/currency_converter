import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../../converter/domain/usecases/get_history.dart';
import '../../../converter/domain/usecases/get_latest_rate.dart';
import 'converter_event.dart';
import 'converter_state.dart';

/// BLoC для управления состоянием конвертера валют
class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final GetLatestRate getLatestRate; // use case: получить текущий курс
  final GetHistory getHistory;       // use case: получить историю за n дней

  ConverterBloc({
    required this.getLatestRate,
    required this.getHistory,
  }) : super(const ConverterState()) {
    // Регистрируем обработчики событий
    on<ConverterInit>(_onInit);
    on<ConverterBaseChanged>(_onBaseChanged);
    on<ConverterTargetChanged>(_onTargetChanged);
    on<ConverterAmountChanged>(_onAmountChanged);
    on<ConverterConvertPressed>(_onConvertPressed);
  }

  /// При инициализации сразу запускаем конвертацию
  Future<void> _onInit(ConverterInit event, Emitter<ConverterState> emit) async {
    add(const ConverterConvertPressed());
  }

  /// Смена базовой валюты (например USD → EUR)
  void _onBaseChanged(ConverterBaseChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(base: event.base));
  }

  /// Смена валюты назначения (например USD → KGS)
  void _onTargetChanged(ConverterTargetChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(target: event.target));
  }

  /// Обновление суммы, введённой пользователем
  void _onAmountChanged(ConverterAmountChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(amountText: event.amountText));
  }

  /// Кнопка "Конвертировать" → считаем результат
  Future<void> _onConvertPressed(
      ConverterConvertPressed event, Emitter<ConverterState> emit) async {
    try {
      // Ставим загрузку и очищаем ошибку
      emit(state.copyWith(loading: true, error: null));

      // Пробуем превратить строку в число (заменяя запятую на точку)
      final amount = double.tryParse(state.amountText.replaceAll(',', '.')) ?? 0.0;

      // Получаем курс валюты
      final rate = await getLatestRate(
        GetLatestRateParams(base: state.base, target: state.target),
      );

      // Считаем результат конвертации
      final converted = amount * rate;

      // Загружаем историю курса за 7 дней
      final history = await getHistory(
        GetHistoryParams(base: state.base, target: state.target, days: 7),
      );

      // Обновляем состояние: убираем loading, пишем результат и историю
      emit(state.copyWith(
        loading: false,
        result: converted,
        history: history,
      ));
    } catch (e) {
      // Если ошибка — сохраняем её в state
      emit(state.copyWith(loading: false, error: 'Ошибка: $e'));
    }
  }
}
