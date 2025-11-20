/**
 * API service for survey operations
 * Handles communication with Flask backend
 */
const API_BASE_URL = SURVEY_CONFIG.apiBaseUrl;

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

const SurveyAPI = {
    /**
     * Fetch professors and subjects that need to be evaluated by student
     * @returns {Promise<Array>} - List of professors with subjects
     */
    async getProfessors() {
        try {
            const token = getAuthToken();
            
            if (!token) {
                console.warn('No auth token found, using fallback professors');
                return SURVEY_CONFIG.fallbackProfessors;
            }
            
            const response = await fetch(`${API_BASE_URL}/student/professors`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!response.ok) {
                console.warn('API call failed, using fallback professors');
                return SURVEY_CONFIG.fallbackProfessors;
            }
            
            const data = await response.json();
            console.log('Loaded professors from backend:', data);
            
            // Transform backend data to match expected format
            const professors = data.professors || [];
            return professors.map(prof => ({
                id: prof.id,
                name: prof.name,
                subject: prof.subjects[0]?.name || 'Multiple subjects',
                subjects: prof.subjects // Include all subjects for reference
            }));
            
        } catch (error) {
            console.error('Error fetching professors:', error);
            console.log('Using fallback professors');
            return SURVEY_CONFIG.fallbackProfessors;
        }
    },

    /**
     * Fetch survey questions
     * @returns {Promise<Array>} - List of 22 questions
     */
    async getQuestions() {
        try {
            // For now, questions are static and defined in config
            // In the future, these could come from backend
            const response = await fetch(`${API_BASE_URL}/survey/questions`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                console.warn('API call failed, using fallback questions');
                return SURVEY_CONFIG.fallbackQuestions;
            }
            
            const data = await response.json();
            return data.questions || SURVEY_CONFIG.fallbackQuestions;
        } catch (error) {
            console.error('Error fetching questions:', error);
            console.log('Using fallback questions');
            return SURVEY_CONFIG.fallbackQuestions;
        }
    },

    /**
     * Fetch Likert scale options
     * @returns {Promise<Array>} - List of rating options
     */
    async getOptions() {
        try {
            // For now, options are static and defined in config
            // In the future, these could come from backend
            const response = await fetch(`${API_BASE_URL}/survey/options`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                console.warn('API call failed, using fallback options');
                return SURVEY_CONFIG.fallbackOptions;
            }
            
            const data = await response.json();
            return data.options || SURVEY_CONFIG.fallbackOptions;
        } catch (error) {
            console.error('Error fetching options:', error);
            console.log('Using fallback options');
            return SURVEY_CONFIG.fallbackOptions;
        }
    },

    /**
     * Submit completed survey with evaluations
     * @param {Object} surveyData - Complete survey data including:
     *   - professorId: ID of professor being evaluated
     *   - answers: Object with question_id -> rating mappings
     *   - comment: General comment about the professor
     * @returns {Promise<Object>} - Submission result
     */
    async submitSurvey(surveyData) {
        try {
            const token = getAuthToken();
            const currentUser = getCurrentUser();
            
            if (!token || !currentUser) {
                throw new Error('Not authenticated. Please log in again.');
            }
            
            // Get the survey ID for this professor
            // First, get all surveys for the student
            const surveysResponse = await fetch(`${API_BASE_URL}/student/surveys`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!surveysResponse.ok) {
                throw new Error('Failed to fetch surveys');
            }
            
            const surveysData = await surveysResponse.json();
            
            // Find the pending survey for this professor
            const survey = surveysData.surveys.find(s => 
                s.professor.id === surveyData.professorId && 
                s.status === 'pending'
            );
            
            if (!survey) {
                throw new Error('No pending survey found for this professor');
            }
            
            // Submit the survey
            const response = await fetch(`${API_BASE_URL}/student/surveys/${survey.id}/submit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    answers: surveyData.answers,
                    comment: surveyData.comment
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to submit survey');
            }
            
            const data = await response.json();
            console.log('✅ Survey submitted successfully:', data);
            
            return {
                success: true,
                message: data.message,
                survey_id: data.survey_id,
                sentiment: data.sentiment,
                confidence: data.confidence
            };
            
        } catch (error) {
            console.error('Error submitting survey:', error);
            
            // Don't use fallback for submission - inform user of error
            throw error;
        }
    },

    /**
     * Get all surveys (pending and completed) for the current student
     * @returns {Promise<Array>} - List of surveys
     */
    async getSurveys() {
        try {
            const token = getAuthToken();
            
            if (!token) {
                throw new Error('Not authenticated');
            }
            
            const response = await fetch(`${API_BASE_URL}/student/surveys`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch surveys');
            }
            
            const data = await response.json();
            return data.surveys || [];
            
        } catch (error) {
            console.error('Error fetching surveys:', error);
            throw error;
        }
    }
};
