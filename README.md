# Sistema de Análisis de Opinión Docente

Sistema para clasificar comentarios de evaluaciones docentes en categorías positivas, negativas y neutras.

## Equipo 2
- **Luis Antonio Espín Acevedo**
- **Kevin Vargas Flores**
- **Anibal Medina Cabrera**
- **Cristopher Axel Diaz Martinez**

## Tecnologías
- **Backend**: Python 
- **Framework**: Flask
- **Frontend**: React + Tailwind CSS
- **Base de Datos**: PostgreSQL
- **ML**: Transformers (HuggingFace)

## Estructura del Proyecto
```
analisis-opinion/
│
├── backend/                          # Servidor Python
│   ├── app/
│   │   ├── __init__.py              # Inicialización de Flask
│   │   ├── config.py                # Configuraciones (DB, secrets, etc.)
│   │   ├── models/                  # Modelos de la BD
│   │   │   ├── __init__.py
│   │   │   ├── user.py              # Modelo Usuario
│   │   │   ├── survey.py            # Modelo Encuesta
│   │   │   ├── comment.py           # Modelo Comentario
│   │   │   └── subject.py           # Modelo Materia
│   │   ├── routes/                  # Endpoints de la API
│   │   │   ├── __init__.py
│   │   │   ├── auth.py              # Login, logout, recuperación
│   │   │   ├── users.py             # Gestión de usuarios (RF-2)
│   │   │   ├── surveys.py           # Encuestas (RF-3)
│   │   │   ├── comments.py          # Búsqueda y filtrado (RF-5)
│   │   │   └── dashboard.py         # Dashboards (RF-6)
│   │   ├── services/                # Lógica de negocio
│   │   │   ├── __init__.py
│   │   │   ├── auth_service.py      # Autenticación
│   │   │   ├── sentiment_service.py # Análisis de sentimientos (RF-4)
│   │   │   └── report_service.py    # Generación de PDFs
│   │   ├── utils/                   # Utilidades
│   │   │   ├── __init__.py
│   │   │   ├── validators.py        # Validaciones
│   │   │   └── decorators.py        # Decoradores (ej: @login_required)
│   │   └── tests/                   # Pruebas unitarias
│   │       ├── test_auth.py
│   │       ├── test_surveys.py
│   │       └── test_sentiment.py
│   ├── migrations/                  # Migraciones de BD (con Alembic)
│   ├── requirements.txt             # Dependencias Python
│   ├── .env.example                 # Variables de entorno (plantilla)
│   └── run.py                       # Punto de entrada del servidor
│
├── frontend/                        # Cliente React
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/              # Componentes reutilizables
│   │   │   ├── common/              # Botones, inputs, modales
│   │   │   │   ├── Button.jsx
│   │   │   │   ├── Input.jsx
│   │   │   │   └── Modal.jsx
│   │   │   ├── layout/              # Header, Sidebar, Footer
│   │   │   │   ├── Header.jsx
│   │   │   │   └── Sidebar.jsx
│   │   │   └── charts/              # Gráficas
│   │   │       ├── BarChart.jsx
│   │   │       └── PieChart.jsx
│   │   ├── pages/                   # Páginas principales
│   │   │   ├── auth/
│   │   │   │   ├── Login.jsx
│   │   │   │   └── RecoverPassword.jsx
│   │   │   ├── student/
│   │   │   │   └── SurveyForm.jsx   # HU-A-01, HU-A-02
│   │   │   ├── teacher/
│   │   │   │   ├── Dashboard.jsx    # HU-B-04
│   │   │   │   └── Reviews.jsx      # HU-B-01
│   │   │   └── coordinator/
│   │   │       ├── Dashboard.jsx    # HU-C-02, HU-C-04
│   │   │       ├── UserManagement.jsx # HU-C-01
│   │   │       └── Reviews.jsx      # HU-C-06
│   │   ├── services/                # Llamadas a la API
│   │   │   ├── api.js               # Configuración base (axios)
│   │   │   ├── authService.js
│   │   │   ├── surveyService.js
│   │   │   └── dashboardService.js
│   │   ├── context/                 # Estado global (Context API)
│   │   │   └── AuthContext.jsx      # Usuario autenticado
│   │   ├── hooks/                   # Custom hooks
│   │   │   └── useAuth.js
│   │   ├── utils/                   # Utilidades
│   │   │   └── formatters.js        # Formateo de fechas, números, etc.
│   │   ├── App.jsx                  # Componente principal
│   │   └── index.js                 # Punto de entrada
│   ├── package.json                 # Dependencias Node
│   └── tailwind.config.js           # Configuración de Tailwind
│
├── database/                        # Scripts de BD
│   ├── schema.sql                   # Esquema inicial
│   └── seed_data.sql                # Datos de prueba
│
├── docs/                            # Documentación
│   ├── api_documentation.md         # Endpoints de la API
│   ├── user_stories.md              # Tus HUs (ya las tienes)
│   └── deployment_guide.md          # Guía de despliegue
│
├── docker-compose.yml               # Para correr todo con Docker
├── .gitignore
└── README.md                        # Instrucciones del proyecto
```

## Instalación

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python run.py
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Documentación
- [Historias de Usuario](docs/user_stories.md)
- [API Documentation](docs/api_documentation.md)

## Flujo de Trabajo Git
Ver [CONTRIBUTING.md](CONTRIBUTING.md)
>>>>>>> 4b50bf6d81209b20a30e81b868d1c696783bd561
