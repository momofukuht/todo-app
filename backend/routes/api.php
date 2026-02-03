<?php

use App\Http\Controllers\TodoController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json(['message' => 'Todo API is running']);
});

Route::apiResource('todos', TodoController::class);
