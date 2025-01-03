import 'package:flutter/material.dart';
import 'add_expense.dart';
import 'groups.dart';
import 'statistics.dart';
import 'payments.dart';
import 'settings.dart';
import 'components/appbar.dart';
import 'components/bottom_nav.dart';
import 'auth/login_and_regis.dart';

/// 🏠 **HomePage**: Hauptseite der App mit Navigation, Zustand und Mikrofonintegration.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// -----------------------------------
// HomePage State-Logik
// -----------------------------------
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isRecording = false;

  /// 🧭 Navigation zwischen BottomNavigationItems
  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToAddExpense();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// ➕ Direkt zur AddExpense-Seite navigieren
  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  /// 👤 Dropdown Menü für eingeloggte Benutzer
  void _showDropdownMenu(String value) {
    switch (value) {
      case 'profile':
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 'logout':
        setState(() {
          _isLoggedIn = false;
          _showMessage("Logged out successfully!");
        });
        break;
    }
  }

  /// 📲 Login-Logik
  void _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailCheckScreen()),
    );

    if (result == true) {
      setState(() {
        _isLoggedIn = true;
        _showMessage("Successfully logged in!");
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// 🎤 Mikrofon-Button gedrückt
  void _onMicrophonePressed() {
    setState(() {
      _isRecording = !_isRecording;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRecording ? '🎙️ Aufnahme gestartet...' : '🛑 Aufnahme gestoppt.',
        ),
      ),
    );
  }

  /// 📌 Inhaltsanzeige basierend auf Navigation
  Widget _buildContent() {
    final List<Widget> loggedInPages = [
      _buildHomeContent(),
      const GroupsPage(),
      const Placeholder(), // Placeholder für Add Expense
      const StatisticsPage(),
      const PaymentsPage(),
    ];

    final List<Widget> loggedOutPages = [
      _buildHomeContent(),
      const GroupsPage(),
      const Placeholder(),
      const StatisticsPage(),
      const Text('Payments (Login Required)'),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: _isLoggedIn ? loggedInPages : loggedOutPages,
    );
  }

  /// 🏠 Inhalt der Startseite
  Widget _buildHomeContent() {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is the Home Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  /// 🎤 Zeige FloatingActionButton nur auf der Home-Seite
  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        heroTag: 'home_microphone_button',
        onPressed: _onMicrophonePressed,
        backgroundColor:
            _isRecording ? Colors.red : Theme.of(context).primaryColor,
        tooltip: _isRecording ? 'Stoppen' : 'Aufnahme starten',
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 30,
          color: Colors.white,
        ),
      );
    }
    return null; // Kein Button auf anderen Seiten anzeigen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: _isLoggedIn,
        onLogout: () => setState(() {
          _isLoggedIn = false;
          _showMessage("Logged out successfully!");
        }),
        onDropdownSelected: (value) => _showDropdownMenu(value),
      ),
      body: _buildContent(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'add_expense.dart';
import 'groups.dart';
import 'statistics.dart';
import 'payments.dart';
import 'settings.dart';
import 'components/appbar.dart';
import 'components/bottom_nav.dart';

/// 🏠 **HomePage**: Hauptseite der App mit Navigation, Zustand und Mikrofonintegration.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// -----------------------------------
// HomePage State-Logik
// -----------------------------------
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isRecording = false;
  String? _audioFilePath; // Gespeicherter Audio-Dateipfad
  final _recorder = Record();

  /// 🧭 Navigation zwischen BottomNavigationItems
  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToAddExpense();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// ➕ Direkt zur AddExpense-Seite navigieren
  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  /// 👤 Dropdown Menü für eingeloggte Benutzer
  void _showDropdownMenu(String value) {
    switch (value) {
      case 'profile':
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 'logout':
        setState(() {
          _isLoggedIn = false;
          _showMessage("Logged out successfully!");
        });
        break;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// 🎤 Mikrofon-Button gedrückt: Aufnahme starten/stoppen
  Future<void> _onMicrophonePressed() async {
    if (!_isRecording) {
      // Berechtigungen prüfen
      if (await _recorder.hasPermission()) {
        // Dateipfad für die Audioaufnahme erstellen
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Aufnahme starten
        await _recorder.start(
          path: filePath,
          encoder: AudioEncoder.aacLc,
          samplingRate: 44100,
          bitRate: 128000,
        );

        setState(() {
          _isRecording = true;
          _audioFilePath = filePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎙️ Aufnahme gestartet...')),
        );
      } else {
        _showMessage('🚫 Mikrofon-Berechtigung verweigert!');
      }
    } else {
      // Aufnahme stoppen
      await _recorder.stop();

      setState(() {
        _isRecording = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎧 Aufnahme gespeichert: $_audioFilePath')),
      );
    }
  }

  /// 📌 Inhaltsanzeige basierend auf Navigation
  Widget _buildContent() {
    final List<Widget> loggedInPages = [
      _buildHomeContent(),
      const GroupsPage(),
      const Placeholder(), // Placeholder für Add Expense
      const StatisticsPage(),
      const PaymentsPage(),
    ];

    final List<Widget> loggedOutPages = [
      _buildHomeContent(),
      const GroupsPage(),
      const Placeholder(),
      const StatisticsPage(),
      const Text('Payments (Login Required)'),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: _isLoggedIn ? loggedInPages : loggedOutPages,
    );
  }

  /// 🏠 Inhalt der Startseite
  Widget _buildHomeContent() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the Home Page',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _audioFilePath != null
                  ? '📁 Gespeicherte Datei: $_audioFilePath'
                  : '🎤 Noch keine Aufnahme vorhanden',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎤 Zeige FloatingActionButton nur auf der Home-Seite
  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        heroTag: 'home_microphone_button', // Eindeutiger Hero-Tag
        onPressed: _onMicrophonePressed,
        backgroundColor:
            _isRecording ? Colors.red : Theme.of(context).primaryColor,
        tooltip: _isRecording ? 'Stoppen' : 'Aufnahme starten',
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 30,
          color: Colors.white,
        ),
      );
    }
    return null; // Kein Button auf anderen Seiten anzeigen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: _isLoggedIn,
        onLogout: () => setState(() => _isLoggedIn = false),
        onDropdownSelected: (value) => _showDropdownMenu(value),
      ),
      body: _buildContent(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}


*/ 