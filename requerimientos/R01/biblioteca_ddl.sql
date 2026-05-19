
-- Requerimiento R01 — Base de Datos de Biblioteca


-- Activar el soporte de llaves foráneas al inicio del script
PRAGMA foreign_keys = ON;

-- Configuración para que las salidas de verificación sean legibles
.headers on
.mode column

-- 1. CREACIÓN DE TABLAS ( usando CREATE TABLE IF NOT EXISTS)


-- "INTEGER PRIMARY KEY" es el pk_ implícito en SQLite (autoincrementa automáticamente)
CREATE TABLE IF NOT EXISTS autores (
    id_autor INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS libros (
    id_libro INTEGER PRIMARY KEY,
    titulo TEXT NOT NULL,
    stock_disponible INTEGER NOT NULL DEFAULT 0,
    precio REAL NOT NULL DEFAULT 0.0, -- <- Agregar este campo para R03
    id_autor INTEGER NOT NULL,
    CONSTRAINT fk_libros_autores FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS estudiantes (
    id_estudiante INTEGER PRIMARY KEY,
    carnet TEXT NOT NULL UNIQUE,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    carrera TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS prestamos (
    id_prestamo INTEGER PRIMARY KEY,
    id_estudiante INTEGER NOT NULL,
    id_libro INTEGER NOT NULL,
    fecha_prestamo TEXT NOT NULL DEFAULT (date('now')),
    fecha_devolucion TEXT NOT NULL,
    estado TEXT NOT NULL CHECK(estado IN ('activo', 'devuelto')),
    CONSTRAINT fk_prestamos_estudiantes FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_prestamos_libros FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE
);

-- 2. CREACIÓN DE ÍNDICES

CREATE INDEX IF NOT EXISTS idx_libros_titulo ON libros(titulo);
CREATE INDEX IF NOT EXISTS idx_prestamos_estudiante ON prestamos(id_estudiante);
CREATE INDEX IF NOT EXISTS idx_prestamos_libro ON prestamos(id_libro);

-- 3. INSERCIÓN DE DATOS DE PRUEBA

--  Insertar 3 Autores
INSERT OR IGNORE INTO autores (id_autor, nombre) VALUES
(1, 'Gabriel García Márquez'),
(2, 'George Orwell'),
(3, 'J.K. Rowling');

-- Insertar 6 Libros
INSERT OR IGNORE INTO libros (id_libro, titulo, stock_disponible, id_autor) VALUES
(1, 'Cien años de soledad', 5, 1),
(2, 'Crónica de una muerte anunciada', 0, 1),
(3, '1984', 3, 2),
(4, 'Rebelión en la granja', 2, 2),
(5, 'Harry Potter y la piedra filosofal', 4, 3),
(6, 'Harry Potter y la cámara secreta', 1, 3);

-- Insertar 4 Estudiantes
INSERT OR IGNORE INTO estudiantes (id_estudiante, carnet, nombres, apellidos, carrera) VALUES
(1, 'AA23001', 'Juan Antonio', 'Pérez Gómez', 'Ingeniería de Sistemas'),
(2, 'BB23002', 'María Elena', 'López Rivas', 'Ingeniería de Sistemas'),
(3, 'CC23003', 'Carlos Alberto', 'Martínez Henríquez', 'Licenciatura en Informática'),
(4, 'DD23004', 'Ana Beatriz', 'Rodríguez Orellana', 'Ingeniería Industrial');

-- Insertar 5 Préstamos de prueba
INSERT OR IGNORE INTO prestamos (id_prestamo, id_estudiante, id_libro, fecha_prestamo, fecha_devolucion, estado) VALUES
(1, 1, 1, '2026-05-01', '2026-05-15', 'devuelto'),
(2, 1, 3, '2026-05-10', '2026-05-24', 'activo'),
(3, 2, 1, '2026-05-05', '2026-05-19', 'activo'),
(4, 3, 4, '2026-04-10', '2026-04-24', 'activo'),
(5, 2, 2, '2026-04-15', '2026-04-29', 'activo');

-- Consulta de verificación rápida de carga
SELECT p.id_prestamo, (e.nombres || ' ' || e.apellidos) AS estudiante, l.titulo, p.estado
FROM prestamos p
JOIN estudiantes e ON p.id_estudiante = e.id_estudiante
JOIN libros l ON p.id_libro = l.id_libro;
