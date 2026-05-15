-- consultas_basicas.sql
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- 4.1 Todos los productos activos con su categoría (INNER JOIN)
SELECT p.nombre, p.precio, p.stock, c.nombre AS categoria
FROM   producto p
INNER  JOIN categoria c ON p.id_categoria = c.id_categoria
WHERE  p.activo = 1
ORDER  BY c.nombre ASC, p.precio DESC;

-- 4.2 Productos entre $1.00 y $2.00 (BETWEEN)
SELECT nombre, precio FROM producto
WHERE  precio BETWEEN 1.00 AND 2.00 AND activo = 1
ORDER  BY precio;

-- 4.3 Búsqueda parcial por nombre (LIKE)
SELECT nombre, precio FROM producto
WHERE  nombre LIKE '%café%' AND activo = 1;

-- 4.4 Productos de categorías Bebidas (IN con subconsulta)
SELECT p.nombre, p.precio
FROM   producto p
WHERE  p.id_categoria IN (
    SELECT id_categoria FROM categoria
    WHERE  nombre LIKE '%Bebidas%'
);

-- 4.5 Clientes con CASE WHEN para teléfono
SELECT nombres, apellidos,
       CASE WHEN telefono IS NULL THEN 'Sin teléfono'
            ELSE telefono END AS contacto
FROM   cliente WHERE activo = 1 ORDER BY apellidos;

-- 4.6 Paginación: segunda página de 5 productos
SELECT nombre, precio FROM producto
WHERE  activo = 1 ORDER BY nombre LIMIT 5 OFFSET 5;

-- 4.7 Baja lógica (estándar APE115: nunca DELETE en registros de negocio)
-- UPDATE producto SET activo = 0 WHERE id_producto = 1;
-- Para verificar las bajas lógicas:
SELECT nombre, activo FROM producto ORDER BY activo DESC, nombre;
