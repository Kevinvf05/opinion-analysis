import React from 'react';
import { formatDate, formatRole, formatSentiment, formatStatus, formatUserName } from '../../utils/formatters';

/**
 * Component to display User model data
 */
export const UserCard = ({ user }) => {
  const roleColors = {
    student: 'bg-blue-100 text-blue-800',
    professor: 'bg-purple-100 text-purple-800',
    admin: 'bg-red-100 text-red-800',
    coordinator: 'bg-green-100 text-green-800'
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-bold">{formatUserName(user)}</h3>
        <span className={`px-3 py-1 rounded-full text-sm font-semibold ${roleColors[user.role]}`}>
          {formatRole(user.role)}
        </span>
      </div>
      <div className="space-y-2 text-sm text-gray-600">
        <p><strong>Email:</strong> {user.email}</p>
        <p><strong>ID:</strong> {user.id}</p>
        <p><strong>Estado:</strong> {user.isActive ? 'Activo' : 'Inactivo'}</p>
        <p><strong>Creado:</strong> {formatDate(user.createdAt)}</p>
      </div>
    </div>
  );
};

/**
 * Component to display Survey model data
 */
export const SurveyCard = ({ survey, student, professor, subject }) => {
  const status = formatStatus(survey.status);

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-bold">Encuesta #{survey.id}</h3>
        <span className={`px-3 py-1 rounded-full text-sm font-semibold ${status.bgColor} ${status.color}`}>
          {status.label}
        </span>
      </div>
      <div className="space-y-2 text-sm">
        <p><strong>Estudiante:</strong> {student ? formatUserName(student) : `ID: ${survey.studentId}`}</p>
        <p><strong>Profesor:</strong> {professor ? formatUserName(professor) : `ID: ${survey.professorId}`}</p>
        <p><strong>Materia:</strong> {subject ? subject.name : `ID: ${survey.subjectId}`}</p>
        <p><strong>Comentarios:</strong> {survey.commentsCount || 0}</p>
        <p><strong>Creada:</strong> {formatDate(survey.createdAt)}</p>
        {survey.completedAt && <p><strong>Completada:</strong> {formatDate(survey.completedAt)}</p>}
      </div>
    </div>
  );
};

/**
 * Component to display Comment model data
 */
export const CommentCard = ({ comment }) => {
  const sentiment = formatSentiment(comment.sentiment);

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-bold">Comentario #{comment.id}</h3>
        {comment.sentiment && (
          <span className={`px-3 py-1 rounded-full text-sm font-semibold ${sentiment.bgColor} ${sentiment.color}`}>
            {sentiment.label}
          </span>
        )}
      </div>
      <p className="text-gray-700 mb-4">{comment.text}</p>
      <div className="space-y-2 text-sm text-gray-600">
        <p><strong>Encuesta ID:</strong> {comment.surveyId}</p>
        {comment.confidenceScore && (
          <p><strong>Confianza:</strong> {(comment.confidenceScore * 100).toFixed(2)}%</p>
        )}
        <p><strong>Creado:</strong> {formatDate(comment.createdAt)}</p>
      </div>
    </div>
  );
};

/**
 * Component to display Subject model data
 */
export const SubjectCard = ({ subject }) => {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-4">
      <div className="mb-4">
        <h3 className="text-xl font-bold">{subject.name}</h3>
        <p className="text-gray-500 text-sm">Código: {subject.code}</p>
      </div>
      <div className="space-y-2 text-sm text-gray-600">
        {subject.description && <p>{subject.description}</p>}
        {subject.semester && <p><strong>Semestre:</strong> {subject.semester}</p>}
        {subject.credits && <p><strong>Créditos:</strong> {subject.credits}</p>}
        <p><strong>Creado:</strong> {formatDate(subject.createdAt)}</p>
      </div>
    </div>
  );
};

/**
 * Generic table to display model data
 */
export const ModelTable = ({ data, columns }) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map((col) => (
              <th
                key={col.key}
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                {col.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((row, idx) => (
            <tr key={idx}>
              {columns.map((col) => (
                <td key={col.key} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {col.render ? col.render(row[col.key], row) : row[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
