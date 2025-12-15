# Requirements Document

## Introduction

Nền tảng ôn thi - thi thử - quản lý học tập trực tuyến là hệ thống số thống nhất phục vụ việc ôn tập, thi thử, kiểm tra định kỳ và quản lý học sinh, giáo viên, phụ huynh. Hệ thống đảm bảo công bằng, minh bạch và an toàn dữ liệu, hỗ trợ chuyển đổi số giáo dục theo chủ trương của Chính phủ và Bộ GD&ĐT.

## Glossary

- **Platform**: Nền tảng ôn thi - thi thử - quản lý học tập trực tuyến
- **Student**: Học sinh sử dụng hệ thống để ôn tập và làm bài thi
- **Teacher**: Giáo viên tạo đề thi, quản lý lớp học và chấm điểm
- **Parent**: Phụ huynh theo dõi tiến trình học tập của con
- **Admin_School**: Quản trị viên cấp trường
- **Admin_System**: Quản trị viên hệ thống
- **Exam**: Bài thi/kiểm tra trực tuyến
- **Exam_Attempt**: Lượt làm bài của học sinh
- **Question_Set**: Bộ câu hỏi được random cho mỗi học sinh
- **Audit_Log**: Nhật ký ghi lại mọi hoạt động trong hệ thống
- **RBAC**: Role-Based Access Control - Phân quyền dựa trên vai trò

## Requirements

### Requirement 1: Authentication & Authorization

**User Story:** As a user, I want to securely log in to the platform with my credentials, so that I can access features appropriate to my role.

#### Acceptance Criteria

1. WHEN a user submits valid credentials THEN the Platform SHALL issue a JWT token and refresh token within 2 seconds
2. WHEN a user submits invalid credentials THEN the Platform SHALL reject the login attempt and return an error message without revealing which credential is incorrect
3. WHEN a JWT token expires THEN the Platform SHALL allow token refresh using a valid refresh token
4. WHEN a user logs out THEN the Platform SHALL invalidate the current session tokens
5. WHILE a user is authenticated THEN the Platform SHALL enforce RBAC permissions on every API request

### Requirement 2: User Management

**User Story:** As an Admin_School, I want to manage users (students, teachers, parents) in my school, so that I can maintain accurate user records.

#### Acceptance Criteria

1. WHEN an Admin_School creates a new user THEN the Platform SHALL generate a unique user ID and store user information with hashed password
2. WHEN an Admin_School imports users via CSV THEN the Platform SHALL validate data format and create accounts for valid entries
3. WHEN an Admin_School links a Parent to a Student THEN the Platform SHALL establish the relationship and grant Parent view access to that Student's data
4. WHEN an Admin_School deactivates a user THEN the Platform SHALL set user status to inactive and prevent future logins
5. WHEN a user profile is updated THEN the Platform SHALL record the change in Audit_Log

### Requirement 3: Class Management

**User Story:** As a Teacher, I want to manage my classes and enrolled students, so that I can organize teaching and assessment activities.

#### Acceptance Criteria

1. WHEN a Teacher creates a class THEN the Platform SHALL generate a unique class ID and associate the Teacher as owner
2. WHEN a Teacher adds students to a class THEN the Platform SHALL validate student existence and create class enrollment records
3. WHEN a Teacher removes a student from a class THEN the Platform SHALL update enrollment status while preserving historical exam data
4. WHEN a Teacher views class details THEN the Platform SHALL display enrolled students and associated exam statistics

### Requirement 4: Question Bank Management

**User Story:** As a Teacher, I want to create and manage questions in a question bank, so that I can build exams efficiently.

#### Acceptance Criteria

1. WHEN a Teacher creates a question THEN the Platform SHALL store question content, type, subject, chapter, difficulty level, and correct answer
2. WHEN a Teacher specifies question type as multiple-choice THEN the Platform SHALL require at least 2 answer options and exactly one correct answer
3. WHEN a Teacher updates a question THEN the Platform SHALL create a new version while preserving the original for historical exam integrity
4. WHEN a Teacher searches questions THEN the Platform SHALL filter by subject, chapter, level, and type within 1 second for up to 10000 questions
5. WHEN a Teacher deletes a question THEN the Platform SHALL soft-delete and exclude from future exams while preserving historical references

### Requirement 5: Exam Creation & Configuration

**User Story:** As a Teacher, I want to create and configure exams with specific parameters, so that I can conduct assessments according to my requirements.

#### Acceptance Criteria

1. WHEN a Teacher creates an exam THEN the Platform SHALL require class assignment, start time, duration, and question selection criteria
2. WHEN a Teacher sets exam password THEN the Platform SHALL require password_open for joining and password_view for viewing results
3. WHEN a Teacher configures random question generation THEN the Platform SHALL accept criteria for subject, chapter, level distribution
4. WHEN a Teacher saves exam configuration THEN the Platform SHALL validate all required fields and store in config_json format
5. WHEN exam start_time is reached THEN the Platform SHALL make the exam available for students to join

### Requirement 6: Exam Taking (Student)

**User Story:** As a Student, I want to take exams online with protection against network issues, so that I can complete assessments reliably.

#### Acceptance Criteria

1. WHEN a Student joins an exam with correct password THEN the Platform SHALL generate a unique Question_Set and create an Exam_Attempt record
2. WHEN a Student receives questions THEN the Platform SHALL display questions without revealing correct answers
3. WHILE a Student is taking an exam THEN the Platform SHALL auto-save answers locally every 10 seconds
4. WHEN network connection is lost during exam THEN the Platform SHALL continue allowing answer input and sync when connection restores
5. WHEN a Student submits an exam THEN the Platform SHALL record submission time and calculate score using auto-grading
6. WHEN exam duration expires THEN the Platform SHALL auto-submit the current answers and prevent further modifications

### Requirement 7: Anti-Cheating Measures

**User Story:** As a Teacher, I want the platform to prevent cheating during exams, so that assessment results are fair and reliable.

#### Acceptance Criteria

1. WHEN generating Question_Set for each Student THEN the Platform SHALL randomize question order and answer order
2. WHEN a Student attempts to take screenshot on mobile THEN the Platform SHALL block the action on Android devices
3. WHEN a Student switches to another app during exam THEN the Platform SHALL log the event with timestamp and duration
4. WHEN the same account logs in from a second device during exam THEN the Platform SHALL terminate the first session and log the incident
5. WHEN any suspicious activity is detected THEN the Platform SHALL record details in Audit_Log for Teacher review

### Requirement 8: Score Management

**User Story:** As a Teacher, I want to view and manage exam scores with proper approval workflow, so that score integrity is maintained.

#### Acceptance Criteria

1. WHEN an exam is completed THEN the Platform SHALL auto-grade objective questions and calculate total score
2. WHEN a Teacher requests score modification THEN the Platform SHALL require 4-level approval workflow before applying changes
3. WHEN score modification is approved THEN the Platform SHALL update score and record full audit trail including approvers
4. WHEN results are ready for publication THEN the Platform SHALL require either 100% submission or timeout before allowing Teacher to publish
5. WHEN results are published THEN the Platform SHALL notify Students and Parents with view access

### Requirement 9: Parent Monitoring

**User Story:** As a Parent, I want to view my child's learning progress and exam results, so that I can support their education.

#### Acceptance Criteria

1. WHEN a Parent logs in THEN the Platform SHALL display only data for linked Student accounts
2. WHEN a Parent views exam results THEN the Platform SHALL show score, submission time, and class ranking
3. WHEN a Parent views learning progress THEN the Platform SHALL display historical scores and trend analysis
4. WHEN new exam results are published THEN the Platform SHALL send notification to linked Parent accounts

### Requirement 10: Audit & Security

**User Story:** As an Admin_System, I want comprehensive audit logging and security controls, so that the platform maintains data integrity and compliance.

#### Acceptance Criteria

1. WHEN any data modification occurs THEN the Platform SHALL record actor_id, action, data_json, and timestamp in Audit_Log
2. WHEN a user attempts unauthorized access THEN the Platform SHALL deny the request and log the attempt
3. WHEN audit logs are queried THEN the Platform SHALL prevent modification or deletion of log entries
4. WHEN sensitive data is accessed THEN the Platform SHALL encrypt data in transit and at rest
5. WHEN backup is scheduled THEN the Platform SHALL create encrypted backup and verify integrity

### Requirement 11: System Performance

**User Story:** As an Admin_System, I want the platform to handle high concurrent load, so that exams can run smoothly for thousands of students.

#### Acceptance Criteria

1. WHEN multiple exams run simultaneously THEN the Platform SHALL support at least 5000 concurrent exam sessions
2. WHEN API requests are made THEN the Platform SHALL respond within 500ms for 95th percentile under normal load
3. WHEN Exam Service experiences high load THEN the Platform SHALL scale independently from other services
4. WHEN system resources are monitored THEN the Platform SHALL alert administrators when thresholds are exceeded

### Requirement 12: Mobile Application

**User Story:** As a Student, I want to use a mobile app for taking exams, so that I can participate from any location with offline support.

#### Acceptance Criteria

1. WHEN a Student opens the mobile app THEN the Platform SHALL provide the same exam functionality as web interface
2. WHEN a Student starts an exam on mobile THEN the Platform SHALL download questions for offline access
3. WHEN mobile device loses network THEN the Platform SHALL continue exam with local storage and sync upon reconnection
4. WHEN mobile app is in exam mode THEN the Platform SHALL lock screen rotation and disable system navigation
5. WHEN exam answers are synced THEN the Platform SHALL resolve conflicts using latest timestamp

### Requirement 13: Data Serialization & API

**User Story:** As a Developer, I want consistent data serialization across all API endpoints, so that web and mobile clients can integrate reliably.

#### Acceptance Criteria

1. WHEN API returns data THEN the Platform SHALL serialize responses in JSON format with consistent field naming
2. WHEN API receives requests THEN the Platform SHALL validate and parse JSON request bodies against defined schemas
3. WHEN serializing exam configuration THEN the Platform SHALL encode config_json with all exam parameters
4. WHEN serializing question data THEN the Platform SHALL encode content_json and answers_json preserving structure
5. WHEN deserializing stored data THEN the Platform SHALL reconstruct objects with full fidelity to original structure

### Requirement 14: Exam Lifecycle & State Management

**User Story:** As a Teacher, I want exams to follow a clear lifecycle with defined states, so that exam availability and visibility are controlled predictably.

#### Acceptance Criteria

1. WHEN an exam is created THEN the Platform SHALL set initial state to DRAFT
2. WHILE exam is in DRAFT state THEN the Platform SHALL hide the exam from Students
3. WHEN exam is scheduled with valid start_time THEN the Platform SHALL transition state to SCHEDULED
4. WHEN exam start_time is reached THEN the Platform SHALL transition state to OPEN automatically
5. WHEN at least one Student joins an OPEN exam THEN the Platform SHALL transition state to IN_PROGRESS
6. WHEN exam duration expires for all attempts THEN the Platform SHALL transition state to CLOSED
7. WHEN Teacher publishes results for a CLOSED exam THEN the Platform SHALL transition state to RESULT_PUBLISHED
8. WHEN Admin archives an exam THEN the Platform SHALL transition state to ARCHIVED and make exam read-only

### Requirement 15: Exam_Attempt Lifecycle

**User Story:** As a Student, I want my exam attempt to have clear states, so that I understand my progress and submission status.

#### Acceptance Criteria

1. WHEN a Student joins an exam THEN the Platform SHALL create Exam_Attempt with state CREATED
2. WHEN a Student answers at least one question THEN the Platform SHALL transition attempt state to IN_PROGRESS
3. WHEN offline answers exist and network is unavailable THEN the Platform SHALL set attempt state to SYNC_PENDING
4. WHEN a Student manually submits THEN the Platform SHALL transition attempt state to SUBMITTED
5. WHEN exam duration expires without manual submission THEN the Platform SHALL transition attempt state to AUTO_SUBMITTED
6. WHEN suspicious activity is confirmed by Teacher THEN the Platform SHALL allow transition to INVALIDATED state

### Requirement 16: Time Synchronization

**User Story:** As a Student, I want exam timing to be accurate and tamper-proof, so that all students have equal time regardless of device clock.

#### Acceptance Criteria

1. WHEN a Student starts an exam THEN the Platform SHALL calculate countdown based on server time
2. WHEN client time differs from server time by more than 5 seconds THEN the Platform SHALL use server time as authoritative
3. WHILE offline mode is active THEN the Platform SHALL continue countdown locally and validate remaining time on sync
4. WHEN time manipulation is detected THEN the Platform SHALL flag the attempt in Audit_Log with manipulation details
5. WHEN Student reconnects after offline period THEN the Platform SHALL recalculate remaining time from server

### Requirement 17: Retake & Attempt Limits

**User Story:** As a Teacher, I want to control how many times students can attempt an exam, so that I can configure assessments appropriately.

#### Acceptance Criteria

1. WHEN exam is configured with single attempt THEN the Platform SHALL prevent Student from rejoining after submission
2. WHEN exam is configured with multiple attempts THEN the Platform SHALL enforce max_attempts limit per Student
3. WHEN multiple attempts exist for a Student THEN the Platform SHALL calculate final score based on configured method (highest, latest, or average)
4. WHEN a Student reaches max_attempts THEN the Platform SHALL display appropriate message and prevent new attempts
5. WHEN Teacher views results THEN the Platform SHALL display all attempts with individual scores and final calculated score

### Requirement 18: Notification System

**User Story:** As a user, I want to receive timely notifications about exam events, so that I stay informed about important activities.

#### Acceptance Criteria

1. WHEN an exam is scheduled THEN the Platform SHALL send notification to enrolled Students
2. WHEN exam results are published THEN the Platform SHALL notify Students and linked Parents
3. WHEN suspicious activity is logged THEN the Platform SHALL alert the responsible Teacher
4. WHEN notification delivery fails THEN the Platform SHALL retry delivery up to 3 times with exponential backoff
5. WHEN a Student is added to a class THEN the Platform SHALL send welcome notification with class details

### Requirement 19: File Upload & Storage

**User Story:** As a Student, I want to upload file answers for essay questions, so that I can submit handwritten or document-based responses.

#### Acceptance Criteria

1. WHEN a Student uploads a file answer THEN the Platform SHALL validate file type against allowed extensions (PDF, JPG, PNG)
2. WHEN a Student uploads a file THEN the Platform SHALL enforce maximum file size of 10MB per file
3. WHEN a file is stored THEN the Platform SHALL link it to the specific Exam_Attempt and question
4. WHEN a file is accessed THEN the Platform SHALL enforce RBAC permissions before serving
5. WHEN an exam is archived THEN the Platform SHALL retain uploaded files in read-only mode

### Requirement 20: Reporting & Export

**User Story:** As a Teacher or Admin, I want to generate reports and export data, so that I can analyze results and fulfill administrative requirements.

#### Acceptance Criteria

1. WHEN a Teacher requests class report THEN the Platform SHALL generate PDF or CSV with scores and statistics
2. WHEN an Admin_School exports data THEN the Platform SHALL include audit metadata and timestamps
3. WHEN exporting datasets larger than 1000 records THEN the Platform SHALL process asynchronously and notify on completion
4. WHEN generating reports THEN the Platform SHALL apply RBAC to limit data to authorized scope
5. WHEN report is generated THEN the Platform SHALL include generation timestamp and requesting user

### Requirement 21: Environment & Configuration

**User Story:** As an Admin_System, I want the platform to support multiple environments and secure configuration, so that deployment and operations are manageable.

#### Acceptance Criteria

1. WHEN deploying the Platform THEN the system SHALL support separate environments (development, staging, production)
2. WHEN storing sensitive configuration THEN the Platform SHALL use secure storage with encryption
3. WHEN enabling feature flags THEN the Platform SHALL allow enabling or disabling exam features without redeployment
4. WHEN environment variables are missing THEN the Platform SHALL fail startup with clear error message
5. WHEN configuration changes are applied THEN the Platform SHALL log the change in Audit_Log
