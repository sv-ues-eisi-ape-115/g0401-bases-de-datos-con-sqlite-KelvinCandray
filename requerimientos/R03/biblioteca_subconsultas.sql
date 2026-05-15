-- =============================================================
-- G0401 — APE 115 — Requerimiento R03
-- Archivo: requerimientos/R03/biblioteca_subconsultas.sql
-- Descripción: Subconsultas — análisis avanzado
-- Autor: (escribe tu nombre aquí)
-- Ejecutar: sqlite3 biblioteca.db < biblioteca_subconsultas.sql
-- =============================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ── R03.1 — Subconsulta ESCALAR ───────────────────────────────
-- Estudiantes que han tomado prestado MÁS libros que el promedio
-- Promedio = CAST(COUNT(*) AS REAL) / COUNT(DISTINCT id_estudiante)
-- TODO:


-- ── R03.2 — Subconsulta CORRELACIONADA ───────────────────────
-- Libros más caros que el precio promedio del MISMO autor
-- (la subconsulta interna debe referenciar id_autor de la consulta externa)
-- TODO:


-- ── R03.3 — NOT IN ────────────────────────────────────────────
-- Estudiantes sin ningún préstamo activo actualmente
-- TODO:


-- ── R03.4 — Correlacionada en SELECT ─────────────────────────
-- Para cada autor: título y precio de su libro más caro
-- TODO:


-- ── R03.5 — Comparación: GROUP BY vs IN ─────────────────────
-- Libros prestados al menos 2 veces — implementar AMBAS versiones:

-- Versión A: GROUP BY + HAVING
-- TODO:

-- Versión B: Subconsulta con IN
-- TODO:

-- Comentario: explica cuál de las dos versiones es más eficiente y por qué
-- TODO: (escribe aquí tu respuesta como comentario SQL)
