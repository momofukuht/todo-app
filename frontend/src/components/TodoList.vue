<template>
  <div class="todo-app">
    <!-- サイドバー広告 -->
    <aside class="sidebar">
      <AdUnit position="sidebar" />
    </aside>

    <main class="main-content">
      <h1>QuickTodo</h1>
      
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

        <!-- バナー広告 -->
        <AdUnit position="banner" />

        <div v-if="editingTodo" class="modal">
          <div class="modal-content">
            <h3>Todoを編集</h3>
            <input v-model="editingTodo.title" @keyup.enter="saveEdit" />
            <button @click="saveEdit">保存</button>
            <button @click="cancelEdit">キャンセル</button>
          </div>
        </div>
      </div>

      <!-- フッター広告 -->
      <footer>
        <AdUnit position="footer" />
      </footer>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { todoApi } from '../services/api.js'
import AdUnit from './AdUnit.vue'

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
.todo-app {
  display: flex;
  min-height: 100vh;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.sidebar {
  width: 300px;
  padding-right: 20px;
  flex-shrink: 0;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

h1 {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
}

.add-todo {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.add-todo input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

button {
  padding: 10px 20px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

button:hover {
  background: #45a049;
}

.todos {
  background: #f9f9f9;
  border-radius: 8px;
  padding: 10px;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  background: white;
  margin-bottom: 8px;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.todo-item input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.todo-item span {
  flex: 1;
  font-size: 16px;
}

.completed {
  text-decoration: line-through;
  color: #999;
}

.error {
  color: red;
  padding: 10px;
  background: #fee;
  border-radius: 4px;
  margin-bottom: 10px;
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
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 8px;
  min-width: 300px;
}

.modal-content h3 {
  margin-top: 0;
  margin-bottom: 15px;
}

.modal-content input {
  width: 100%;
  padding: 10px;
  margin-bottom: 15px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
}

.modal-content button {
  margin-right: 10px;
}

footer {
  margin-top: auto;
  padding-top: 20px;
}

/* モバイル対応 */
@media (max-width: 768px) {
  .todo-app {
    flex-direction: column;
    padding: 10px;
  }
  
  .sidebar {
    width: 100%;
    padding-right: 0;
    padding-bottom: 20px;
  }
  
  .add-todo {
    flex-direction: column;
  }
  
  .todo-item {
    flex-wrap: wrap;
  }
  
  .todo-item span {
    width: 100%;
    margin: 5px 0;
  }
}
</style>
