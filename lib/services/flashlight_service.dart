import 'package:torch_light/torch_light.dart';

class FlashlightService {
  static Future<void> turnOn() async {
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      print('Could not turn on flashlight: $e');
    }
  }

  static Future<void> turnOff() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Could not turn off flashlight: $e');
    }
  }

  static Future<void> toggle(bool on) async {
    if (on) {
      await turnOn();
    } else {
      await turnOff();
    }
  }
}