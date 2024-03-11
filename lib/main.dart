import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

void main() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          onlyAlertOnce: true,
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple)
    ],
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  @override
  void initState() {
    super.initState();
    initPusherConnect();
  }

  void initPusherConnect() async {
    try {
      await pusher.init(
          apiKey: '085a6eb21bd2d1912f89', cluster: 'ap1', onEvent: onEvent);
      await pusher.subscribe(channelName: 'my-channel');
      await pusher.connect();
      print("SUCCESS CONNECT");
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void onEvent(PusherEvent event) {
    print("ON EVENT: $event");
    print("EVENT DATA: ${event.data}");

    Map<String, dynamic> jsonData = json.decode(event.data);

    print("WILL CREATE NOTIF");
    pushNotif(jsonData);
  }

  void pushNotif(Map<String, dynamic> data) async {
    print("DO CREATE NOTIF $data");
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: data['id'],
            channelKey: 'alerts',
            title: data['title'],
            body: data['body']));

    print("SUCCESS CREATE NOTIF");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pusher Notification'),
        ),
        body: Center(
          child: Text("Pusher Notif Example"),
        ),
      ),
    );
  }
}
