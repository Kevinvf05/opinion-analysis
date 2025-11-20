import api from './api';

export const getAdminStats = async () => {
  const response = await api.get('/dashboard/admin/stats');
  return response.data;
};

export const getAllProfessorsRatings = async () => {
  const response = await api.get('/dashboard/admin/professors/ratings');
  return response.data;
};

export const getProfessorRatings = async (professorId) => {
  const response = await api.get(`/dashboard/admin/professor/${professorId}/ratings`);
  return response.data;
};

export const getAllUsers = async (page = 1, perPage = 10, role = null) => {
  const params = { page, per_page: perPage };
  if (role) params.role = role;
  const response = await api.get('/users', { params });
  return response.data;
};

export const createUser = async (userData) => {
  const response = await api.post('/users', userData);
  return response.data;
};

export const updateUser = async (userId, userData) => {
  const response = await api.put(`/users/${userId}`, userData);
  return response.data;
};

export const deleteUser = async (userId, password = null) => {
  const config = password ? {
    data: { password }
  } : {};
  
  const response = await api.delete(`/users/${userId}`, config);
  return response.data;
};

export const deactivateUser = async (userId) => {
  const response = await api.put(`/users/${userId}/deactivate`);
  return response.data;
};

export const getAdminCount = async () => {
  const response = await api.get('/users?role=admin');
  return response.data.total;
};
