import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserToggleIcon extends StatelessWidget {
  final VoidCallback? onSignOut;
  const UserToggleIcon({Key? key, this.onSignOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox.shrink();
    return PopupMenuButton<int>(
      icon: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          user.displayName != null && user.displayName!.isNotEmpty
              ? user.displayName![0].toUpperCase()
              : user.email != null && user.email!.isNotEmpty
                  ? user.email![0].toUpperCase()
                  : '?',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? user.email ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (user.email != null)
                Text(
                  user.email!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Se déconnecter', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 1) {
          await FirebaseAuth.instance.signOut();
          if (onSignOut != null) onSignOut!();
        }
      },
    );
  }
}
