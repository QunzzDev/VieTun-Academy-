import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sync_service.dart';

/// Widget showing current sync status.
/// Requirements: 6.4, 12.3
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        if (syncService.isSyncing) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Syncing...'),
            ],
          );
        }
        
        if (!syncService.isOnline) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Offline${syncService.pendingSyncCount > 0 ? ' (${syncService.pendingSyncCount} pending)' : ''}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          );
        }
        
        if (syncService.pendingSyncCount > 0) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text('${syncService.pendingSyncCount} pending'),
            ],
          );
        }
        
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('Synced', style: TextStyle(color: Colors.green)),
          ],
        );
      },
    );
  }
}
