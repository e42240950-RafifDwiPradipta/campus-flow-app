import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<Map<String, dynamic>> _getEventsForDay(
    DateTime day,
    List<Map<String, dynamic>> dataKalender,
  ) {
    return dataKalender.where((event) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF114B5F),
        foregroundColor: Colors.white,
        title: const Text(
          "Kalender Akademik",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kalender_akademik')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF114B5F)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat kalender: ${snapshot.error}"),
            );
          }

          List<Map<String, dynamic>> kalenderData = [];
          if (snapshot.hasData) {
            kalenderData = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return {
                'title': data['title'] ?? 'Kegiatan',
                'date': data['date'] ?? '-',
                'color': Color(data['color'] ?? Colors.orange.value),
                'markerStart': (data['markerStart'] as Timestamp?)?.toDate(),
                'markerEnd': (data['markerEnd'] as Timestamp?)?.toDate(),
              };
            }).toList();
          }

          final eventsThisMonth = kalenderData.where((event) {
            if (event['markerStart'] == null || event['markerEnd'] == null) {
              return false;
            }

            DateTime start = event['markerStart'] as DateTime;
            DateTime end = event['markerEnd'] as DateTime;

            int startMonthValue = start.year * 12 + start.month;
            int endMonthValue = end.year * 12 + end.month;
            int focusMonthValue = _focusedDay.year * 12 + _focusedDay.month;

            return focusMonthValue >= startMonthValue &&
                focusMonthValue <= endMonthValue;
          }).toList();

          return Column(
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
                      final events = _getEventsForDay(day, kalenderData);

                      if (events.isNotEmpty) {
                        // =========================================================
                        // LOGIKA PRIORITAS WARNA (Sesuai Permintaan)
                        // =========================================================
                        bool adaMerah = false;
                        bool adaOranye = false;
                        bool adaBiru = false;
                        bool adaHijau = false;

                        for (var e in events) {
                          Color c = e['color'] ?? Colors.orange;
                          if (c.value == Colors.red.value)
                            adaMerah = true;
                          else if (c.value == Colors.orange.value)
                            adaOranye = true;
                          else if (c.value == Colors.blue.value)
                            adaBiru = true;
                          else if (c.value == Colors.green.value)
                            adaHijau = true;
                        }

                        Color eventColor;
                        if (adaMerah)
                          eventColor = Colors.red;
                        else if (adaOranye)
                          eventColor = Colors.orange;
                        else if (adaBiru)
                          eventColor = Colors.blue;
                        else if (adaHijau)
                          eventColor = Colors.green;
                        else
                          eventColor = events[0]['color'] ?? Colors.orange;
                        // =========================================================

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
          );
        },
      ),
    );
  }
}
