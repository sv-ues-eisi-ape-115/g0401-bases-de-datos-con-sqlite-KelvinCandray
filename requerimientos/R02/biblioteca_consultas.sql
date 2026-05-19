--
-- Requerimiento R02 — Consultas DML — Reportes de la Biblioteca
--

-- Asegurar la correcta visualización de las columnas en la terminal
.headers on
.mode column



-- 1: Todos los libros disponibles (stock_disponible > 0) con nombre del autor, ordenados por título.

SELECT l.titulo, a.nombre AS autor, l.stock_disponible
FROM libros l JOIN autores a ON l.id_autor = a.id_autor
WHERE l.stock_disponible > 0
ORDER BY l.titulo ASC;

-- 2: Estudiantes con préstamos activos: nombre completo con ||, carnet, título del libro y fecha de devolución; ordenar por fecha más próxima

SELECT (e.nombres || ' ' || e.apellidos) AS estudiante_completo, e.carnet, l.titulo AS titulo_libro, p.fecha_devolucion
FROM prestamos p JOIN estudiantes e ON p.id_estudiante = e.id_estudiante
JOIN libros l ON p.id_libro = l.id_libro
WHERE p.estado = 'activo'
ORDER BY p.fecha_devolucion ASC;

--  3: Top 3 libros con mayor número de préstamos históricos (incluye devueltos). Usar GROUP BY + COUNT.

SELECT l.titulo, COUNT(p.id_prestamo) AS total_prestamos
FROM libros l JOIN prestamos p ON l.id_libro = p.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY total_prestamos DESC
LIMIT 3;

-- 4: Préstamos vencidos: fecha_devolucion < date('now') y estado = 'activo'. Mostrar nombre del estudiante, título del libro y días de retraso calculado con julianday(date('now')) - julianday(fecha_devolucion).

SELECT (e.nombres || ' ' || e.apellidos) AS estudiante, l.titulo AS titulo_libro, p.fecha_devolucion,
CAST(julianday(date('now')) - julianday(p.fecha_devolucion) AS INTEGER) AS dias_retraso
FROM prestamos p JOIN estudiantes e ON p.id_estudiante = e.id_estudiante
JOIN libros l ON p.id_libro = l.id_libro WHERE p.fecha_devolucion < date('now')
  AND p.estado = 'activo';

-- 5: Estadísticas por carrera: total de estudiantes, préstamos activos y devueltos. Usar GROUP BY + COUNT con LEFT JOIN.

SELECT e.carrera, COUNT(DISTINCT e.id_estudiante) AS total_estudiantes,
COUNT(CASE WHEN p.estado = 'activo' THEN 1 END) AS prestamos_activos,
COUNT(CASE WHEN p.estado = 'devuelto' THEN 1 END) AS prestamos_devueltos
FROM estudiantes e LEFT JOIN prestamos p ON e.id_estudiante = p.id_estudiante
GROUP BY e.carrera;

-- 6: Libros que NUNCA han sido prestados usando LEFT JOIN + WHERE id_prestamo IS NULL.

SELECT l.id_libro, l.titulo
FROM libros l
LEFT JOIN prestamos p ON l.id_libro = p.id_libro
WHERE p.id_prestamo IS NULL;
