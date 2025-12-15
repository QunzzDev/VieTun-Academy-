import 'package:equatable/equatable.dart';

/// Question types
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillBlank,
  essay,
}

/// Question difficulty levels
enum QuestionLevel {
  easy,
  medium,
  hard,
}

/// Question model
class Question extends Equatable {
  final String id;
  final String teacherId;
  final String subject;
  final String chapter;
  final QuestionLevel level;
  final QuestionType type;
  final QuestionContent content;
  final List<AnswerOption> answers;
  final String? correctAnswer;
  final int version;
  final bool isDeleted;
  final DateTime createdAt;
  
  const Question({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.chapter,
    required this.level,
    required this.type,
    required this.content,
    required this.answers,
    this.correctAnswer,
    required this.version,
    required this.isDeleted,
    required this.createdAt,
  });
  
  factory Question.fromJson(Map<String, dynamic> json) {
    final contentJson = json['content_json'] as Map<String, dynamic>? ?? {};
    final answersJson = json['answers_json'] as Map<String, dynamic>? ?? {};
    
    return Question(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      subject: json['subject'] as String,
      chapter: json['chapter'] as String,
      level: _parseLevel(json['level'] as String),
      type: _parseType(json['type'] as String),
      content: QuestionContent.fromJson(contentJson),
      answers: (answersJson['options'] as List<dynamic>?)
          ?.map((o) => AnswerOption.fromJson(o as Map<String, dynamic>))
          .toList() ?? [],
      correctAnswer: json['correct_answer'] as String?,
      version: json['version'] as int? ?? 1,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'subject': subject,
      'chapter': chapter,
      'level': level.name.toUpperCase(),
      'type': type.name.toUpperCase(),
      'content_json': content.toJson(),
      'answers_json': {
        'options': answers.map((a) => a.toJson()).toList(),
      },
      'correct_answer': correctAnswer,
      'version': version,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Returns question without correct answer (for student view)
  Question withoutAnswer() {
    return Question(
      id: id,
      teacherId: teacherId,
      subject: subject,
      chapter: chapter,
      level: level,
      type: type,
      content: content,
      answers: answers,
      correctAnswer: null,
      version: version,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }
  
  static QuestionLevel _parseLevel(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return QuestionLevel.easy;
      case 'MEDIUM':
        return QuestionLevel.medium;
      case 'HARD':
        return QuestionLevel.hard;
      default:
        return QuestionLevel.medium;
    }
  }
  
  static QuestionType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return QuestionType.multipleChoice;
      case 'TRUE_FALSE':
        return QuestionType.trueFalse;
      case 'FILL_BLANK':
        return QuestionType.fillBlank;
      case 'ESSAY':
        return QuestionType.essay;
      default:
        return QuestionType.multipleChoice;
    }
  }
  
  @override
  List<Object?> get props => [
    id, teacherId, subject, chapter, level, type, 
    content, answers, correctAnswer, version, isDeleted, createdAt
  ];
}

/// Question content
class QuestionContent extends Equatable {
  final String text;
  final List<String> images;
  final String? latex;
  
  const QuestionContent({
    required this.text,
    this.images = const [],
    this.latex,
  });
  
  factory QuestionContent.fromJson(Map<String, dynamic> json) {
    return QuestionContent(
      text: json['text'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      latex: json['latex'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'images': images,
      'latex': latex,
    };
  }
  
  @override
  List<Object?> get props => [text, images, latex];
}

/// Answer option for multiple choice questions
class AnswerOption extends Equatable {
  final String id;
  final String text;
  
  const AnswerOption({
    required this.id,
    required this.text,
  });
  
  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
  
  @override
  List<Object?> get props => [id, text];
}
