import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SmsService {
  static final Telephony telephony = Telephony.instance;

  // Send location SMS to all saved emergency contacts
  static Future<void> sendLocationSms(double latitude, double longitude) async {
    try {
      // Check SMS permission
      bool? permissionsGranted = await telephony.requestSmsPermissions;
      if (permissionsGranted != true) {
        print('SMS permissions not granted');
        return;
      }

      // Load contacts
      final contacts = await _loadContacts();
      if (contacts.isEmpty) {
        print('No emergency contacts found');
        return;
      }

      // Create Google Maps link with coordinates
      final String mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
      final String message =
          'EMERGENCY: I need help! My current location is: $mapsLink';

      // Send SMS to all emergency contacts
      for (final contact in contacts) {
        final String phoneNumber = contact['number'] ?? '';
        if (phoneNumber.isNotEmpty) {
          await telephony.sendSms(to: phoneNumber, message: message);
          print('Emergency SMS sent to ${contact['name']} ($phoneNumber)');
        }
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  // Load emergency contacts from shared preferences
  static Future<List<Map<String, String>>> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('emergency_contacts');

    if (contactsJson != null) {
      final decoded = jsonDecode(contactsJson) as List;
      return decoded
          .map(
            (item) => {
              'name': item['name'].toString(),
              'number': item['number'].toString(),
            },
          )
          .toList();
    }

    return [];
  }
}
