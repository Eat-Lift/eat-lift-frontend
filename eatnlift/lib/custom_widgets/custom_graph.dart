import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SingleGraphWidget extends StatelessWidget {
  final String title;
  final List<double> dataPoints;
  final Color lineColor;
  final VoidCallback onTap;

  const SingleGraphWidget({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.lineColor,
    required this.onTap,
  });

  LineChartData createChart(List<FlSpot> spots, Color lineColor) {
    return LineChartData(
      minX: 0,
      maxX: spots.isNotEmpty ? spots.length - 1 : 1,
      minY: spots.isNotEmpty
          ? spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 1
          : 0,
      maxY: spots.isNotEmpty
          ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1
          : 1,
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
                radius: 3,
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

  List<FlSpot> _convertToSpots(List<double> points) {
    return points
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _convertToSpots(dataPoints);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            maxLines: 1,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 130,
          height: 130,
          child: LineChart(
            createChart(spots, lineColor),
          ),
        ),
      ],
    );
  }
}
