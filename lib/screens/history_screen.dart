import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/database_service.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  List<Map<String, dynamic>> filteredHistory = [];
  bool isLoading = true;

  String selectedSport = "All Sports";

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    history = await DatabaseSevice.getHistory(widget.userId);
    applyFilters();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  void applyFilters() {
    filteredHistory = history.where((item) {
      bool sportMatch =
          selectedSport == "All Sports" || item['sportName'] == selectedSport;

      return sportMatch;
    }).toList();
  }

  Future<void> removeHistory(int historyId) async {
    await DatabaseSevice.deleteHistory(historyId);
    await loadHistory();

    if (!mounted) return;
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return "${remainingSeconds}s";
    }

    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  String formatHeaderDate(String rawDate) {
    DateTime date = DateTime.tryParse(rawDate) ?? DateTime.now();

    List<String> weekdays = [
      "MONDAY",
      "TUESDAY",
      "WEDNESDAY",
      "THURSDAY",
      "FRIDAY",
      "SATURDAY",
      "SUNDAY",
    ];

    List<String> months = [
      "JANUARY",
      "FEBRUARY",
      "MARCH",
      "APRIL",
      "MAY",
      "JUNE",
      "JULY",
      "AUGUST",
      "SEPTEMBER",
      "OCTOBER",
      "NOVEMBER",
      "DECEMBER",
    ];

    String weekday = weekdays[date.weekday - 1];
    String month = months[date.month - 1];

    return "$weekday, $month ${date.day}, ${date.year}";
  }

  String formatTimeText(String rawDate) {
    DateTime date = DateTime.tryParse(rawDate) ?? DateTime.now();
    DateTime now = DateTime.now();

    Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours} hr ago";
    } else {
      return "${difference.inDays} day(s) ago";
    }
  }

  IconData getSportIcon(String sportName) {
    switch (sportName.toLowerCase()) {
      case "basketball":
        return Icons.sports_basketball_outlined;
      case "soccer":
        return Icons.sports_soccer_outlined;
      case "tennis":
        return Icons.sports_tennis_outlined;
      default:
        return Icons.fitness_center_outlined;
    }
  }

  List<String> getSportOptions() {
    final sportNames = history
        .map((e) => e['sportName'].toString())
        .toSet()
        .toList();
    sportNames.sort();
    return ["All Sports", ...sportNames];
  }

  Widget buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: colorbg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colortxt),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: colorbg,

          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: colortxt),
          style: TextStyle(
            color: colortxt,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    String styleName = item['type'] == "outdoor"
        ? "Athletic Style"
        : "Home Style";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF61D4C0), Color(0xFFD4F24C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  getSportIcon(item['sportName']),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['exerciseName'],
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item['sportName']} • $styleName",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          formatDuration(item['duration']),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await removeHistory(item['id']);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              formatTimeText(item['date']),
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: colorbg,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: loadHistory,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Icon(Icons.history, size: 34, color: colortxt),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Exercise History",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: colortxt,
                              ),
                            ),
                            Text(
                              "${history.length} exercises completed",
                              style: TextStyle(fontSize: 18, color: colortxt),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, color: colortxt),
                      const SizedBox(width: 8),
                      Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colortxt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: buildFilterDropdown(
                          value: selectedSport,
                          items: getSportOptions(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedSport = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: colortxt),
                  const SizedBox(height: 16),
                  if (filteredHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          "No exercise history yet",
                          style: TextStyle(fontSize: 18, color: colortxt),
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      formatHeaderDate(filteredHistory.first['date']),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colortxt,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredHistory.map(buildHistoryCard),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
