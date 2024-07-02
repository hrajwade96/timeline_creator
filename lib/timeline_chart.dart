import 'package:flutter/material.dart';
import 'package:timeline_creator/timeline.dart';

class TimelineChart extends StatefulWidget {
  final List<TimelineEvent> events;

  const TimelineChart({super.key, required this.events});

  @override
  TimelineChartState createState() => TimelineChartState();
}

class TimelineChartState extends State<TimelineChart> {
  double _zoomLevel = 50.0; // More zoomed out by default

  @override
  Widget build(BuildContext context) {
    int earliestStartTime = widget.events.map((event) => event.start).reduce((a, b) => a < b ? a : b);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 150), // Space for context text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.events.map((event) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(event.content),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.events.map((event) {
                          final duration = event.end - event.start;
                          final offset = event.start - earliestStartTime;
                          final color = _getColorForDuration(duration);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(width: offset / _zoomLevel),
                                Tooltip(
                                  message: "${event.content}\nStart: ${_formatTimestamp(event.start)}\nEnd: ${_formatTimestamp(event.end)}\nDuration: $duration ms",
                                  child: Container(
                                    width: duration / _zoomLevel,
                                    height: 20,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                setState(() {
                  _zoomLevel = (_zoomLevel * 1.2).clamp(1.0, 1000.0);
                });
              },
            ),
            Text('Zoom: ${100-_zoomLevel.floor()}'),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                setState(() {
                  _zoomLevel = (_zoomLevel / 1.2).clamp(1.0, 1000.0);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.minute}:${dateTime.second}.${dateTime.millisecond}";
  }

  Color _getColorForDuration(int duration) {
    if (duration < 500) {
      return Colors.lightBlue[200]!;
    } else if (duration < 1000) {
      return Colors.lightBlue[400]!;
    } else if (duration < 1500) {
      return Colors.blue[600]!;
    } else {
      return Colors.blue[800]!;
    }
  }

}
