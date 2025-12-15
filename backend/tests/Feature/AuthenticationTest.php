<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;
use Tymon\JWTAuth\Facades\JWTAuth;

/**
 * Feature: online-exam-platform, Property 1: Authentication Token Round-Trip
 * Validates: Requirements 1.1, 1.3
 * 
 * For any valid user credentials, logging in should return valid JWT and refresh tokens,
 * and using the refresh token should return a new valid access token.
 */
class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Feature: online-exam-platform, Property 1: Authentication Token Round-Trip
     * Validates: Requirements 1.1, 1.3
     * 
     * Property-based test: For any valid user with random credentials,
     * login should return valid tokens and refresh should work.
     */
    public function test_authentication_round_trip_property(): void
    {
        // Generate random test data for property-based testing
        $iterations = 100;
        
        for ($i = 0; $i < $iterations; $i++) {
            // Generate random credentials
            $username = 'user_' . fake()->unique()->userName() . '_' . $i;
            $password = fake()->password(8, 20);
            $role = fake()->randomElement(['ADMIN_SYSTEM', 'ADMIN_SCHOOL', 'TEACHER', 'STUDENT', 'PARENT']);
            
            // Create user with known password
            $user = User::create([
                'username' => $username,
                'email' => fake()->unique()->safeEmail(),
                'password' => Hash::make($password),
                'role' => $role,
                'status' => 'ACTIVE',
            ]);

            // Step 1: Login should return valid tokens
            $loginResponse = $this->postJson('/api/auth/login', [
                'username' => $username,
                'password' => $password,
            ]);

            $loginResponse->assertStatus(200)
                ->assertJsonStructure([
                    'accessToken',
                    'refreshToken',
                    'expiresIn',
                    'tokenType',
                ]);

            $accessToken = $loginResponse->json('accessToken');
            $refreshToken = $loginResponse->json('refreshToken');

            // Verify access token is valid
            $this->assertNotEmpty($accessToken);
            $this->assertNotEmpty($refreshToken);

            // Step 2: Access token should work for authenticated requests
            $meResponse = $this->call(
                'GET',
                '/api/me',
                [],
                [],
                [],
                ['HTTP_AUTHORIZATION' => 'Bearer ' . $accessToken]
            );

            $meResponse->assertStatus(200)
                ->assertJson([
                    'id' => $user->id,
                    'username' => $username,
                    'role' => $role,
                ]);

            // Step 3: Refresh token should return new valid access token
            $refreshResponse = $this->call(
                'POST',
                '/api/auth/refresh',
                [],
                [],
                [],
                ['HTTP_AUTHORIZATION' => 'Bearer ' . $accessToken]
            );

            $refreshResponse->assertStatus(200)
                ->assertJsonStructure([
                    'accessToken',
                    'refreshToken',
                    'expiresIn',
                    'tokenType',
                ]);

            $newAccessToken = $refreshResponse->json('accessToken');
            
            // Verify new access token is different from old one
            $this->assertNotEquals($accessToken, $newAccessToken);

            // Step 4: New access token should work
            $newMeResponse = $this->call(
                'GET',
                '/api/me',
                [],
                [],
                [],
                ['HTTP_AUTHORIZATION' => 'Bearer ' . $newAccessToken]
            );

            $newMeResponse->assertStatus(200)
                ->assertJson([
                    'id' => $user->id,
                    'username' => $username,
                ]);

            // Clean up for next iteration - logout to invalidate token
            $this->call(
                'POST',
                '/api/auth/logout',
                [],
                [],
                [],
                ['HTTP_AUTHORIZATION' => 'Bearer ' . $newAccessToken]
            );
            
            // Also invalidate the original access token
            try {
                JWTAuth::setToken($accessToken)->invalidate();
            } catch (\Exception $e) {
                // Token might already be invalidated
            }
            
            // Clear the JWT auth state
            JWTAuth::unsetToken();
            auth('api')->logout();
            
            // Delete user
            $user->delete();
        }
    }

    /**
     * Feature: online-exam-platform, Property 4: RBAC Enforcement
     * Validates: Requirements 1.5
     * 
     * Property-based test: For any authenticated user and any API endpoint,
     * the request should only succeed if the user's role has permission for that resource and action.
     */
    public function test_rbac_enforcement_property(): void
    {
        // Define role-route mappings for testing
        $roleRouteTests = [
            // Admin routes - should be accessible by ADMIN_SYSTEM and ADMIN_SCHOOL
            [
                'route' => '/api/admin/dashboard',
                'allowed_roles' => ['ADMIN_SYSTEM', 'ADMIN_SCHOOL'],
                'denied_roles' => ['TEACHER', 'STUDENT', 'PARENT'],
            ],
            // Teacher routes - should be accessible by ADMIN_SYSTEM, ADMIN_SCHOOL, TEACHER
            [
                'route' => '/api/teacher/classes',
                'allowed_roles' => ['ADMIN_SYSTEM', 'ADMIN_SCHOOL', 'TEACHER'],
                'denied_roles' => ['STUDENT', 'PARENT'],
            ],
            // Student routes - should only be accessible by STUDENT
            [
                'route' => '/api/student/exams',
                'allowed_roles' => ['STUDENT'],
                'denied_roles' => ['ADMIN_SYSTEM', 'ADMIN_SCHOOL', 'TEACHER', 'PARENT'],
            ],
            // Parent routes - should only be accessible by PARENT
            [
                'route' => '/api/parent/children',
                'allowed_roles' => ['PARENT'],
                'denied_roles' => ['ADMIN_SYSTEM', 'ADMIN_SCHOOL', 'TEACHER', 'STUDENT'],
            ],
        ];

        $iterations = 100;
        
        for ($i = 0; $i < $iterations; $i++) {
            // Pick a random route test
            $routeTest = $roleRouteTests[array_rand($roleRouteTests)];
            
            // Pick a random role (either allowed or denied)
            $allRoles = array_merge($routeTest['allowed_roles'], $routeTest['denied_roles']);
            $role = $allRoles[array_rand($allRoles)];
            $shouldBeAllowed = in_array($role, $routeTest['allowed_roles']);
            
            // Generate random credentials
            $username = 'rbac_user_' . fake()->unique()->userName() . '_' . $i;
            $password = fake()->password(8, 20);
            
            // Create user with the selected role
            $user = User::create([
                'username' => $username,
                'email' => fake()->unique()->safeEmail(),
                'password' => Hash::make($password),
                'role' => $role,
                'status' => 'ACTIVE',
            ]);

            // Login to get token
            $loginResponse = $this->postJson('/api/auth/login', [
                'username' => $username,
                'password' => $password,
            ]);

            $accessToken = $loginResponse->json('accessToken');

            // Try to access the route
            $response = $this->call(
                'GET',
                $routeTest['route'],
                [],
                [],
                [],
                ['HTTP_AUTHORIZATION' => 'Bearer ' . $accessToken]
            );

            if ($shouldBeAllowed) {
                // Should get 200 OK
                $this->assertEquals(
                    200,
                    $response->status(),
                    "Role {$role} should have access to {$routeTest['route']}"
                );
            } else {
                // Should get 403 Forbidden
                $this->assertEquals(
                    403,
                    $response->status(),
                    "Role {$role} should NOT have access to {$routeTest['route']}"
                );
            }

            // Clean up
            try {
                JWTAuth::setToken($accessToken)->invalidate();
            } catch (\Exception $e) {
                // Token might already be invalidated
            }
            JWTAuth::unsetToken();
            auth('api')->logout();
            
            $user->delete();
        }
    }
}
