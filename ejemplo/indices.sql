-- indices.sql — Análisis de consultas con EXPLAIN
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- 8.1 Ver el plan de ejecución SIN índice personalizado
EXPLAIN QUERY PLAN
SELECT * FROM producto WHERE nombre LIKE 'Café%';

-- 8.2 Crear índice compuesto (categoría + precio)
CREATE INDEX IF NOT EXISTS idx_prod_cat_precio
    ON producto(id_categoria, precio);

-- 8.3 Ver el plan CON el índice compuesto
EXPLAIN QUERY PLAN
SELECT nombre, precio FROM producto
WHERE id_categoria = 1 AND precio <= 2.00;

-- 8.4 Listar todos los índices de la tabla producto
PRAGMA index_list(producto);

-- 8.5 Ver las columnas de un índice específico
PRAGMA index_info(idx_prod_cat_precio);

-- 8.6 Eliminar un índice
-- DROP INDEX IF EXISTS idx_prod_cat_precio;

-- 8.7 Estadísticas de todas las tablas
SELECT name, type FROM sqlite_master
WHERE type IN ('table','index','view','trigger')
ORDER BY type, name;
