# Implementation Plan

## Phase 1: Project Setup & Core Infrastructure

- [x] 1. Initialize Laravel Backend Project






  - [x] 1.1 Create Laravel project with required packages

    - Install Laravel 11.x
    - Configure PostgreSQL database connection
    - Install JWT authentication package (tymon/jwt-auth)
    - Install Pest PHP for property-based testing
    - Configure Redis for caching and sessions
    - _Requirements: 21.1, 21.4_

  - [x] 1.2 Set up database migrations for core tables

    - Create users, students, parents, teachers tables
    - Create parent_student_links table
    - Create audit_logs table
    - _Requirements: 2.1, 10.1_

  - [x] 1.3 Write property test for audit log immutability

    - **Property 24: Audit Log Immutability**
    - **Validates: Requirements 10.3**

- [x] 2. Initialize Flutter Mobile Project






  - [x] 2.1 Create Flutter project with required packages

    - Initialize Flutter project for Android & iOS
    - Add dio for HTTP requests
    - Add flutter_secure_storage for token storage
    - Add sqflite for local database
    - Add dart_check for property-based testing
    - _Requirements: 12.1_

  - [x] 2.2 Set up project structure

    - Create folder structure (models, services, repositories, screens, widgets)
    - Configure environment variables
    - _Requirements: 21.1_

## Phase 2: Authentication & Authorization

- [-] 3. Implement Auth Service (Backend)





  - [ ] 3.1 Create authentication endpoints
    - POST /api/auth/login - Issue JWT and refresh token
    - POST /api/auth/refresh - Refresh access token
    - POST /api/auth/logout - Invalidate session

    - _Requirements: 1.1, 1.3, 1.4_
  - [x] 3.2 Write property test for authentication round-trip

    - **Property 1: Authentication Token Round-Trip**
    - **Validates: Requirements 1.1, 1.3**


  - [ ] 3.3 Implement RBAC middleware
    - Create role-based permission checking

    - Define permissions for each role (ADMIN_SYSTEM, ADMIN_SCHOOL, TEACHER, STUDENT, PARENT)
    - _Requirements: 1.5_
  - [ ] 3.4 Write property test for RBAC enforcement
    - **Property 4: RBAC Enforcement**
    - **Validates: Requirements 1.5**
  - [ ] 3.5 Write property test for invalid credentials
    - **Property 2: Invalid Credentials Rejection**
    - **Validates: Requirements 1.2**
  - [ ] 3.6 Write property test for logout invalidation
    - **Property 3: Logout Invalidates Session**
    - **Validates: Requirements 1.4**

- [ ] 4. Implement Auth in Flutter
  - [ ] 4.1 Create auth service and repository
    - Implement login, logout, refresh token methods
    - Store tokens in secure storage
    - _Requirements: 1.1, 1.4_
  - [ ] 4.2 Create login screen UI
    - Username/password input fields
    - Error handling and display
    - _Requirements: 1.2_

- [ ] 5. Checkpoint - Authentication
  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: User Management

- [ ] 6. Implement User Management (Backend)
  - [ ] 6.1 Create user CRUD endpoints
    - POST /api/users - Create user
    - GET /api/users/{id} - Get user
    - PUT /api/users/{id} - Update user
    - DELETE /api/users/{id} - Deactivate user
    - _Requirements: 2.1, 2.4_
  - [ ] 6.2 Write property test for user creation uniqueness
    - **Property 5: User Creation Uniqueness**
    - **Validates: Requirements 2.1**
  - [ ] 6.3 Write property test for deactivation prevents login
    - **Property 7: User Deactivation Prevents Login**
    - **Validates: Requirements 2.4**
  - [ ] 6.4 Implement CSV import for users
    - Parse and validate CSV format
    - Batch create users
    - _Requirements: 2.2_
  - [ ] 6.5 Implement parent-student linking
    - POST /api/parent-student-links
    - Validate both entities exist
    - _Requirements: 2.3_
  - [ ] 6.6 Write property test for parent-student link access
    - **Property 6: Parent-Student Link Access**
    - **Validates: Requirements 2.3, 9.1**
  - [ ] 6.7 Write property test for audit log completeness
    - **Property 8: Audit Log Completeness**
    - **Validates: Requirements 2.5, 10.1**

## Phase 4: Class & Question Management

- [ ] 7. Implement Class Management (Backend)
  - [ ] 7.1 Create class CRUD endpoints
    - POST /api/classes - Create class
    - GET /api/classes/{id} - Get class details
    - POST /api/classes/{id}/students - Add students
    - DELETE /api/classes/{id}/students/{studentId} - Remove student
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [ ] 7.2 Write property test for class ownership
    - **Property 9: Class Ownership**
    - **Validates: Requirements 3.1**
  - [ ] 7.3 Write property test for student removal preserves history
    - **Property 10: Student Removal Preserves History**
    - **Validates: Requirements 3.3**

- [ ] 8. Implement Question Bank (Backend)
  - [ ] 8.1 Create question CRUD endpoints
    - POST /api/questions - Create question
    - GET /api/questions - Search questions with filters
    - PUT /api/questions/{id} - Update question (versioning)
    - DELETE /api/questions/{id} - Soft delete
    - _Requirements: 4.1, 4.3, 4.4, 4.5_
  - [ ] 8.2 Implement question validation
    - Validate multiple-choice has 2+ options and 1 correct answer
    - Validate required fields (subject, chapter, level, type)
    - _Requirements: 4.2_
  - [ ] 8.3 Write property test for multiple choice validation
    - **Property 13: Multiple Choice Validation**
    - **Validates: Requirements 4.2**
  - [ ] 8.4 Write property test for question versioning
    - **Property 11: Question Versioning**
    - **Validates: Requirements 4.3**
  - [ ] 8.5 Write property test for question soft delete
    - **Property 12: Question Soft Delete**
    - **Validates: Requirements 4.5**

- [ ] 9. Checkpoint - User & Question Management
  - Ensure all tests pass, ask the user if questions arise.

## Phase 5: Exam Service Core

- [ ] 10. Implement Exam CRUD (Backend)
  - [ ] 10.1 Create database migrations for exam tables
    - Create exams table with state machine fields
    - Create exam_attempts table
    - Create attempt_answers table
    - _Requirements: 5.1, 6.1_
  - [ ] 10.2 Create exam CRUD endpoints
    - POST /api/exams - Create exam (DRAFT state)
    - GET /api/exams/{id} - Get exam details
    - PUT /api/exams/{id} - Update exam config
    - POST /api/exams/{id}/schedule - Schedule exam
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 14.1, 14.3_
  - [ ] 10.3 Write property test for exam config serialization round-trip
    - **Property 14: Exam Configuration Serialization Round-Trip**
    - **Validates: Requirements 5.4, 13.3, 13.4, 13.5**

- [ ] 11. Implement Exam State Machine (Backend)
  - [ ] 11.1 Create exam state transition logic
    - DRAFT → SCHEDULED (on schedule)
    - SCHEDULED → OPEN (on start_time)
    - OPEN → IN_PROGRESS (on first join)
    - IN_PROGRESS → CLOSED (on all done)
    - CLOSED → RESULT_PUBLISHED (on publish)
    - RESULT_PUBLISHED → ARCHIVED (on archive)
    - _Requirements: 14.1, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8_
  - [ ] 11.2 Write property test for exam state machine validity
    - **Property 25: Exam State Machine Validity**
    - **Validates: Requirements 14.1, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8**
  - [ ] 11.3 Create scheduled job for auto state transitions
    - Job to transition SCHEDULED → OPEN at start_time
    - _Requirements: 5.5, 14.4_

## Phase 6: Exam Taking Flow

- [ ] 12. Implement Exam Join & Question Generation (Backend)
  - [ ] 12.1 Create exam join endpoint
    - POST /api/exams/{id}/join - Join with password
    - Generate unique question set per student
    - Create exam_attempt record
    - _Requirements: 6.1, 7.1_
  - [ ] 12.2 Write property test for unique question set per student
    - **Property 15: Unique Question Set Per Student**
    - **Validates: Requirements 6.1, 7.1**
  - [ ] 12.3 Create get questions endpoint
    - GET /api/attempts/{id}/questions - Return questions without answers
    - _Requirements: 6.2_
  - [ ] 12.4 Write property test for questions without answers
    - **Property 16: Questions Without Answers**
    - **Validates: Requirements 6.2**

- [ ] 13. Implement Answer Submission (Backend)
  - [ ] 13.1 Create answer save endpoint
    - POST /api/attempts/{id}/answers - Save answer
    - Record timestamp for each answer
    - _Requirements: 6.3_
  - [ ] 13.2 Create submit endpoint
    - POST /api/attempts/{id}/submit - Manual submit
    - Calculate score using auto-grading
    - _Requirements: 6.5_
  - [ ] 13.3 Write property test for auto-grading correctness
    - **Property 18: Auto-Grading Correctness**
    - **Validates: Requirements 6.5, 8.1**
  - [ ] 13.4 Implement auto-submit on timeout
    - Scheduled job to auto-submit expired attempts
    - _Requirements: 6.6_
  - [ ] 13.5 Write property test for auto-submit on timeout
    - **Property 19: Auto-Submit on Timeout**
    - **Validates: Requirements 6.6**

- [ ] 14. Implement Attempt State Machine (Backend)
  - [ ] 14.1 Create attempt state transition logic
    - CREATED → IN_PROGRESS (on answer)
    - IN_PROGRESS → SYNC_PENDING (offline)
    - SYNC_PENDING → IN_PROGRESS (sync complete)
    - IN_PROGRESS → SUBMITTED (manual submit)
    - IN_PROGRESS → AUTO_SUBMITTED (timeout)
    - SUBMITTED/AUTO_SUBMITTED → INVALIDATED (flagged)
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_
  - [ ] 14.2 Write property test for attempt state machine validity
    - **Property 26: Attempt State Machine Validity**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6**

- [ ] 15. Checkpoint - Exam Core Flow
  - Ensure all tests pass, ask the user if questions arise.

## Phase 7: Mobile Exam Taking

- [ ] 16. Implement Exam Flow in Flutter
  - [ ] 16.1 Create exam list and join screens
    - Display available exams
    - Password input for joining
    - _Requirements: 6.1_
  - [ ] 16.2 Create exam taking screen
    - Display questions with navigation
    - Answer selection UI
    - Timer display
    - _Requirements: 6.2, 6.3_
  - [ ] 16.3 Implement local storage for offline support
    - Save answers to SQLite every 10 seconds
    - Queue answers for sync
    - _Requirements: 6.3, 6.4, 12.2_
  - [ ] 16.4 Write property test for offline sync consistency
    - **Property 17: Offline Sync Consistency**
    - **Validates: Requirements 6.4, 12.3**
  - [ ] 16.5 Implement sync service
    - Sync queued answers when online
    - Conflict resolution by timestamp
    - _Requirements: 12.5_
  - [ ] 16.6 Write property test for conflict resolution
    - **Property 34: Conflict Resolution by Timestamp**
    - **Validates: Requirements 12.5**

- [ ] 17. Implement Time Synchronization
  - [ ] 17.1 Create server time sync endpoint (Backend)
    - GET /api/time - Return server timestamp
    - _Requirements: 16.1, 16.2_
  - [ ] 17.2 Implement time sync in Flutter
    - Calculate time offset from server
    - Use server time for countdown
    - Recalculate on reconnection
    - _Requirements: 16.1, 16.2, 16.3, 16.5_
  - [ ] 17.3 Write property test for server-authoritative time
    - **Property 27: Server-Authoritative Time**
    - **Validates: Requirements 16.1, 16.2, 16.5**

## Phase 8: Anti-Cheating & Security

- [ ] 18. Implement Anti-Cheating Measures (Backend)
  - [ ] 18.1 Create activity logging endpoint
    - POST /api/attempts/{id}/activity - Log suspicious activity
    - Record app switch, time manipulation
    - _Requirements: 7.3, 7.5_
  - [ ] 18.2 Write property test for suspicious activity logging
    - **Property 21: Suspicious Activity Logging**
    - **Validates: Requirements 7.3, 7.5**
  - [ ] 18.3 Implement concurrent login detection
    - Terminate first session on second login during exam
    - Log incident
    - _Requirements: 7.4_
  - [ ] 18.4 Write property test for concurrent login termination
    - **Property 20: Concurrent Login Termination**
    - **Validates: Requirements 7.4**

- [ ] 19. Implement Anti-Cheating in Flutter
  - [ ] 19.1 Implement exam mode restrictions
    - Lock screen rotation
    - Disable system navigation (Android)
    - _Requirements: 12.4_
  - [ ] 19.2 Implement app lifecycle monitoring
    - Detect app background/foreground
    - Log to backend
    - _Requirements: 7.3_

- [ ] 20. Checkpoint - Exam Taking Complete
  - Ensure all tests pass, ask the user if questions arise.

## Phase 9: Score Management

- [ ] 21. Implement Score Management (Backend)
  - [ ] 21.1 Implement attempt limit enforcement
    - Check max_attempts before allowing join
    - _Requirements: 17.1, 17.2, 17.4_
  - [ ] 21.2 Write property test for attempt limit enforcement
    - **Property 28: Attempt Limit Enforcement**
    - **Validates: Requirements 17.1, 17.2, 17.4**
  - [ ] 21.3 Implement multi-attempt score calculation
    - Calculate final score based on method (highest, latest, average)
    - _Requirements: 17.3, 17.5_
  - [ ] 21.4 Write property test for multi-attempt score calculation
    - **Property 29: Multi-Attempt Score Calculation**
    - **Validates: Requirements 17.3**
  - [ ] 21.5 Implement score modification workflow
    - POST /api/score-modifications - Request modification
    - POST /api/score-modifications/{id}/approve - Approve (4-level)
    - _Requirements: 8.2, 8.3_
  - [ ] 21.6 Write property test for score modification workflow
    - **Property 22: Score Modification Workflow**
    - **Validates: Requirements 8.2, 8.3**
  - [ ] 21.7 Implement results publication
    - POST /api/exams/{id}/publish - Publish results
    - Check 100% submission or timeout
    - _Requirements: 8.4, 8.5_
  - [ ] 21.8 Write property test for results publication prerequisites
    - **Property 23: Results Publication Prerequisites**
    - **Validates: Requirements 8.4**

## Phase 10: Notifications

- [ ] 22. Implement Notification Service (Backend)
  - [ ] 22.1 Create notification infrastructure
    - Create notifications table migration
    - Implement notification service
    - _Requirements: 18.1, 18.2, 18.3, 18.5_
  - [ ] 22.2 Implement notification triggers
    - Exam scheduled notification
    - Results published notification
    - Suspicious activity alert
    - Class enrollment notification
    - _Requirements: 18.1, 18.2, 18.3, 18.5_
  - [ ] 22.3 Implement retry logic
    - Retry failed notifications up to 3 times
    - Exponential backoff
    - _Requirements: 18.4_
  - [ ] 22.4 Write property test for notification retry logic
    - **Property 30: Notification Retry Logic**
    - **Validates: Requirements 18.4**

- [ ] 23. Implement Push Notifications in Flutter
  - [ ] 23.1 Configure Firebase Cloud Messaging
    - Set up FCM for Android and iOS
    - Handle notification tokens
    - _Requirements: 18.1_
  - [ ] 23.2 Implement notification handling
    - Display notifications
    - Navigate to relevant screens
    - _Requirements: 18.2_

## Phase 11: File Upload & Reports

- [ ] 24. Implement File Upload (Backend)
  - [ ] 24.1 Create file upload endpoint
    - POST /api/attempts/{attemptId}/questions/{questionId}/files
    - Validate file type (PDF, JPG, PNG)
    - Validate file size (max 10MB)
    - _Requirements: 19.1, 19.2, 19.3_
  - [ ] 24.2 Write property test for file upload validation
    - **Property 31: File Upload Validation**
    - **Validates: Requirements 19.1, 19.2**
  - [ ] 24.3 Implement file access with RBAC
    - GET /api/files/{id} - Download with permission check
    - _Requirements: 19.4_
  - [ ] 24.4 Write property test for file access RBAC
    - **Property 32: File Access RBAC**
    - **Validates: Requirements 19.4**

- [ ] 25. Implement Report Service (Backend)
  - [ ] 25.1 Create report generation endpoints
    - POST /api/reports/class/{classId}/exam/{examId}
    - Support PDF and CSV formats
    - _Requirements: 20.1, 20.5_
  - [ ] 25.2 Implement async processing for large datasets
    - Queue reports > 1000 records
    - Notify on completion
    - _Requirements: 20.3_
  - [ ] 25.3 Implement RBAC scoping for reports
    - Limit data to authorized scope
    - _Requirements: 20.4_
  - [ ] 25.4 Write property test for report RBAC scoping
    - **Property 33: Report RBAC Scoping**
    - **Validates: Requirements 20.4**

- [ ] 26. Checkpoint - File & Reports
  - Ensure all tests pass, ask the user if questions arise.

## Phase 12: Parent Portal

- [ ] 27. Implement Parent Features (Backend)
  - [ ] 27.1 Create parent dashboard endpoints
    - GET /api/parent/students - Get linked students
    - GET /api/parent/students/{id}/results - Get exam results
    - GET /api/parent/students/{id}/progress - Get learning progress
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 28. Implement Parent Features in Flutter
  - [ ] 28.1 Create parent dashboard screen
    - Display linked students
    - Show exam results with ranking
    - Show progress trends
    - _Requirements: 9.1, 9.2, 9.3_

## Phase 13: Feature Flags & Configuration

- [ ] 29. Implement Feature Flags (Backend)
  - [ ] 29.1 Create feature flag system
    - Store flags in database/config
    - API to toggle flags
    - _Requirements: 21.3_
  - [ ] 29.2 Write property test for feature flag toggle
    - **Property 35: Feature Flag Toggle**
    - **Validates: Requirements 21.3**
  - [ ] 29.3 Implement configuration change logging
    - Log all config changes to audit log
    - _Requirements: 21.5_

## Phase 14: Teacher & Admin Web Interfaces

- [ ] 30. Implement Teacher Web Dashboard
  - [ ] 30.1 Create class management UI
    - List classes, add/remove students
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [ ] 30.2 Create question bank UI
    - CRUD questions with rich editor
    - Search and filter
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  - [ ] 30.3 Create exam management UI
    - Create/edit exams
    - Configure question criteria
    - View results and statistics
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 8.4, 8.5_

- [ ] 31. Implement Admin Web Dashboard
  - [ ] 31.1 Create user management UI
    - CRUD users, CSV import
    - Parent-student linking
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [ ] 31.2 Create audit log viewer
    - Search and filter logs
    - Export functionality
    - _Requirements: 10.1, 10.3_
  - [ ] 31.3 Create system configuration UI
    - Feature flags management
    - Environment settings
    - _Requirements: 21.3_

- [ ] 32. Final Checkpoint - All Tests Pass
  - Ensure all tests pass, ask the user if questions arise.
