-- =============================================================
-- G0401 — APE 115 — Requerimiento R04
-- Archivo: requerimientos/R04/biblioteca_objetos.sql
-- Descripción: Vistas y Triggers con sintaxis SQLite
-- Autor: (escribe tu nombre aquí)
-- Ejecutar: sqlite3 biblioteca.db < biblioteca_objetos.sql
-- =============================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ── VISTA 1: vw_prestamo_activo ───────────────────────────────
-- Columnas requeridas:
--   id_prestamo, fecha_prestamo, fecha_devolucion,
--   dias_restantes = ROUND(julianday(fecha_devolucion) - julianday(date('now')))
--   estado, nombre completo (con ||), carnet, titulo del libro, isbn
-- Solo préstamos con estado = 'activo'
DROP VIEW IF EXISTS vw_prestamo_activo;
-- TODO: CREATE VIEW vw_prestamo_activo AS ...


-- ── VISTA 2: vw_libro_disponibilidad ─────────────────────────
-- Columnas: titulo, autor (nombre), stock_total, stock_disponible,
--   prestados_ahora = (stock_total - stock_disponible),
--   pct_disponible = ROUND(stock_disponible * 100.0 / stock_total)
DROP VIEW IF EXISTS vw_libro_disponibilidad;
-- TODO: CREATE VIEW vw_libro_disponibilidad AS ...


-- ── TRIGGER 1: trg_prestamo_nuevo ────────────────────────────
-- AFTER INSERT ON prestamo FOR EACH ROW
-- Acción: decrementa stock_disponible del libro
-- Validación: si stock < 0 → RAISE(ROLLBACK, 'Sin stock disponible')
DROP TRIGGER IF EXISTS trg_prestamo_nuevo;
-- TODO: CREATE TRIGGER trg_prestamo_nuevo
--       AFTER INSERT ON prestamo FOR EACH ROW
--       BEGIN
--           UPDATE libro SET stock_disponible = stock_disponible - 1
--           WHERE id_libro = NEW.id_libro;
--           SELECT CASE WHEN (SELECT stock_disponible FROM libro
--                             WHERE id_libro = NEW.id_libro) < 0
--                       THEN RAISE(ROLLBACK, 'Sin stock disponible')
--                  END;
--       END;


-- ── TRIGGER 2: trg_prestamo_devuelto ─────────────────────────
-- AFTER UPDATE ON prestamo FOR EACH ROW
-- WHEN NEW.estado = 'devuelto' AND NEW.fecha_devuelto IS NULL
-- Acción: asigna fecha_devuelto, incrementa stock_disponible
DROP TRIGGER IF EXISTS trg_prestamo_devuelto;
-- TODO: CREATE TRIGGER trg_prestamo_devuelto
--       AFTER UPDATE ON prestamo FOR EACH ROW
--       WHEN NEW.estado = 'devuelto' AND NEW.fecha_devuelto IS NULL
--       BEGIN
--           UPDATE prestamo SET fecha_devuelto = datetime('now','localtime')
--           WHERE id_prestamo = OLD.id_prestamo;
--           UPDATE libro SET stock_disponible = stock_disponible + 1
--           WHERE id_libro = OLD.id_libro;
--       END;


-- ── Prueba del flujo completo (reemplaza los TODO) ────────────
-- 1. Registrar un nuevo préstamo
-- TODO: INSERT INTO prestamo(fecha_devolucion, id_estudiante, id_libro)
--       VALUES (date('now', '+7 days'), 1, 1);

-- 2. Verificar disponibilidad
-- SELECT * FROM vw_libro_disponibilidad;

-- 3. Devolver el préstamo
-- TODO: UPDATE prestamo SET estado = 'devuelto'
--       WHERE id_prestamo = (SELECT MAX(id_prestamo) FROM prestamo);

-- 4. Verificar que la vista ya no lo muestra
-- SELECT * FROM vw_prestamo_activo;
