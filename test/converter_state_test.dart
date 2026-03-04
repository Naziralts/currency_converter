import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_state.dart';

void main() {

  test('initial state should be correct', () {

    const state = ConverterState();

    expect(state.loading, false);
    expect(state.result, null);
    expect(state.error, null);

  });

  test('loading state works', () {

    const state = ConverterState(loading: true);

    expect(state.loading, true);

  });

  test('result state works', () {

    const state = ConverterState(result: 100);

    expect(state.result, 100);

  });

  test('error state works', () {

    const state = ConverterState(error: 'Conversion failed');

    expect(state.error, 'Conversion failed');

  });

}