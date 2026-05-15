-- =============================================================
-- G0401 — APE 115 — Requerimiento R01
-- Archivo: requerimientos/R01/biblioteca_ddl.sql
-- Descripción: DDL completo del sistema de biblioteca
-- Autor: (escribe tu nombre aquí)
-- Ejecutar: sqlite3 biblioteca.db < biblioteca_ddl.sql
-- =============================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column

-- TODO R01.1: Crear tabla 'autor'
-- Columnas: id_autor (PK AUTOINCREMENT), nombre TEXT NOT NULL,
--           nacionalidad TEXT, activo INTEGER DEFAULT 1
-- CREATE TABLE IF NOT EXISTS autor ( ... );


-- TODO R01.2: Crear tabla 'libro'
-- Columnas: id_libro (PK), titulo NOT NULL, isbn TEXT UNIQUE,
--           precio REAL CHECK(>0), stock_total INTEGER DEFAULT 5,
--           stock_disponible INTEGER DEFAULT 5, activo INTEGER DEFAULT 1,
--           id_autor (FK → autor ON DELETE RESTRICT ON UPDATE CASCADE)
-- CREATE TABLE IF NOT EXISTS libro ( ... );


-- TODO R01.3: Crear tabla 'estudiante'
-- Columnas: id_estudiante (PK), carnet TEXT UNIQUE NOT NULL,
--           nombres TEXT NOT NULL, apellidos TEXT NOT NULL,
--           email TEXT UNIQUE, carrera TEXT, activo INTEGER DEFAULT 1
-- CREATE TABLE IF NOT EXISTS estudiante ( ... );


-- TODO R01.4: Crear tabla 'prestamo'
-- Columnas: id_prestamo (PK), fecha_prestamo TEXT DEFAULT datetime('now','localtime'),
--           fecha_devolucion TEXT NOT NULL, fecha_devuelto TEXT,
--           estado TEXT DEFAULT 'activo' CHECK(estado IN ('activo','devuelto','vencido')),
--           id_estudiante (FK → estudiante), id_libro (FK → libro ON DELETE RESTRICT)
-- CREATE TABLE IF NOT EXISTS prestamo ( ... );


-- TODO R01.5: Crear índices
-- Usar prefijo idx_ (estándar APE115)
-- En todas las FK, en libro(titulo) y en prestamo(estado)
-- CREATE INDEX IF NOT EXISTS idx_... ON ...;


-- TODO R01.6: Insertar datos de prueba con INSERT OR IGNORE
-- Mínimo: 3 autores, 6 libros, 4 estudiantes, 5 préstamos
-- INSERT OR IGNORE INTO autor(nombre, nacionalidad) VALUES (...);


-- Verificación automática (NO modificar estas líneas)
SELECT 'tablas=' || COUNT(*) FROM sqlite_master
WHERE  type = 'table' AND name IN ('autor','libro','estudiante','prestamo');
SELECT 'autores='     || COUNT(*) FROM autor;
SELECT 'libros='      || COUNT(*) FROM libro;
SELECT 'estudiantes=' || COUNT(*) FROM estudiante;
SELECT 'prestamos='   || COUNT(*) FROM prestamo;
