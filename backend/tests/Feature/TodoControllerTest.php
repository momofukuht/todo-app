<?php

namespace Tests\Feature;

use App\Models\Todo;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TodoControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_get_all_todos(): void
    {
        Todo::factory()->count(3)->create();

        $response = $this->getJson('/api/todos');

        $response->assertStatus(200)
            ->assertJsonCount(3);
    }

    public function test_can_create_todo(): void
    {
        $data = ['title' => 'Test Todo'];

        $response = $this->postJson('/api/todos', $data);

        $response->assertStatus(201)
            ->assertJsonFragment(['title' => 'Test Todo']);
        
        $this->assertDatabaseHas('todos', ['title' => 'Test Todo']);
    }

    public function test_can_update_todo(): void
    {
        $todo = Todo::factory()->create(['title' => 'Old Title']);

        $response = $this->putJson("/api/todos/{$todo->id}", [
            'title' => 'New Title'
        ]);

        $response->assertStatus(200)
            ->assertJsonFragment(['title' => 'New Title']);
    }

    public function test_can_delete_todo(): void
    {
        $todo = Todo::factory()->create();

        $response = $this->deleteJson("/api/todos/{$todo->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('todos', ['id' => $todo->id]);
    }

    public function test_validation_fails_without_title(): void
    {
        $response = $this->postJson('/api/todos', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }
}
