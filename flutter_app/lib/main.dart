import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/call_record.dart';
import 'models/contact.dart';
import 'screens/stacked_recents_screen.dart';
import 'screens/t9_dialpad_screen.dart';
import 'screens/contacts_screen.dart';
import 'services/telecom_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141417),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const StackDialerApp());
}

class StackDialerApp extends StatelessWidget {
  const StackDialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StackDialer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18161E),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          surface: Color(0xFF1E1E24),
        ),
      ),
      home: const MainDialerHost(),
    );
  }
}

class MainDialerHost extends StatefulWidget {
  const MainDialerHost({super.key});

  @override
  State<MainDialerHost> createState() => _MainDialerHostState();
}

class _MainDialerHostState extends State<MainDialerHost> {
  int _currentIndex = 0;
  List<CallRecord> _callLogs = [];
  List<ContactModel> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDeviceData();
  }

  Future<void> _initDeviceData() async {
    setState(() => _isLoading = true);
    await TelecomService.requestPermissions();
    final logs = await TelecomService.fetchDeviceCallLogs();
    final contacts = await TelecomService.fetchDeviceContacts();

    if (mounted) {
      setState(() {
        _callLogs = logs;
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  void _onCallNumber(String number) async {
    final success = await TelecomService.makeRealCall(number);
    if (success) {
      // Re-fetch call logs after call completes
      Future.delayed(const Duration(seconds: 4), () {
        _initDeviceData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18161E),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            )
          : IndexedStack(
              index: _currentIndex,
              children: [
                StackedRecentsScreen(
                  calls: _callLogs,
                  onRefresh: _initDeviceData,
                  onCallNumber: _onCallNumber,
                ),
                T9DialpadScreen(
                  contacts: _contacts,
                  onCallNumber: _onCallNumber,
                ),
                ContactsScreen(
                  contacts: _contacts,
                  onCallNumber: _onCallNumber,
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141417).withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'Recents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dialpad_outlined),
              activeIcon: Icon(Icons.dialpad),
              label: 'Keypad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              activeIcon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
          ],
        ),
      ),
    );
  }
}
