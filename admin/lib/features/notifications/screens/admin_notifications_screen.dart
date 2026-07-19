import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _targetAudience = 'all';
  bool _isSending = false;

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      return;
    }
    setState(() => _isSending = true);
    try {
      // Use FCM topic subscription based on audience
      String topic = 'all_users';
      if (_targetAudience == 'premium') topic = 'premium_users';
      if (_targetAudience == 'new') topic = 'new_users';

      await FirebaseMessaging.instance.subscribeToTopic(topic);

      // Save notification record
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text,
        'body': _bodyController.text,
        'audience': _targetAudience,
        'topic': topic,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الإشعار')),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إرسال الإشعارات',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الإشعار',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'نص الإشعار',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _targetAudience,
                    decoration:
                        const InputDecoration(labelText: 'الفئة المستهدفة'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('الجميع')),
                      DropdownMenuItem(value: 'premium', child: Text('المميزون')),
                      DropdownMenuItem(value: 'new', child: Text('الجدد')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _targetAudience = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال'),
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
