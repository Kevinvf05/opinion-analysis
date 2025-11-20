import React, { useState, useEffect } from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';
import { getAdminStats, getAllProfessorsRatings } from '../../services/adminService';

const COLORS = {
  positive: '#10B981',
  neutral: '#F59E0B',
  negative: '#EF4444'
};

const AdminDashboard = () => {
  const [stats, setStats] = useState(null);
  const [professorsRatings, setProfessorsRatings] = useState([]);
  const [selectedProfessor, setSelectedProfessor] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [statsData, ratingsData] = await Promise.all([
        getAdminStats(),
        getAllProfessorsRatings()
      ]);
      setStats(statsData);
      setProfessorsRatings(ratingsData);
      if (ratingsData.length > 0) {
        setSelectedProfessor(ratingsData[0]);
      }
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getPieChartData = (ratings) => {
    return [
      { name: 'Positivo', value: ratings.positive, color: COLORS.positive },
      { name: 'Neutral', value: ratings.neutral, color: COLORS.neutral },
      { name: 'Negativo', value: ratings.negative, color: COLORS.negative }
    ].filter(item => item.value > 0);
  };

  if (loading) {
    return <div className="flex justify-center items-center h-screen">Cargando...</div>;
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Panel de Administración</h1>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-500 text-sm">Total Usuarios</h3>
          <p className="text-3xl font-bold">{stats.totalUsers}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-500 text-sm">Profesores</h3>
          <p className="text-3xl font-bold">{stats.totalProfessors}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-500 text-sm">Estudiantes</h3>
          <p className="text-3xl font-bold">{stats.totalStudents}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-500 text-sm">Participación</h3>
          <p className="text-3xl font-bold">{stats.participationRate}%</p>
        </div>
      </div>

      {/* Professor Ratings Section */}
      <div className="bg-white p-6 rounded-lg shadow mb-8">
        <h2 className="text-2xl font-bold mb-4">Calificaciones por Profesor</h2>
        
        <div className="mb-4">
          <select
            className="w-full md:w-64 p-2 border rounded"
            value={selectedProfessor?.professorId || ''}
            onChange={(e) => {
              const prof = professorsRatings.find(p => p.professorId === parseInt(e.target.value));
              setSelectedProfessor(prof);
            }}
          >
            {professorsRatings.map(prof => (
              <option key={prof.professorId} value={prof.professorId}>
                {prof.professorName}
              </option>
            ))}
          </select>
        </div>

        {selectedProfessor && (
          <div className="flex flex-col md:flex-row items-center justify-around">
            <div className="w-full md:w-1/2">
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={getPieChartData(selectedProfessor.ratings)}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {getPieChartData(selectedProfessor.ratings).map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="w-full md:w-1/2 mt-4 md:mt-0">
              <h3 className="text-xl font-semibold mb-4">{selectedProfessor.professorName}</h3>
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-green-600">Positivo:</span>
                  <span className="font-bold">{selectedProfessor.ratings.positive}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-yellow-600">Neutral:</span>
                  <span className="font-bold">{selectedProfessor.ratings.neutral}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-red-600">Negativo:</span>
                  <span className="font-bold">{selectedProfessor.ratings.negative}</span>
                </div>
                <div className="flex justify-between items-center pt-2 border-t">
                  <span className="font-semibold">Total:</span>
                  <span className="font-bold">{selectedProfessor.total}</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Action Buttons */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <button
          onClick={() => window.location.href = '/admin/users?action=create'}
          className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg"
        >
          Crear Usuario
        </button>
        <button
          onClick={() => window.location.href = '/admin/users'}
          className="bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg"
        >
          Gestionar Usuarios
        </button>
        <button
          onClick={() => window.location.href = '/admin/professors'}
          className="bg-purple-600 hover:bg-purple-700 text-white font-bold py-3 px-6 rounded-lg"
        >
          Editar Profesores
        </button>
      </div>
    </div>
  );
};

export default AdminDashboard;
