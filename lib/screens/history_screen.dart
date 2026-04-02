import 'package:flutter/material.dart';

import '../database/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    history = await DBHelper.getHistory(widget.userId);
    setState(() {});
  }

  Future<void> removeHistory(int historyId) async {
    await DBHelper.deleteHistory(historyId);
    await loadHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("History deleted")));
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text("No exercise history yet"));
    }

    return RefreshIndicator(
      onRefresh: loadHistory,
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          var item = history[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(item['exerciseName']),
              subtitle: Text("${item['sportName']}\n${item['date']}"),
              isThreeLine: true,
              trailing: IconButton(
                onPressed: () async {
                  await removeHistory(item['id']);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          );
        },
      ),
    );
  }
}
