import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

export const todoApi = {
  getAll() {
    return api.get('/todos')
  },
  
  getById(id) {
    return api.get(`/todos/${id}`)
  },
  
  create(title) {
    return api.post('/todos', { title })
  },
  
  update(id, data) {
    return api.put(`/todos/${id}`, data)
  },
  
  delete(id) {
    return api.delete(`/todos/${id}`)
  }
}

export default api
