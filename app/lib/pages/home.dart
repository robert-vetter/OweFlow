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

  /// 🏠 Inhalt der Startseite (Optimierter Home Content)
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏦 Wallet-Übersicht
          _buildWalletOverview(),
          const SizedBox(height: 16),

          // ⚡ Schnelle Aktionen
          _buildQuickActions(),
          const SizedBox(height: 16),

          // 🤖 Smarte Empfehlungen
          _buildSmartSuggestions(),
          const SizedBox(height: 16),

          // 📊 Finanzstatistiken
          _buildFinanceStats(),
        ],
      ),
    );
  }

  /// 🏦 Persönliches Wallet: Kontostand & letzte Transaktionen
  Widget _buildWalletOverview() {
    return Card(
      elevation: 2,
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
            const SizedBox(height: 8),
            Text(
              'Kontostand: €250.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const Text(
              'Letzte Transaktionen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('Lisa bezahlt – €15.00'),
              subtitle: Text('Heute, 10:30'),
            ),
            const ListTile(
              leading: Icon(Icons.arrow_downward, color: Colors.green),
              title: Text('Max hat dir – €25.00 gesendet'),
              subtitle: Text('Gestern, 14:20'),
            ),
          ],
        ),
      ),
    );
  }

  /// ⚡ Schnelle Aktionen: Buttons für häufige Aktionen
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schnelle Aktionen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.account_balance_wallet,
                label: 'Geld einzahlen',
                color: Colors.blue,
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.autorenew,
                label: 'Schulden begleichen',
                color: Colors.orange,
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.bar_chart,
                label: 'Details anzeigen',
                color: Colors.purple,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
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

  /// 📊 Finanzstatistiken
  Widget _buildFinanceStats() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('40% deiner Ausgaben gingen an Essen.'),
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
