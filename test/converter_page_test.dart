import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/features/converter/presentation/bloc/converter_state.dart';

void main() {

  test('initial state', () {
    const state = ConverterState();

    expect(state.loading, false);
    expect(state.result, null);
    expect(state.error, null);
  });

  test('loading state', () {
    const state = ConverterState(loading: true);

    expect(state.loading, true);
  });

  test('result state', () {
    const state = ConverterState(result: 120);

    expect(state.result, 120);
  });

}