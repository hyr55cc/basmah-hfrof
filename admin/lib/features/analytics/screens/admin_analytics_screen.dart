import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التحليلات',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          // Funnel chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مسار اللعب (Funnel)',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _FunnelRow('بداية اللعبة', 100, 100, Colors.blue),
                  _FunnelRow('أكمل المستوى الأول', 85, 100, Colors.green),
                  _FunnelRow('أكمل 10 مستويات', 62, 100, Colors.orange),
                  _FunnelRow('أكمل 50 مستوى', 35, 100, Colors.purple),
                  _FunnelRow('أكمل 100 مستوى', 18, 100, Colors.red),
                  _FunnelRow('شراء شيء', 8, 100, Colors.pink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('توزيع المنصات',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: 45,
                                color: Colors.blue,
                                title: '45%',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: 35,
                                color: Colors.green,
                                title: '35%',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: 20,
                                color: Colors.orange,
                                title: '20%',
                                radius: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('معدل الاحتفاظ',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _bar(0, 100, Colors.blue),
                              _bar(1, 75, Colors.blue),
                              _bar(2, 60, Colors.blue),
                              _bar(3, 50, Colors.blue),
                              _bar(4, 45, Colors.blue),
                              _bar(5, 40, Colors.blue),
                              _bar(6, 38, Colors.blue),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
        ),
      ],
    );
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow(this.label, this.value, this.max, this.color);
  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (value / max * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / max,
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$value ($percent%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
