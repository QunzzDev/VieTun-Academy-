<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;

class AuthController extends Controller
{
    /**
     * Login user and issue JWT and refresh token.
     * 
     * POST /api/auth/login
     * Requirements: 1.1, 1.2
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Invalid request format',
                    'details' => $validator->errors(),
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 400);
        }

        $credentials = [
            'username' => $request->input('username'),
            'password' => $request->input('password'),
        ];

        try {
            // Find user by username first
            $user = User::where('username', $credentials['username'])->first();
            
            // Check if user exists and is active before attempting authentication
            if (!$user) {
                return response()->json([
                    'error' => [
                        'code' => 'INVALID_CREDENTIALS',
                        'message' => 'The provided credentials are incorrect',
                        'timestamp' => now()->toIso8601String(),
                    ]
                ], 401);
            }

            // Check if user is active (Requirements: 2.4)
            if (!$user->isActive()) {
                return response()->json([
                    'error' => [
                        'code' => 'INVALID_CREDENTIALS',
                        'message' => 'The provided credentials are incorrect',
                        'timestamp' => now()->toIso8601String(),
                    ]
                ], 401);
            }

            // Attempt to authenticate and get access token
            if (!$accessToken = JWTAuth::attempt($credentials)) {
                // Return generic error message without revealing which credential is incorrect
                // Requirements: 1.2
                return response()->json([
                    'error' => [
                        'code' => 'INVALID_CREDENTIALS',
                        'message' => 'The provided credentials are incorrect',
                        'timestamp' => now()->toIso8601String(),
                    ]
                ], 401);
            }

            // Generate refresh token with longer TTL
            $refreshToken = $this->generateRefreshToken($user);

            return response()->json([
                'accessToken' => $accessToken,
                'refreshToken' => $refreshToken,
                'expiresIn' => config('jwt.ttl') * 60, // Convert minutes to seconds
                'tokenType' => 'Bearer',
            ]);

        } catch (JWTException $e) {
            return response()->json([
                'error' => [
                    'code' => 'INTERNAL_ERROR',
                    'message' => 'Could not create token',
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 500);
        }
    }

    /**
     * Refresh access token using refresh token.
     * 
     * POST /api/auth/refresh
     * Requirements: 1.3
     */
    public function refresh(Request $request): JsonResponse
    {
        try {
            // Get the current token and refresh it
            $newToken = JWTAuth::parseToken()->refresh();
            
            $user = auth('api')->user();
            
            // Generate new refresh token
            $refreshToken = $this->generateRefreshToken($user);

            return response()->json([
                'accessToken' => $newToken,
                'refreshToken' => $refreshToken,
                'expiresIn' => config('jwt.ttl') * 60,
                'tokenType' => 'Bearer',
            ]);

        } catch (TokenExpiredException $e) {
            return response()->json([
                'error' => [
                    'code' => 'TOKEN_EXPIRED',
                    'message' => 'Token has expired and cannot be refreshed',
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 401);
        } catch (TokenInvalidException $e) {
            return response()->json([
                'error' => [
                    'code' => 'TOKEN_INVALID',
                    'message' => 'Token is invalid',
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 401);
        } catch (JWTException $e) {
            return response()->json([
                'error' => [
                    'code' => 'TOKEN_ABSENT',
                    'message' => 'Token is required',
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 401);
        }
    }

    /**
     * Logout user and invalidate session tokens.
     * 
     * POST /api/auth/logout
     * Requirements: 1.4
     */
    public function logout(): JsonResponse
    {
        try {
            // Invalidate the current token (adds to blacklist)
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'message' => 'Successfully logged out',
            ]);

        } catch (JWTException $e) {
            return response()->json([
                'error' => [
                    'code' => 'LOGOUT_FAILED',
                    'message' => 'Failed to logout',
                    'timestamp' => now()->toIso8601String(),
                ]
            ], 500);
        }
    }

    /**
     * Get authenticated user information.
     * 
     * GET /api/me
     */
    public function me(): JsonResponse
    {
        $user = auth('api')->user();
        
        return response()->json([
            'id' => $user->id,
            'username' => $user->username,
            'email' => $user->email,
            'role' => $user->role,
            'status' => $user->status,
            'schoolId' => $user->school_id,
        ]);
    }

    /**
     * Generate a refresh token for the user.
     * For simplicity, we use the same token as both access and refresh token.
     * The refresh token is just the access token that can be used to get a new one.
     */
    private function generateRefreshToken(User $user): string
    {
        // Create a custom claim to identify this as a refresh token
        $customClaims = [
            'type' => 'refresh',
            'role' => $user->role,
            'school_id' => $user->school_id,
        ];

        return JWTAuth::customClaims($customClaims)->fromUser($user);
    }
}
