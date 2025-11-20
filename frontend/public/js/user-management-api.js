/**
 * User Management API Functions
 * Handles all API calls for user management (CRUD operations)
 */

// Use relative URL when running through nginx proxy, absolute when running directly
const IS_PROXIED = window.location.port === '8080';
const API_BASE_URL = IS_PROXIED ? '/api' : 'http://localhost:5000/api';

console.log('========== User Management API Configuration ==========');
console.log('Current location:', window.location.href);
console.log('Is proxied:', IS_PROXIED);
console.log('API Base URL:', API_BASE_URL);
console.log('=======================================================');

// Get JWT token from localStorage
function getToken() {
    return localStorage.getItem('authToken');
}

/**
 * Get all users with optional filtering
 * @param {string} roleFilter - Filter by role: 'all', 'student', 'professor', 'admin'
 * @param {string} searchTerm - Search term for name, email, or matricula
 * @returns {Promise<Object>} Object containing users array and total count
 */
async function getAllUsers(roleFilter = 'all', searchTerm = '') {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        const params = new URLSearchParams();
        if (roleFilter !== 'all') {
            params.append('role', roleFilter);
        }
        if (searchTerm) {
            params.append('search', searchTerm);
        }
        
        const url = `${API_BASE_URL}/admin/users${params.toString() ? '?' + params.toString() : ''}`;
        console.log('Fetching users from:', url);
        
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Users fetched successfully:', data.total, 'users');
        return data;
        
    } catch (error) {
        console.error('Error fetching users:', error);
        throw error;
    }
}

/**
 * Update user information
 * @param {number} userId - The ID of the user to update
 * @param {Object} userData - Object containing fields to update
 * @returns {Promise<Object>} Updated user data
 */
async function updateUser(userId, userData) {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        console.log('Updating user:', userId, userData);
        
        const response = await fetch(`${API_BASE_URL}/admin/users/${userId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('User updated successfully:', data);
        return data;
        
    } catch (error) {
        console.error('Error updating user:', error);
        throw error;
    }
}

/**
 * Delete a user
 * @param {number} userId - The ID of the user to delete
 * @returns {Promise<Object>} Deletion confirmation
 */
async function deleteUser(userId) {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        console.log('Deleting user:', userId);
        
        const response = await fetch(`${API_BASE_URL}/admin/users/${userId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('User deleted successfully:', data);
        return data;
        
    } catch (error) {
        console.error('Error deleting user:', error);
        throw error;
    }
}

/**
 * Toggle user active status
 * @param {number} userId - The ID of the user
 * @param {boolean} currentStatus - Current active status
 * @returns {Promise<Object>} Updated user data
 */
async function toggleUserStatus(userId, currentStatus) {
    try {
        return await updateUser(userId, { is_active: !currentStatus });
    } catch (error) {
        console.error('Error toggling user status:', error);
        throw error;
    }
}

/**
 * Create a new user
 * @param {Object} userData - User data including role-specific fields
 * @returns {Promise<Object>} Created user data
 */
async function createUser(userData) {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        console.log('Creating user:', userData);
        
        const response = await fetch(`${API_BASE_URL}/admin/users/create`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('User created successfully:', data);
        return data;
        
    } catch (error) {
        console.error('Error creating user:', error);
        throw error;
    }
}

/**
 * Validate admin password (for sensitive operations)
 * This would normally validate against the backend
 * @param {string} password - Admin password to validate
 * @returns {Promise<boolean>} Whether password is valid
 */
async function validateAdminPassword(password) {
    // In a real application, this would make an API call to validate
    // For now, we'll let the backend handle validation during delete operations
    return password && password.length > 0;
}

/**
 * Update professor information
 * @param {number} professorId - The ID of the professor to update
 * @param {Object} professorData - Object containing fields to update
 * @returns {Promise<Object>} Updated professor data
 */
async function updateProfessor(professorId, professorData) {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        console.log('Updating professor:', professorId, professorData);
        
        const response = await fetch(`${API_BASE_URL}/admin/professors/${professorId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(professorData)
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Professor updated successfully:', data);
        return data;
        
    } catch (error) {
        console.error('Error updating professor:', error);
        throw error;
    }
}

/**
 * Get all professors
 * @returns {Promise<Object>} Object containing professors array and total count
 */
async function getAllProfessorsForManagement() {
    try {
        const token = getToken();
        
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        const response = await fetch(`${API_BASE_URL}/admin/professors`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Professors fetched successfully:', data.total, 'professors');
        return data;
        
    } catch (error) {
        console.error('Error fetching professors:', error);
        throw error;
    }
}
