import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إدارة المستخدمين',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'بحث بالاسم...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['displayName'] as String? ?? '';
                  return name.contains(_searchQuery);
                }).toList();
                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('الاسم')),
                        DataColumn(label: Text('البريد')),
                        DataColumn(label: Text('العملات')),
                        DataColumn(label: Text('المستوى')),
                        DataColumn(label: Text('مميز')),
                        DataColumn(label: Text('إجراءات')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text('${data['displayName'] ?? '-'}')),
                          DataCell(Text('${data['email'] ?? '-'}')),
                          DataCell(Text('${data['coins'] ?? 0}')),
                          DataCell(Text('${data['currentLevel'] ?? 1}')),
                          DataCell(Text(
                              '${data['isPremium'] == true ? 'نعم' : 'لا'}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_rounded,
                                    color: Colors.green),
                                onPressed: () => _addCoins(doc.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.flag_rounded,
                                    color: Colors.blue),
                                onPressed: () => _unlockLevel(doc.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.block_rounded,
                                    color: Colors.red),
                                onPressed: () => _banUser(doc.id),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addCoins(String userId) async {
    final controller = TextEditingController(text: '100');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عملات'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'عدد العملات'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(result),
      });
    }
  }

  void _unlockLevel(String userId) async {
    final controller = TextEditingController(text: '50');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فتح مستوى'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'رقم المستوى'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('فتح'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _firestore.collection('users').doc(userId).update({
        'maxUnlockedLevel': result,
      });
    }
  }

  void _banUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: const Text('هل تريد حظر هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حظر'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'bannedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
