/**
 * Admin Dashboard API Functions
 * Handles all API calls for the admin dashboard
 */

// Use relative URL when running through nginx proxy, absolute when running directly
// Check if we're running through the nginx proxy (port 8080) or directly
const IS_PROXIED = window.location.port === '8080';
const API_BASE_URL = IS_PROXIED ? '/api' : 'http://localhost:5000/api';

console.log('========== API Configuration ==========');
console.log('Current location:', window.location.href);
console.log('Is proxied:', IS_PROXIED);
console.log('API Base URL:', API_BASE_URL);
console.log('=======================================');

// Get JWT token from localStorage
function getToken() {
    return localStorage.getItem('authToken');
}

// Get dashboard statistics
async function getDashboardStats() {
    try {
        const token = getToken();
        
        console.log('========== getDashboardStats ==========');
        console.log('Starting fetch...');
        console.log('API URL:', `${API_BASE_URL}/admin/dashboard/stats`);
        console.log('Token exists:', !!token);
        console.log('Token (first 50 chars):', token ? token.substring(0, 50) + '...' : 'NO TOKEN');
        console.log('Token length:', token ? token.length : 0);
        console.log('=========================================');
        
        if (!token) {
            throw new Error('No authentication token found. Please login again.');
        }
        
        const response = await fetch(`${API_BASE_URL}/admin/dashboard/stats`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('========== API Response ==========');
        console.log('Response status:', response.status);
        console.log('Response ok:', response.ok);
        console.log('Response statusText:', response.statusText);
        console.log('==================================');
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('========== API ERROR ==========');
            console.error('Status:', response.status);
            console.error('Error response:', errorText);
            console.error('===============================');
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }
        
        const data = await response.json();
        console.log('getDashboardStats: Success!', data);
        return data;
    } catch (error) {
        console.error('========== getDashboardStats ERROR ==========');
        console.error('Exception caught:', error);
        console.error('Error message:', error.message);
        console.error('Error type:', error.constructor.name);
        
        // Check if this is a network error
        if (error.message === 'Failed to fetch' || error.name === 'TypeError') {
            console.error('');
            console.error('🔴 NETWORK ERROR DETECTED!');
            console.error('This usually means:');
            console.error('  1. The backend server is not running on ' + API_BASE_URL);
            console.error('  2. There is a CORS (Cross-Origin) issue');
            console.error('  3. The backend is not accessible from the frontend');
            console.error('');
            console.error('SOLUTION:');
            console.error('  - Make sure the backend is running: docker-compose up backend');
            console.error('  - Or start it manually: cd backend && python run.py');
            console.error('  - Check that backend is accessible at: ' + API_BASE_URL);
            console.error('');
        }
        
        console.error('=============================================');
        throw error;
    }
}

// Get all professors
async function getAllProfessors() {
    try {
        const token = getToken();
        
        console.log('========== getAllProfessors ==========');
        console.log('Starting fetch...');
        console.log('Token exists:', !!token);
        console.log('======================================');
        
        if (!token) {
            throw new Error('No authentication token found. Please login again.');
        }
        
        const response = await fetch(`${API_BASE_URL}/admin/professors`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('getAllProfessors: Response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('getAllProfessors: Error response:', errorText);
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }
        
        const data = await response.json();
        console.log('getAllProfessors: Success!', data);
        return data;
    } catch (error) {
        console.error('getAllProfessors: Exception caught:', error);
        throw error;
    }
}

// Get all students
async function getAllStudents() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/students`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${getToken()}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to fetch students');
        }
        
        return await response.json();
    } catch (error) {
        console.error('Error fetching students:', error);
        throw error;
    }
}

// Get all users
async function getAllUsers(roleFilter = 'all') {
    try {
        const token = getToken();
        if (!token) {
            throw new Error('No authentication token found');
        }
        
        console.log('Fetching all users with role filter:', roleFilter);
        const url = roleFilter !== 'all' 
            ? `${API_BASE_URL}/admin/users?role=${roleFilter}`
            : `${API_BASE_URL}/admin/users`;
            
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || `HTTP error ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Users loaded:', data);
        
        // If we need professor_ids, get them from the professors endpoint
        if (data.users && data.users.some(u => u.role === 'professor')) {
            try {
                const profResponse = await fetch(`${API_BASE_URL}/admin/professors`, {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });
                if (profResponse.ok) {
                    const profData = await profResponse.json();
                    // Map professor_id to users
                    data.users.forEach(user => {
                        if (user.role === 'professor') {
                            const prof = profData.professors.find(p => p.user_id === user.id);
                            if (prof) {
                                user.professor_id = prof.id;
                            }
                        }
                    });
                }
            } catch (e) {
                console.warn('Could not fetch professor data:', e);
            }
        }
        
        return data;
    } catch (error) {
        console.error('Error fetching users:', error);
        throw error;
    }
}

// Get all subjects
async function getAllSubjects() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/subjects`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${getToken()}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to fetch subjects');
        }
        
        return await response.json();
    } catch (error) {
        console.error('Error fetching subjects:', error);
        throw error;
    }
}

// Create a new user
async function createUser(userData) {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/users/create`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${getToken()}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Failed to create user');
        }
        
        return data;
    } catch (error) {
        console.error('Error creating user:', error);
        throw error;
    }
}

// Load dashboard data on page load
async function loadDashboardData() {
    try {
        // Show loading state
        showLoading(true);
        
        // Fetch all data in parallel
        const [statsData, professorsData, studentsData, subjectsData] = await Promise.all([
            getDashboardStats(),
            getAllProfessors(),
            getAllStudents(),
            getAllSubjects()
        ]);
        
        // Update dashboard with data
        updateDashboardStats(statsData.stats);
        updateRecentActivities(statsData.recent_activities || []);
        updateProfessorsTable(professorsData.professors || []);
        updateStudentsTable(studentsData.students || []);
        updateSubjectsTable(subjectsData.subjects || []);
        
        console.log('Dashboard data loaded successfully');
        
    } catch (error) {
        console.error('Error loading dashboard data:', error);
        
        // Check if it's an auth error
        if (error.message.includes('401') || error.message.includes('403')) {
            alert('Sesión expirada. Por favor, inicia sesión nuevamente.');
            window.location.href = '/login.html';
        } else {
            alert('Error al cargar los datos del dashboard. Intenta recargar la página.');
        }
    } finally {
        showLoading(false);
    }
}

// Update dashboard statistics
function updateDashboardStats(stats) {
    // Update stat cards if they exist
    const elements = {
        'total-users': stats.total_users,
        'total-students': stats.total_students,
        'total-professors': stats.total_professors,
        'total-admins': stats.total_admins,
        'total-subjects': stats.total_subjects,
        'total-groups': stats.total_groups,
        'total-surveys': stats.total_surveys,
        'completed-surveys': stats.completed_surveys,
        'pending-surveys': stats.pending_surveys
    };
    
    for (const [id, value] of Object.entries(elements)) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }
}

// Update recent activities
function updateRecentActivities(activities) {
    const container = document.getElementById('recent-activities');
    if (!container) return;
    
    if (activities.length === 0) {
        container.innerHTML = '<p class="text-gray-500 text-center py-4">No hay actividades recientes</p>';
        return;
    }
    
    container.innerHTML = activities.map(activity => `
        <div class="border-b border-gray-200 py-3 last:border-0">
            <div class="flex justify-between items-start">
                <div>
                    <span class="inline-block px-2 py-1 text-xs font-semibold rounded ${getRoleBadgeClass(activity.user_type)}">
                        ${activity.user_type}
                    </span>
                    <p class="text-sm text-gray-700 mt-1">${activity.description}</p>
                </div>
                <span class="text-xs text-gray-500">
                    ${formatDateTime(activity.created_at)}
                </span>
            </div>
        </div>
    `).join('');
}

// Update professors table
function updateProfessorsTable(professors) {
    const tbody = document.getElementById('professors-table-body');
    if (!tbody) return;
    
    if (professors.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-gray-500">No hay profesores registrados</td></tr>';
        return;
    }
    
    tbody.innerHTML = professors.map(prof => `
        <tr class="hover:bg-gray-50">
            <td class="px-4 py-3">${escapeHtml(prof.name)}</td>
            <td class="px-4 py-3">${escapeHtml(prof.email)}</td>
            <td class="px-4 py-3">${escapeHtml(prof.department || 'N/A')}</td>
            <td class="px-4 py-3">${prof.average_rating.toFixed(2)} ⭐</td>
            <td class="px-4 py-3">${prof.total_ratings}</td>
            <td class="px-4 py-3">
                <span class="inline-block px-2 py-1 text-xs font-semibold rounded ${prof.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                    ${prof.is_active ? 'Activo' : 'Inactivo'}
                </span>
            </td>
        </tr>
    `).join('');
}

// Update students table
function updateStudentsTable(students) {
    const tbody = document.getElementById('students-table-body');
    if (!tbody) return;
    
    if (students.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-gray-500">No hay estudiantes registrados</td></tr>';
        return;
    }
    
    tbody.innerHTML = students.map(student => `
        <tr class="hover:bg-gray-50">
            <td class="px-4 py-3">${escapeHtml(student.matricula)}</td>
            <td class="px-4 py-3">${escapeHtml(student.name)}</td>
            <td class="px-4 py-3">${student.semester || 'N/A'}</td>
            <td class="px-4 py-3">${escapeHtml(student.career || 'N/A')}</td>
            <td class="px-4 py-3">${escapeHtml(student.group || 'N/A')}</td>
            <td class="px-4 py-3">
                <span class="inline-block px-2 py-1 text-xs font-semibold rounded ${student.has_completed_survey ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">
                    ${student.has_completed_survey ? 'Completada' : 'Pendiente'}
                </span>
            </td>
        </tr>
    `).join('');
}

// Update subjects table
function updateSubjectsTable(subjects) {
    const tbody = document.getElementById('subjects-table-body');
    if (!tbody) return;
    
    if (subjects.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-gray-500">No hay materias registradas</td></tr>';
        return;
    }
    
    tbody.innerHTML = subjects.map(subject => `
        <tr class="hover:bg-gray-50">
            <td class="px-4 py-3">${escapeHtml(subject.code)}</td>
            <td class="px-4 py-3">${escapeHtml(subject.name)}</td>
            <td class="px-4 py-3">${escapeHtml(subject.professor || 'Sin asignar')}</td>
            <td class="px-4 py-3">${subject.semester || 'N/A'}</td>
            <td class="px-4 py-3">${subject.total_groups}</td>
            <td class="px-4 py-3">
                <span class="inline-block px-2 py-1 text-xs font-semibold rounded ${subject.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                    ${subject.is_active ? 'Activo' : 'Inactivo'}
                </span>
            </td>
        </tr>
    `).join('');
}

// Helper functions
function showLoading(isLoading) {
    const loader = document.getElementById('loading-overlay');
    if (loader) {
        loader.style.display = isLoading ? 'flex' : 'none';
    }
    document.body.style.cursor = isLoading ? 'wait' : 'default';
}

function getRoleBadgeClass(role) {
    const classes = {
        'admin': 'bg-purple-100 text-purple-800',
        'professor': 'bg-blue-100 text-blue-800',
        'student': 'bg-green-100 text-green-800'
    };
    return classes[role] || 'bg-gray-100 text-gray-800';
}

function formatDateTime(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleString('es-MX', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}

// Check if user is logged in and is admin
function checkAdminAuth() {
    const token = getToken();
    const userStr = localStorage.getItem('currentUser'); // Fixed: was 'user', should be 'currentUser'
    
    console.log('checkAdminAuth() called');
    console.log('  Token:', token ? 'EXISTS' : 'MISSING');
    console.log('  User data:', userStr ? 'EXISTS' : 'MISSING');
    
    if (!token || !userStr) {
        console.error('❌ Auth check failed - redirecting to login');
        console.error('  Token:', !!token);
        console.error('  User:', !!userStr);
        window.location.href = '/login.html';
        return false;
    }
    
    try {
        const user = JSON.parse(userStr);
        if (user.role !== 'admin') {
            alert('Acceso denegado. Solo administradores pueden acceder a esta página.');
            window.location.href = '/login.html';
            return false;
        }
        
        // Update admin name in header if element exists
        const adminNameElement = document.getElementById('admin-name');
        if (adminNameElement) {
            adminNameElement.textContent = user.name || user.email;
        }
        
        return true;
    } catch (error) {
        console.error('Error parsing user data:', error);
        // Delay redirect by 10 seconds to give time for debugging/inspection
        setTimeout(() => {
            console.warn('Redirecting to login page after 10s delay due to parse error.');
            window.location.href = '/login.html';
        }, 10000);
        return false;
    }
}

// DISABLED - This was causing immediate redirects
// The HTML file handles auth checking and data loading instead
// Initialize dashboard on page load
// document.addEventListener('DOMContentLoaded', function() {
//     // Check authentication first
//     if (checkAdminAuth()) {
//         // Load dashboard data
//         loadDashboardData();
//     }
// });

// AdminAPI object for easier access
const AdminAPI = {
    getDashboardStats,
    getAllUsers,
    createUser,
    getAllProfessors,
    getAllStudents,
    getAllSubjects,
    checkAdminAuth,
    escapeHtml,
    getToken,
    
    // New methods for subjects and groups
    async createSubject(subjectData) {
        try {
            const token = getToken();
            if (!token) {
                throw new Error('No authentication token found');
            }
            
            console.log('Creating subject with data:', subjectData);
            const response = await fetch(`${API_BASE_URL}/admin/subjects`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(subjectData)
            });
            
            console.log('Create subject response status:', response.status);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || `HTTP error ${response.status}`);
            }
            
            const data = await response.json();
            console.log('Subject created:', data);
            return data;
        } catch (error) {
            console.error('Error creating subject:', error);
            throw error;
        }
    },
    
    async getAllGroups() {
        try {
            const token = getToken();
            if (!token) {
                throw new Error('No authentication token found');
            }
            
            console.log('Fetching all groups...');
            const response = await fetch(`${API_BASE_URL}/admin/groups`, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('Groups response status:', response.status);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || `HTTP error ${response.status}`);
            }
            
            const data = await response.json();
            console.log('Groups loaded:', data);
            return data;
        } catch (error) {
            console.error('Error fetching groups:', error);
            throw error;
        }
    },
    
    async updateSubject(subjectId, subjectData) {
        try {
            const token = getToken();
            if (!token) {
                throw new Error('No authentication token found');
            }
            
            console.log(`Updating subject ${subjectId} with data:`, subjectData);
            const response = await fetch(`${API_BASE_URL}/admin/subjects/${subjectId}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(subjectData)
            });
            
            console.log('Update subject response status:', response.status);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || `HTTP error ${response.status}`);
            }
            
            const data = await response.json();
            console.log('Subject updated:', data);
            return data;
        } catch (error) {
            console.error('Error updating subject:', error);
            throw error;
        }
    },
    
    async createGroup(groupData) {
        try {
            const token = getToken();
            if (!token) {
                throw new Error('No authentication token found');
            }
            
            console.log('Creating group with data:', groupData);
            const response = await fetch(`${API_BASE_URL}/admin/groups`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(groupData)
            });
            
            console.log('Create group response status:', response.status);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || `HTTP error ${response.status}`);
            }
            
            const data = await response.json();
            console.log('Group created:', data);
            return data;
        } catch (error) {
            console.error('Error creating group:', error);
            throw error;
        }
    }
};
