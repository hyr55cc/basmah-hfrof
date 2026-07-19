import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminRevenueScreen extends StatelessWidget {
  const AdminRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإيرادات',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          // KPIs
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: const [
              _RevenueKpi(
                title: 'إيرادات اليوم',
                value: '\$2,540',
                color: Colors.green,
              ),
              _RevenueKpi(
                title: 'إيرادات الأسبوع',
                value: '\$15,830',
                color: Colors.blue,
              ),
              _RevenueKpi(
                title: 'إيرادات الشهر',
                value: '\$58,420',
                color: Colors.purple,
              ),
              _RevenueKpi(
                title: 'متوسط ARPU',
                value: '\$1.95',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الإيرادات - آخر 30 يوم',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(30, (i) {
                              return FlSpot(
                                i.toDouble(),
                                1500 +
                                    i * 30 +
                                    (i % 5) * 200 -
                                    (i % 7) * 150,
                              );
                            }),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Recent transactions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('آخر المعاملات',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collectionGroup('purchases')
                        .orderBy('purchasedAt', descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, i) {
                          final doc = snapshot.data!.docs[i];
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.green,
                            ),
                            title: Text(
                              '${data['productId'] ?? 'منتج'}',
                            ),
                            subtitle: Text(
                              '${data['transactionId'] ?? '-'}',
                            ),
                            trailing: Text(
                              '\$${data['amount'] ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueKpi extends StatelessWidget {
  const _RevenueKpi({
    required this.title,
    required this.value,
    required this.color,
  });
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_money_rounded,
                color: color,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
