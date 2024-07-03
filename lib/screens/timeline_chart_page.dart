import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../timeline.dart';
import '../timeline_chart.dart';

class TimelineChartPage extends StatefulWidget {
  const TimelineChartPage({super.key});

  @override
  TimelineChartPageState createState() => TimelineChartPageState();
}

class TimelineChartPageState extends State<TimelineChartPage> {
  List<TimelineEvent> events = [];
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // Optionally load a default JSON file
    // loadJson();
  }

  Future<void> loadJson() async {
    final jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/events.json');
    setState(() {
      events = parseEvents(jsonString);
    });
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String fileContent = String.fromCharCodes(result.files.single.bytes!);
      setState(() {
        events = parseEvents(fileContent);
      });
    }
  }

  void toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('Timeline Visualizer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: toggleFullScreen,
                ),
              ],
            ),
      body: Column(
        children: [
          if (!_isFullScreen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: pickFile,
                child: const Text('Import JSON'),
              ),
            ),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                        "Please select a JSON file to display the timeline."))
                : TimelineChart(
                    events: events,
                    isFullScreen: _isFullScreen,
                    toggleFullScreen: toggleFullScreen),
          ),
        ],
      ),
    );
  }
}
