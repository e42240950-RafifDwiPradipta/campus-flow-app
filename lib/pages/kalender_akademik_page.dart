import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';

class KalenderAkademikPage extends StatefulWidget {
  const KalenderAkademikPage({super.key});

  @override
  State<KalenderAkademikPage> createState() => _KalenderAkademikPageState();
}

class _KalenderAkademikPageState extends State<KalenderAkademikPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // FUNGSI UNTUK MEWARNAI BLOK KALENDER (TETAP SAMA)
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return dataKalenderGlobal.where((event) {
      if (event['markerStart'] == null || event['markerEnd'] == null) {
        return false;
      }

      DateTime start = event['markerStart'] as DateTime;
      DateTime end = event['markerEnd'] as DateTime;

      DateTime dayNormalized = DateTime(day.year, day.month, day.day);
      DateTime startNormalized = DateTime(start.year, start.month, start.day);
      DateTime endNormalized = DateTime(end.year, end.month, end.day);

      return dayNormalized.compareTo(startNormalized) >= 0 &&
          dayNormalized.compareTo(endNormalized) <= 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // LOGIKA BARU: FILTER EVENT RENTANG PANJANG & PENDEK
    // =========================================================
    final eventsThisMonth = dataKalenderGlobal.where((event) {
      if (event['markerStart'] == null || event['markerEnd'] == null) {
        return false;
      }

      DateTime start = event['markerStart'] as DateTime;
      DateTime end = event['markerEnd'] as DateTime;

      // Ubah tahun dan bulan menjadi satu angka absolut
      // Ini paling akurat untuk mendeteksi bulan di tengah-tengah rentang
      int startMonthValue = start.year * 12 + start.month;
      int endMonthValue = end.year * 12 + end.month;
      int focusMonthValue = _focusedDay.year * 12 + _focusedDay.month;

      // Event akan muncul jika bulan yang sedang dilihat (focusMonth)
      // lebih besar/sama dengan bulan mulai, DAN lebih kecil/sama dengan bulan selesai
      return focusMonthValue >= startMonthValue &&
          focusMonthValue <= endMonthValue;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF114B5F),
        title: const Text(
          "Kalender Akademik",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2035),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              // Update _focusedDay saat bulan digeser (swipe)
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },

              calendarFormat: _calendarFormat,
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  if (events.isNotEmpty) {
                    Color eventColor = events[0]['color'] ?? Colors.orange;
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: eventColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: eventColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          const Divider(height: 1),

          // =========================================================
          // LIST EVENT YANG SUDAH DI-FILTER
          // =========================================================
          Expanded(
            child: eventsThisMonth.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada jadwal di bulan ini.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: eventsThisMonth.length,
                    itemBuilder: (context, index) {
                      final event = eventsThisMonth[index];
                      Color color = event['color'] ?? Colors.orange;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border(
                            left: BorderSide(color: color, width: 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event['date'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
