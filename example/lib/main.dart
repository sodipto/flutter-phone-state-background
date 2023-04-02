import 'package:flutter/material.dart';
import 'dart:async';

import 'package:phone_state_background/phone_state_background.dart';

/// Defines a callback that will handle all background incoming events
Future<void> phoneStateBackgroundCallbackHandler(
  PhoneStateBackgroundEvent event,
  String number,
  int duration,
) async {
  switch (event) {
    case PhoneStateBackgroundEvent.incomingstart:
      print(
          '[ Caller ] Incoming call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingmissed:
      print(
          '[ Caller ] Incoming call missed, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingreceived:
      print(
          '[ Caller ] Incoming call received, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingend:
      print(
          '[ Caller ] Incoming call ended, number: $number, duration $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingstart:
      print(
          '[ Caller ] Ougoing call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingend:
      print(
          '[ Caller ] Ougoing call ended, number: $number, duration: $duration s');
      break;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Run your app as you would normally do...
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone State Background',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Phone State Background'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? hasPermission;

  @override
  void initState() {
    super.initState();
    _hasPermission();
  }

  Future<void> _hasPermission() async {
    final permission = await PhoneStateBackground.checkPermission();
    print('Caller permission $permission');
    setState(() => hasPermission = permission);
  }

  Future<void> _requestPermission() async {
    await PhoneStateBackground.requestPermissions();
    await _hasPermission();
  }

  Future<void> _stop() async {
    await PhoneStateBackground.stopPhoneStateBackground();
  }

  Future<void> _init() async {
    if (hasPermission != true) return;
    await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Has Permission: $hasPermission',
              style: TextStyle(
                  fontSize: 16,
                  color: hasPermission! ? Colors.green : Colors.red),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _requestPermission(),
                child: const Text('Check Permission'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () => _init(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Background color
                  ),
                  child: const Text('Start Listener'),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _stop(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Background color
                ),
                child: const Text('Stop Listener'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
