import 'package:flutter_test/flutter_test.dart';
import 'package:exam_platform_mobile/models/exam.dart';

void main() {
  group('Exam Model', () {
    test('fromJson creates valid Exam', () {
      final json = {
        'id': 'exam-123',
        'class_id': 'class-1',
        'teacher_id': 'teacher-1',
        'title': 'Math Test',
        'state': 'OPEN',
        'start_time': '2024-01-01T09:00:00Z',
        'duration_minutes': 60,
        'password_open': 'secret123',
        'config_json': {
          'shuffleQuestions': true,
          'shuffleAnswers': true,
        },
        'max_attempts': 2,
        'scoring_method': 'HIGHEST',
        'created_at': '2024-01-01T00:00:00Z',
      };
      
      final exam = Exam.fromJson(json);
      
      expect(exam.id, 'exam-123');
      expect(exam.title, 'Math Test');
      expect(exam.state, ExamState.open);
      expect(exam.durationMinutes, 60);
      expect(exam.maxAttempts, 2);
      expect(exam.scoringMethod, ScoringMethod.highest);
    });
    
    test('toJson produces valid JSON', () {
      final exam = Exam(
        id: 'exam-123',
        classId: 'class-1',
        teacherId: 'teacher-1',
        title: 'Math Test',
        state: ExamState.open,
        startTime: DateTime.parse('2024-01-01T09:00:00Z'),
        durationMinutes: 60,
        passwordOpen: 'secret123',
        configJson: {'shuffleQuestions': true},
        maxAttempts: 2,
        scoringMethod: ScoringMethod.highest,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      
      final json = exam.toJson();
      
      expect(json['id'], 'exam-123');
      expect(json['title'], 'Math Test');
      expect(json['state'], 'OPEN');
      expect(json['duration_minutes'], 60);
    });
    
    test('parses all exam states correctly', () {
      final states = [
        'DRAFT', 'SCHEDULED', 'OPEN', 'IN_PROGRESS', 
        'CLOSED', 'RESULT_PUBLISHED', 'ARCHIVED'
      ];
      final expected = [
        ExamState.draft, ExamState.scheduled, ExamState.open,
        ExamState.inProgress, ExamState.closed, 
        ExamState.resultPublished, ExamState.archived,
      ];
      
      for (var i = 0; i < states.length; i++) {
        final json = {
          'id': 'exam-123',
          'class_id': 'class-1',
          'teacher_id': 'teacher-1',
          'title': 'Test',
          'state': states[i],
          'start_time': '2024-01-01T09:00:00Z',
          'duration_minutes': 60,
          'config_json': {},
          'created_at': '2024-01-01T00:00:00Z',
        };
        
        final exam = Exam.fromJson(json);
        expect(exam.state, expected[i]);
      }
    });
    
    test('parses all scoring methods correctly', () {
      final methods = ['HIGHEST', 'LATEST', 'AVERAGE'];
      final expected = [
        ScoringMethod.highest, 
        ScoringMethod.latest, 
        ScoringMethod.average,
      ];
      
      for (var i = 0; i < methods.length; i++) {
        final json = {
          'id': 'exam-123',
          'class_id': 'class-1',
          'teacher_id': 'teacher-1',
          'title': 'Test',
          'state': 'DRAFT',
          'start_time': '2024-01-01T09:00:00Z',
          'duration_minutes': 60,
          'config_json': {},
          'scoring_method': methods[i],
          'created_at': '2024-01-01T00:00:00Z',
        };
        
        final exam = Exam.fromJson(json);
        expect(exam.scoringMethod, expected[i]);
      }
    });
  });
}
