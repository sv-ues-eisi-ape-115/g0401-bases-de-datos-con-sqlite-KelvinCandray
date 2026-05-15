-- dml_insert.sql — Datos de prueba
PRAGMA foreign_keys = ON;

-- INSERT OR IGNORE: si la fila ya existe (UNIQUE), se omite sin error
-- Útil para ejecutar el script varias veces sin duplicar datos
INSERT OR IGNORE INTO categoria(nombre, descripcion) VALUES
    ('Bebidas calientes', 'Café, té, chocolate y similares'),
    ('Bebidas frías',     'Jugos, refrescos y agua'),
    ('Comida rápida',     'Sandwiches, hamburguesas y wraps'),
    ('Repostería',        'Pasteles, galletas y pan dulce'),
    ('Snacks',            'Papas, maíz y botanas');

INSERT OR IGNORE INTO producto(nombre, precio, stock, id_categoria) VALUES
    ('Café americano',     1.25, 100, 1),
    ('Café con leche',     1.50, 100, 1),
    ('Cappuccino',         1.75,  80, 1),
    ('Té verde',           1.00,  60, 1),
    ('Jugo de naranja',    1.50,  50, 2),
    ('Agua embotellada',   0.50, 200, 2),
    ('Refresco 350ml',     0.75, 150, 2),
    ('Sandwich jamón',     2.50,  40, 3),
    ('Hamburguesa simple', 3.50,  30, 3),
    ('Wrap pollo',         3.00,  25, 3),
    ('Pastel de chocolate',1.75,  20, 4),
    ('Galletas surtidas',  0.50,  80, 4),
    ('Pan dulce',          0.35, 100, 4),
    ('Papas fritas',       1.00,  60, 5),
    ('Maíz tostado',       0.75,  80, 5);

INSERT OR IGNORE INTO cliente(nombres, apellidos, email, telefono) VALUES
    ('Ana',    'García',    'ana.garcia@ues.edu.sv',     '7711-0001'),
    ('Carlos', 'Martínez',  'carlos.martinez@ues.edu.sv','7722-0002'),
    ('María',  'López',     'maria.lopez@ues.edu.sv',    '7733-0003'),
    ('José',   'Hernández', 'jose.hernandez@ues.edu.sv', NULL       ),
    ('Sofía',  'Rodríguez', 'sofia.rodriguez@ues.edu.sv','7755-0005');

-- Ventas (id_cliente referencias a los 5 clientes)
INSERT INTO venta(id_cliente) VALUES (1),(2),(1),(3),(4);

-- Detalles de venta con subtotal calculado (cantidad * precio_unit)
INSERT INTO detalle_venta(cantidad, precio_unit, subtotal, id_venta, id_producto) VALUES
    (2, 1.25, 2.50, 1,  1),  -- venta 1: 2 cafés americanos
    (1, 2.50, 2.50, 1,  8),  -- venta 1: 1 sandwich jamón
    (1, 1.75, 1.75, 2,  3),  -- venta 2: 1 cappuccino
    (1, 1.75, 1.75, 2, 11),  -- venta 2: 1 pastel de chocolate
    (3, 0.35, 1.05, 3, 13),  -- venta 3: 3 panes dulces
    (2, 1.00, 2.00, 3, 14),  -- venta 3: 2 papas fritas
    (1, 3.50, 3.50, 4,  9),  -- venta 4: 1 hamburguesa
    (1, 0.75, 0.75, 4,  7),  -- venta 4: 1 refresco
    (2, 1.50, 3.00, 5,  2),  -- venta 5: 2 cafés con leche
    (1, 0.50, 0.50, 5, 12);  -- venta 5: 1 galletas surtidas

-- Actualizar totales de venta
UPDATE venta SET total = (
    SELECT SUM(subtotal) FROM detalle_venta
    WHERE id_venta = venta.id_venta
);

SELECT 'Datos insertados OK' AS resultado;
SELECT 'Productos: ' || COUNT(*) FROM producto;
SELECT 'Clientes: '  || COUNT(*) FROM cliente;
SELECT 'Ventas: '    || COUNT(*) FROM venta;
