import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/trend_point.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({required this.points, super.key});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No yearly data available.'));
    }

    final maxY = points
        .map((point) => point.count)
        .fold<int>(
          0,
          (previous, current) => current > previous ? current : previous,
        )
        .toDouble();

    return Semantics(
      label: 'Line chart showing publications grouped by year',
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY + 1,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Color(0xFFE2E8F0)),
              bottom: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: _yearInterval(points),
                getTitlesWidget: (value, meta) {
                  final year = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      year.toString(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .map(
                    (point) =>
                        FlSpot(point.year.toDouble(), point.count.toDouble()),
                  )
                  .toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _yearInterval(List<TrendPoint> points) {
    if (points.length <= 6) return 1;
    final range = points.last.year - points.first.year;
    return (range / 5).ceilToDouble().clamp(1, 10);
  }
}
