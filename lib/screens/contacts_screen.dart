import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'dart:convert';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, String>> contacts = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final Telephony telephony = Telephony.instance;

  int? editingIndex;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactList = contacts
        .map((e) => {'name': e['name']!, 'number': e['number']!})
        .toList();
    final contactsJson = jsonEncode(contactList);
    await prefs.setString('emergency_contacts', contactsJson);
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('emergency_contacts');
    if (contactsJson != null) {
      final decoded = jsonDecode(contactsJson) as List;
      setState(() {
        contacts = decoded
            .map((item) => {
                  'name': item['name'].toString(),
                  'number': item['number'].toString(),
                })
            .toList();
      });
    }
  }

  void addOrUpdateContact() {
    final name = nameController.text.trim();
    final number = numberController.text.trim();

    if (name.isEmpty || number.isEmpty) return;

    setState(() {
      if (editingIndex == null) {
        contacts.add({'name': name, 'number': number});
      } else {
        contacts[editingIndex!] = {'name': name, 'number': number};
        editingIndex = null;
      }
      nameController.clear();
      numberController.clear();
    });

    saveContacts();
  }

  void startEdit(int index) {
    setState(() {
      editingIndex = index;
      nameController.text = contacts[index]['name'] ?? '';
      numberController.text = contacts[index]['number'] ?? '';
    });
  }

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
      if (editingIndex == index) {
        editingIndex = null;
        nameController.clear();
        numberController.clear();
      }
    });
    saveContacts();
  }

  Future<void> sendEmergencySms(String number, String message) async {
    final bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == true) {
      await telephony.sendSms(
        to: number,
        message: message,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS sent to $number")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SMS permission denied")),
      );
    }
  }

  void sendAlertToAllContacts() {
    const message = "This is an emergency! Please help me immediately!";
    for (var contact in contacts) {
      final number = contact['number'];
      if (number != null) {
        sendEmergencySms(number, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add Emergency Contact'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addOrUpdateContact,
              child: Text(
                editingIndex == null ? 'Add Contact' : 'Update Contact',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Saved Contacts:'),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact['name'] ?? ''),
                    subtitle: Text(contact['number'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => startEdit(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteContact(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
