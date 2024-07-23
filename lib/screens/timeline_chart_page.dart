import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../timeline.dart';
import '../timeline_viewer.dart';

class TimelineViewerPage extends StatefulWidget {
  const TimelineViewerPage({super.key});

  @override
  TimelineViewerPageState createState() => TimelineViewerPageState();
}

class TimelineViewerPageState extends State<TimelineViewerPage> {
  static const String guidelinesText = '''
Guidelines:
1. Click on 'Import JSON' to upload your timeline events json file.
2. The JSON file should be an array of events.
3. Each event should include the following fields:
   - id (int): A unique identifier for the event.
   - content (string): A description of the event.
   - start (int): The start time of the event in milliseconds since epoch.
   - end (int): The end time of the event in milliseconds since epoch.

Sample JSON:
[
  {"id": 1, "content": "Event 1", "start": 1622559600000, "end": 1622563200000},
  {"id": 2, "content": "Event 2", "start": 1622563200000, "end": 1622566800000}
]
''';

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
      backgroundColor: Colors.white70,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.blue[50],
              title: const Text('Timeline Viewer'),
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
                child: const Text(
                  'Import JSON',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                color: Color(0xFFE3F2FD),
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SelectableText(
                    guidelinesText,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                        "Please select a JSON file to display the timeline."))
                : TimelineViewer(
                    events: events,
                    isFullScreen: _isFullScreen,
                    toggleFullScreen: toggleFullScreen),
          ),
        ],
      ),
    );
  }
}
