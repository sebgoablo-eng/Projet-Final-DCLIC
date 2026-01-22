import 'package:flutter/material.dart';
import '../database_helper.dart';

class AddNoteScreen extends StatelessWidget {
  final int userId;
  const AddNoteScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    Future<void> save() async {
      final db = await DatabaseHelper.database;
      await db.insert('notes', {
        'title': titleCtrl.text,
        'content': contentCtrl.text,
        'date': DateTime.now().toString(),
        'user_id': userId,
      });
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle note'),
        actions: [
          TextButton(
            onPressed: save,
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Contenu'),
            ),
          ],
        ),
      ),
    );
  }
}
