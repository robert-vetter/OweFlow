import 'package:flutter/material.dart';
import '../auth/login_and_regis.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final Function(String) onDropdownSelected;

  const CustomAppBar({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
    required this.onDropdownSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Entfernt den Standard-Back-Button
      actions: [
        isLoggedIn
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.person),
                onSelected: onDropdownSelected,
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Profile'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              )
            : TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmailCheckScreen()),
                  );
                  if (result == true) {
                    // Logik zur Aktualisierung des Zustands im HomePage
                  }
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.black),
                ),
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
