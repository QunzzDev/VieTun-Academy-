import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../services/sync_service.dart';

/// Repository for local SQLite storage.
/// Handles offline answer storage and sync queue.
/// Requirements: 6.3, 6.4, 12.2
class LocalStorageRepository {
  static LocalStorageRepository? _instance;
  Database? _database;
  final Uuid _uuid = const Uuid();
  
  static Future<LocalStorageRepository> getInstance() async {
    _instance ??= LocalStorageRepository._();
    await _instance!._initDatabase();
    return _instance!;
  }
  
  LocalStorageRepository._();
  
  Future<void> _initDatabase() async {
    if (_database != null) return;
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'exam_platform.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Offline answers table
        await db.execute('''
          CREATE TABLE offline_answers (
            id TEXT PRIMARY KEY,
            attempt_id TEXT NOT NULL,
            question_id TEXT NOT NULL,
            answer_json TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        
        // Cached exams table
        await db.execute('''
          CREATE TABLE cached_exams (
            id TEXT PRIMARY KEY,
            exam_json TEXT NOT NULL,
            cached_at TEXT NOT NULL
          )
        ''');
        
        // Cached questions table
        await db.execute('''
          CREATE TABLE cached_questions (
            id TEXT PRIMARY KEY,
            attempt_id TEXT NOT NULL,
            question_json TEXT NOT NULL,
            cached_at TEXT NOT NULL
          )
        ''');
        
        // Create indexes
        await db.execute(
          'CREATE INDEX idx_offline_answers_attempt ON offline_answers(attempt_id)'
        );
        await db.execute(
          'CREATE INDEX idx_offline_answers_synced ON offline_answers(is_synced)'
        );
      },
    );
  }
  
  /// Save an answer for offline sync
  Future<void> saveOfflineAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answer,
    required DateTime timestamp,
  }) async {
    await _database!.insert(
      'offline_answers',
      {
        'id': _uuid.v4(),
        'attempt_id': attemptId,
        'question_id': questionId,
        'answer_json': jsonEncode(answer),
        'timestamp': timestamp.toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get all pending (unsynced) answers
  Future<List<OfflineAnswer>> getPendingAnswers() async {
    final results = await _database!.query(
      'offline_answers',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
    
    return results.map((row) => OfflineAnswer(
      id: row['id'] as String,
      attemptId: row['attempt_id'] as String,
      questionId: row['question_id'] as String,
      answer: jsonDecode(row['answer_json'] as String) as Map<String, dynamic>,
      timestamp: DateTime.parse(row['timestamp'] as String),
      isSynced: (row['is_synced'] as int) == 1,
    )).toList();
  }
  
  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final result = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM offline_answers WHERE is_synced = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Check if attempt has pending answers
  Future<bool> hasPendingAnswers(String attemptId) async {
    final result = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM offline_answers WHERE attempt_id = ? AND is_synced = 0',
      [attemptId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
  
  /// Mark answer as synced
  Future<void> markAsSynced(String answerId) async {
    await _database!.update(
      'offline_answers',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [answerId],
    );
  }
  
  /// Cache exam for offline access
  Future<void> cacheExam(String examId, Map<String, dynamic> examJson) async {
    await _database!.insert(
      'cached_exams',
      {
        'id': examId,
        'exam_json': jsonEncode(examJson),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get cached exam
  Future<Map<String, dynamic>?> getCachedExam(String examId) async {
    final results = await _database!.query(
      'cached_exams',
      where: 'id = ?',
      whereArgs: [examId],
    );
    
    if (results.isEmpty) return null;
    return jsonDecode(results.first['exam_json'] as String) as Map<String, dynamic>;
  }
  
  /// Cache questions for offline access
  Future<void> cacheQuestions(String attemptId, List<Map<String, dynamic>> questions) async {
    final batch = _database!.batch();
    
    for (final question in questions) {
      batch.insert(
        'cached_questions',
        {
          'id': question['id'],
          'attempt_id': attemptId,
          'question_json': jsonEncode(question),
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  /// Get cached questions for attempt
  Future<List<Map<String, dynamic>>> getCachedQuestions(String attemptId) async {
    final results = await _database!.query(
      'cached_questions',
      where: 'attempt_id = ?',
      whereArgs: [attemptId],
    );
    
    return results.map((row) => 
      jsonDecode(row['question_json'] as String) as Map<String, dynamic>
    ).toList();
  }
  
  /// Clear all cached data
  Future<void> clearCache() async {
    await _database!.delete('cached_exams');
    await _database!.delete('cached_questions');
  }
  
  /// Clear synced answers older than specified days
  Future<void> cleanupSyncedAnswers({int olderThanDays = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: olderThanDays));
    await _database!.delete(
      'offline_answers',
      where: 'is_synced = 1 AND created_at < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }
  
  /// Close database connection
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
