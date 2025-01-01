import 'package:flutter/material.dart';
import 'add_expense.dart';
import 'groups.dart';
import 'statistics.dart';
import 'payments.dart';
import 'settings.dart';
import 'components/appbar.dart';
import 'components/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// -----------------------------------
// HomeScreen UI
// -----------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

// -----------------------------------
// HomeScreen Logic
// -----------------------------------
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
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

  /// 📌 Inhaltsanzeige
  Widget _buildContent() {
    final List<Widget> loggedInPages = [
      const HomeScreen(),
      const GroupsPage(),
      const Placeholder(), // Placeholder für Add Expense
      const StatisticsPage(),
      const PaymentsPage(),
    ];

    final List<Widget> loggedOutPages = [
      const HomeScreen(),
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
