const { useState, useEffect } = React;

const SurveyApp = () => {
    // State management for survey responses and navigation
    const [currentQuestion, setCurrentQuestion] = useState(0);
    const [answers, setAnswers] = useState({});
    const [comments, setComments] = useState({});
    const [errors, setErrors] = useState({});
    const [showSubmitModal, setShowSubmitModal] = useState(false);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [loadError, setLoadError] = useState(null);
    const [professors, setProfessors] = useState([]);
    const [questions, setQuestions] = useState([]);
    const [options, setOptions] = useState([]);

    /**
     * Load survey data from API on component mount
     */
    useEffect(() => {
        const loadSurveyData = async () => {
            try {
                setIsLoading(true);
                setLoadError(null);
                
                console.log('Loading survey data...');
                
                // Check authentication
                const currentUser = JSON.parse(localStorage.getItem('currentUser') || 'null');
                if (!currentUser || currentUser.role !== 'student') {
                    setLoadError('Not authenticated as student. Please log in.');
                    return;
                }
                
                console.log('Authenticated student:', currentUser.first_name, currentUser.last_name);
                
                // Fetch all required data in parallel
                const [professorsData, questionsData, optionsData] = await Promise.all([
                    SurveyAPI.getProfessors(),
                    SurveyAPI.getQuestions(),
                    SurveyAPI.getOptions()
                ]);
                
                console.log('Loaded professors:', professorsData);
                console.log('Loaded questions:', questionsData.length);
                console.log('Loaded options:', optionsData.length);
                
                setProfessors(professorsData);
                setQuestions(questionsData);
                setOptions(optionsData);
                
            } catch (error) {
                console.error('Failed to load survey data:', error);
                setLoadError(error.message);
            } finally {
                setIsLoading(false);
            }
        };
        
        loadSurveyData();
    }, []);

    /**
     * Calculate progress based on answered questions for all professors and comments
     */
    const calculateProgress = () => {
        const totalQuestions = questions.length * professors.length;
        const totalComments = professors.length;
        const totalItems = totalQuestions + totalComments;

        let answeredQuestions = 0;
        questions.forEach(q => {
            professors.forEach(p => {
                if (answers[q.id]?.[p.id]) {
                    answeredQuestions++;
                }
            });
        });

        let validComments = 0;
        professors.forEach(p => {
            if (comments[p.id]?.trim().length >= 10) {
                validComments++;
            }
        });

        return ((answeredQuestions + validComments) / totalItems) * 100;
    };

    const progress = calculateProgress();

    // Check if all questions for all professors are answered
    const allQuestionsAnswered = questions.every(q => 
        professors.every(p => answers[q.id]?.[p.id])
    );

    // Check if all professors have valid comments
    const allCommentsValid = professors.every(p => 
        comments[p.id]?.trim().length >= 10
    );

    // Get current question object
    const question = questions[currentQuestion];

    /**
     * Handle answer selection for a specific professor and question
     */
    const handleAnswer = (questionId, professorId, value) => {
        setAnswers(prev => ({
            ...prev,
            [questionId]: {
                ...prev[questionId],
                [professorId]: value
            }
        }));
        
        setErrors(prev => ({
            ...prev,
            [`question_${questionId}_prof_${professorId}`]: null
        }));
    };

    /**
     * Navigate to next question
     */
    const handleNext = () => {
        const question = questions[currentQuestion];
        let hasError = false;
        const newErrors = {};

        professors.forEach(prof => {
            if (!answers[question.id]?.[prof.id]) {
                newErrors[`question_${question.id}_prof_${prof.id}`] = "Por favor selecciona una opción";
                hasError = true;
            }
        });

        if (hasError) {
            setErrors(newErrors);
            return;
        }
        
        if (currentQuestion < questions.length - 1) {
            setCurrentQuestion(prev => prev + 1);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    /**
     * Navigate to previous question
     */
    const handlePrevious = () => {
        if (currentQuestion > 0) {
            setCurrentQuestion(prev => prev - 1);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    /**
     * Handle comment change for a specific professor
     */
    const handleCommentChange = (professorId, value) => {
        setComments(prev => ({
            ...prev,
            [professorId]: value
        }));
        setErrors(prev => ({
            ...prev,
            [`comment_${professorId}`]: null
        }));
    };

    /**
     * Validate entire survey before submission
     */
    const validateSurvey = () => {
        const newErrors = {};
        
        questions.forEach(q => {
            professors.forEach(p => {
                if (!answers[q.id]?.[p.id]) {
                    newErrors[`question_${q.id}_prof_${p.id}`] = "Sin responder";
                }
            });
        });

        professors.forEach(p => {
            if (!comments[p.id]?.trim()) {
                newErrors[`comment_${p.id}`] = "Comentario obligatorio";
            } else if (comments[p.id].trim().length < 10) {
                newErrors[`comment_${p.id}`] = "Mínimo 10 caracteres";
            }
        });

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    /**
     * Calculate metrics for each professor
     */
    const calculateProfessorMetrics = () => {
        return professors.map(professor => {
            const professorAnswers = [];
            let totalScore = 0;
            let positiveCount = 0;
            let neutralCount = 0;
            let negativeCount = 0;

            questions.forEach(q => {
                const answer = answers[q.id]?.[professor.id];
                if (answer) {
                    professorAnswers.push({
                        questionId: q.id,
                        questionText: q.text,
                        category: q.category,
                        topic: q.topic,
                        score: answer
                    });
                    totalScore += answer;

                    if (answer >= 4) positiveCount++;
                    else if (answer === 3) neutralCount++;
                    else negativeCount++;
                }
            });

            const averageScore = totalScore / questions.length;
            const percentageScore = (averageScore / 5) * 100;

            return {
                professorId: professor.id,
                professorName: professor.name,
                subject: professor.subject,
                totalQuestions: questions.length,
                responses: professorAnswers,
                comment: comments[professor.id],
                metrics: {
                    totalScore: totalScore,
                    averageScore: averageScore.toFixed(2),
                    percentageScore: percentageScore.toFixed(2),
                    positiveCount: positiveCount,
                    neutralCount: neutralCount,
                    negativeCount: negativeCount,
                    positivePercentage: ((positiveCount / questions.length) * 100).toFixed(2),
                    neutralPercentage: ((neutralCount / questions.length) * 100).toFixed(2),
                    negativePercentage: ((negativeCount / questions.length) * 100).toFixed(2)
                }
            };
        });
    };

    /**
     * Prepare survey for submission
     */
    const handleSubmit = () => {
        if (validateSurvey()) {
            setShowSubmitModal(true);
        } else {
            const firstErrorQuestion = questions.findIndex(q => 
                professors.some(p => errors[`question_${q.id}_prof_${p.id}`])
            );
            if (firstErrorQuestion !== -1) {
                setCurrentQuestion(firstErrorQuestion);
            }
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    /**
     * Submit survey to backend
     */
    const confirmSubmit = async () => {
        setIsSubmitting(true);
        
        try {
            const professorEvaluations = calculateProfessorMetrics();
            
            console.log('Submitting surveys for', professorEvaluations.length, 'professors');
            
            // Submit each professor evaluation separately
            const submissionPromises = professorEvaluations.map(async (evaluation) => {
                // Transform answers to simple question_id -> rating format
                const answerMap = {};
                evaluation.responses.forEach(response => {
                    answerMap[response.questionId] = response.score;
                });
                
                const surveyData = {
                    professorId: evaluation.professorId,
                    answers: answerMap,
                    comment: evaluation.comment || 'No additional comments'
                };
                
                console.log(`Submitting survey for professor ${evaluation.professorName}:`, surveyData);
                
                try {
                    const result = await SurveyAPI.submitSurvey(surveyData);
                    console.log(`✅ Survey submitted for ${evaluation.professorName}:`, result);
                    return { success: true, professor: evaluation.professorName, result };
                } catch (error) {
                    console.error(`❌ Failed to submit survey for ${evaluation.professorName}:`, error);
                    return { success: false, professor: evaluation.professorName, error: error.message };
                }
            });
            
            // Wait for all submissions to complete
            const results = await Promise.all(submissionPromises);
            
            // Check if all submissions were successful
            const successCount = results.filter(r => r.success).length;
            const failCount = results.filter(r => !r.success).length;
            
            console.log(`Survey submission complete: ${successCount} successful, ${failCount} failed`);
            
            if (failCount === 0) {
                alert(`¡Gracias por tu evaluación! Has evaluado exitosamente a ${successCount} profesores.`);
                window.location.href = 'index.html';
            } else if (successCount > 0) {
                alert(`Evaluación parcialmente exitosa: ${successCount} profesores evaluados, ${failCount} fallidos. Por favor contacta soporte.`);
                window.location.href = 'index.html';
            } else {
                throw new Error('No se pudo enviar ninguna evaluación');
            }
            
        } catch (error) {
            console.error('Error submitting survey:', error);
            alert('Error al enviar la evaluación. Por favor, intenta de nuevo.');
            setIsSubmitting(false);
            setShowSubmitModal(false);
        }
    };

    /**
     * Get color coding for professor column
     */
    const getProfessorColor = (index) => {
        const colors = [
            'from-purple-500 to-purple-600',
            'from-blue-500 to-blue-600',
            'from-green-500 to-green-600'
        ];
        return colors[index % colors.length];
    };

    // Show loading state
    if (isLoading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-purple-600 mx-auto mb-4"></div>
                    <p className="text-gray-600">Cargando encuesta...</p>
                </div>
            </div>
        );
    }

    // Show error state
    if (loadError) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
                <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-6 text-center">
                    <svg className="w-16 h-16 text-red-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <h2 className="text-xl font-bold text-gray-900 mb-2">Error al cargar la encuesta</h2>
                    <p className="text-gray-600 mb-4">{loadError}</p>
                    <button 
                        onClick={() => window.location.reload()} 
                        className="gradient-bg text-white px-6 py-2 rounded-lg font-semibold hover:shadow-lg transition"
                    >
                        Reintentar
                    </button>
                </div>
            </div>
        );
    }

    return (
        <SurveyLayout
            progress={progress}
            professors={professors}
            currentQuestion={currentQuestion}
            question={question}
            questions={questions}
            options={options}
            answers={answers}
            comments={comments}
            errors={errors}
            allQuestionsAnswered={allQuestionsAnswered}
            allCommentsValid={allCommentsValid}
            showSubmitModal={showSubmitModal}
            isSubmitting={isSubmitting}
            handleAnswer={handleAnswer}
            handleNext={handleNext}
            handlePrevious={handlePrevious}
            handleCommentChange={handleCommentChange}
            handleSubmit={handleSubmit}
            confirmSubmit={confirmSubmit}
            setShowSubmitModal={setShowSubmitModal}
            getProfessorColor={getProfessorColor}
        />
    );
};
