<?php

/**
 * Feature: online-exam-platform, Property 24: Audit Log Immutability
 * Validates: Requirements 10.3
 * 
 * For any audit log entry, modification or deletion should be prevented.
 * 
 * NOTE: This test requires PHP 8.2+ to run. The property being tested is:
 * "For any audit log entry, modification or deletion should be prevented."
 */

use App\Exceptions\AuditLogImmutableException;
use App\Models\AuditLog;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;

uses(RefreshDatabase::class);

/**
 * Property 24: Audit Log Immutability - Update Prevention
 * 
 * For any audit log entry, updates to any field should throw an exception.
 * This property test generates random audit log entries and verifies that
 * modifications are prevented.
 */
test('audit log entries cannot be modified', function () {
    // Generate random audit log data
    $actions = ['CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'VIEW'];
    $resourceTypes = ['User', 'Student', 'Teacher', 'Exam', 'Question', 'Class'];
    
    // Run property test with multiple random inputs (100 iterations)
    for ($i = 0; $i < 100; $i++) {
        $originalData = [
            'actor_id' => null,
            'action' => $actions[array_rand($actions)],
            'resource_type' => $resourceTypes[array_rand($resourceTypes)],
            'resource_id' => Str::uuid()->toString(),
            'data_json' => [
                'field' => 'value_' . Str::random(10),
                'number' => rand(1, 1000),
            ],
            'ip_address' => rand(1, 255) . '.' . rand(0, 255) . '.' . rand(0, 255) . '.' . rand(0, 255),
            'created_at' => now(),
        ];

        // Create the audit log entry
        $auditLog = AuditLog::create($originalData);
        
        // Store original values for comparison
        $originalAction = $auditLog->action;
        $originalResourceType = $auditLog->resource_type;
        $originalResourceId = $auditLog->resource_id;
        $originalDataJson = $auditLog->data_json;
        
        // Attempt to modify the audit log - should throw exception
        $auditLog->action = 'MODIFIED_ACTION';
        
        $exceptionThrown = false;
        try {
            $auditLog->save();
        } catch (AuditLogImmutableException $e) {
            $exceptionThrown = true;
        }
        
        expect($exceptionThrown)->toBeTrue('Update should throw AuditLogImmutableException');
        
        // Refresh from database and verify data is unchanged
        $auditLog->refresh();
        expect($auditLog->action)->toBe($originalAction);
        expect($auditLog->resource_type)->toBe($originalResourceType);
        expect($auditLog->resource_id)->toBe($originalResourceId);
        expect($auditLog->data_json)->toBe($originalDataJson);
    }
});

/**
 * Property 24: Audit Log Immutability - Delete Prevention
 * 
 * For any audit log entry, deletion should throw an exception.
 */
test('audit log entries cannot be deleted', function () {
    $actions = ['CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'VIEW'];
    $resourceTypes = ['User', 'Student', 'Teacher', 'Exam', 'Question', 'Class'];
    
    // Run property test with multiple random inputs (100 iterations)
    for ($i = 0; $i < 100; $i++) {
        $originalData = [
            'actor_id' => null,
            'action' => $actions[array_rand($actions)],
            'resource_type' => $resourceTypes[array_rand($resourceTypes)],
            'resource_id' => Str::uuid()->toString(),
            'data_json' => [
                'field' => 'value_' . Str::random(10),
                'number' => rand(1, 1000),
            ],
            'ip_address' => rand(1, 255) . '.' . rand(0, 255) . '.' . rand(0, 255) . '.' . rand(0, 255),
            'created_at' => now(),
        ];

        // Create the audit log entry
        $auditLog = AuditLog::create($originalData);
        $auditLogId = $auditLog->id;
        
        // Attempt to delete the audit log - should throw exception
        $exceptionThrown = false;
        try {
            $auditLog->delete();
        } catch (AuditLogImmutableException $e) {
            $exceptionThrown = true;
        }
        
        expect($exceptionThrown)->toBeTrue('Delete should throw AuditLogImmutableException');
        
        // Verify the record still exists in database
        $existingLog = AuditLog::find($auditLogId);
        expect($existingLog)->not->toBeNull('Audit log should still exist after failed delete');
        expect($existingLog->id)->toBe($auditLogId);
    }
});

/**
 * Property 24: Audit Log Immutability - Data Preservation
 * 
 * For any audit log entry, all original data should be preserved after
 * failed modification attempts.
 */
test('audit log entries preserve all original data after failed modification attempts', function () {
    // Run property test with multiple random inputs (100 iterations)
    for ($i = 0; $i < 100; $i++) {
        $originalData = [
            'actor_id' => null,
            'action' => 'ACTION_' . Str::random(5),
            'resource_type' => 'ResourceType_' . Str::random(5),
            'resource_id' => Str::uuid()->toString(),
            'data_json' => [
                'key1' => Str::random(20),
                'key2' => rand(1, 10000),
                'nested' => [
                    'a' => Str::random(10),
                    'b' => rand(1, 100),
                ],
            ],
            'ip_address' => rand(1, 255) . '.' . rand(0, 255) . '.' . rand(0, 255) . '.' . rand(0, 255),
            'created_at' => now(),
        ];

        // Create the audit log entry
        $auditLog = AuditLog::create($originalData);
        
        // Store all original values
        $originalValues = [
            'id' => $auditLog->id,
            'action' => $auditLog->action,
            'resource_type' => $auditLog->resource_type,
            'resource_id' => $auditLog->resource_id,
            'data_json' => $auditLog->data_json,
            'ip_address' => $auditLog->ip_address,
        ];
        
        // Attempt multiple modifications
        $modifications = [
            ['action', 'NEW_ACTION'],
            ['resource_type', 'NEW_TYPE'],
            ['ip_address', '999.999.999.999'],
        ];
        
        foreach ($modifications as [$field, $newValue]) {
            $auditLog->$field = $newValue;
            
            try {
                $auditLog->save();
            } catch (AuditLogImmutableException $e) {
                // Expected
            }
            
            // Refresh and verify all original values are preserved
            $auditLog->refresh();
            expect($auditLog->id)->toBe($originalValues['id']);
            expect($auditLog->action)->toBe($originalValues['action']);
            expect($auditLog->resource_type)->toBe($originalValues['resource_type']);
            expect($auditLog->resource_id)->toBe($originalValues['resource_id']);
            expect($auditLog->data_json)->toBe($originalValues['data_json']);
            expect($auditLog->ip_address)->toBe($originalValues['ip_address']);
        }
    }
});
