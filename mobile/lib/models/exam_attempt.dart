import 'package:equatable/equatable.dart';

/// Exam attempt states following the state machine
enum AttemptState {
  created,
  inProgress,
  syncPending,
  submitted,
  autoSubmitted,
  invalidated,
}

/// Exam attempt model
class ExamAttempt extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final List<QuestionSetItem> questionSet;
  final AttemptState state;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final double? score;
  final int attemptNumber;
  final List<ActivityLogEntry> activityLog;
  
  const ExamAttempt({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.questionSet,
    required this.state,
    this.startedAt,
    this.submittedAt,
    this.score,
    required this.attemptNumber,
    required this.activityLog,
  });
  
  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      studentId: json['student_id'] as String,
      questionSet: (json['question_set_json']?['questions'] as List<dynamic>?)
          ?.map((q) => QuestionSetItem.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
      state: _parseState(json['state'] as String),
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at'] as String) 
          : null,
      score: (json['score'] as num?)?.toDouble(),
      attemptNumber: json['attempt_number'] as int? ?? 1,
      activityLog: (json['activity_log'] as List<dynamic>?)
          ?.map((a) => ActivityLogEntry.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'question_set_json': {
        'questions': questionSet.map((q) => q.toJson()).toList(),
      },
      'state': state.name.toUpperCase(),
      'started_at': startedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'score': score,
      'attempt_number': attemptNumber,
      'activity_log': activityLog.map((a) => a.toJson()).toList(),
    };
  }
  
  static AttemptState _parseState(String state) {
    switch (state.toUpperCase()) {
      case 'CREATED':
        return AttemptState.created;
      case 'IN_PROGRESS':
        return AttemptState.inProgress;
      case 'SYNC_PENDING':
        return AttemptState.syncPending;
      case 'SUBMITTED':
        return AttemptState.submitted;
      case 'AUTO_SUBMITTED':
        return AttemptState.autoSubmitted;
      case 'INVALIDATED':
        return AttemptState.invalidated;
      default:
        return AttemptState.created;
    }
  }
  
  ExamAttempt copyWith({
    String? id,
    String? examId,
    String? studentId,
    List<QuestionSetItem>? questionSet,
    AttemptState? state,
    DateTime? startedAt,
    DateTime? submittedAt,
    double? score,
    int? attemptNumber,
    List<ActivityLogEntry>? activityLog,
  }) {
    return ExamAttempt(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      questionSet: questionSet ?? this.questionSet,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      score: score ?? this.score,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      activityLog: activityLog ?? this.activityLog,
    );
  }
  
  @override
  List<Object?> get props => [
    id, examId, studentId, questionSet, state, 
    startedAt, submittedAt, score, attemptNumber, activityLog
  ];
}

/// Question set item for randomized question order
class QuestionSetItem extends Equatable {
  final String questionId;
  final int order;
  final List<String> shuffledAnswerOrder;
  
  const QuestionSetItem({
    required this.questionId,
    required this.order,
    required this.shuffledAnswerOrder,
  });
  
  factory QuestionSetItem.fromJson(Map<String, dynamic> json) {
    return QuestionSetItem(
      questionId: json['questionId'] as String,
      order: json['order'] as int,
      shuffledAnswerOrder: (json['shuffledAnswerOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'order': order,
      'shuffledAnswerOrder': shuffledAnswerOrder,
    };
  }
  
  @override
  List<Object?> get props => [questionId, order, shuffledAnswerOrder];
}

/// Activity log entry for tracking suspicious activity
class ActivityLogEntry extends Equatable {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? details;
  
  const ActivityLogEntry({
    required this.type,
    required this.timestamp,
    this.details,
  });
  
  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
  
  @override
  List<Object?> get props => [type, timestamp, details];
}
