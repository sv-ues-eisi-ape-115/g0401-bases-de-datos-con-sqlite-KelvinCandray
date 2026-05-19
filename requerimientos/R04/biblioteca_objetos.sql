--
-- Requerimiento R04 — Vistas y Triggers — SQLite
--


.headers on
.mode column

-- CREANDO VISTAS

CREATE VIEW IF NOT EXISTS vw_prestamo_activo AS
SELECT p.id_prestamo, e.carnet, (e.nombres || ' ' || e.apellidos) AS estudiante, l.titulo, p.fecha_devolucion
FROM prestamos p
JOIN estudiantes e ON p.id_estudiante = e.id_estudiante
JOIN libros l ON p.id_libro = l.id_libro
WHERE p.estado = 'activo';

CREATE VIEW IF NOT EXISTS vw_libro_disponibilidad AS
SELECT id_libro, titulo, stock_disponible
FROM libros;



-- Triggers  (RN-R04.4: DROP previo)
DROP TRIGGER IF EXISTS trg_prestamo_nuevo;
CREATE TRIGGER trg_prestamo_nuevo
BEFORE INSERT ON prestamos
FOR EACH ROW
WHEN (SELECT stock_disponible FROM libros WHERE id_libro = NEW.id_libro) <= 0
BEGIN
    SELECT RAISE(ROLLBACK, 'Operación Cancelada: El libro seleccionado no cuenta con unidades disponibles en stock.');
END;

-- CREANDO TRIGGERS
DROP TRIGGER IF EXISTS trg_actualizar_stock_prestamo;
CREATE TRIGGER trg_actualizar_stock_prestamo
AFTER INSERT ON prestamos
FOR EACH ROW
BEGIN
    UPDATE libros SET stock_disponible = stock_disponible - 1 WHERE id_libro = NEW.id_libro;
END;

DROP TRIGGER IF EXISTS trg_restaurar_stock_devolucion;
CREATE TRIGGER trg_restaurar_stock_devolucion
AFTER UPDATE OF estado ON prestamos
FOR EACH ROW
WHEN NEW.estado = 'devuelto' AND OLD.estado = 'activo'
BEGIN
    UPDATE libros SET stock_disponible = stock_disponible + 1 WHERE id_libro = NEW.id_libro;
END;
