import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/sync_service.dart';
import 'login_screen.dart';

/// Home screen after successful login.
/// Shows different content based on user role.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Platform'),
        actions: [
          // Sync status indicator
          Consumer<SyncService>(
            builder: (context, syncService, child) {
              if (!syncService.isOnline) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.cloud_off, color: Colors.orange),
                );
              }
              if (syncService.pendingSyncCount > 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Badge(
                    label: Text('${syncService.pendingSyncCount}'),
                    child: const Icon(Icons.sync),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.logout();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(
                            user.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _getRoleDisplayName(user.role),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      if (authService.isStudent) ...[
                        _buildActionCard(
                          context,
                          icon: Icons.quiz,
                          title: 'My Exams',
                          onTap: () {
                            // TODO: Navigate to exams list
                          },
                        ),
                        _buildActionCard(
                          context,
                          icon: Icons.history,
                          title: 'Results',
                          onTap: () {
                            // TODO: Navigate to results
                          },
                        ),
                      ],
                      if (authService.isParent) ...[
                        _buildActionCard(
                          context,
                          icon: Icons.child_care,
                          title: 'My Children',
                          onTap: () {
                            // TODO: Navigate to children list
                          },
                        ),
                        _buildActionCard(
                          context,
                          icon: Icons.assessment,
                          title: 'Progress',
                          onTap: () {
                            // TODO: Navigate to progress
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getRoleDisplayName(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.adminSystem':
        return 'System Administrator';
      case 'UserRole.adminSchool':
        return 'School Administrator';
      case 'UserRole.teacher':
        return 'Teacher';
      case 'UserRole.student':
        return 'Student';
      case 'UserRole.parent':
        return 'Parent';
      default:
        return 'User';
    }
  }
}
