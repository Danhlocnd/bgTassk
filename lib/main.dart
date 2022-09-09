import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
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
      connectAndListen();

    }
    return Future.value(true);
  });
}

show(String msg) async {
  final FlutterLocalNotificationsPlugin flutterlocal =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          "channelId danhloc", "channelName android Noti",
          importance: Importance.max, priority: Priority.high, showWhen: false);
  const NotificationDetails platfromChanel =
      NotificationDetails(android: androidNotificationDetails);
  var ramdom = Random(10);
  await flutterlocal.show(
      ramdom.nextInt(10000), msg, "data['data']['email']", platfromChanel,
      payload: 'item x ');
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


  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(

    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,

    ),
  );
  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {

  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  connectAndListen();
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      // connectAndListen();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      // connectAndListen();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // // // bring to foreground
  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  //   // final hello = preferences.getString("hello");
  //   // print(hello);
  //
  //   if (service is AndroidServiceInstance) {
  //     service.setForegroundNotificationInfo(
  //       title: "My App Service",
  //       content: "Updated at ${DateTime.now()}",
  //     );
  //   }
  //
  //   /// you can see this log in logcat
  //   print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  //
  //   // test using external plugin
  //   final deviceInfo = DeviceInfoPlugin();
  //   String? device;
  //   if (Platform.isAndroid) {
  //     final androidInfo = await deviceInfo.androidInfo;
  //     device = androidInfo.model;
  //   }
  //
  //   if (Platform.isIOS) {
  //     final iosInfo = await deviceInfo.iosInfo;
  //     device = iosInfo.model;
  //   }
  //
  //   service.invoke(
  //     'update',
  //     {
  //       "current_date": DateTime.now().toIso8601String(),
  //       "device": device,
  //     },
  //   );
  // });
}
 connectAndListen() async {

  IO.Socket socket = IO.io(
      'http://192.168.101.20:5000',
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // disable auto-connection// for Flutter or Dart VM
          .build());

  if(socket.connected == false) {
    socket.connect();

    final FlutterLocalNotificationsPlugin flutterlocal =
    FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        "channelId danhloc", "channelName android Noti",
        importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platfromChanel =
    NotificationDetails(android: androidNotificationDetails);
    var ramdom = Random(10).nextInt(10000);
    socket.onConnect((data) async {
      print("connect");
      Fluttertoast.showToast(
          msg: "connect socket", toastLength: Toast.LENGTH_LONG);
      socket.on(
          'message',
              (msg) async =>
          {
            await flutterlocal.show(ramdom, msg,
                "data['data']['email']", platfromChanel,
                payload: 'item x ')
          });
        // test using external plugin
        final deviceInfo = DeviceInfoPlugin();
        String? device;
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          device = androidInfo.model;
        }

        if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          device = iosInfo.model;
        }
      socket.emit('info',device);
    });
  }
  socket.onConnectError((data) {
    log(data);
    connectAndListen();
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
