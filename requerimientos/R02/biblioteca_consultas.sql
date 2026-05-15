-- =============================================================
-- G0401 — APE 115 — Requerimiento R02
-- Archivo: requerimientos/R02/biblioteca_consultas.sql
-- Descripción: Consultas DML — Reportes de la biblioteca
-- Autor: (escribe tu nombre aquí)
-- Prerequisito: R01/biblioteca_ddl.sql ejecutado
-- Ejecutar: sqlite3 biblioteca.db < biblioteca_consultas.sql
-- =============================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ── R02.1 — Libros disponibles con autor ──────────────────────
-- INNER JOIN libro → autor. Filtrar stock_disponible > 0. Ordenar por título.
-- TODO:


-- ── R02.2 — Estudiantes con préstamos activos ─────────────────
-- INNER JOIN 3 tablas: prestamo → estudiante → libro
-- Mostrar nombre completo (con ||), carnet, título, fecha_devolucion
-- Ordenar por fecha más próxima
-- TODO:


-- ── R02.3 — Top 3 libros más prestados ────────────────────────
-- GROUP BY + COUNT + LIMIT 3
-- TODO:


-- ── R02.4 — Préstamos vencidos con días de retraso ────────────
-- fecha_devolucion < date('now') Y estado='activo'
-- dias_retraso = CAST(julianday(date('now')) - julianday(fecha_devolucion) AS INTEGER)
-- TODO:


-- ── R02.5 — Estadísticas por carrera ──────────────────────────
-- Mostrar: carrera, total_estudiantes, prestamos_activos, prestamos_devueltos
-- LEFT JOIN + GROUP BY + SUM(CASE WHEN ...)
-- TODO:


-- ── R02.6 — Libros NUNCA prestados ────────────────────────────
-- LEFT JOIN libro → prestamo WHERE id_prestamo IS NULL
-- TODO:
