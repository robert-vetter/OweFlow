import 'package:app/pages/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../auth/login_and_regis.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  final Function(String) onDropdownSelected;

  const CustomAppBar({
    super.key,
    required this.onLogout,
    required this.onDropdownSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authNotifier,
      builder: (context, isLoggedIn, _) {
        return AppBar(
          automaticallyImplyLeading: false, // Entfernt den Standard-Back-Button
          actions: [
            if (isLoggedIn)
              PopupMenuButton<String>(
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
                  PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        authNotifier.update();
                        onLogout();
                      },
                    ),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmailCheckScreen(),
                    ),
                  );
                  if (result == true) {
                    authNotifier.update(); // Login-Zustand aktualisieren
                  }
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.black),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
