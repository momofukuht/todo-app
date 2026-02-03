<template>
  <div class="todo-list">
    <div class="add-todo">
      <input v-model="newTodoTitle" @keyup.enter="addTodo" placeholder="新しいTodoを入力..." />
      <button @click="addTodo">追加</button>
    </div>

    <div v-if="loading">読み込み中...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="todos.length === 0">Todoがありません</div>
    
    <div v-else class="todos">
      <div v-for="todo in todos" :key="todo.id" class="todo-item">
        <input type="checkbox" :checked="todo.completed" @change="toggleTodo(todo)" />
        <span :class="{ completed: todo.completed }">{{ todo.title }}</span>
        <button @click="startEdit(todo)">編集</button>
        <button @click="deleteTodo(todo.id)">削除</button>
      </div>
    </div>

    <div v-if="editingTodo" class="modal">
      <div class="modal-content">
        <h3>Todoを編集</h3>
        <input v-model="editingTodo.title" @keyup.enter="saveEdit" />
        <button @click="saveEdit">保存</button>
        <button @click="cancelEdit">キャンセル</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { todoApi } from '../services/api.js'

const todos = ref([])
const newTodoTitle = ref('')
const loading = ref(false)
const error = ref(null)
const editingTodo = ref(null)

const fetchTodos = async () => {
  loading.value = true
  try {
    const response = await todoApi.getAll()
    todos.value = response.data
  } catch (err) {
    error.value = '取得に失敗しました'
  } finally {
    loading.value = false
  }
}

const addTodo = async () => {
  if (!newTodoTitle.value.trim()) return
  try {
    const response = await todoApi.create(newTodoTitle.value.trim())
    todos.value.unshift(response.data)
    newTodoTitle.value = ''
  } catch (err) {
    error.value = '追加に失敗しました'
  }
}

const toggleTodo = async (todo) => {
  try {
    const response = await todoApi.update(todo.id, { completed: !todo.completed })
    const index = todos.value.findIndex(t => t.id === todo.id)
    if (index !== -1) todos.value[index] = response.data
  } catch (err) {
    error.value = '更新に失敗しました'
  }
}

const startEdit = (todo) => {
  editingTodo.value = { ...todo }
}

const saveEdit = async () => {
  if (!editingTodo.value.title.trim()) return
  try {
    const response = await todoApi.update(editingTodo.value.id, { title: editingTodo.value.title.trim() })
    const index = todos.value.findIndex(t => t.id === editingTodo.value.id)
    if (index !== -1) todos.value[index] = response.data
    editingTodo.value = null
  } catch (err) {
    error.value = '更新に失敗しました'
  }
}

const cancelEdit = () => {
  editingTodo.value = null
}

const deleteTodo = async (id) => {
  if (!confirm('削除しますか？')) return
  try {
    await todoApi.delete(id)
    todos.value = todos.value.filter(t => t.id !== id)
  } catch (err) {
    error.value = '削除に失敗しました'
  }
}

onMounted(fetchTodos)
</script>

<style scoped>
.add-todo {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

input {
  flex: 1;
  padding: 8px;
}

button {
  padding: 8px 16px;
  cursor: pointer;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border-bottom: 1px solid #eee;
}

.completed {
  text-decoration: line-through;
  color: #999;
}

.error {
  color: red;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
}
</style>
