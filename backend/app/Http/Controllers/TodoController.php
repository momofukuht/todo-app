<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TodoController extends Controller
{
    public function index(): JsonResponse
    {
        $todos = Todo::orderBy('created_at', 'desc')->get();
        return response()->json($todos);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
        ]);

        $todo = Todo::create([
            'title' => $validated['title'],
            'completed' => false,
        ]);

        return response()->json($todo, 201);
    }

    public function show(Todo $todo): JsonResponse
    {
        return response()->json($todo);
    }

    public function update(Request $request, Todo $todo): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'completed' => 'sometimes|boolean',
        ]);

        $todo->update($validated);

        return response()->json($todo);
    }

    public function destroy(Todo $todo): JsonResponse
    {
        $todo->delete();
        return response()->json(null, 204);
    }
}
