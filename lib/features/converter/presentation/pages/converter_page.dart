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

    final isWide = MediaQuery.of(context).size.width > 600;
    final horizontalPadding =
        isWide ? MediaQuery.of(context).size.width * 0.2 : 16.0;

    return BlocConsumer<ConverterBloc, ConverterState>(
      listener: (context, state) {
        if (state.error != null &&
            !state.error!.contains('Введите корректную сумму')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        final base = state.base;
        final target = state.target;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              
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

                const SizedBox(height: 20),

                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calculate),
                    errorText:
                        state.error?.contains('Введите корректную сумму') == true
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

                const SizedBox(height: 24),

               
                GestureDetector(
                  onTap: state.loading
                      ? null
                      : () => context
                          .read<ConverterBloc>()
                          .add(const ConverterConvertPressed()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: state.loading
                          ? LinearGradient(colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ])
                          : LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF00E1D2),
                                      const Color(0xFF007AFF),
                                    ]
                                  : [
                                      const Color(0xFF0066FF),
                                      const Color(0xFF00CCFF),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: [
                        if (!state.loading)
                          BoxShadow(
                            color: (isDark
                                    ? Colors.tealAccent
                                    : Colors.blueAccent)
                               
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                      ],
                    ),
                    child: Center(
                      child: state.loading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.currency_exchange,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Convert',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

     
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

                if (state.result != null && state.error == null)
                  _ResultCard(
                    amountText: state.amountText,
                    base: base,
                    target: target,
                    result: numberFormat.format(state.result),
                    meta: _currencyMeta,
                  ),

                const SizedBox(height: 20),

               
                if (state.history.isNotEmpty && state.error == null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CurrencyChart(points: state.history),
                    ),
                  ),

                if (state.loading) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],

                const SizedBox(height: 12),

                _HistoryHint(target: target),
              ],
            ),
          ),
        );
      },
    );
  }
}


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
        isDense: true,
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
              Flexible(
                child: Text(
                  '${m.name} ($code)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text('$amountText ${b?.flag ?? ''} $base'),
        subtitle: Text('= $result ${t?.flag ?? ''} $target'),
      ),
    );
  }
}


class _HistoryHint extends StatelessWidget {
  final String target;
  const _HistoryHint({required this.target});

  @override
  Widget build(BuildContext context) {
    return Text(
      '💡 Если график пустой — возможно, Frankfurter не поддерживает валюту '
      '($target). Конвертация всё равно работает.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
    );
  }
}
