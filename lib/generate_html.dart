import 'package:flutter/material.dart';
import 'package:timeline_creator/timeline.dart';

String generateHtml(List<TimelineEvent> events) {
  final StringBuffer htmlBuffer = StringBuffer();

  htmlBuffer.write('''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Timeline Chart</title>
    <style>
      body {
        font-family: Arial, sans-serif;
      }
      .timeline-event {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
      }
      .event-bar {
        height: 20px;
        margin-left: 10px;
        margin-right: 10px;
      }
      .context-text {
        width: 150px;
        text-align: left;
      }
    </style>
  </head>
  <body>
  ''');

  for (var event in events) {
    final duration = event.end - event.start;
    final color = Colors.primaries[event.id % Colors.primaries.length].toString().replaceAll("Color(", "").replaceAll(")", "");
    htmlBuffer.write('''
    <div class="timeline-event">
      <div class="context-text">${event.content}</div>
      <div class="event-bar" style="width: ${duration}px; background-color: $color;"></div>
      <span>$duration ms</span>
    </div>
    ''');
  }

  htmlBuffer.write('''
  </body>
  </html>
  ''');

  return htmlBuffer.toString();
}
