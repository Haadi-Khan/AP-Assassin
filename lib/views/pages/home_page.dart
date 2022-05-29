import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hse_assassin/constants/constants.dart';
import 'package:hse_assassin/constants/routes.dart';

enum MenuAction { logout }

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('Home Page'),
      ],
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(textLogout),
        content: const Text(textLogoutCheck),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(textCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(textLogout),
          )
        ],
      );
    },
  ).then(((value) => value ?? false));
}

AppBar homeBar(BuildContext context, State state) {
  return AppBar(
    title: const Text('Main UI'),
    actions: [
      PopupMenuButton<MenuAction>(
        onSelected: (value) async {
          switch (value) {
            case MenuAction.logout:
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await FirebaseAuth.instance.signOut();
                if (!state.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  welcomeRoute,
                  (_) => false,
                );
              }
          }
        },
        itemBuilder: (context) {
          return [
            const PopupMenuItem<MenuAction>(
              value: MenuAction.logout,
              child: Text('Log out'),
            ),
          ];
        },
      )
    ],
  );
}
