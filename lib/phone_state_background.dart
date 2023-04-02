library phone_state_background;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_state_background/src/phone_state_background_event.dart';
import 'package:phone_state_background/src/error.dart';

export 'src/phone_state_background_event.dart';
export 'src/error.dart';

class PhoneStateBackground {
  static const MethodChannel _channel =
      MethodChannel('me.sodipto.phone_state_background');

  static Future<void> initialize(
    Function(PhoneStateBackgroundEvent, String, int) onEventCallbackDispatcher,
  ) async {
    final hasPermissions = await checkPermission();

    if (!hasPermissions) throw MissingAuthorizationFailure();

    final callback = PluginUtilities.getCallbackHandle(_callbackDispatcher);
    final onEventCallback =
        PluginUtilities.getCallbackHandle(onEventCallbackDispatcher);

    try {
      await _channel.invokeMethod('initialize', <dynamic>[
        callback!.toRawHandle(),
        onEventCallback!.toRawHandle(),
      ]);
    } on PlatformException catch (_) {
      throw UnableToInitializeFailure('Unable to initialize Caller plugin');
    }
  }

  /// Prompt the user to grant permission for the events needed for this plugin
  /// to work, `READ_PHONE_STATE` and `READ_CALL_LOG`
  static Future<void> requestPermissions() async {
    await _channel.invokeMethod('requestPermissions');
  }

  /// Check if the user has granted permission for `READ_PHONE_STATE` and `READ_CALL_LOG`
  ///
  /// The future will always be resolved with a value, there's no need to wrap
  /// this method in a `try/catch` block
  static Future<bool> checkPermission() async {
    try {
      final res = await _channel.invokeMethod('checkPermissions');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  /// Stops the service and cleans the previous registered callback
  static Future<void> stopPhoneStateBackground() async {
    await _channel.invokeMethod('stopcallstate');
  }
}

void _callbackDispatcher() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const MethodChannel _backgroundChannel =
      MethodChannel('me.sodipto.phone_state_background_listner');

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    final args = call.arguments as List<dynamic>;

    // 3.1. Retrieve callback instance for handle.
    final Function? userCallback = PluginUtilities.getCallbackFromHandle(
      CallbackHandle.fromRawHandle(args.elementAt(1)),
    );

    late PhoneStateBackgroundEvent event;
    switch (args.elementAt(2)) {
      case 'INCOMINGSTART':
        event = PhoneStateBackgroundEvent.incomingstart;
        break;
      case 'INCOMINGMISSED':
        event = PhoneStateBackgroundEvent.incomingmissed;
        break;
      case 'INCOMINGRECEIVED':
        event = PhoneStateBackgroundEvent.incomingreceived;
        break;
      case 'INCOMINGEND':
        event = PhoneStateBackgroundEvent.incomingend;
        break;
      case 'OUTGOINGEND':
        event = PhoneStateBackgroundEvent.outgoingend;
        break;
      case 'OUTGOINGSTART':
        event = PhoneStateBackgroundEvent.outgoingstart;
        break;

      default:
        throw Exception('Unkown event name');
    }

    //Invoke callback.
    userCallback?.call(event, args.elementAt(4), args.elementAt(3));
  });
}
