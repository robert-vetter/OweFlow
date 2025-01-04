import 'package:flutter/material.dart';
import 'groups.dart';
import 'settings.dart';
import 'components/appbar.dart';
import 'components/bottom_nav.dart';
import 'auth/login_and_regis.dart';

/// 🏠 **HomePage**: Hauptseite der App mit Navigation und Zustand.
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

  /// 🧭 Navigation zwischen BottomNavigationItems
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  /// Snackbar-Nachricht anzeigen
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// 📌 Inhaltsanzeige basierend auf Navigation
  Widget _buildContent() {
    final List<Widget> loggedInPages = [
      _buildHomeContent(),
      const GroupsPage(),
    ];

    final List<Widget> loggedOutPages = [
      _buildHomeContent(),
      const GroupsPage(),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: _isLoggedIn ? loggedInPages : loggedOutPages,
    );
  }

  /// 🏠 Optimierter Startbildschirm: Nutzerzentriert
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWalletOverview(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildSmartSuggestions(),
          const SizedBox(height: 16),
          _buildReminders(),
        ],
      ),
    );
  }

  /// 🏦 Persönliches Wallet: Finanzstatus
  Widget _buildWalletOverview() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dein Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kontostand: €250.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const Divider(),
            _buildTransactionItem('Lisa bezahlt – €15.00', 'Heute, 10:30',
                Icons.arrow_upward, Colors.red),
            _buildTransactionItem('Max hat dir – €25.00 gesendet',
                'Gestern, 14:20', Icons.arrow_downward, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  /// ⚡ Schnelle Aktionen
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
              Icons.account_balance_wallet, 'Geld einzahlen', Colors.blue),
          _buildActionButton(
              Icons.autorenew, 'Schulden begleichen', Colors.orange),
          _buildActionButton(
              Icons.person_add, 'Freund hinzufügen', Colors.green),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: () {},
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
          mini: true,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 🤖 Smarte Empfehlungen
  Widget _buildSmartSuggestions() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.amber),
        title: const Text('Lisa wartet auf eine Rückzahlung von dir.'),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Zahlen'),
        ),
      ),
    );
  }

  /// 📅 Erinnerungen
  Widget _buildReminders() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.blue),
        title: const Text('Du hast eine offene Zahlung an Max.'),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Erledigen'),
        ),
      ),
    );
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
    );
  }
}
