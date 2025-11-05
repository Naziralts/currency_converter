import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/history_point.dart';
import 'package:intl/intl.dart';


class CurrencyChart extends StatelessWidget {

  final List<HistoryPoint> points;

  const CurrencyChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
  
    final dates = <String>[];

    final df = DateFormat('dd.MM');


    for (var i = 0; i < points.length; i++) {
      final p = points[i];

      spots.add(FlSpot(i.toDouble(), p.rate));
      
      dates.add(df.format(p.date));
    }

    final rawMin = points.map((e) => e.rate).reduce((a, b) => a < b ? a : b);
    final rawMax = points.map((e) => e.rate).reduce((a, b) => a > b ? a : b);

    double minY = rawMin;
    double maxY = rawMax;

   
    if (minY == maxY) {
      minY = rawMin * 0.995;
      maxY = rawMax * 1.005;
    }

    return SizedBox(
      height: 260, 
      child: LineChart(
        LineChartData(
    
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,

        
          gridData: FlGridData(
            show: true,         
            drawVerticalLine: false, 
          ),

        
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Colors.transparent), 
              right: BorderSide(color: Colors.transparent),
              left: BorderSide(color: Colors.black12),
              bottom: BorderSide(color: Colors.black12),
            ),
          ),


          titlesData: FlTitlesData(
     
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

         
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44, 
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ),

       
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                 
                  if (i < 0 || i >= dates.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      dates[i], 
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  );
                },
              ),
            ),
          ),

       
          lineBarsData: [
            LineChartBarData(
              spots: spots,         
              isCurved: true,      
              barWidth: 3,           
              color: Colors.blue,    
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false), 
              
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.18),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
