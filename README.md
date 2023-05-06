# phone_state_background

A flutter plugin to handle Phone Call State and execute a Dart callback in background.
<br />

## Warning 

> This plugin only supported in android platform.

<br />

## IOS Implementation

> Corrently IOS is not supported. Unfortunately I'm not familiar with IOS development neither with Switf/ObjC languages, so if you wish to help any PR will be welcome.

<br />

## Android

After importing this plugin to your project as usual, add the following to your `AndroidManifest.xml` within the `<manifest></manifest> tags:`


```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_CALL_LOG" />
```

Also, apparently it is necessary to register the broadcast receiver manually,
otherwise an error will be throw saying that our receiver does not exist inside the app. Within the `<application></application>` tags, add:


```xml
<receiver android:name="me.sodipto.phone_state_background.PhoneStateBackgroundServiceReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.PHONE_STATE" />
    </intent-filter>
</receiver>
```


<br />

## Getting started


All you need to start using our package after installing it, is defining a callback which must be a top level function or static function, that will be called by our plugin when any incoming or outgoing call events are detected.

`
@pragma('vm:entry-point') // Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
void phoneStateBackgroundCallbackHandler(PhoneStateBackgroundEvent event, String number, int duration)
`

This callback handler must accept 3 arguments:

- <b>phoneStateBackgroundEvent</b>: The event type detect by our plugin in background.

- <b>number</b>: The incoming/outgoin number that is triggering the phone state call.

- <b>duration</b>: An integer that represents the duration of the call in seconds.

The `PhoneStateBackgroundEvent` is an `enum` with four possible values: 

Event Value  | Description
------------ | ------------
incomingstart | Indicates an incoming call.
incomingmissed | Indicates an incoming call missed.
incomingreceived | Indicates an incoming call received.
incomingend | Indicates an incoming call end.
outgoingstart | Indicates an outgoing call start.
outgoingend | Indicates an outgoing call end.

Since all this process happens in background in a Dart Isolate, there's no guarantee that the current
OS will call the registered callback as soon as an event is triggered or that the callback will ever be called at all,
each OS handle background services with different policies. Make sure to ask user permission before calling the `PhoneStateBackground.initialize` 
method of our plugin. Check the [example] to see a simple implementation of it.

```xml
/// Defines a callback that will handle all background incoming events
@pragma('vm:entry-point') // Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
Future<void> phoneStateBackgroundCallbackHandler(
  PhoneStateBackgroundEvent event,
  String number,
  int duration,
) async {
  switch (event) {
    case PhoneStateBackgroundEvent.incomingstart:
      print('Incoming call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingmissed:
      print('Incoming call missed, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingreceived:
      print('Incoming call received, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingend:
      print('Incoming call ended, number: $number, duration $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingstart:
      print('Ougoing call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingend:
      print('Ougoing call ended, number: $number, duration: $duration s');
      break;
  }
}
```
[example]: <https://pub.dev/packages/phone_state_background/example>

