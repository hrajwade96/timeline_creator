import 'dart:convert';

class TimelineEvent {
  final int id;
  final String content;
  final int start;
  final int end;

  TimelineEvent({required this.id, required this.content, required this.start, required this.end});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'],
      content: json['content'],
      start: json['start'],
      end: json['end'],
    );
  }
}

List<TimelineEvent> parseEvents(String jsonStr) {
  final parsed = json.decode(jsonStr).cast<Map<String, dynamic>>();
  return parsed.map<TimelineEvent>((json) => TimelineEvent.fromJson(json)).toList();
}
