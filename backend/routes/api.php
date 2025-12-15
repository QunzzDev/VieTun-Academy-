<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group.
|
*/

// Authentication routes
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('auth:api');
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:api');
});

// Protected routes (require authentication)
Route::middleware('auth:api')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
});

// RBAC protected routes - for testing and actual use
Route::middleware(['auth:api'])->group(function () {
    // Admin-only routes
    Route::middleware('role:ADMIN_SYSTEM,ADMIN_SCHOOL')->group(function () {
        Route::get('/admin/dashboard', function () {
            return response()->json(['message' => 'Admin dashboard']);
        });
    });
    
    // Teacher routes
    Route::middleware('role:ADMIN_SYSTEM,ADMIN_SCHOOL,TEACHER')->group(function () {
        Route::get('/teacher/classes', function () {
            return response()->json(['message' => 'Teacher classes']);
        });
    });
    
    // Student routes
    Route::middleware('role:STUDENT')->group(function () {
        Route::get('/student/exams', function () {
            return response()->json(['message' => 'Student exams']);
        });
    });
    
    // Parent routes
    Route::middleware('role:PARENT')->group(function () {
        Route::get('/parent/children', function () {
            return response()->json(['message' => 'Parent children']);
        });
    });
});
