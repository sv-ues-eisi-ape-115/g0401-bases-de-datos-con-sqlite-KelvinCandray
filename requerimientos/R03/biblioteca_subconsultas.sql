--
-- Requerimiento R03 — Subconsultas — Análisis Avanzado
--

.headers on
.mode column

-- RN-R03.4: EXPLICACIÓN DE DIFERENCIA ENTRE SUBCONSULTA ESCALAR Y CORRELACIONADA

-- Subconsulta Escalar: Es independiente de la consulta externa, se ejecuta una sola vez y devuelve un único valor constante.

--Subconsulta Correlacionada: Depende de filas de la consulta externa; se ejecuta de manera iterativa fila por fila analizada por el bloque principal.

-- 1: Estudiantes que han tomado prestado más libros que el promedio de préstamos por estudiante (subconsulta escalar en WHERE).
SELECT (e.nombres || ' ' || e.apellidos) AS estudiante, COUNT(p.id_prestamo) AS total_prestamos
FROM estudiantes e JOIN prestamos p ON e.id_estudiante = p.id_estudiante
GROUP BY e.id_estudiante
HAVING COUNT(p.id_prestamo) > (
SELECT COUNT(*) * 1.0 / COUNT(DISTINCT id_estudiante)
FROM prestamos
);

-- 2: Libros cuyo precio es mayor que el precio promedio de libros del mismo autor (subconsulta correlacionada — referencia id_autor de la consulta externa)
SELECT l_ext.titulo, l_ext.precio, l_ext.id_autor FROM libros l_ext
WHERE l_ext.precio > ( SELECT AVG(l_int.precio) FROM libros l_int
WHERE l_int.id_autor = l_ext.id_autor
);

-- 3: Estudiantes sin ningún préstamo activo actualmente (subconsulta con NOT IN).
-- NOta: "NOT IN" y "LEFT JOIN + IS NULL" dan el mismo resultado porque ambos representan la diferencia de conjuntos (A - B) en álgebra relacional, filtrando exclusiones directas.
SELECT e.id_estudiante, (e.nombres || ' ' || e.apellidos) AS estudiante
FROM estudiantes e
WHERE e.id_estudiante NOT IN ( SELECT p.id_estudiante FROM prestamos p
WHERE p.estado = 'activo' AND p.id_estudiante IS NOT NULL
);

-- 4: Para cada autor, el título y precio de su libro más caro (subconsulta correlacionada en el SELECT o en el WHERE).
SELECT l_ext.id_autor, l_ext.titulo, l_ext.precio
FROM libros l_ext
WHERE l_ext.precio = ( SELECT MAX(l_int.precio) FROM libros l_int
WHERE l_int.id_autor = l_ext.id_autor
);

-- 5: Libros prestados al menos 2 veces — comparar usando subconsulta con HAVING vs con IN.
SELECT id_libro, titulo FROM libros WHERE id_libro IN ( SELECT id_libro
FROM prestamos GROUP BY id_libro HAVING COUNT(id_prestamo) >= 2
);
