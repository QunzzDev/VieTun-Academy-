import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/exam_attempt.dart';
import '../repositories/local_storage_repository.dart';

/// Sync service for offline support.
/// Handles syncing answers when connection is restored.
/// Requirements: 6.4, 12.3, 12.5
class SyncService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  LocalStorageRepository? _localStorage;
  
  bool _isOnline = true;
  bool _isSyncing = false;
  int _pendingSyncCount = 0;
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingSyncCount => _pendingSyncCount;
  
  SyncService() {
    _initConnectivity();
  }
  
  void setLocalStorage(LocalStorageRepository localStorage) {
    _localStorage = localStorage;
  }
  
  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !_isOnline;
      _isOnline = results.isNotEmpty && 
          results.any((r) => r != ConnectivityResult.none);
      
      if (wasOffline && _isOnline) {
        // Connection restored, trigger sync
        syncPendingAnswers();
      }
      
      notifyListeners();
    });
    
    // Check initial connectivity
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.isNotEmpty && 
        results.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }
  
  /// Queue an answer for sync when offline
  Future<void> queueAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answer,
    required DateTime timestamp,
  }) async {
    if (_localStorage == null) return;
    
    await _localStorage!.saveOfflineAnswer(
      attemptId: attemptId,
      questionId: questionId,
      answer: answer,
      timestamp: timestamp,
    );
    
    _pendingSyncCount = await _localStorage!.getPendingSyncCount();
    notifyListeners();
  }
  
  /// Sync all pending answers to server
  Future<SyncResult> syncPendingAnswers() async {
    if (_localStorage == null || !_isOnline || _isSyncing) {
      return SyncResult(synced: 0, failed: 0, conflicts: []);
    }
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      final pendingAnswers = await _localStorage!.getPendingAnswers();
      int synced = 0;
      int failed = 0;
      List<SyncConflict> conflicts = [];
      
      for (final answer in pendingAnswers) {
        try {
          // TODO: Implement actual API sync
          // For now, mark as synced
          await _localStorage!.markAsSynced(answer.id);
          synced++;
        } catch (e) {
          if (e is SyncConflictException) {
            conflicts.add(SyncConflict(
              localAnswer: answer,
              serverTimestamp: e.serverTimestamp,
            ));
          } else {
            failed++;
          }
        }
      }
      
      // Resolve conflicts by timestamp (latest wins)
      for (final conflict in conflicts) {
        if (conflict.localAnswer.timestamp.isAfter(conflict.serverTimestamp)) {
          // Local is newer, push to server
          // TODO: Implement force push
        } else {
          // Server is newer, discard local
          await _localStorage!.markAsSynced(conflict.localAnswer.id);
        }
      }
      
      _pendingSyncCount = await _localStorage!.getPendingSyncCount();
      _isSyncing = false;
      notifyListeners();
      
      return SyncResult(synced: synced, failed: failed, conflicts: conflicts);
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Get current sync status for an attempt
  Future<AttemptState> getAttemptSyncState(String attemptId) async {
    if (_localStorage == null) return AttemptState.inProgress;
    
    final hasPending = await _localStorage!.hasPendingAnswers(attemptId);
    if (hasPending && !_isOnline) {
      return AttemptState.syncPending;
    }
    return AttemptState.inProgress;
  }
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final List<SyncConflict> conflicts;
  
  SyncResult({
    required this.synced,
    required this.failed,
    required this.conflicts,
  });
}

/// Represents a sync conflict
class SyncConflict {
  final OfflineAnswer localAnswer;
  final DateTime serverTimestamp;
  
  SyncConflict({
    required this.localAnswer,
    required this.serverTimestamp,
  });
}

/// Exception thrown when sync conflict occurs
class SyncConflictException implements Exception {
  final DateTime serverTimestamp;
  
  SyncConflictException(this.serverTimestamp);
}

/// Offline answer model
class OfflineAnswer {
  final String id;
  final String attemptId;
  final String questionId;
  final Map<String, dynamic> answer;
  final DateTime timestamp;
  final bool isSynced;
  
  OfflineAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.answer,
    required this.timestamp,
    required this.isSynced,
  });
}
