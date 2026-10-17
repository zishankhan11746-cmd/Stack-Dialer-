import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/call_record.dart';
import '../models/contact.dart';

class TelecomService {
  static const MethodChannel _channel = MethodChannel('com.stackdialer.app/telecom');

  /// Request all required telephony permissions
  static Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.phone,
      Permission.contacts,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  /// Check if StackDialer is the Default Phone Dialer
  static Future<bool> isDefaultDialer() async {
    try {
      final bool? isDefault = await _channel.invokeMethod('isDefaultDialer');
      return isDefault ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request Android OS to prompt user to set StackDialer as default dialer
  static Future<void> requestDefaultDialer() async {
    try {
      await _channel.invokeMethod('requestDefaultDialer');
    } catch (e) {
      // Fallback
    }
  }

  /// Place an ACTUAL real carrier telephone call using Android SIM
  static Future<bool> makeRealCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+*#]'), '');
    if (clean.isEmpty) return false;

    try {
      // Direct carrier calling (bypasses dialer screen)
      final bool? res = await FlutterPhoneDirectCaller.callNumber(clean);
      if (res == true) return true;
    } catch (_) {
      // Fallback to standard tel URI
    }

    final Uri uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Fetch real Android call logs from device storage
  static Future<List<CallRecord>> fetchDeviceCallLogs() async {
    try {
      final Iterable<CallLogEntry> entries = await CallLog.query();
      return entries.map((e) {
        CallType type = CallType.incoming;
        switch (e.callType) {
          case CallType.outgoing:
            type = CallType.outgoing;
            break;
          case CallType.missed:
            type = CallType.missed;
            break;
          case CallType.rejected:
            type = CallType.rejected;
            break;
          default:
            type = CallType.incoming;
        }

        return CallRecord(
          id: '${e.timestamp ?? DateTime.now().millisecondsSinceEpoch}',
          name: (e.name != null && e.name!.isNotEmpty) ? e.name! : (e.number ?? 'Unknown'),
          number: e.number ?? '',
          type: type,
          timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp ?? DateTime.now().millisecondsSinceEpoch),
          durationSeconds: e.duration ?? 0,
          simSlot: (e.simDisplayName?.contains('2') ?? false) ? 2 : 1,
          simCarrier: e.simDisplayName ?? 'Cellular',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch real Android contacts from device address book
  static Future<List<ContactModel>> fetchDeviceContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final List<Contact> deviceContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        return deviceContacts.map((c) {
          final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
          return ContactModel(
            id: c.id,
            name: c.displayName,
            number: phone,
            company: c.organizations.isNotEmpty ? c.organizations.first.company : null,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
