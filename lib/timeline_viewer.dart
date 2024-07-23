import 'package:flutter/material.dart';
import 'package:timeline_creator/timeline.dart';

class TimelineViewer extends StatefulWidget {
  final List<TimelineEvent> events;
  final bool isFullScreen;
  final VoidCallback toggleFullScreen;

  const TimelineViewer({
    super.key,
    required this.events,
    required this.isFullScreen,
    required this.toggleFullScreen,
  });

  @override
  TimelineViewerState createState() => TimelineViewerState();
}

class TimelineViewerState extends State<TimelineViewer> {
  double _zoomLevel = 10.0;
  List<TimelineEvent> _filteredEvents = [];
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEvents = widget.events;
    _filterController.addListener(() {
      _filterEvents(_filterController.text);
    });
  }

  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = widget.events
          .where((event) =>
              event.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int earliestStartTime = _filteredEvents.isNotEmpty
        ? _filteredEvents
            .map((event) => event.start)
            .reduce((a, b) => a < b ? a : b)
        : 0;

    return Column(
      children: [
        if (!widget.isFullScreen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    labelText: 'Filter Events',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor:
                        Colors.white70, // Background color of the TextField
                    suffixIcon: _filterController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _filterController.clear();
                              _filterEvents('');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _filteredEvents.isEmpty
              ? const Center(child: Text("No matching events found."))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 150), // Space for context text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _filteredEvents.map((event) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    event.content,
                                    style: const TextStyle(
                                        color: Colors.black87), // Text color
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _filteredEvents.map((event) {
                                final duration = event.end - event.start;
                                final offset = event.start - earliestStartTime;
                                final color = _getColorForDuration(duration);
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      SizedBox(width: offset / _zoomLevel),
                                      Tooltip(
                                        message:
                                            "${event.content}\nStart: ${_formatTimestamp(event.start)}\nEnd: ${_formatTimestamp(event.end)}\nDuration: $duration ms",
                                        child: GestureDetector(
                                          onTap: () => _showEventDetails(event),
                                          child: Container(
                                            width: duration / _zoomLevel,
                                            height: 20,
                                            color: color,
                                            child: Center(
                                              child: Text(
                                                "$duration ms",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
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
            Text('Zoom: ${100 - _zoomLevel.floor()}'),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                setState(() {
                  _zoomLevel = (_zoomLevel / 1.2).clamp(1.0, 1000.0);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _zoomLevel = 10.0; // Reset zoom level to 90.0
                });
              },
            ),
            IconButton(
              icon: Icon(widget.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen),
              onPressed: widget.toggleFullScreen,
            ),
          ],
        ),
      ],
    );
  }

  void _showEventDetails(TimelineEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.content),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Start: ${_formatTimestamp(event.start)}"),
              Text("End: ${_formatTimestamp(event.end)}"),
              Text("Duration: ${event.end - event.start} ms"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
