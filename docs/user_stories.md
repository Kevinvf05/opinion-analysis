# Problematica a resolver
## Contexto  
"Existe un momento importante en el que los alumnos evalúan a los profesores, ya que, al final del **formulario de evaluación**, aparece una **sección de comentarios**. Sin embargo, esta sección suele quedar *desaprovechada*: nadie la revisa ni se utiliza esa información adecuadamente.

Como ***coordinadora***, tengo la necesidad de poder clasificar esos comentarios para tomar decisiones informadas. Por ejemplo, si un ***profesor*** recibe muchos comentarios negativos, probablemente lo recorte para el siguiente semestre. No tiene sentido que siga impartiendo clases si los estudiantes no están aprendiendo o no tienen una buena percepción de su enseñanza. Por eso, es necesario desarrollar esta habilidad de análisis y uso de esa información.

*¿Cómo quiero clasificar los comentarios?* En tres categorías: **positivos, negativos y neutros**. Los neutros son aquellos que no aportan valor significativo a la evaluación del docente.

Este sistema estará disponible para tres tipos de usuarios: el ***coordinador de carrera, los profesores y, posiblemente, los estudiantes.***

- Los alumnos lo utilizarán al llenar la encuesta de satisfacción. Una vez que completen la evaluación, todos los comentarios quedarán registrados.

- Los profesores podrán acceder a sus propios comentarios mediante un sistema de filtros. Por ejemplo, un docente podrá buscarse por su nombre y ver todos los comentarios que ha recibido. Si ha impartido dos materias, podrá ver los comentarios agrupados o filtrarlos por cada una.

- Se podrán aplicar filtros por materia y por tipo de comentario (positivo, negativo o neutro). Esto puede hacerse de forma general o por asignatura específica.

- Además, el sistema permitirá exportar los comentarios en formato PDF para que el profesor pueda guardarlos como parte de su historial docente.

- Solo el coordinador de carrera tendrá permiso para registrar nuevos profesores en el sistema. Los profesores no podrán registrarse por cuenta propia, y solo recibirán acceso una vez que estén oficialmente asignados.

- Este sistema estará disponible antes de finalizar el semestre y durante el periodo vacacional, para que los profesores puedan revisar los comentarios recibidos.

- Finalmente, al inicio del sistema, quiero que haya un dashboard donde se muestre la información que le esta proporcionando la encuesta al profesor."

## Historias de Usuario  

### Estudiantes  
- **HU-A-01:**  
  Como estudiante matriculado en el semestre vigente (identificado por su matrícula), quiero responder una encuesta obligatoria por cada profesor que cursé, para que mi opinión quede registrada.  
  **Beneficio:** Asegurar la recolección de la opinión esencial de los alumnos.  

- **HU-A-02:**  
  Como estudiante matriculado en el semestre vigente (identificado por su matrícula), quiero dejar un comentario libre al final de la encuesta, para aportar retroalimentación cualitativa.  
  **Beneficio:** Obtener observaciones que ayuden a mejorar la enseñanza.  

- **HU-A-03:**  
  Como estudiante matriculado en el semestre vigente (identificado por su matrícula), quiero iniciar sesión con matrícula y contraseña, para acceder al sistema y responder encuestas.  
  **Beneficio:** Controlar el acceso y relacionar respuestas con el estudiante.  

---

### Profesor  
- **HU-B-01:**  
  Como profesor asignado en la institución (identificado por su correo institucional), quiero ver todas las reseñas y comentarios que me han dejado, para conocer la opinión de mis alumnos.  
  **Beneficio:** Permite al docente revisar su desempeño y reflexionar sobre su práctica.  

- **HU-B-02:**  
  Como profesor asignado en la institución (identificado por su correo institucional), quiero que las reseñas se muestren de forma anónima, para proteger la identidad del estudiante.  
  **Beneficio:** Fomentar respuestas sinceras y proteger la privacidad.  

- **HU-B-03:**  
  Como profesor asignado en la institución (identificado por su correo institucional), quiero iniciar sesión con correo institucional y contraseña, para acceder a mis comentarios y herramientas.  
  **Beneficio:** Acceso seguro y personalizado al entorno docente.  

- **HU-B-04:**  
  Como profesor asignado en la institución (identificado por su correo institucional), quiero ver un panel con gráficos básicos (promedio de evaluaciones y participación), para revisar mis resultados de manera visual.  
  **Beneficio:** Facilitar la interpretación rápida de indicadores relevantes.  

---

### Coordinador  
- **HU-C-01:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero registrar y gestionar cuentas de profesores, para que solo el personal autorizado tenga acceso.  
  **Beneficio:** Mantener control administrativo y seguridad en el acceso.  

- **HU-C-02:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero ver un panel con indicadores agregados (desempeño global y participación), para monitorear la calidad docente a nivel de carrera.  
  **Beneficio:** Tomar decisiones informadas a partir de datos consolidados.  

- **HU-C-03:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero filtrar el panel por materia y por rango de fechas, para obtener análisis específicos.  
  **Beneficio:** Permitir foco en materias o periodos con problemas o mejoras.  

- **HU-C-04:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero ver el promedio de evaluaciones por profesor en una gráfica de barras, para comparar rendimiento entre docentes.  
  **Beneficio:** Visualizar comparaciones para priorizar acciones.  

- **HU-C-05:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero ver el porcentaje de participación de alumnos por materia, para detectar materias con baja respuesta.  
  **Beneficio:** Medir validez de los resultados y detectar necesidades de incentivos.  

- **HU-C-06:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero consultar las reseñas y comentarios de cada profesor por materia, para evaluar desempeño por asignatura.  
  **Beneficio:** Permite análisis más fino y acciones específicas por materia.  

- **HU-C-07:**  
  Como coordinador de la carrera (con privilegios administrativos) y profesor asignado, quiero exportar reseñas y métricas a PDF, para archivar o compartir reportes oficiales.  
  **Beneficio:** Facilitar documentación y evidencias administrativas.  

- **HU-C-08:**  
  Como coordinador de la carrera (con privilegios administrativos), quiero iniciar sesión con credenciales administrativas, para gestionar la plataforma con seguridad.  
  **Beneficio:** Asegurar que solo personal autorizado pueda administrar el sistema.  

