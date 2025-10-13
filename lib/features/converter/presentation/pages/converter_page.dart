import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../widgets/currency_chart.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  static const _currencyMeta = <String, ({String flag, String name})>{
    'USD': (flag: '🇺🇸', name: 'US Dollar'),
    'EUR': (flag: '🇪🇺', name: 'Euro'),
    'GBP': (flag: '🇬🇧', name: 'British Pound'),
    'KGS': (flag: '🇰🇬', name: 'Kyrgyzstani Som'),
    'KZT': (flag: '🇰🇿', name: 'Kazakhstani Tenge'),
    'RUB': (flag: '🇷🇺', name: 'Russian Ruble'),
    'TRY': (flag: '🇹🇷', name: 'Turkish Lira'),
    'JPY': (flag: '🇯🇵', name: 'Japanese Yen'),
    'CNY': (flag: '🇨🇳', name: 'Chinese Yuan'),
    'UAH': (flag: '🇺🇦', name: 'Ukrainian Hryvnia'),
    'CAD': (flag: '🇨🇦', name: 'Canadian Dollar'),
    'AUD': (flag: '🇦🇺', name: 'Australian Dollar'),
    'CHF': (flag: '🇨🇭', name: 'Swiss Franc'),
    'PLN': (flag: '🇵🇱', name: 'Polish Złoty'),
    'AED': (flag: '🇦🇪', name: 'UAE Dirham'),
    'INR': (flag: '🇮🇳', name: 'Indian Rupee'),
  };

  static List<String> get _currencies => _currencyMeta.keys.toList();

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0.####");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
      ),
      body: BlocConsumer<ConverterBloc, ConverterState>(
        listener: (context, state) {
          // Убираем автоматическое показывание ошибок в SnackBar
          // Ошибки теперь показываются в интерфейсе
        },
        builder: (context, state) {
          final base = state.base;
          final target = state.target;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // -------------------- ВЫБОР ВАЛЮТ --------------------
                Row(
                  children: [
                    Expanded(
                      child: _CurrencyDropdown(
                        label: 'From',
                        value: base,
                        items: _currencies,
                        meta: _currencyMeta,
                        onChanged: (v) => context
                            .read<ConverterBloc>()
                            .add(ConverterBaseChanged(v!)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Swap',
                      onPressed: () {
                        context.read<ConverterBloc>()
                          ..add(ConverterBaseChanged(target))
                          ..add(ConverterTargetChanged(base));
                      },
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CurrencyDropdown(
                        label: 'To',
                        value: target,
                        items: _currencies,
                        meta: _currencyMeta,
                        onChanged: (v) => context
                            .read<ConverterBloc>()
                            .add(ConverterTargetChanged(v!)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // -------------------- ВВОД СУММЫ --------------------
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calculate),
                    // Показываем ошибку под полем ввода
                    errorText: state.error?.contains('Введите корректную сумму') == true 
                        ? state.error 
                        : null,
                  ),
                  controller: TextEditingController(text: state.amountText)
                    ..selection = TextSelection.collapsed(
                        offset: state.amountText.length),
                  onChanged: (txt) => context
                      .read<ConverterBloc>()
                      .add(ConverterAmountChanged(txt)),
                ),

                const SizedBox(height: 16),

                // -------------------- КНОПКА КОНВЕРТАЦИИ --------------------
                ElevatedButton.icon(
                  onPressed: state.loading
                      ? null
                      : () => context
                          .read<ConverterBloc>()
                          .add(const ConverterConvertPressed()),
                  icon: const Icon(Icons.currency_exchange),
                  label: const Text('Convert'),
                ),

                const SizedBox(height: 16),

                // -------------------- ОШИБКИ --------------------
                if (state.error != null && 
                    !state.error!.contains('Введите корректную сумму'))
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // -------------------- РЕЗУЛЬТАТ --------------------
                if (state.result != null && state.error == null)
                  _ResultCard(
                    amountText: state.amountText,
                    base: base,
                    target: target,
                    result: numberFormat.format(state.result),
                    meta: _currencyMeta,
                  ),

                const SizedBox(height: 16),

                // -------------------- ГРАФИК --------------------
                if (state.history.isNotEmpty && state.error == null)
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CurrencyChart(points: state.history),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // -------------------- ИНДИКАТОР ЗАГРУЗКИ --------------------
                if (state.loading) const LinearProgressIndicator(),

                const SizedBox(height: 8),

                // -------------------- ПОДСКАЗКА --------------------
                _HistoryHint(target: target),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===================================================================
// Виджет выбора валюты (Dropdown)
// ===================================================================
class _CurrencyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Map<String, ({String flag, String name})> meta;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.meta,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      isExpanded: true,
      items: items.map((code) {
        final m = meta[code]!;
        return DropdownMenuItem(
          value: code,
          child: Row(
            children: [
              Text(m.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                code,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  m.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// ===================================================================
// Карточка результата
// ===================================================================
class _ResultCard extends StatelessWidget {
  final String amountText;
  final String base;
  final String target;
  final String result;
  final Map<String, ({String flag, String name})> meta;

  const _ResultCard({
    required this.amountText,
    required this.base,
    required this.target,
    required this.result,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final b = meta[base];
    final t = meta[target];
    return Card(
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text('$amountText ${b != null ? '${b.flag} $base' : base}'),
        subtitle: Text('= $result ${t != null ? '${t.flag} $target' : target}'),
      ),
    );
  }
}

// ===================================================================
// Подсказка для пользователя
// ===================================================================
class _HistoryHint extends StatelessWidget {
  final String target;
  const _HistoryHint({required this.target});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tip: если график пустой для выбранной пары — возможно, Frankfurter '
      'не поддерживает одну из валют (например, AED/KGS/KZT). '
      'Конвертация всё равно работает.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
    );
  }
}