import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final providerId =
    user?.providerData.isNotEmpty == true ? user!.providerData.first.providerId : null;

    String providerLabel;
    if (providerId == 'google.com') {
      providerLabel = 'Google';
    } else if (providerId == 'password') {
      providerLabel = 'Email & Password';
    } else {
      providerLabel = providerId ?? 'Desconhecido';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? const Center(child: Text('Nenhum utilizador autenticado'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${user.email ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Provider: $providerLabel',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                await auth.signOut();
                Navigator.of(context).pop(); // volta ao ecrã anterior (Login será mostrado pelo main)
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
