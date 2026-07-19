import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLevelsScreen extends StatefulWidget {
  const AdminLevelsScreen({super.key});
  @override
  State<AdminLevelsScreen> createState() => _AdminLevelsScreenState();
}

class _AdminLevelsScreenState extends State<AdminLevelsScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _difficultyFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('إدارة المستويات',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showLevelDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة مستوى'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'بحث برقم المستوى...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _difficultyFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'easy', child: Text('سهل')),
                  DropdownMenuItem(value: 'medium', child: Text('متوسط')),
                  DropdownMenuItem(value: 'hard', child: Text('صعب')),
                  DropdownMenuItem(value: 'expert', child: Text('خبير')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _difficultyFilter = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Levels list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('levels')
                  .orderBy('id', descending: false)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (_difficultyFilter != 'all' &&
                      data['difficulty'] != _difficultyFilter) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    return doc.id.contains(_searchQuery);
                  }
                  return true;
                }).toList();
                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('الرقم')),
                        DataColumn(label: Text('الحروف')),
                        DataColumn(label: Text('الإجابات')),
                        DataColumn(label: Text('الصعوبة')),
                        DataColumn(label: Text('المكافأة')),
                        DataColumn(label: Text('إجراءات')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text('${data['id'] ?? doc.id}')),
                          DataCell(Text(
                              (data['letters'] as List?)?.join(' ') ?? '')),
                          DataCell(Text(
                              '${(data['answers'] as List?)?.length ?? 0}')),
                          DataCell(Text('${data['difficulty'] ?? '-'}')),
                          DataCell(Text('${data['rewardCoins'] ?? 0}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded,
                                    color: Colors.blue),
                                onPressed: () => _showLevelDialog(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded,
                                    color: Colors.red),
                                onPressed: () => _confirmDelete(doc.id),
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

  void _showLevelDialog([DocumentSnapshot? doc]) {
    final isEdit = doc != null;
    final data = isEdit ? doc.data() as Map<String, dynamic> : <String, dynamic>{};
    final idController = TextEditingController(
      text: isEdit ? '${data['id']}' : '',
    );
    final lettersController = TextEditingController(
      text: isEdit ? (data['letters'] as List?)?.join(',') ?? '' : '',
    );
    final answersController = TextEditingController(
      text: isEdit ? (data['answers'] as List?)?.join(',') ?? '' : '',
    );
    final difficultyController = TextEditingController(
      text: isEdit ? '${data['difficulty'] ?? 'easy'}' : 'easy',
    );
    final rewardController = TextEditingController(
      text: isEdit ? '${data['rewardCoins'] ?? 50}' : '50',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'تعديل المستوى' : 'إضافة مستوى جديد'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'رقم المستوى'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lettersController,
                  decoration: const InputDecoration(
                    labelText: 'الحروف (افصل بفاصلة)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: answersController,
                  decoration: const InputDecoration(
                    labelText: 'الإجابات (افصل بفاصلة)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: difficultyController,
                  decoration:
                      const InputDecoration(labelText: 'الصعوبة (easy/medium/hard)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rewardController,
                  decoration: const InputDecoration(labelText: 'مكافأة العملات'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(idController.text);
              if (id == null) return;
              final level = {
                'id': id,
                'level': id,
                'letters': lettersController.text.split(',').map((s) => s.trim()).toList(),
                'answers': answersController.text.split(',').map((s) => s.trim()).toList(),
                'difficulty': difficultyController.text.trim(),
                'rewardCoins': int.tryParse(rewardController.text) ?? 50,
                'updatedAt': FieldValue.serverTimestamp(),
              };
              await _firestore
                  .collection('levels')
                  .doc(id.toString())
                  .set(level, SetOptions(merge: true));
              if (mounted) Navigator.pop(context);
            },
            child: Text(isEdit ? 'حفظ' : 'إضافة'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستوى'),
        content: Text('هل تريد حذف المستوى $id؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('levels').doc(id).delete();
    }
  }
}
