import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CheckGraphs extends StatelessWidget {
  final List<dynamic> checks;

  const CheckGraphs({super.key,
    required this.checks
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> parsedChecks =
        checks.cast<Map<String, dynamic>>();

    final weightData = _getGraphData(parsedChecks, 'weight');
    final bodyFatData = _getGraphData(parsedChecks, 'bodyfat');

  LineChartData createChart(List<FlSpot> spots, Color lineColor) {
    return LineChartData(
      minX: 0,
      maxX: spots.length - 1,
      minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 1,
      maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 4,
          color: lineColor,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2,
                color: lineColor,
                strokeWidth: 1,
                strokeColor: Colors.black,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }


  return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  "Pes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 130,
                  height: 130,
                  child: weightData.length > 2 
                  ? LineChart(
                      createChart(weightData, Colors.red),
                    )
                  : const Center(
                      child: Text(
                        "No hi ha dades suficients",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const Text(
                  "Greix",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 130,
                  height: 130,
                  child: bodyFatData.length > 2
                  ? LineChart(
                      createChart(bodyFatData, Colors.orange),
                    )
                  : const Center(
                      child: Text(
                        "No hi ha dades suficients",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<FlSpot> _getGraphData(List<Map<String, dynamic>> checks, String key) {
    final List<FlSpot> data = [];
    for (int i = 0; i < checks.length; i++) {
      final value = checks[i][key];
      if (value != null) {
        data.add(FlSpot(i.toDouble(), value));
      }
    }
    return data;
  }
}
