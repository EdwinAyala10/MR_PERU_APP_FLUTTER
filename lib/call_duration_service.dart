import 'package:flutter/services.dart';

class CallDurationService {
  static const platform = MethodChannel('com.mr_peru.crm_app.call_duration');

  CallDurationService() {
    platform.setMethodCallHandler(_methodCallHandler);
  }

  Function(int duration)? onCallEnded;

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == "callEnded") {
      final duration = call.arguments as int;
      if (onCallEnded != null) {
        onCallEnded!(duration);
      }
    }
  }

  Future<void> makeCall(String phoneNumber) async {
    try {
      await platform.invokeMethod('startCall', phoneNumber);
    } on PlatformException catch (e) {
      print("Failed to start call: '${e.message}'.");
    }
  }
}