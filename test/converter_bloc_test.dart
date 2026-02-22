import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_converter/features/converter/presentation/bloc/converter_bloc.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_event.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_state.dart';

import 'package:currency_converter/features/converter/domain/usecases/get_latest_rate.dart';
import 'package:currency_converter/features/converter/domain/usecases/get_history.dart';

class MockGetLatestRate extends Mock implements GetLatestRate {}
class MockGetHistory extends Mock implements GetHistory {}

void main() {
  late ConverterBloc bloc;
  late MockGetLatestRate mockLatest;
  late MockGetHistory mockHistory;

  setUpAll(() {
    registerFallbackValue(
      GetLatestRateParams(base: 'USD', target: 'EUR'),
    );
    registerFallbackValue(
      GetHistoryParams(base: 'USD', target: 'EUR', days: 7),
    );
  });

  setUp(() {
    mockLatest = MockGetLatestRate();
    mockHistory = MockGetHistory();

    bloc = ConverterBloc(
      getLatestRate: mockLatest,
      getHistory: mockHistory,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  // --------------------------------------------------
  // 1️⃣ Initial State
  // --------------------------------------------------

  test('initial state is default ConverterState', () {
    expect(bloc.state, const ConverterState());
  });

  // --------------------------------------------------
  // 2️⃣ Empty input
  // --------------------------------------------------

  blocTest<ConverterBloc, ConverterState>(
    'emits error when amount is empty',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(const ConverterAmountChanged(''));
      await Future.delayed(Duration.zero);
      bloc.add(const ConverterConvertPressed());
    },
    expect: () => [
      isA<ConverterState>(),
      isA<ConverterState>()
          .having((s) => s.loading, 'loading', false)
          .having(
            (s) => s.error,
            'error',
            'Введите сумму для конвертации',
          ),
    ],
  );

  // --------------------------------------------------
  // 3️⃣ Zero input (invalid number)
  // --------------------------------------------------

  blocTest<ConverterBloc, ConverterState>(
    'emits error when amount is zero',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(const ConverterAmountChanged('0'));
      await Future.delayed(Duration.zero);
      bloc.add(const ConverterConvertPressed());
    },
    expect: () => [
      isA<ConverterState>(),
      isA<ConverterState>()
          .having((s) => s.loading, 'loading', false)
          .having(
            (s) => s.error,
            'error',
            'Введите корректную сумму (только цифры)',
          ),
    ],
  );

  // --------------------------------------------------
  // 4️⃣ Success flow
  // --------------------------------------------------

  blocTest<ConverterBloc, ConverterState>(
    'emits loading then success when API works',
    build: () {
      when(() => mockLatest(any()))
          .thenAnswer((_) async => 2.0);

      when(() => mockHistory(any()))
          .thenAnswer((_) async => []);

      return bloc;
    },
    act: (bloc) async {
      bloc.add(const ConverterAmountChanged('10'));
      await Future.delayed(Duration.zero);
      bloc.add(const ConverterConvertPressed());
    },
    expect: () => [
      isA<ConverterState>(), // amount changed
      isA<ConverterState>().having((s) => s.loading, 'loading', true),
      isA<ConverterState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.result, 'result', 20.0),
    ],
  );

  // --------------------------------------------------
  // 5️⃣ API Exception
  // --------------------------------------------------

  blocTest<ConverterBloc, ConverterState>(
    'emits error when API throws exception',
    build: () {
      when(() => mockLatest(any()))
          .thenThrow(Exception('API error'));

      return bloc;
    },
    act: (bloc) async {
      bloc.add(const ConverterAmountChanged('10'));
      await Future.delayed(Duration.zero);
      bloc.add(const ConverterConvertPressed());
    },
    expect: () => [
      isA<ConverterState>(),
      isA<ConverterState>().having((s) => s.loading, 'loading', true),
      isA<ConverterState>().having(
        (s) => s.error,
        'error',
        contains('Ошибка конвертации'),
      ),
    ],
  );
}