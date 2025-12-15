import 'package:flutter_test/flutter_test.dart';
import 'package:exam_platform_mobile/models/user.dart';

void main() {
  group('User Model', () {
    test('fromJson creates valid User', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'school_id': 'school-1',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.role, UserRole.student);
      expect(user.status, UserStatus.active);
      expect(user.schoolId, 'school-1');
    });
    
    test('toJson produces valid JSON', () {
      final user = User(
        id: '123',
        username: 'testuser',
        role: UserRole.student,
        status: UserStatus.active,
        schoolId: 'school-1',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      
      final json = user.toJson();
      
      expect(json['id'], '123');
      expect(json['username'], 'testuser');
      expect(json['role'], 'STUDENT');
      expect(json['status'], 'ACTIVE');
    });
    
    test('parses all user roles correctly', () {
      final roles = ['ADMIN_SYSTEM', 'ADMIN_SCHOOL', 'TEACHER', 'STUDENT', 'PARENT'];
      final expected = [
        UserRole.adminSystem,
        UserRole.adminSchool,
        UserRole.teacher,
        UserRole.student,
        UserRole.parent,
      ];
      
      for (var i = 0; i < roles.length; i++) {
        final json = {
          'id': '123',
          'username': 'testuser',
          'role': roles[i],
          'status': 'ACTIVE',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        };
        
        final user = User.fromJson(json);
        expect(user.role, expected[i]);
      }
    });
  });
}
