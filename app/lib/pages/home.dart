import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Screens for each tab in the Taskbar
  final List<Widget> _pages = [
    HomeScreen(),
    GroupsScreen(),
    Placeholder(), // Placeholder for the Quick Action
    StatisticsScreen(),
    PaymentsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.add_circle, size: 40.0), // Highlighted Quick Action
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Payments',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // Define Quick Action logic here
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.add),
                          title: Text('Add Expense'),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to Add Expense screen
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.group_add),
                          title: Text('Create Group'),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to Create Group screen
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.account_balance),
                          title: Text('Settle Debt'),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to Settle Debt screen
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

// Placeholder screens for each tab
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen'),
    );
  }
}

class GroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Groups Screen'),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Statistics Screen'),
    );
  }
}

class PaymentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Payments Screen'),
    );
  }
}
