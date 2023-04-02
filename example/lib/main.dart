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
      title: 'Phone State Background Plugin Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permission = await PhoneStateBackground.checkPermission();
    print('Caller permission $permission');
    setState(() => hasPermission = permission);
  }

  Future<void> _requestPermission() async {
    await PhoneStateBackground.requestPermissions();
    await _checkPermission();
  }

  Future<void> _stopCaller() async {
    await PhoneStateBackground.stopCaller();
  }

  Future<void> _startCaller() async {
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
            Text(hasPermission == true ? 'Has permission' : 'No permission'),
            ElevatedButton(
              onPressed: () => _requestPermission(),
              child: const Text('Ask Permission'),
            ),
            ElevatedButton(
              onPressed: () => _startCaller(),
              child: const Text('Start caller'),
            ),
            ElevatedButton(
              onPressed: () => _stopCaller(),
              child: const Text('Stop caller'),
            ),
          ],
        ),
      ),
    );
  }
}
