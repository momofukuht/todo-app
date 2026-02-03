<template>
  <div class="todo-app">
    <h1>Todo App</h1>
    <TodoList />
  </div>
</template>

<script setup>
import TodoList from './components/TodoList.vue'
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
  background-color: #f5f5f5;
}

.todo-app {
  max-width: 600px;
  margin: 50px auto;
  padding: 20px;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
}
</style>
