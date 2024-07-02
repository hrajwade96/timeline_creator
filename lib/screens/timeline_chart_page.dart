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

  @override
  void initState() {
    super.initState();
    // Optionally load a default JSON file
    // loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/events.json');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Chart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: pickFile,
              child: const Text('Import JSON'),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("Please select a JSON file to display the timeline."))
                : TimelineChart(events: events),
          ),
        ],
      ),
    );
  }
}
