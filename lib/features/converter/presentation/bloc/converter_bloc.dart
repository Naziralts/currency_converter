import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../../converter/domain/usecases/get_history.dart';
import '../../../converter/domain/usecases/get_latest_rate.dart';
import 'converter_event.dart';
import 'converter_state.dart';

/// BLoC для управления состоянием конвертера валют
class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final GetLatestRate getLatestRate;
  final GetHistory getHistory;

  ConverterBloc({
    required this.getLatestRate,
    required this.getHistory,
  }) : super(const ConverterState()) {
    on<ConverterInit>(_onInit);
    on<ConverterBaseChanged>(_onBaseChanged);
    on<ConverterTargetChanged>(_onTargetChanged);
    on<ConverterAmountChanged>(_onAmountChanged);
    on<ConverterConvertPressed>(_onConvertPressed);
  }

  Future<void> _onInit(ConverterInit event, Emitter<ConverterState> emit) async {
    add(const ConverterConvertPressed());
  }

  void _onBaseChanged(ConverterBaseChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(base: event.base));
    // Автоматически запускаем конвертацию при смене валюты
    add(const ConverterConvertPressed());
  }

  void _onTargetChanged(ConverterTargetChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(target: event.target));
    // Автоматически запускаем конвертацию при смене валюты
    add(const ConverterConvertPressed());
  }

  void _onAmountChanged(ConverterAmountChanged event, Emitter<ConverterState> emit) {
    // Валидация ввода - разрешаем только цифры, точку и запятую
    final validatedText = _validateAmountInput(event.amountText);
    emit(state.copyWith(amountText: validatedText));
  }

  /// Валидация ввода - разрешает только цифры, одну точку или запятую
  String _validateAmountInput(String input) {
    if (input.isEmpty) return '';
    
    // Удаляем все символы, кроме цифр, точки и запятой
    var cleaned = input.replaceAll(RegExp(r'[^\d.,]'), '');
    
    // Заменяем запятые на точки
    cleaned = cleaned.replaceAll(',', '.');
    
    // Разрешаем только одну десятичную точку
    final dotIndex = cleaned.indexOf('.');
    if (dotIndex != -1) {
      final beforeDot = cleaned.substring(0, dotIndex);
      final afterDot = cleaned.substring(dotIndex + 1).replaceAll('.', '');
      cleaned = '$beforeDot.$afterDot';
    }
    
    // Убираем ведущие нули (кроме случая "0.123")
    if (cleaned.startsWith('0') && cleaned.length > 1 && !cleaned.startsWith('0.')) {
      cleaned = cleaned.substring(1);
    }
    
    return cleaned;
  }

  /// Кнопка "Конвертировать" → считаем результат
  Future<void> _onConvertPressed(
      ConverterConvertPressed event, Emitter<ConverterState> emit) async {
    try {
      // Если поле пустое или содержит невалидные данные, показываем ошибку
      if (state.amountText.isEmpty) {
        emit(state.copyWith(
          loading: false,
          error: 'Введите сумму для конвертации',
          result: null,
        ));
        return;
      }

      // Пробуем превратить строку в число
      final amount = double.tryParse(state.amountText);
      if (amount == null || amount <= 0) {
        emit(state.copyWith(
          loading: false,
          error: 'Введите корректную сумму (только цифры)',
          result: null,
        ));
        return;
      }

      // Ставим загрузку и очищаем ошибку
      emit(state.copyWith(loading: true, error: null));

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
      emit(state.copyWith(
        loading: false, 
        error: 'Ошибка конвертации: $e',
        result: null,
      ));
    }
  }
}