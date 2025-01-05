import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'groups.dart';
import 'settings.dart';
import 'components/appbar.dart';
import 'components/bottom_nav.dart';
import 'auth/login_and_regis.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _isLoggedIn = (data.session?.user.id) != null ? true : false;
      });
    });
  }

  /// 🧭 Navigation zwischen BottomNavigationItems
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          _showSnackBar("Logged out successfully!");
        });
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final List<Widget> pages = [
      _buildHomeContent(),
      const GroupsPage(),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: pages,
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildWalletHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildQuickActions(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        _buildRecentTransactions(),
        SliverToBoxAdapter(
          child: _buildSmartSuggestions(),
        ),
        SliverToBoxAdapter(
          child: _buildReminders(),
        ),
      ],
    );
  }

  Widget _buildWalletHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Balance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '€250.00',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletStat('Income', '€450.00', Icons.arrow_downward),
              _buildWalletStat('Expenses', '€200.00', Icons.arrow_upward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletStat(String label, String amount, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            'Send',
            Icons.send_rounded,
            Colors.purple,
            () {},
          ),
          _buildActionButton(
            'Request',
            Icons.account_balance_wallet,
            Colors.orange,
            () {},
          ),
          _buildActionButton(
            'Split',
            Icons.group_add,
            Colors.green,
            () {},
          ),
          _buildActionButton(
            'Scan',
            Icons.qr_code_scanner,
            Colors.blue,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'name': 'Lisa',
        'amount': '-€15.00',
        'date': 'Today, 10:30',
        'type': 'expense'
      },
      {
        'name': 'Max',
        'amount': '+€25.00',
        'date': 'Yesterday, 14:20',
        'type': 'income'
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction['type'] == 'expense'
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              child: Icon(
                transaction['type'] == 'expense'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction['type'] == 'expense'
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            title: Text(transaction['name']!),
            subtitle: Text(transaction['date']!),
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                color: transaction['type'] == 'expense'
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Suggestion',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Text('Lisa is waiting for a payment from you.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminders() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Text('You have a pending payment to Max.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
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
