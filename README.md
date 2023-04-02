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

Add the following permissions to your `AndroidManifest.xml` file:


```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_CALL_LOG" />
```

Also, apparently it is necessary to register the broadcast receiver manually,
otherwise an error will be throw saying that our receiver does not exist inside the app:


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
method of our plugin. Check the example to see a simple implementation of it.


