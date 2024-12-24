import 'package:app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'auth/login_and_regis.dart';
import 'groups.dart';
import 'statistics.dart';
import 'payments.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Eingeloggt oder nicht eingeloggt
  final bool _isLoggedIn = false;

  /// Navigation zwischen BottomNavigationItems
  void _onItemTapped(int index) {
    if (index == 2) {
      _showQuickActions();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Quick Actions Modal
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Expense'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create Group'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Settle Debt'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// Dropdown Menü für eingeloggte Benutzer
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
        // Logout Logic
        break;
    }
  }

  /// 📌 **Gemeinsame Scaffold-Struktur**
  Widget _buildSharedContent() {
    return Scaffold(
      appBar: AppBar(
        leading: !_isLoggedIn
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: _openMenu,
              )
            : null,
        actions: [
          _isLoggedIn
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.person),
                  onSelected: _showDropdownMenu,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: const Text('Profile'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                      ),
                    ),
                  ],
                )
              : TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailCheckScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  /// 📌 **Inhaltsanzeige für beide Zustände**
  Widget _buildContent() {
    final List<Widget> loggedInPages = [
      const HomeScreen(),
      const GroupsPage(),
      const Placeholder(), // Placeholder for Quick Action Modal
      const StatisticsPage(),
      const PaymentsPage(),
    ];

    final List<Widget> loggedOutPages = [
      const HomeScreen(),
      const GroupsPage(),
      const Placeholder(), // Placeholder for Quick Action Modal
      const StatisticsPage(),
      const Text('Payments (Login Required)'),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: _isLoggedIn ? loggedInPages : loggedOutPages,
    );
  }

  /// 📌 **Gemeinsame BottomNavigationBar**
  Widget _buildNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40.0), label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        BottomNavigationBarItem(
            icon: Icon(Icons.attach_money), label: 'Payments'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  /// 📌 **Menü für nicht eingeloggte Benutzer**
  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSharedContent();
  }
}

// -----------------------------------
// HomeScreen Widget
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
