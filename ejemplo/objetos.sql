-- objetos.sql — Vistas y triggers en SQLite
PRAGMA foreign_keys = ON;

-- ════════════════════════════════════════════════════
-- VISTA: vw_venta_detalle
-- Prefijo vw_ — estándar APE115
-- ════════════════════════════════════════════════════
DROP VIEW IF EXISTS vw_venta_detalle;

CREATE VIEW vw_venta_detalle AS
SELECT v.id_venta,
       v.fecha,
       cl.nombres || ' ' || cl.apellidos  AS cliente,
       p.nombre                            AS producto,
       c.nombre                            AS categoria,
       dv.cantidad,
       dv.precio_unit,
       dv.subtotal,
       v.total                             AS total_venta
FROM   venta v
INNER  JOIN cliente       cl ON v.id_cliente   = cl.id_cliente
INNER  JOIN detalle_venta dv ON v.id_venta     = dv.id_venta
INNER  JOIN producto      p  ON dv.id_producto = p.id_producto
INNER  JOIN categoria     c  ON p.id_categoria = c.id_categoria
WHERE  v.anulada = 0;

-- Probar la vista
SELECT * FROM vw_venta_detalle LIMIT 5;

-- ════════════════════════════════════════════════════
-- TRIGGER: auditoría de cambios de stock
-- Prefijo trg_ — estándar APE115
-- Nota: SQLite NO tiene DELIMITER; la sintaxis es directa
-- ════════════════════════════════════════════════════

-- Tabla de auditoría (crear si no existe)
CREATE TABLE IF NOT EXISTS auditoria_stock (
    id_auditoria  INTEGER  PRIMARY KEY AUTOINCREMENT,
    id_producto   INTEGER  NOT NULL,
    nombre_prod   TEXT     NOT NULL,
    stock_antes   INTEGER  NOT NULL,
    stock_nuevo   INTEGER  NOT NULL,
    fecha_cambio  TEXT     NOT NULL DEFAULT (datetime('now','localtime'))
);

DROP TRIGGER IF EXISTS trg_producto_stock_audit;

CREATE TRIGGER trg_producto_stock_audit
AFTER UPDATE OF stock ON producto
FOR EACH ROW
WHEN OLD.stock <> NEW.stock
BEGIN
    INSERT INTO auditoria_stock(id_producto, nombre_prod,
                               stock_antes, stock_nuevo)
    VALUES (OLD.id_producto,
            OLD.nombre,
            OLD.stock,
            NEW.stock);
END;

-- Probar el trigger
UPDATE producto SET stock = stock - 5 WHERE id_producto = 1;
UPDATE producto SET stock = stock - 3 WHERE id_producto = 2;

SELECT p.nombre, a.stock_antes, a.stock_nuevo,
       a.stock_nuevo - a.stock_antes AS diferencia,
       a.fecha_cambio
FROM   auditoria_stock a
INNER  JOIN producto p ON a.id_producto = p.id_producto;
