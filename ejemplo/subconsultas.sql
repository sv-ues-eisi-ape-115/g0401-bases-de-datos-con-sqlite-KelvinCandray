-- subconsultas.sql
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- 6.1 ESCALAR: productos más caros que el precio promedio general
SELECT nombre, precio
FROM   producto
WHERE  precio > (SELECT AVG(precio) FROM producto WHERE activo = 1)
  AND  activo = 1
ORDER  BY precio DESC;

-- 6.2 CON IN: productos que han sido vendidos al menos una vez
SELECT nombre, precio
FROM   producto
WHERE  id_producto IN (
    SELECT DISTINCT id_producto FROM detalle_venta
)
ORDER  BY nombre;

-- 6.3 NOT IN: productos que NUNCA han sido vendidos
SELECT nombre, precio
FROM   producto
WHERE  id_producto NOT IN (
    SELECT DISTINCT id_producto FROM detalle_venta
)
AND activo = 1;

-- 6.4 CORRELACIONADA: productos más caros que el promedio
--     de SU propia categoría
SELECT p.nombre,
       ROUND(p.precio, 2) AS precio,
       ROUND((
           SELECT AVG(p2.precio)
           FROM   producto p2
           WHERE  p2.id_categoria = p.id_categoria
             AND  p2.activo = 1
       ), 2) AS prom_categoria
FROM   producto p
WHERE  p.precio > (
    SELECT AVG(p3.precio)
    FROM   producto p3
    WHERE  p3.id_categoria = p.id_categoria AND p3.activo = 1
) AND p.activo = 1
ORDER  BY p.id_categoria, p.precio DESC;
