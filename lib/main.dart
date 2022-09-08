import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;




const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    if (task == 'uniquekey') {
      final httpsUri = Uri(
          scheme: 'https',
          host: 'reqres.in',
          path: 'api/users/2'
      );
      var response = await http.get(httpsUri);
      Map data = jsonDecode(response.body);
      final FlutterLocalNotificationsPlugin flutterlocal = FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails("channelId danhloc", "channelName android Noti",importance: Importance.max,priority: Priority.high,showWhen: false);
         const NotificationDetails platfromChanel = NotificationDetails(android: androidNotificationDetails);

         await flutterlocal.show(0,data['data']['first_name'],data['data']['email'], platfromChanel,payload: 'item x ');

    }
   return Future.value(true);
   }

  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androiinitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher",);
  const IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings();
   const InitializationSettings initializationSettings =  InitializationSettings(android: androiinitializationSettings,iOS: iosInitializationSettings);

   await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification() );
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      // isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  Workmanager().registerPeriodicTask("1", "uniquekey",frequency: Duration(minutes: 15));
  
  runApp(const MyApp());
}

 onSelectNotification () {
   // if(payload != null) {
     debugPrint('notification payload :  abc');
     Fluttertoast.showToast(msg: "thông bao",toastLength: Toast.LENGTH_LONG);
   // }

   
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () async {
                    final httpsUri = Uri(
                        scheme: 'https',
                        host: 'reqres.in',
                        path: 'api/users/2'
                        );
                    var response = await http.get(httpsUri);
                    Map data = json.decode(response.body);
                    final FlutterLocalNotificationsPlugin flutterlocal = FlutterLocalNotificationsPlugin();
                    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails("channelId danhloc", "channelName android Noti",importance: Importance.max,priority: Priority.high,showWhen: false);
                    const NotificationDetails platfromChanel = NotificationDetails(android: androidNotificationDetails);

                    await flutterlocal.show(0,data['data']['first_name'],data['data']['email'], platfromChanel,payload: 'item x ');

                  },
                ),
                SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleTaskKey,
                      simpleTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("Register rescheduled Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      rescheduledTaskKey,
                      rescheduledTaskKey,
                      inputData: <String, dynamic>{
                        'key': Random().nextInt(64000),
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("Register failed Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      failedTaskKey,
                      failedTaskKey,
                    );
                  },
                ),
                //This task runs once
                //This wait at least 10 seconds before running
                ElevatedButton(
                    child: Text("Register Delayed OneOff Task"),
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        simpleDelayedTask,
                        simpleDelayedTask,
                        initialDelay: Duration(seconds: 10),
                        constraints: Constraints(
                          // connected or metered mark the task as requiring internet
                          networkType: NetworkType.connected,
                          // require external power
                          requiresCharging: true,
                        ),

                      );
                    }),
                SizedBox(height: 8),
                //This task runs periodically
                //It will wait at least 10 seconds before its first launch
                //Since we have not provided a frequency it will be the default 15 minutes
                ElevatedButton(
                    child: Text("Register Periodic Task (Android)"),
                    onPressed: Platform.isAndroid
                        ? () {
                      Workmanager().registerPeriodicTask(
                        simplePeriodicTask,
                        simplePeriodicTask,
                        initialDelay: const Duration(seconds: 10),
                        // frequency: const Duration(minutes: 30),

                      );
                    }
                        : null),
                //This task runs periodically
                //It will run about every hour
                ElevatedButton(
                    child: Text("Register 1 hour Periodic Task (Android)"),
                    onPressed: Platform.isAndroid
                        ? () {
                      Workmanager().registerPeriodicTask(
                        simplePeriodicTask,
                        simplePeriodic1HourTask,
                        frequency: Duration(hours: 1),
                      );
                    }
                        : null),
                SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
