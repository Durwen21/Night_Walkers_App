import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAlarm([String filename = 'alarm.wav']) async {
    await _player.setReleaseMode(ReleaseMode.loop); // Loop the alarm
    await _player.play(AssetSource('sounds/$filename'));
  }

  static Future<void> stopAlarm() async {
    await _player.stop();
  }
}