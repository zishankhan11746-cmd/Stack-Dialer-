import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactsScreen extends StatelessWidget {
  final List<ContactModel> contacts;
  final Function(String number) onCallNumber;

  const ContactsScreen({
    super.key,
    required this.contacts,
    required this.onCallNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18161E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18161E),
        elevation: 0,
        title: const Text('Phone Contacts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Text(
                'No contacts synced yet.\nTap refresh to fetch device contacts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final c = contacts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.withOpacity(0.3),
                        child: Text(c.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            if (c.number.isNotEmpty)
                              Text(c.number, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Color(0xFF10B981), size: 20),
                        onPressed: () => onCallNumber(c.number),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
