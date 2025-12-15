import 'package:equatable/equatable.dart';

/// Exam states following the state machine
enum ExamState {
  draft,
  scheduled,
  open,
  inProgress,
  closed,
  resultPublished,
  archived,
}

/// Exam model
class Exam extends Equatable {
  final String id;
  final String classId;
  final String teacherId;
  final String title;
  final ExamState state;
  final DateTime startTime;
  final int durationMinutes;
  final String? passwordOpen;
  final String? passwordView;
  final Map<String, dynamic> configJson;
  final int maxAttempts;
  final ScoringMethod scoringMethod;
  final DateTime createdAt;
  
  const Exam({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.state,
    required this.startTime,
    required this.durationMinutes,
    this.passwordOpen,
    this.passwordView,
    required this.configJson,
    required this.maxAttempts,
    required this.scoringMethod,
    required this.createdAt,
  });
  
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String,
      state: _parseState(json['state'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: json['duration_minutes'] as int,
      passwordOpen: json['password_open'] as String?,
      passwordView: json['password_view'] as String?,
      configJson: json['config_json'] as Map<String, dynamic>? ?? {},
      maxAttempts: json['max_attempts'] as int? ?? 1,
      scoringMethod: _parseScoringMethod(json['scoring_method'] as String? ?? 'HIGHEST'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'title': title,
      'state': state.name.toUpperCase(),
      'start_time': startTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'password_open': passwordOpen,
      'password_view': passwordView,
      'config_json': configJson,
      'max_attempts': maxAttempts,
      'scoring_method': scoringMethod.name.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  static ExamState _parseState(String state) {
    switch (state.toUpperCase()) {
      case 'DRAFT':
        return ExamState.draft;
      case 'SCHEDULED':
        return ExamState.scheduled;
      case 'OPEN':
        return ExamState.open;
      case 'IN_PROGRESS':
        return ExamState.inProgress;
      case 'CLOSED':
        return ExamState.closed;
      case 'RESULT_PUBLISHED':
        return ExamState.resultPublished;
      case 'ARCHIVED':
        return ExamState.archived;
      default:
        return ExamState.draft;
    }
  }
  
  static ScoringMethod _parseScoringMethod(String method) {
    switch (method.toUpperCase()) {
      case 'HIGHEST':
        return ScoringMethod.highest;
      case 'LATEST':
        return ScoringMethod.latest;
      case 'AVERAGE':
        return ScoringMethod.average;
      default:
        return ScoringMethod.highest;
    }
  }
  
  @override
  List<Object?> get props => [
    id, classId, teacherId, title, state, startTime, 
    durationMinutes, passwordOpen, passwordView, configJson,
    maxAttempts, scoringMethod, createdAt
  ];
}

enum ScoringMethod {
  highest,
  latest,
  average,
}
