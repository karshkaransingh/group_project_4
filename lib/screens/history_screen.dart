import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/database_service.dart';
import '../widgets/history_card.dart';

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

  // load history on start
  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // fetch history from database
  Future<void> loadHistory() async {
    history = await DatabaseSevice.getHistory(widget.userId);

    applyFilters(); // apply selected filter

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // filter history by sport
  void applyFilters() {
    filteredHistory = history.where((item) {
      // check if selected sport matches
      bool sportMatch =
          selectedSport == "All Sports" || item['sportName'] == selectedSport;

      return sportMatch;
    }).toList();
  }

  // delete history item and refresh list
  Future<void> removeHistory(int historyId) async {
    await DatabaseSevice.deleteHistory(historyId);

    await loadHistory(); // reload history

    if (!mounted) return;
  }

  // convert seconds to readable time
  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return "${remainingSeconds}s";
    }

    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  // format header date text
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

  // show relative time text
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

  // get icon based on sport
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

  // get dropdown sport options
  List<String> getSportOptions() {
    final sportNames = history
        .map((e) => e['sportName'].toString())
        .toSet() // remove duplicates
        .toList();

    sportNames.sort();

    return ["All Sports", ...sportNames];
  }

  // filter dropdown widget
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

          onChanged: onChanged, // update filter
        ),
      ),
    );
  }

  // main screen UI
  @override
  Widget build(BuildContext context) {
    // loading screen
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,

      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: colorbg,

          body: SafeArea(
            // pull to refresh
            child: RefreshIndicator(
              onRefresh: loadHistory,

              child: ListView(
                padding: const EdgeInsets.all(18),

                children: [
                  // screen header
                  Row(
                    children: [
                      const SizedBox(width: 4),

                      Icon(Icons.history, size: 34, color: colortxt),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // title
                            Text(
                              "Exercise History",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: colortxt,
                              ),
                            ),

                            // count text
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

                  // filter title
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

                  // filter dropdown
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

                              applyFilters(); // apply new filter
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

                  // empty state
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
                  else
                    ...List.generate(filteredHistory.length, (index) {
                      final item = filteredHistory[index];

                      final currentDate =
                          DateTime.tryParse(item['date']) ?? DateTime.now();

                      final currentDayKey =
                          "${currentDate.year}-${currentDate.month}-${currentDate.day}";

                      String? previousDayKey;

                      if (index > 0) {
                        final previousDate =
                            DateTime.tryParse(
                              filteredHistory[index - 1]['date'],
                            ) ??
                            DateTime.now();

                        previousDayKey =
                            "${previousDate.year}-${previousDate.month}-${previousDate.day}";
                      }

                      final bool showDateHeader =
                          index == 0 || currentDayKey != previousDayKey;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            Text(
                              formatHeaderDate(item['date']),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colortxt,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          HistoryCard(
                            item: item,

                            durationText: formatDuration(item['duration']),

                            timeText: formatTimeText(item['date']),

                            icon: getSportIcon(item['sportName']),

                            onDelete: () async {
                              await removeHistory(item['id']);
                            },
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
