import 'package:flutter/material.dart';
import 'add_friend.dart';
import 'add_expense.dart'; // Neue Seite zum Erstellen einer Gruppe hinzufügen

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool _showFriends = true; // Zustand zur Anzeige von Freunden oder Gruppen

  /// 🎯 Umschalten zwischen Freunde und Gruppen
  void _toggleView(bool showFriends) {
    setState(() {
      _showFriends = showFriends;
    });
  }

  /// 📌 Build FloatingActionButton basierend auf dem Zustand
  Widget? _buildFloatingActionButton() {
    if (_showFriends) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFriendPage()),
          );
        },
        label: const Text('Add Friend'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blue,
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        label: const Text('Add Group'),
        icon: const Icon(Icons.group_add),
        backgroundColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🧭 Umschaltbereich zwischen Freunde und Gruppen
      body: Column(
        children: [
          /// 🔄 Umschalt-Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _toggleView(false),
                style: TextButton.styleFrom(
                  backgroundColor: !_showFriends
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                  foregroundColor: !_showFriends ? Colors.blue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Gruppen'),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _toggleView(true),
                style: TextButton.styleFrom(
                  backgroundColor: _showFriends
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                  foregroundColor: _showFriends ? Colors.blue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Freunde'),
              ),
            ],
          ),

          /// 📌 Inhaltsbereich (abhängig vom Zustand)
          Expanded(
            child: _showFriends ? _buildFriendsView() : _buildGroupsView(),
          ),
        ],
      ),

      /// ➕ FloatingActionButton je nach Zustand anzeigen
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 👥 Anzeige der Freunde
  Widget _buildFriendsView() {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Anna Müller'),
          subtitle: Text('Letzte Aktivität: Gestern'),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Ben Schmidt'),
          subtitle: Text('Letzte Aktivität: Vor 2 Tagen'),
        ),
      ],
    );
  }

  /// 🏘️ Anzeige der Gruppen
  Widget _buildGroupsView() {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.group),
          title: Text('WG Berlin'),
          subtitle: Text('3 Mitglieder, 5 offene Ausgaben'),
        ),
        ListTile(
          leading: Icon(Icons.group),
          title: Text('Urlaub Spanien'),
          subtitle: Text('5 Mitglieder, 2 offene Ausgaben'),
        ),
      ],
    );
  }
}
