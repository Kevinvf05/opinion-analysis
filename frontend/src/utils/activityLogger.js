/**
 * Activity Logger Utility
 * Logs user actions to localStorage and syncs with backend
 */

const STORAGE_KEY = 'systemActivities';
const MAX_LOCAL_ACTIVITIES = 100;

export const ActivityTypes = {
  SURVEY_COMPLETED: 'survey_completed',
  USER_CREATED: 'user_created',
  USER_UPDATED: 'user_updated',
  USER_DELETED: 'user_deleted',
  PROFESSOR_UPDATED: 'professor_updated',
  SUBJECT_ASSIGNED: 'subject_assigned',
  LOGIN: 'login',
  LOGOUT: 'logout'
};

/**
 * Log an activity
 * @param {string} type - Activity type from ActivityTypes
 * @param {string} userName - Name of user performing action
 * @param {string} description - Description of the activity
 * @param {object} metadata - Additional metadata
 */
export const logActivity = (type, userName, description, metadata = {}) => {
  try {
    const activities = getActivities();
    
    const newActivity = {
      type,
      userName,
      description,
      timeAgo: 'Hace unos segundos',
      timestamp: new Date().toISOString(),
      metadata
    };
    
    activities.push(newActivity);
    
    // Keep only last MAX_LOCAL_ACTIVITIES
    if (activities.length > MAX_LOCAL_ACTIVITIES) {
      activities.splice(0, activities.length - MAX_LOCAL_ACTIVITIES);
    }
    
    localStorage.setItem(STORAGE_KEY, JSON.stringify(activities));
    
    // Dispatch custom event for real-time updates
    window.dispatchEvent(new CustomEvent('activityLogged', { detail: newActivity }));
    
    return newActivity;
  } catch (error) {
    console.error('Error logging activity:', error);
    return null;
  }
};

/**
 * Get all activities from localStorage
 * @returns {Array} Array of activities
 */
export const getActivities = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : [];
  } catch (error) {
    console.error('Error getting activities:', error);
    return [];
  }
};

/**
 * Get recent activities
 * @param {number} limit - Number of activities to return
 * @returns {Array} Array of recent activities
 */
export const getRecentActivities = (limit = 10) => {
  const activities = getActivities();
  return activities.slice(-limit).reverse();
};

/**
 * Clear all activities
 */
export const clearActivities = () => {
  localStorage.removeItem(STORAGE_KEY);
};

/**
 * Calculate time ago string
 * @param {string} timestamp - ISO timestamp
 * @returns {string} Human-readable time ago
 */
export const calculateTimeAgo = (timestamp) => {
  const now = new Date();
  const past = new Date(timestamp);
  const diffMs = now - past;
  const diffSec = Math.floor(diffMs / 1000);
  
  if (diffSec < 60) return 'Hace unos segundos';
  if (diffSec < 3600) {
    const mins = Math.floor(diffSec / 60);
    return `Hace ${mins} minuto${mins !== 1 ? 's' : ''}`;
  }
  if (diffSec < 86400) {
    const hours = Math.floor(diffSec / 3600);
    return `Hace ${hours} hora${hours !== 1 ? 's' : ''}`;
  }
  if (diffSec < 604800) {
    const days = Math.floor(diffSec / 86400);
    return `Hace ${days} día${days !== 1 ? 's' : ''}`;
  }
  
  return past.toLocaleDateString('es-MX');
};

/**
 * Update time ago for all activities
 */
export const updateTimeAgo = () => {
  const activities = getActivities();
  const updated = activities.map(activity => ({
    ...activity,
    timeAgo: calculateTimeAgo(activity.timestamp)
  }));
  localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
  return updated;
};
