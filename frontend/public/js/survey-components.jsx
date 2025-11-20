/**
 * Main Survey Layout Component
 * This is the top-level container that orchestrates all survey UI elements
 * It receives all state and handlers from the parent SurveyApp component
 */
const SurveyLayout = ({
    progress,                  // Current completion percentage (0-100)
    professors,                // Array of professor objects to evaluate
    currentQuestion,           // Index of the current question being displayed
    question,                  // Current question object
    questions,                 // Array of all 22 questions
    options,                   // Likert scale options (1-5)
    answers,                   // Object storing all answers: {questionId: {professorId: value}}
    comments,                  // Object storing comments: {professorId: comment}
    errors,                    // Object storing validation errors
    allQuestionsAnswered,      // Boolean - true if all questions answered
    allCommentsValid,          // Boolean - true if all comments meet requirements
    showSubmitModal,           // Boolean - controls modal visibility
    isSubmitting,              // Boolean - true during submission process
    handleAnswer,              // Function to handle answer selection
    handleNext,                // Function to navigate to next question
    handlePrevious,            // Function to navigate to previous question
    handleCommentChange,       // Function to handle comment changes
    handleSubmit,              // Function to initiate submission
    confirmSubmit,             // Function to confirm and execute submission
    setShowSubmitModal,        // Function to toggle modal visibility
    getProfessorColor          // Function to get color scheme for each professor
}) => (
    <div className="min-h-screen bg-gray-50">
        {/* Header with UAEM branding - sticks to top when scrolling */}
        <SurveyHeader />
        
        {/* Progress bar showing completion percentage - also sticky */}
        <ProgressBar progress={progress} professors={professors} />
        
        {/* Main content area with max width for readability */}
        <main className="max-w-6xl mx-auto px-4 py-8">
            {/* Blue banner explaining anonymous nature of survey */}
            <AnonymousNotice professorsCount={professors.length} />
            
            {/* Display current question if not finished with all questions */}
            {currentQuestion < questions.length && (
                <QuestionCard
                    question={question}
                    currentQuestion={currentQuestion}
                    totalQuestions={questions.length}
                    professors={professors}
                    options={options}
                    answers={answers}
                    errors={errors}
                    handleAnswer={handleAnswer}
                    handleNext={handleNext}
                    handlePrevious={handlePrevious}
                    getProfessorColor={getProfessorColor}
                />
            )}

            {/* Comment section appears only after all questions are answered */}
            {allQuestionsAnswered && (
                <CommentSection
                    professors={professors}
                    comments={comments}
                    errors={errors}
                    handleCommentChange={handleCommentChange}
                    getProfessorColor={getProfessorColor}
                />
            )}

            {/* Submit button - enabled only when everything is complete */}
            <SubmitButton
                allQuestionsAnswered={allQuestionsAnswered}
                allCommentsValid={allCommentsValid}
                professorsCount={professors.length}
                handleSubmit={handleSubmit}
            />
        </main>

        {/* Confirmation modal - shows before final submission */}
        {showSubmitModal && (
            <ConfirmationModal
                professorsCount={professors.length}
                isSubmitting={isSubmitting}
                confirmSubmit={confirmSubmit}
                onClose={() => setShowSubmitModal(false)}
            />
        )}

        {/* Footer with copyright and privacy notice */}
        <SurveyFooter />
    </div>
);

/**
 * Survey Header Component
 * Purple gradient header with UAEM branding
 * Stays at the top of the screen when scrolling (sticky positioning)
 */
const SurveyHeader = () => (
    <header className="gradient-bg text-white py-6 shadow-lg sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-4">
            <h1 className="text-2xl sm:text-3xl font-bold text-center">Evaluación Docente</h1>
            <p className="text-center mt-2 text-purple-100">UAEM - Rectoría</p>
        </div>
    </header>
);

/**
 * Progress Bar Component
 * Shows visual feedback of survey completion
 * Displays percentage and number of professors being evaluated
 * Sticks below the header when scrolling
 */
const ProgressBar = ({ progress, professors }) => (
    <div className="bg-white border-b sticky top-[88px] z-10">
        <div className="max-w-6xl mx-auto px-4 py-4">
            {/* Progress percentage display */}
            <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-semibold text-gray-700">Progreso</span>
                <span className="text-sm font-semibold text-purple-600">{Math.round(progress)}%</span>
            </div>
            
            {/* Visual progress bar with gradient fill */}
            <div className="w-full bg-gray-200 rounded-full h-3">
                <div 
                    className="progress-bar gradient-bg h-3 rounded-full"
                    style={{ width: `${progress}%` }}
                ></div>
            </div>
            
            {/* Helper text showing number of professors */}
            <p className="text-xs text-gray-500 mt-2">
                Evaluando {professors.length} profesores
            </p>
        </div>
    </div>
);

/**
 * Anonymous Notice Component
 * Blue banner that reassures students their responses are anonymous
 * Displays lock icon and explanation text
 */
const AnonymousNotice = ({ professorsCount }) => (
    <div className="bg-blue-50 border-l-4 border-blue-500 p-4 mb-6 rounded-r-lg">
        <div className="flex items-start">
            {/* Lock icon to represent security/privacy */}
            <svg className="w-6 h-6 text-blue-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
            </svg>
            <div>
                <p className="font-semibold text-blue-900">Tu evaluación es completamente anónima</p>
                <p className="text-sm text-blue-700 mt-1">
                    Tus respuestas no pueden ser rastreadas hasta ti. Evaluarás a {professorsCount} profesores en una sola sesión.
                </p>
            </div>
        </div>
    </div>
);

/**
 * Question Card Component
 * Main card that displays a single question and evaluation options for all professors
 * Shows topic badge, question number, category, and the question text
 * Contains evaluation sections for each professor and navigation buttons
 */
const QuestionCard = ({
    question,              // Current question object with text, topic, category
    currentQuestion,       // Index of current question (0-based)
    totalQuestions,        // Total number of questions (22)
    professors,            // Array of professors to evaluate
    options,               // Likert scale options (1-5)
    answers,               // Current answers state
    errors,                // Validation errors
    handleAnswer,          // Function to record an answer
    handleNext,            // Function to go to next question
    handlePrevious,        // Function to go to previous question
    getProfessorColor      // Function to get color for each professor
}) => (
    <div className="question-card bg-white rounded-xl shadow-lg p-6 sm:p-8 mb-6">
        {/* Question header with topic badge and question number */}
        <div className="mb-6">
            {/* Topic badge (e.g., "Clima de aula y valores") */}
            <span className="inline-block bg-purple-100 text-purple-800 text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wide mb-3">
                {question.topic}
            </span>
            
            {/* Question number display */}
            <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mt-2">
                Pregunta {currentQuestion + 1} de {totalQuestions}
            </h2>
            
            {/* Category subtitle (e.g., "Clima de aula") */}
            <p className="text-sm text-gray-500 mt-1">{question.category}</p>
        </div>

        {/* Question text in a highlighted box */}
        <div className="bg-gradient-to-r from-purple-50 to-blue-50 rounded-lg p-6 mb-6">
            <p className="text-lg sm:text-xl text-gray-800 font-medium">
                {question.text}
            </p>
        </div>

        {/* Professor evaluation sections - one for each professor */}
        <div className="space-y-6">
            {professors.map((professor, profIndex) => (
                <ProfessorEvaluation
                    key={professor.id}
                    professor={professor}
                    profIndex={profIndex}
                    question={question}
                    options={options}
                    answers={answers}
                    errors={errors}
                    handleAnswer={handleAnswer}
                    getProfessorColor={getProfessorColor}
                />
            ))}
        </div>

        {/* Previous/Next navigation buttons */}
        <NavigationButtons
            currentQuestion={currentQuestion}
            handlePrevious={handlePrevious}
            handleNext={handleNext}
        />
    </div>
);

/**
 * Professor Evaluation Component
 * Individual section for evaluating one professor on one question
 * Shows professor name, subject, and radio button options (1-5 scale)
 * Uses color-coding to distinguish between different professors
 */
const ProfessorEvaluation = ({
    professor,         // Professor object with id, name, subject
    profIndex,         // Index of professor (for color coding)
    question,          // Current question being answered
    options,           // Likert scale options
    answers,           // Current answers state
    errors,            // Validation errors for this professor
    handleAnswer,      // Function to record answer
    getProfessorColor  // Function to get this professor's color scheme
}) => (
    <div className="border-2 border-gray-200 rounded-lg p-4">
        {/* Professor header with gradient background (purple/blue/green) */}
        <div className={`bg-gradient-to-r ${getProfessorColor(profIndex)} text-white px-4 py-2 rounded-lg mb-4`}>
            <h3 className="font-bold text-lg">{professor.name}</h3>
            <p className="text-sm opacity-90">{professor.subject}</p>
        </div>

        {/* Radio button options (1-5 Likert scale) */}
        <div className="space-y-2">
            {options.map(option => (
                <div key={option.value} className="radio-option">
                    {/* Hidden radio input (we use custom label styling) */}
                    <input
                        type="radio"
                        id={`q${question.id}_p${professor.id}_${option.value}`}
                        name={`question_${question.id}_professor_${professor.id}`}
                        value={option.value}
                        checked={answers[question.id]?.[professor.id] === option.value}
                        onChange={() => handleAnswer(question.id, professor.id, option.value)}
                        className="hidden"
                    />
                    
                    {/* Custom styled label that acts as the clickable button */}
                    <label
                        htmlFor={`q${question.id}_p${professor.id}_${option.value}`}
                        className="flex items-center justify-between p-3 border-2 border-gray-200 rounded-lg cursor-pointer hover:border-purple-400 transition-all"
                    >
                        {/* Left side: colored dot and label text */}
                        <div className="flex items-center space-x-3">
                            <div className={`w-3 h-3 rounded-full ${option.color}`}></div>
                            <span className="font-medium text-gray-700 text-sm">{option.label}</span>
                        </div>
                        
                        {/* Right side: numeric value (1-5) */}
                        <span className="text-xl font-bold text-gray-400">{option.value}</span>
                    </label>
                </div>
            ))}
        </div>

        {/* Error message if this professor wasn't rated */}
        {errors[`question_${question.id}_prof_${professor.id}`] && (
            <p className="mt-2 text-red-600 text-sm font-semibold animate-pulse">
                {errors[`question_${question.id}_prof_${professor.id}`]}
            </p>
        )}
    </div>
);

/**
 * Navigation Buttons Component
 * Previous and Next buttons for navigating between questions
 * Previous button is disabled on first question
 * Includes arrow icons for visual clarity
 */
const NavigationButtons = ({ currentQuestion, handlePrevious, handleNext }) => (
    <div className="flex justify-between mt-8 gap-4">
        {/* Previous button - disabled on first question */}
        <button
            onClick={handlePrevious}
            disabled={currentQuestion === 0}
            className="flex items-center px-6 py-3 border-2 border-gray-300 rounded-lg font-semibold text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
        >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7"></path>
            </svg>
            Anterior
        </button>
        
        {/* Next button - validates current question before proceeding */}
        <button
            onClick={handleNext}
            className="flex items-center gradient-bg text-white px-6 py-3 rounded-lg font-semibold hover:shadow-lg transition"
        >
            Siguiente
            <svg className="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
            </svg>
        </button>
    </div>
);

/**
 * Comment Section Component
 * Appears after all questions are answered
 * Contains a textarea for each professor where students write comments
 * Minimum 10 characters required per professor
 */
const CommentSection = ({ professors, comments, errors, handleCommentChange, getProfessorColor }) => (
    <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8 mb-6">
        <h3 className="text-2xl font-bold text-gray-900 mb-4">Comentarios por Profesor</h3>
        <p className="text-gray-600 mb-6">
            Por favor, comparte tus comentarios sobre cada profesor. 
            <span className="font-semibold text-purple-600"> Todos los campos son obligatorios (mínimo 10 caracteres).</span>
        </p>
        
        {/* Comment box for each professor */}
        <div className="space-y-6">
            {professors.map((professor, profIndex) => (
                <div key={professor.id} className="border-2 border-gray-200 rounded-lg p-4">
                    {/* Professor header (matches evaluation section colors) */}
                    <div className={`bg-gradient-to-r ${getProfessorColor(profIndex)} text-white px-4 py-2 rounded-lg mb-4`}>
                        <h4 className="font-bold text-lg">{professor.name}</h4>
                        <p className="text-sm opacity-90">{professor.subject}</p>
                    </div>
                    
                    {/* Multi-line text input for comments */}
                    <textarea
                        value={comments[professor.id] || ''}
                        onChange={(e) => handleCommentChange(professor.id, e.target.value)}
                        placeholder={`Comentarios sobre ${professor.name}... (mínimo 10 caracteres)`}
                        rows="4"
                        className={`w-full px-4 py-3 border-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 resize-none ${
                            errors[`comment_${professor.id}`] ? 'border-red-500' : 'border-gray-300'
                        }`}
                    ></textarea>
                    
                    {/* Character count and validation feedback */}
                    <div className="flex justify-between items-center mt-2">
                        {/* Character counter - turns green when requirement is met */}
                        <span className={`text-sm ${(comments[professor.id]?.length || 0) >= 10 ? 'text-green-600' : 'text-gray-500'}`}>
                            {comments[professor.id]?.length || 0} caracteres (mínimo 10)
                        </span>
                        
                        {/* Error message if comment is invalid */}
                        {errors[`comment_${professor.id}`] && (
                            <p className="text-red-600 text-sm font-semibold">
                                {errors[`comment_${professor.id}`]}
                            </p>
                        )}
                    </div>
                </div>
            ))}
        </div>
    </div>
);

/**
 * Submit Button Component
 * Large button at the bottom of the survey
 * Only enabled when all questions are answered AND all comments are valid
 * Shows helpful error messages when requirements aren't met
 */
const SubmitButton = ({ allQuestionsAnswered, allCommentsValid, professorsCount, handleSubmit }) => (
    <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8">
        {/* Main submit button - disabled until survey is complete */}
        <button
            onClick={handleSubmit}
            disabled={!allQuestionsAnswered || !allCommentsValid}
            className="w-full gradient-bg text-white py-4 px-6 rounded-lg font-bold text-lg hover:shadow-2xl disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:scale-105"
        >
            {/* Button text changes based on completion status */}
            {allQuestionsAnswered && allCommentsValid ? (
                <>Enviar Evaluación de {professorsCount} Profesores</>
            ) : (
                <>Completa todas las evaluaciones y comentarios para continuar</>
            )}
        </button>
        
        {/* Error messages explaining what's still needed */}
        {(!allQuestionsAnswered || !allCommentsValid) && (
            <p className="text-center text-sm text-red-600 mt-3 font-semibold">
                {!allQuestionsAnswered && `Asegúrate de evaluar a todos los profesores en todas las preguntas. `}
                {!allCommentsValid && "Todos los profesores requieren comentarios (mínimo 10 caracteres cada uno)."}
            </p>
        )}
    </div>
);

/**
 * Confirmation Modal Component
 * Popup dialog that appears before final submission
 * Asks user to confirm they want to submit (no going back after this)
 * Reminds them the evaluation is anonymous
 * Shows loading state during submission
 */
const ConfirmationModal = ({ professorsCount, isSubmitting, confirmSubmit, onClose }) => (
    // Dark overlay that covers the entire screen
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        {/* White modal card in the center */}
        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-8">
            <div className="text-center">
                {/* Checkmark icon in purple circle */}
                <div className="w-16 h-16 gradient-bg rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                </div>
                
                {/* Modal title */}
                <h3 className="text-2xl font-bold text-gray-900 mb-2">¿Enviar Evaluación?</h3>
                
                {/* Main message - confirms number of professors */}
                <p className="text-gray-600 mb-4">
                    Estás a punto de enviar la evaluación de <span className="font-bold text-purple-600">{professorsCount} profesores</span>.
                </p>
                
                {/* Warning message - no edits after submission */}
                <p className="text-sm text-gray-500 mb-6">
                    Una vez enviada, no podrás modificar tus respuestas. 
                    Recuerda que tu evaluación es completamente anónima.
                </p>
                
                {/* Action buttons */}
                <div className="flex gap-4">
                    {/* Cancel button - closes modal */}
                    <button
                        onClick={onClose}
                        disabled={isSubmitting}
                        className="flex-1 px-6 py-3 border-2 border-gray-300 rounded-lg font-semibold text-gray-700 hover:bg-gray-50 disabled:opacity-50 transition"
                    >
                        Cancelar
                    </button>
                    
                    {/* Confirm button - actually submits the survey */}
                    <button
                        onClick={confirmSubmit}
                        disabled={isSubmitting}
                        className="flex-1 gradient-bg text-white px-6 py-3 rounded-lg font-semibold hover:shadow-lg disabled:opacity-50 transition"
                    >
                        {/* Shows "Enviando..." while submitting */}
                        {isSubmitting ? 'Enviando...' : 'Confirmar'}
                    </button>
                </div>
            </div>
        </div>
    </div>
);

/**
 * Survey Footer Component
 * Bottom section with copyright and privacy notice
 * Appears at the end of the page
 */
const SurveyFooter = () => (
    <footer className="bg-gray-900 text-white py-8 mt-12">
        <div className="max-w-6xl mx-auto px-4 text-center">
            {/* Copyright notice */}
            <p className="text-sm text-gray-400">
                &copy; 2024 UAEM - Rectoría. Sistema de Evaluación Docente.
            </p>
            
            {/* Privacy reminder */}
            <p className="text-xs text-gray-500 mt-2">
                Tus respuestas son anónimas y confidenciales.
            </p>
        </div>
    </footer>
);
