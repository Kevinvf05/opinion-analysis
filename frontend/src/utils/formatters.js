/**
 * Format date to readable string
 * @param {string|Date} date - Date to format
 * @returns {string} Formatted date
 */
export const formatDate = (date) => {
  if (!date) return 'N/A';
  const d = new Date(date);
  return d.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};

/**
 * Format date with time
 * @param {string|Date} date - Date to format
 * @returns {string} Formatted date and time
 */
export const formatDateTime = (date) => {
  if (!date) return 'N/A';
  const d = new Date(date);
  return d.toLocaleString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

/**
 * Format user role to Spanish
 * @param {string} role - User role (student, professor, admin, coordinator)
 * @returns {string} Formatted role
 */
export const formatRole = (role) => {
  const roles = {
    student: 'Estudiante',
    professor: 'Profesor',
    admin: 'Administrador',
    coordinator: 'Coordinador'
  };
  return roles[role] || role;
};

/**
 * Format sentiment to Spanish with color
 * @param {string} sentiment - Sentiment type (positive, negative, neutral)
 * @returns {object} Object with label and color
 */
export const formatSentiment = (sentiment) => {
  const sentiments = {
    positive: { label: 'Positivo', color: 'text-green-600', bgColor: 'bg-green-100' },
    negative: { label: 'Negativo', color: 'text-red-600', bgColor: 'bg-red-100' },
    neutral: { label: 'Neutral', color: 'text-yellow-600', bgColor: 'bg-yellow-100' }
  };
  return sentiments[sentiment] || { label: sentiment, color: 'text-gray-600', bgColor: 'bg-gray-100' };
};

/**
 * Format survey status
 * @param {string} status - Survey status
 * @returns {object} Object with label and color
 */
export const formatStatus = (status) => {
  const statuses = {
    pending: { label: 'Pendiente', color: 'text-yellow-600', bgColor: 'bg-yellow-100' },
    completed: { label: 'Completada', color: 'text-green-600', bgColor: 'bg-green-100' },
    cancelled: { label: 'Cancelada', color: 'text-red-600', bgColor: 'bg-red-100' }
  };
  return statuses[status] || { label: status, color: 'text-gray-600', bgColor: 'bg-gray-100' };
};

/**
 * Format percentage
 * @param {number} value - Number to format
 * @param {number} decimals - Number of decimal places
 * @returns {string} Formatted percentage
 */
export const formatPercentage = (value, decimals = 2) => {
  if (value === null || value === undefined) return '0%';
  return `${Number(value).toFixed(decimals)}%`;
};

/**
 * Format number with thousands separator
 * @param {number} value - Number to format
 * @returns {string} Formatted number
 */
export const formatNumber = (value) => {
  if (value === null || value === undefined) return '0';
  return value.toLocaleString('es-MX');
};

/**
 * Truncate text to specified length
 * @param {string} text - Text to truncate
 * @param {number} maxLength - Maximum length
 * @returns {string} Truncated text
 */
export const truncateText = (text, maxLength = 100) => {
  if (!text) return '';
  if (text.length <= maxLength) return text;
  return `${text.substring(0, maxLength)}...`;
};

/**
 * Format user full name
 * @param {object} user - User object
 * @returns {string} Full name
 */
export const formatUserName = (user) => {
  if (!user) return 'N/A';
  return `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.email;
};

/**
 * Get initials from name
 * @param {string} firstName - First name
 * @param {string} lastName - Last name
 * @returns {string} Initials
 */
export const getInitials = (firstName, lastName) => {
  const first = firstName ? firstName.charAt(0).toUpperCase() : '';
  const last = lastName ? lastName.charAt(0).toUpperCase() : '';
  return `${first}${last}`;
};
