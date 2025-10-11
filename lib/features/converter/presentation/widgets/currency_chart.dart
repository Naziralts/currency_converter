import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/history_point.dart';
import 'package:intl/intl.dart';

/// Виджет для отображения графика валютного курса
class CurrencyChart extends StatelessWidget {
  /// Список исторических точек (дата + курс)
  final List<HistoryPoint> points;

  const CurrencyChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    // Если данных нет — возвращаем пустой контейнер
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    // Массив точек для графика
    final spots = <FlSpot>[];
    // Список дат (подписи снизу)
    final dates = <String>[];
    // Форматтер для дат: день.месяц (например, 07.09)
    final df = DateFormat('dd.MM');

    // Заполняем массив точек и дат
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      // X = индекс (0,1,2...), Y = курс валюты
      spots.add(FlSpot(i.toDouble(), p.rate));
      // Добавляем отформатированную дату
      dates.add(df.format(p.date));
    }

    // Находим минимальное и максимальное значение курса
    final rawMin = points.map((e) => e.rate).reduce((a, b) => a < b ? a : b);
    final rawMax = points.map((e) => e.rate).reduce((a, b) => a > b ? a : b);

    double minY = rawMin;
    double maxY = rawMax;

    // Если все значения одинаковые — создаём небольшой "коридор",
    // чтобы график не выглядел как прямая линия
    if (minY == maxY) {
      minY = rawMin * 0.995;
      maxY = rawMax * 1.005;
    }

    // Собственно, сам график
    return SizedBox(
      height: 260, // фиксированная высота графика
      child: LineChart(
        LineChartData(
          // Границы по осям
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,

          // Настройки сетки
          gridData: FlGridData(
            show: true,          // показывать ли сетку
            drawVerticalLine: false, // вертикальные линии убраны
          ),

          // Рамки графика
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Colors.transparent), // верх скрыт
              right: BorderSide(color: Colors.transparent), // право скрыто
              left: BorderSide(color: Colors.black12), // слева линия
              bottom: BorderSide(color: Colors.black12), // снизу линия
            ),
          ),

          // Подписи осей
          titlesData: FlTitlesData(
            // Верхняя ось скрыта
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            // Правая ось скрыта
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Левая ось (курсы валюты)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44, // место для текста
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(2), // показываем число с 2 знаками
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ),

            // Нижняя ось (даты)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  // Если индекс вне диапазона — ничего не рисуем
                  if (i < 0 || i >= dates.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      dates[i], // выводим дату
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  );
                },
              ),
            ),
          ),

          // Данные линии (сама линия графика)
          lineBarsData: [
            LineChartBarData(
              spots: spots,          // точки
              isCurved: true,        // сглаживание линии
              barWidth: 3,           // толщина
              color: Colors.blue,    // цвет линии
              isStrokeCapRound: true,// скруглённые края
              dotData: const FlDotData(show: false), // скрываем точки
              // Заливка под графиком
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.18), // полупрозрачная синяя заливка
              ),
            ),
          ],
        ),
      ),
    );
  }
}
