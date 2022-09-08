import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";
String? selectedNotificationPayload;
final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'uniquekey') {
      // connectAndListen();
      // final httpsUri = Uri(
      //     scheme: 'https',
      //     host: 'reqres.in',
      //     path: 'api/users/2'
      // );
      // var response = await http.get(httpsUri);
      // Map data = jsonDecode(response.body);
      // final FlutterLocalNotificationsPlugin flutterlocal =
      //     FlutterLocalNotificationsPlugin();
      // const AndroidNotificationDetails androidNotificationDetails =
      //     AndroidNotificationDetails(
      //         "channelId danhloc", "channelName android Noti",
      //         importance: Importance.max,
      //         priority: Priority.high,
      //         showWhen: false);
      // const NotificationDetails platfromChanel =
      //     NotificationDetails(android: androidNotificationDetails);
      //
      // await flutterlocal.show(0123, "data['data']['first_name']",
      //     "data['data']['email']", platfromChanel,
      //     payload: 'item x ');

      // final _channel = IOWebSocketChannel.connect(
      //   Uri.parse('wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self'),
      // );
      // _channel.stream.listen((message) async {
      //
      //   print(message);
      //   // if(message == "Hello world!"){
      //     final FlutterLocalNotificationsPlugin flutterlocal =
      //     FlutterLocalNotificationsPlugin();
      //     const AndroidNotificationDetails androidNotificationDetails =
      //     AndroidNotificationDetails(
      //         "channelId danhloc", "channelName android Noti",
      //         importance: Importance.max,
      //         priority: Priority.high,
      //         showWhen: false);
      //     const NotificationDetails platfromChanel =
      //     NotificationDetails(android: androidNotificationDetails);
      //
      //     await flutterlocal.show(0123, "data['data']['first_name']",
      //         "data['data']['email']", platfromChanel,
      //         payload: 'item x ');
      //   // }
      //   // Fluttertoast.showToast(msg: "$message", toastLength: Toast.LENGTH_SHORT);
      //   // _channel.sink.add('received!');
      //   // _channel.sink.close(status.goingAway);
      // });
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androiinitializationSettings =
      AndroidInitializationSettings(
    "@mipmap/ic_launcher",
  );
  const IOSInitializationSettings iosInitializationSettings =
      IOSInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: androiinitializationSettings, iOS: iosInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  // Workmanager().registerPeriodicTask(
  //   "uniquekey",
  //   "uniquekey",
  //   // initialDelay: const Duration(seconds: 10),
  // );

  runApp(const MyApp());
}


IO.Socket socket = IO.io('http://192.168.101.20:5000',OptionBuilder()
    .setTransports(['websocket']).disableAutoConnect() // disable auto-connection// for Flutter or Dart VM
    .build());
void connectAndListen() {

  socket.connect();

  // socket.emit("signin", widget.sourchat.id);
  socket.on('hello', (arg) => {print(arg)});

  socket.onConnect((data) {
    print("connect");
    socket.on("message", (msg) {
      print(msg);
      socket.emit("message", {
        "message": "message",
        "sourceId": "sourceId",
        "targetId": "targetId"
      });
    });
  });

  socket.onConnectError((data) {
    log(data);
  });

  socket.onError((data) {
    log(data);
  });
  print(socket.connected);
  //When an event recieved from server, data is added to the stream
  // socket.onDisconnect((_) => print('disconnect'));
}

Future onSelectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  selectedNotificationPayload = payload;
  selectNotificationSubject.add(payload);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    connectAndListen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Flutter WorkManager Example"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    child: TextFormField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(labelText: 'Send a message'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // StreamBuilder(
                  //   stream: _channel.stream,
                  //   builder: (context, snapshot) {
                  //
                  //     return Text(snapshot.hasData ? '${snapshot.data}' : '');
                  //   },
                  // )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                socket.emit("message", {
                  "message": "message",
                  "sourceId": "sourceId",
                  "targetId": "targetId"
                });
              },
              tooltip: 'Send message',
              child: const Icon(Icons.send),
              // This trailing comma makes auto-formatting nicer for build methods.
            )));
  }

  //
  void _sendMessage() {}
  //
  // @override
  // void dispose() {
  //   _channel.sink.close();
  //   _controller.dispose();
  //   super.dispose();
  // }
}
