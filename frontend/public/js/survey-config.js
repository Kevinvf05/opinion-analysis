// Use relative URL when running through nginx proxy
const IS_PROXIED = window.location.port === '8080';

const SURVEY_CONFIG = {
    // API base URL - will be used by survey-api.js
    apiBaseUrl: IS_PROXIED ? '/api' : 'http://localhost:5000/api',
    
    // Fallback professors data (used if API fails)
    fallbackProfessors: [
        { id: 1, name: "Dr. María González", subject: "Arquitectura de Software" },
        { id: 2, name: "Ing. Carlos Rodríguez", subject: "Base de Datos" },
        { id: 3, name: "Mtra. Ana López", subject: "Desarrollo Web" }
    ],

    // Fallback questions (used if API fails)
    fallbackQuestions: [
        // Topic 1: Clima de aula y valores
        { id: 1, topic: "Clima de aula y valores", text: "El profesor promueve un ambiente de respeto y tolerancia en el aula", category: "Clima de aula" },
        { id: 2, topic: "Clima de aula y valores", text: "El profesor fomenta la participación activa de todos los estudiantes", category: "Participación" },
        { id: 3, topic: "Clima de aula y valores", text: "El profesor muestra disposición para atender dudas y consultas", category: "Atención" },
        { id: 4, topic: "Clima de aula y valores", text: "El profesor trata a los estudiantes con respeto y equidad", category: "Respeto" },
        { id: 5, topic: "Clima de aula y valores", text: "El profesor promueve valores éticos y profesionales", category: "Valores" },
        
        // Topic 2: Dominio de la asignatura
        { id: 6, topic: "Dominio de la asignatura", text: "El profesor demuestra dominio y conocimiento de la materia", category: "Conocimiento" },
        { id: 7, topic: "Dominio de la asignatura", text: "El profesor relaciona los contenidos con situaciones de la vida real", category: "Aplicación práctica" },
        { id: 8, topic: "Dominio de la asignatura", text: "El profesor utiliza ejemplos y casos relevantes para facilitar el aprendizaje", category: "Ejemplos" },
        { id: 9, topic: "Dominio de la asignatura", text: "El profesor demuestra actualización en los temas de la asignatura", category: "Actualización" },
        
        // Topic 3: Planeación y organización
        { id: 10, topic: "Planeación y organización", text: "El profesor presenta y explica el programa de la asignatura al inicio del curso", category: "Presentación" },
        { id: 11, topic: "Planeación y organización", text: "El profesor organiza y estructura las clases de manera clara", category: "Organización" },
        { id: 12, topic: "Planeación y organización", text: "El profesor cumple con el programa establecido de la asignatura", category: "Cumplimiento" },
        { id: 13, topic: "Planeación y organización", text: "El profesor distribuye adecuadamente el tiempo de la clase", category: "Tiempo" },
        
        // Topic 4: Estrategias de enseñanza
        { id: 14, topic: "Estrategias de enseñanza", text: "El profesor explica con claridad los temas de la clase", category: "Claridad" },
        { id: 15, topic: "Estrategias de enseñanza", text: "El profesor utiliza recursos didácticos apropiados (presentaciones, videos, etc.)", category: "Recursos" },
        { id: 16, topic: "Estrategias de enseñanza", text: "El profesor motiva e incentiva el aprendizaje de los estudiantes", category: "Motivación" },
        { id: 17, topic: "Estrategias de enseñanza", text: "El profesor fomenta el pensamiento crítico y analítico", category: "Pensamiento crítico" },
        
        // Topic 5: Evaluación del aprendizaje
        { id: 18, topic: "Evaluación del aprendizaje", text: "El profesor explica claramente los criterios de evaluación", category: "Criterios" },
        { id: 19, topic: "Evaluación del aprendizaje", text: "El profesor evalúa de manera justa y objetiva", category: "Justicia" },
        { id: 20, topic: "Evaluación del aprendizaje", text: "El profesor proporciona retroalimentación oportuna sobre el desempeño", category: "Retroalimentación" },
        
        // Topic 6: Cumplimiento y puntualidad
        { id: 21, topic: "Cumplimiento y puntualidad", text: "El profesor es puntual al inicio y término de las clases", category: "Puntualidad" },
        { id: 22, topic: "Cumplimiento y puntualidad", text: "El profesor asiste regularmente a clases", category: "Asistencia" }
    ],

    // Fallback options
    fallbackOptions: [
        { value: 5, label: "Totalmente de acuerdo", color: "bg-green-500" },
        { value: 4, label: "De acuerdo", color: "bg-blue-500" },
        { value: 3, label: "Neutral", color: "bg-yellow-500" },
        { value: 2, label: "En desacuerdo", color: "bg-orange-500" },
        { value: 1, label: "Totalmente en desacuerdo", color: "bg-red-500" }
    ]
};
