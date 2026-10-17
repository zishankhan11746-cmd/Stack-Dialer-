import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/telecom_service.dart';

class T9DialpadScreen extends StatefulWidget {
  final List<ContactModel> contacts;
  final Function(String number) onCallNumber;

  const T9DialpadScreen({
    super.key,
    required this.contacts,
    required this.onCallNumber,
  });

  @override
  State<T9DialpadScreen> createState() => _T9DialpadScreenState();
}

class _T9DialpadScreenState extends State<T9DialpadScreen> {
  String _digits = '';
  int _selectedSim = 1;

  final Map<String, String> _t9Letters = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '*': '',
    '0': '+',
    '#': '',
  };

  void _onDigitPress(String digit) {
    setState(() => _digits += digit);
  }

  void _onDelete() {
    if (_digits.isNotEmpty) {
      setState(() => _digits = _digits.substring(0, _digits.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    // T9 Contact Matches
    final matches = _digits.isEmpty
        ? <ContactModel>[]
        : widget.contacts.where((c) {
            return c.number.contains(_digits) ||
                c.name.toLowerCase().contains(_digits.toLowerCase());
          }).take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF18161E),
      body: SafeArea(
        child: Column(
          children: [
            // Top SIM Toggle Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSimPill(1, 'SIM 1 (Jio 5G)'),
                  const SizedBox(width: 12),
                  _buildSimPill(2, 'SIM 2 (Airtel)'),
                ],
              ),
            ),

            // T9 Matches Preview
            if (matches.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: matches.map((m) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                        child: Text(m.initials, style: const TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                      ),
                      title: Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(m.number, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Color(0xFF10B981), size: 18),
                        onPressed: () => widget.onCallNumber(m.number),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const Spacer(),

            // Display Dialed Number
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _digits.isEmpty ? 'Enter number' : _digits,
                    style: TextStyle(
                      color: _digits.isEmpty ? Colors.white24 : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (_digits.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined, color: Colors.white54, size: 22),
                      onPressed: _onDelete,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Dialpad Keypad Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['*', '0', '#']),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Real Call Action Button
            Center(
              child: InkWell(
                onTap: () {
                  if (_digits.isNotEmpty) {
                    widget.onCallNumber(_digits);
                  }
                },
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.call, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSimPill(int slot, String label) {
    final isSelected = _selectedSim == slot;
    return GestureDetector(
      onTap: () => setState(() => _selectedSim = slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF10B981) : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    final sub = _t9Letters[key] ?? '';
    return InkWell(
      onTap: () => _onDigitPress(key),
      onLongPress: () {
        if (key == '0') _onDigitPress('+');
      },
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              key,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1),
              ),
          ],
        ),
      ),
    );
  }
}
