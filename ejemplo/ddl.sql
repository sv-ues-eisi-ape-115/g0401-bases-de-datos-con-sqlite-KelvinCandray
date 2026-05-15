-- ddl.sql — Esquema completo de la cafetería
-- Ejecutar con: sqlite3 ape115_cafeteria.db < ddl.sql

-- ❶ Activar claves foráneas (OBLIGATORIO en SQLite — inactivo por defecto)
PRAGMA foreign_keys = ON;

-- ❷ Tabla padre: categoria
CREATE TABLE IF NOT EXISTS categoria (
    id_categoria  INTEGER  PRIMARY KEY AUTOINCREMENT,
    nombre        TEXT     NOT NULL UNIQUE,
    descripcion   TEXT,
    activo        INTEGER  NOT NULL DEFAULT 1
);

-- ❸ Tabla hijo: producto (referencia categoria)
CREATE TABLE IF NOT EXISTS producto (
    id_producto   INTEGER  PRIMARY KEY AUTOINCREMENT,
    nombre        TEXT     NOT NULL,
    descripcion   TEXT,
    precio        REAL     NOT NULL CHECK(precio > 0),
    stock         INTEGER  NOT NULL DEFAULT 0 CHECK(stock >= 0),
    activo        INTEGER  NOT NULL DEFAULT 1,
    id_categoria  INTEGER  NOT NULL,
    CONSTRAINT fk_prod_cat FOREIGN KEY(id_categoria)
        REFERENCES categoria(id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ❹ Índice para búsquedas por nombre (estándar APE115: prefijo idx_)
CREATE INDEX IF NOT EXISTS idx_producto_nombre ON producto(nombre);

-- ❺ Tabla cliente
CREATE TABLE IF NOT EXISTS cliente (
    id_cliente  INTEGER  PRIMARY KEY AUTOINCREMENT,
    nombres     TEXT     NOT NULL,
    apellidos   TEXT     NOT NULL,
    email       TEXT     NOT NULL UNIQUE,
    telefono    TEXT,
    activo      INTEGER  NOT NULL DEFAULT 1
);

-- ❻ Tabla venta (cabecera del comprobante)
CREATE TABLE IF NOT EXISTS venta (
    id_venta    INTEGER  PRIMARY KEY AUTOINCREMENT,
    fecha       TEXT     NOT NULL DEFAULT (datetime('now','localtime')),
    total       REAL     NOT NULL DEFAULT 0.0,
    anulada     INTEGER  NOT NULL DEFAULT 0,
    id_cliente  INTEGER  NOT NULL,
    CONSTRAINT fk_venta_cli FOREIGN KEY(id_cliente)
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ❼ Tabla detalle_venta (líneas del comprobante)
CREATE TABLE IF NOT EXISTS detalle_venta (
    id_detalle  INTEGER  PRIMARY KEY AUTOINCREMENT,
    cantidad    INTEGER  NOT NULL CHECK(cantidad > 0),
    precio_unit REAL     NOT NULL,
    subtotal    REAL     NOT NULL,  -- calculado en la app o trigger
    id_venta    INTEGER  NOT NULL,
    id_producto INTEGER  NOT NULL,
    CONSTRAINT fk_det_venta  FOREIGN KEY(id_venta)
        REFERENCES venta(id_venta) ON DELETE CASCADE,
    CONSTRAINT fk_det_prod   FOREIGN KEY(id_producto)
        REFERENCES producto(id_producto) ON DELETE RESTRICT
);

-- ❽ Índices en claves foráneas (buena práctica obligatoria)
CREATE INDEX IF NOT EXISTS idx_venta_cliente    ON venta(id_cliente);
CREATE INDEX IF NOT EXISTS idx_det_venta        ON detalle_venta(id_venta);
CREATE INDEX IF NOT EXISTS idx_det_producto     ON detalle_venta(id_producto);

-- Verificación: mostrar tablas creadas
SELECT 'Tablas creadas: ' || COUNT(*) AS resultado FROM sqlite_master
WHERE type = 'table';
