-- consultas_agrupadas.sql
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- 5.1 Resumen estadístico general de productos
SELECT COUNT(*)              AS total_productos,
       COUNT(descripcion)    AS con_descripcion,
       ROUND(AVG(precio),2)  AS precio_promedio,
       MAX(precio)           AS precio_maximo,
       MIN(precio)           AS precio_minimo,
       SUM(stock)            AS stock_total
FROM   producto WHERE activo = 1;

-- 5.2 Productos y estadísticas por categoría (LEFT JOIN + GROUP BY)
SELECT   c.nombre                    AS categoria,
         COUNT(p.id_producto)         AS total_productos,
         ROUND(AVG(p.precio), 2)      AS precio_promedio,
         SUM(p.stock)                 AS stock_total
FROM     categoria c
LEFT     JOIN producto p ON c.id_categoria = p.id_categoria
                        AND p.activo = 1
GROUP    BY c.id_categoria, c.nombre
ORDER    BY total_productos DESC;

-- 5.3 Solo categorías con más de 2 productos (HAVING)
-- HAVING filtra GRUPOS, WHERE filtra FILAS individuales
SELECT   c.nombre, COUNT(p.id_producto) AS total
FROM     categoria c
INNER    JOIN producto p ON c.id_categoria = p.id_categoria
                        AND p.activo = 1
GROUP    BY c.id_categoria
HAVING   COUNT(p.id_producto) > 2
ORDER    BY total DESC;

-- 5.4 Ventas por cliente con total gastado
SELECT   cl.nombres || ' ' || cl.apellidos  AS cliente,
         COUNT(v.id_venta)                  AS num_ventas,
         ROUND(SUM(v.total), 2)             AS total_gastado
FROM     cliente cl
LEFT     JOIN venta v ON cl.id_cliente = v.id_cliente AND v.anulada = 0
GROUP    BY cl.id_cliente
ORDER    BY total_gastado DESC;

-- Nota SQLite: concatenación con || en lugar de CONCAT() de MySQL
