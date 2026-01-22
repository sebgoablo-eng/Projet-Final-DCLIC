import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatefulWidget {
  final int userId;

  const NotesListScreen({super.key, required this.userId});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final db = await DatabaseHelper.database;
    final data = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [widget.userId],
      orderBy: 'id DESC',
    );

    setState(() {
      notes = data;
    });
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final day = twoDigits(date.day);
    final month = twoDigits(date.month);
    final year = date.year;
    final hour = twoDigits(date.hour);
    final minute = twoDigits(date.minute);

    return '$day/$month/$year $hour:$minute';
  }

  void confirmDelete(int noteId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              final db = await DatabaseHelper.database;
              await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);

              Navigator.pop(context);
              loadNotes();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supprimé avec succès')),
              );
            },
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des notes'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNoteScreen(userId: widget.userId),
            ),
          );
          loadNotes();
        },
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'Aucune note disponible',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (_, index) {
                final note = notes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      note['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          note['content'].length > 40
                              ? '${note['content'].substring(0, 40)}...'
                              : note['content'],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatDate(note['date']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteDetailScreen(note: note),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(note['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
