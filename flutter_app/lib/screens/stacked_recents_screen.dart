import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/call_record.dart';
import '../services/telecom_service.dart';

class StackedRecentsScreen extends StatefulWidget {
  final List<CallRecord> calls;
  final VoidCallback onRefresh;
  final Function(String number) onCallNumber;

  const StackedRecentsScreen({
    super.key,
    required this.calls,
    required this.onRefresh,
    required this.onCallNumber,
  });

  @override
  State<StackedRecentsScreen> createState() => _StackedRecentsScreenState();
}

class _StackedRecentsScreenState extends State<StackedRecentsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _activeStyleIndex = 0;
  bool _isDefaultDialer = false;
  String _searchQuery = '';

  final List<String> _styleNames = [
    'iOS Depth',
    '3D Coverflow',
    'Cascade Wave',
    'Cyberpunk Neon',
    'Origami Fold',
    'Tinder Arc',
    'Accordion Spring',
    'Dynamic Island',
    'VisionOS Glass',
    'Charcoal Executive',
  ];

  @override
  void initState() {
    super.initState();
    _checkDefaultDialer();
  }

  Future<void> _checkDefaultDialer() async {
    final res = await TelecomService.isDefaultDialer();
    if (mounted) setState(() => _isDefaultDialer = res);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.calls.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.number.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF18161E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18161E),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    '${_activeStyleIndex + 1}. ${_styleNames[_activeStyleIndex]}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Cycle Style Button
          IconButton(
            icon: const Icon(Icons.shuffle, size: 18, color: Colors.white70),
            onPressed: () {
              setState(() {
                _activeStyleIndex = (_activeStyleIndex + 1) % _styleNames.length;
              });
            },
            tooltip: 'Next Animation Style',
          ),
          // Set as Default Dialer Button
          if (!_isDefaultDialer)
            TextButton.icon(
              onPressed: () async {
                await TelecomService.requestDefaultDialer();
                _checkDefaultDialer();
              },
              icon: const Icon(Icons.security, size: 14, color: Color(0xFF10B981)),
              label: const Text('Set Default', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search call records...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ),

          // 3D Stacked Call Cards List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No call logs found.\nCalls will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final call = filtered[index];
                      return _buildStackedCard(call, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedCard(CallRecord call, int index) {
    final bool isMissed = call.type == CallType.missed || call.type == CallType.rejected;

    return Dismissible(
      key: Key(call.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: const Color(0xFF10B981).withOpacity(0.3),
        child: const Icon(Icons.call, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withOpacity(0.3),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          widget.onCallNumber(call.number);
          return false;
        }
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMissed
              ? const Color(0xFF241A24).withOpacity(0.9)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMissed
                ? Colors.redAccent.withOpacity(0.3)
                : Colors.white.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isMissed ? Colors.red.withOpacity(0.2) : Colors.indigo.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Icon(
                  call.type == CallType.outgoing
                      ? Icons.call_made
                      : call.type == CallType.missed
                          ? Icons.call_missed
                          : Icons.call_received,
                  color: isMissed ? Colors.redAccent : const Color(0xFF10B981),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Caller Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.name,
                    style: TextStyle(
                      color: isMissed ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SIM ${call.simSlot}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        call.number,
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        call.durationString,
                        style: TextStyle(
                          color: isMissed ? Colors.redAccent.withOpacity(0.8) : Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Call Button (Direct SIM)
            IconButton(
              icon: const Icon(Icons.phone, color: Color(0xFF10B981), size: 22),
              onPressed: () => widget.onCallNumber(call.number),
              tooltip: 'Call via SIM',
            ),
          ],
        ),
      ),
    );
  }
}
