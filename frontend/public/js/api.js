/**
 * API Configuration and Utility Functions
 * Simple API client for the UAEM Evaluation System
 */

// Use relative URL when running through nginx proxy
const IS_PROXIED = window.location.port === '8080';

const API_CONFIG = {
    baseURL: IS_PROXIED ? '/api' : 'http://localhost:5000/api',
    timeout: 10000
};

/**
 * Get authentication token from localStorage
 */
function getToken() {
    return localStorage.getItem('token');
}

/**
 * Get current user from localStorage
 */
function getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
}

/**
 * Check if user is authenticated
 */
function isAuthenticated() {
    return !!getToken();
}

/**
 * Clear authentication data
 */
function clearAuth() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
}

/**
 * Make authenticated API request
 */
async function apiRequest(endpoint, options = {}) {
    const url = `${API_CONFIG.baseURL}${endpoint}`;
    const token = getToken();
    
    const headers = {
        'Content-Type': 'application/json',
        ...(options.headers || {})
    };
    
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }
    
    const config = {
        ...options,
        headers
    };
    
    try {
        const response = await fetch(url, config);
        const data = await response.json();
        
        if (!response.ok) {
            // Handle authentication errors
            if (response.status === 401) {
                clearAuth();
                window.location.href = '/login.html';
                throw new Error('Session expired. Please login again.');
            }
            
            throw new Error(data.error || `HTTP Error ${response.status}`);
        }
        
        return data;
    } catch (error) {
        console.error('API Request Error:', error);
        throw error;
    }
}

/**
 * API Methods
 */
const API = {
    auth: {
        login: (credentials) => apiRequest('/auth/login', {
            method: 'POST',
            body: JSON.stringify(credentials)
        }),
        
        getCurrentUser: () => apiRequest('/auth/me', {
            method: 'GET'
        }),
        
        logout: () => {
            clearAuth();
            window.location.href = '/login.html';
        }
    },
    
    health: {
        check: () => apiRequest('/health', {
            method: 'GET'
        })
    }
};

/**
 * Protect page - redirect to login if not authenticated
 */
function requireAuth() {
    if (!isAuthenticated()) {
        window.location.href = '/login.html';
        return false;
    }
    return true;
}

/**
 * Require specific role(s)
 * Valid roles: 'student', 'professor', 'admin'
 */
function requireRole(...roles) {
    if (!requireAuth()) return false;
    
    const user = getCurrentUser();
    if (!user || !roles.includes(user.role)) {
        alert('No tienes permisos para acceder a esta página');
        window.location.href = '/index.html';
        return false;
    }
    return true;
}
