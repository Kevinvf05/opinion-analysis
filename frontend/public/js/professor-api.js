/**
 * Professor API Service
 * Handles all API calls for professor operations
 */

// Use relative URL when running through nginx proxy
const IS_PROXIED = window.location.port === '8080';
const API_BASE_URL = IS_PROXIED ? '/api' : 'http://localhost:5000/api';

console.log('========== Professor API Configuration ==========');
console.log('Current location:', window.location.href);
console.log('Is proxied:', IS_PROXIED);
console.log('API Base URL:', API_BASE_URL);
console.log('===============================================');

/**
 * Helper function to get auth token from localStorage
 */
function getAuthToken() {
    return localStorage.getItem('authToken');
}

/**
 * Helper function to get current user from localStorage
 */
function getCurrentUser() {
    const userStr = localStorage.getItem('currentUser');
    return userStr ? JSON.parse(userStr) : null;
}

/**
 * Helper function to handle API errors and redirect to login if unauthorized
 */
function handleAPIError(error, response) {
    if (response && response.status === 401) {
        console.error('Unauthorized - redirecting to login');
        localStorage.removeItem('authToken');
        localStorage.removeItem('currentUser');
        window.location.href = '/login.html';
    }
    throw error;
}

const ProfessorAPI = {
    /**
     * Get dashboard statistics for the professor
     * @returns {Promise<Object>} Dashboard stats including subjects, groups, students, satisfaction, sentiment breakdown, recent comments
     */
    async getDashboardStats() {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            const response = await fetch(`${API_BASE_URL}/professor/dashboard`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                handleAPIError(new Error(errorData.error || 'Failed to fetch dashboard stats'), response);
            }
            
            const data = await response.json();
            console.log('Dashboard stats loaded:', data);
            return data;
            
        } catch (error) {
            console.error('Error fetching dashboard stats:', error);
            throw error;
        }
    },

    /**
     * Get all subjects taught by the professor with groups and stats
     * @returns {Promise<Object>} Subjects data with groups and sentiment stats
     */
    async getSubjects() {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            const response = await fetch(`${API_BASE_URL}/professor/subjects`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                handleAPIError(new Error(errorData.error || 'Failed to fetch subjects'), response);
            }
            
            const data = await response.json();
            console.log('Subjects loaded:', data);
            return data;
            
        } catch (error) {
            console.error('Error fetching subjects:', error);
            throw error;
        }
    },

    /**
     * Get professor profile information
     * @returns {Promise<Object>} Profile data including personal info and stats
     */
    async getProfile() {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            const response = await fetch(`${API_BASE_URL}/professor/profile`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                handleAPIError(new Error(errorData.error || 'Failed to fetch profile'), response);
            }
            
            const data = await response.json();
            console.log('Profile loaded:', data);
            return data;
            
        } catch (error) {
            console.error('Error fetching profile:', error);
            throw error;
        }
    },

    /**
     * Update professor profile information
     * @param {Object} profileData - Profile data to update (first_name, last_name, phone, department, office, specialization)
     * @returns {Promise<Object>} Updated profile data
     */
    async updateProfile(profileData) {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            const response = await fetch(`${API_BASE_URL}/professor/profile`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(profileData)
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                handleAPIError(new Error(errorData.error || 'Failed to update profile'), response);
            }
            
            const data = await response.json();
            console.log('✅ Profile updated:', data);
            
            // Update localStorage with new user data
            const currentUser = getCurrentUser();
            if (currentUser) {
                currentUser.first_name = data.profile.first_name;
                currentUser.last_name = data.profile.last_name;
                localStorage.setItem('currentUser', JSON.stringify(currentUser));
            }
            
            return data;
            
        } catch (error) {
            console.error('Error updating profile:', error);
            throw error;
        }
    },

    /**
     * Change professor password
     * @param {Object} passwordData - Object with current_password and new_password
     * @returns {Promise<Object>} Success message
     */
    async changePassword(passwordData) {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            console.log('Changing password with data:', { current_password: '***', new_password: '***' });
            
            const response = await fetch(`${API_BASE_URL}/professor/password`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(passwordData)
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to change password');
            }
            
            const data = await response.json();
            console.log('✅ Password changed successfully');
            return data;
            
        } catch (error) {
            console.error('Error changing password:', error);
            throw error;
        }
    },

    /**
     * Logout - clear local storage and redirect to login
     */
    logout() {
        localStorage.removeItem('authToken');
        localStorage.removeItem('currentUser');
        window.location.href = '/login.html';
    }
};
