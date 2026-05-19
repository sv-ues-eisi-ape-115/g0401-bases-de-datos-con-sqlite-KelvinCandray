[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/ZU0Gji1h)
# G0401 — Bases de Datos con SQLite en Debian

> **APE 115 — Aplicaciones de Escritorio · FIA · EISI · Universidad de El Salvador**  
> Laboratorio 1 de 2 — Unidad 4 · Ciclo III / 2026

[![Autocalificación](https://img.shields.io/badge/autograding-GitHub%20Classroom-blue?logo=github)](../../actions)
[![SQLite](https://img.shields.io/badge/SQLite-3.45%2B-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Debian](https://img.shields.io/badge/Debian-GNU%2FLinux-A80030?logo=debian&logoColor=white)](https://www.debian.org/)

---

## Descripción

En este laboratorio aprenderás a trabajar con **bases de datos relacionales usando SQLite** desde la terminal de Debian, sin necesidad de instalar un servidor de base de datos.  
Construirás el esquema de una cafetería universitaria paso a paso y luego aplicarás ese conocimiento en los requerimientos sobre un sistema de biblioteca.

---

## Estructura del Repositorio

```
g0401-sqlite/
├── ejemplo/                      ← scripts del ejemplo paso a paso (cafetería)
│   ├── ddl.sql                   ← Paso 2: CREATE TABLE
│   ├── dml_insert.sql            ← Paso 3: INSERT de datos de prueba
│   ├── consultas_basicas.sql     ← Paso 4: SELECT, JOIN, LIKE, BETWEEN
│   ├── consultas_agrupadas.sql   ← Paso 5: GROUP BY, HAVING, AVG, COUNT
│   ├── subconsultas.sql          ← Paso 6: subconsultas (3 tipos)
│   ├── objetos.sql               ← Paso 7: VIEW y TRIGGER
│   └── indices.sql               ← Paso 8: EXPLAIN QUERY PLAN
│
├── requerimientos/
│   ├── R01/
│   │   └── biblioteca_ddl.sql    ← DDL completo de la biblioteca
│   ├── R02/
│   │   └── biblioteca_consultas.sql
│   ├── R03/
│   │   └── biblioteca_subconsultas.sql
│   ├── R04/
│   │   └── biblioteca_objetos.sql
│   └── R05/
│       ├── setup.sh
│       ├── consultar.sh
│       ├── reporte.sh
│       └── backup.sh
└── README.md
```

---

## Inicio Rápido

```bash
# Clonar tu repositorio asignado por GitHub Classroom
git clone https://github.com/APE115-UES/g0401-TUNOMBRE.git
cd g0401-TUNOMBRE

# Instalar sqlite3
sudo apt update && sudo apt install -y sqlite3
sqlite3 --version   # debe mostrar 3.45.x

# Ejecutar el ejemplo completo de la cafetería
mkdir -p ~/lab_g0401/cafeteria && cd ~/lab_g0401/cafeteria
sqlite3 ape115_cafeteria.db < ~/g0401-TUNOMBRE/ejemplo/ddl.sql
sqlite3 ape115_cafeteria.db < ~/g0401-TUNOMBRE/ejemplo/dml_insert.sql
sqlite3 ape115_cafeteria.db < ~/g0401-TUNOMBRE/ejemplo/consultas_basicas.sql

# Verificar resultado
sqlite3 ape115_cafeteria.db ".tables"
```

---

## Ejemplo Paso a Paso — Sistema de Cafetería

> **Estos archivos ya están completos en `ejemplo/`. Estúdialos antes de comenzar los requerimientos.**

### Paso 1 — Instalar sqlite3 y preparar el directorio

```bash
# Instalar sqlite3 desde los repositorios de Debian
sudo apt update && sudo apt install -y sqlite3

# Verificar la instalación
sqlite3 --version
# → 3.45.1 2024-01-30 ...

# Crear directorio de trabajo
mkdir -p ~/lab_g0401/cafeteria
cd ~/lab_g0401/cafeteria
pwd
# → /home/alumno/lab_g0401/cafeteria
```

> ** Verificación:** `sqlite3 --version` debe mostrar `3.45.x` o superior.  
> Si ves `command not found`, el `apt install` no se completó. Intenta nuevamente.

---

### Paso 2 — Crear el archivo DDL (`ddl.sql`)

```bash
# Abrir el editor para crear el archivo
nano ddl.sql

# Ejecutar el script para crear la BD
sqlite3 ape115_cafeteria.db < ddl.sql
# → Tablas creadas: 6

# Verificar en modo interactivo
sqlite3 ape115_cafeteria.db
sqlite> .tables
sqlite> .schema producto
sqlite> PRAGMA table_info(producto);
sqlite> .quit
```

> **Punto crítico de SQLite:** Las claves foráneas están **desactivadas por defecto**.  
> Debes escribir `PRAGMA foreign_keys = ON;` al inicio de **cada** script o sesión.  
> En Java (G0402) se activa una vez al abrir cada `Connection` desde el DAO.

### Paso 3 — Insertar datos de prueba (`dml_insert.sql`)

```bash
nano dml_insert.sql
sqlite3 ape115_cafeteria.db < dml_insert.sql
# → Datos insertados OK
# → Productos: 15 | Clientes: 5 | Ventas: 5
```

---

### Paso 4 — Consultas SELECT (`consultas_basicas.sql`)

```bash
sqlite3 ape115_cafeteria.db < consultas_basicas.sql
```

> **Regla:** Antes de ejecutar un `UPDATE` o `DELETE`, conviértelo en `SELECT`  
> con los mismos filtros y verifica cuántas filas afecta.  
> En SQLite puedes activar el modo seguro con `PRAGMA secure_delete = ON;`

---

### Paso 5 — GROUP BY, HAVING y agregación (`consultas_agrupadas.sql`)

```bash
sqlite3 ape115_cafeteria.db < consultas_agrupadas.sql
```

| Función | Descripción | Ignora NULL |
|---------|-------------|-------------|
| `COUNT(*)` | Total de filas | No |
| `COUNT(col)` | Total de valores no nulos | **Sí** |
| `AVG(col)` | Promedio | Sí |
| `SUM(col)` | Suma total | Sí |
| `MAX(col)` | Valor máximo | Sí |
| `MIN(col)` | Valor mínimo | Sí |

> **WHERE** filtra filas individuales · **HAVING** filtra grupos (se usa con GROUP BY)

---

### Paso 6 — Subconsultas (`subconsultas.sql`)

```bash
sqlite3 ape115_cafeteria.db < subconsultas.sql
```

| Tipo | Cuándo usar | Ejemplo |
|------|-------------|---------|
| **Escalar** | Un solo valor de retorno | `WHERE precio > (SELECT AVG(precio)...)` |
| **Con IN** | Lista de valores | `WHERE id IN (SELECT id FROM ...)` |
| **Correlacionada** | Referencia la consulta externa | `WHERE precio > (SELECT AVG(p2.precio) WHERE p2.id_cat = p.id_cat)` |

---

### Paso 7 — Vistas y Triggers (`objetos.sql`)

```bash
sqlite3 ape115_cafeteria.db < objetos.sql
```

**Diferencia de Triggers SQLite vs MySQL:**

```sql
-- MySQL: necesita DELIMITER
DELIMITER //
CREATE TRIGGER trg_ejemplo
AFTER UPDATE ON tabla FOR EACH ROW
BEGIN
    -- lógica
END //
DELIMITER ;

-- SQLite: SIN DELIMITER, bloque directo + cláusula WHEN
CREATE TRIGGER trg_ejemplo
AFTER UPDATE ON tabla FOR EACH ROW
WHEN OLD.columna <> NEW.columna  -- ← cláusula WHEN exclusiva de SQLite
BEGIN
    -- lógica
END;
```

---

### Paso 8 — Índices y EXPLAIN (`indices.sql`)

```bash
sqlite3 ape115_cafeteria.db < indices.sql
```

**Interpretar EXPLAIN QUERY PLAN:**

| Resultado | Significado | ¿Es bueno? |
|-----------|-------------|------------|
| `SCAN tabla` | Escaneo completo | Solo en tablas pequeñas |
| `SEARCH tabla USING INDEX` | Usa un índice | Siempre mejor |
| `SEARCH tabla USING COVERING INDEX` | Índice cubre todas las columnas | Óptimo |

---

## Requerimientos

> **Todos los requerimientos se implementan usando la BD de biblioteca** (diferente al ejemplo de cafetería).  
> Los archivos esqueleto con `TODO` ya están en `requerimientos/`. Completa cada `TODO`.

### R01 — DDL Completo de la Biblioteca `(20 pts)`

**Archivo:** `requerimientos/R01/biblioteca_ddl.sql`

Diseña e implementa un esquema completo del sistema de biblioteca:

| Tabla | Columnas principales |
|-------|---------------------|
| `autor` | `id_autor` PK, `nombre` NOT NULL, `nacionalidad`, `activo` DEFAULT 1 |
| `libro` | `id_libro` PK, `titulo` NOT NULL, `isbn` UNIQUE, `precio` CHECK(>0), `stock_total` DEFAULT 5, `stock_disponible` DEFAULT 5, `activo`, `id_autor` FK |
| `estudiante` | `id_estudiante` PK, `carnet` UNIQUE NOT NULL, `nombres`, `apellidos`, `email` UNIQUE, `carrera`, `activo` |
| `prestamo` | `id_prestamo` PK, `fecha_prestamo` DEFAULT `datetime('now','localtime')`, `fecha_devolucion` NOT NULL, `fecha_devuelto`, `estado` CHECK IN ('activo','devuelto','vencido'), `id_estudiante` FK, `id_libro` FK |

**Reglas de negocio:**
- `PRAGMA foreign_keys = ON;` al inicio del script
- Nomenclatura estándar APE115: `fk_` en constraints, `idx_` en índices
- Script **idempotente**: usar `CREATE TABLE IF NOT EXISTS` e `INSERT OR IGNORE`
- Insertar: ≥3 autores, ≥6 libros, ≥4 estudiantes, ≥5 préstamos

---

### R02 — Consultas DML — Reportes `(20 pts)`

**Archivo:** `requerimientos/R02/biblioteca_consultas.sql`

| # | Consulta | Técnica requerida |
|---|----------|------------------|
| R02.1 | Libros disponibles con autor | `INNER JOIN` + filtro `stock_disponible > 0` |
| R02.2 | Estudiantes con préstamos activos | `INNER JOIN` 3 tablas |
| R02.3 | Top 3 libros más prestados | `GROUP BY` + `COUNT` + `LIMIT` |
| R02.4 | Préstamos vencidos con días de retraso | `julianday()` para calcular días |
| R02.5 | Estadísticas por carrera | `LEFT JOIN` + `GROUP BY` + `SUM(CASE WHEN...)` |
| R02.6 | Libros nunca prestados | `LEFT JOIN` + `WHERE id IS NULL` |

**Reglas de negocio:**
- Concatenar nombre completo con `||` (no `CONCAT` — SQLite no lo tiene)
- Alias de tabla de 1-2 letras en todos los JOINs
- `julianday()` para calcular días de retraso en R02.4

---

### R03 — Subconsultas — Análisis Avanzado `(20 pts)`

**Archivo:** `requerimientos/R03/biblioteca_subconsultas.sql`

| # | Análisis | Tipo de subconsulta |
|---|----------|-------------------|
| R03.1 | Estudiantes con más préstamos que el promedio | Escalar |
| R03.2 | Libros más caros que el promedio del mismo autor | Correlacionada |
| R03.3 | Estudiantes sin préstamos activos | `NOT IN` |
| R03.4 | Libro más caro por autor | Correlacionada en SELECT |
| R03.5 | Libros prestados ≥2 veces (dos versiones) | `GROUP BY + HAVING` y con `IN` |

**Reglas de negocio:**
- R03.2 **debe** referenciar el `id_autor` de la consulta externa
- R03.5 implementar **ambas** versiones con comentario explicando diferencias

---

### R04 — Vistas y Triggers SQLite `(25 pts)`

**Archivo:** `requerimientos/R04/biblioteca_objetos.sql`

#### Vistas

| Vista | Columnas clave |
|-------|---------------|
| `vw_prestamo_activo` | id_prestamo, fechas, `dias_restantes` con `ROUND(julianday(fecha_dev)-julianday(date('now')))`, nombre estudiante (`\|\|`), título libro. Solo estado='activo' |
| `vw_libro_disponibilidad` | título, autor, stock_total, stock_disponible, prestados_ahora, `pct_disponible` |

#### Triggers

| Trigger | Evento | Acción |
|---------|--------|--------|
| `trg_prestamo_nuevo` | `AFTER INSERT ON prestamo` | Decrementa `stock_disponible`. Si resulta < 0: `RAISE(ROLLBACK,'Sin stock disponible')` |
| `trg_prestamo_devuelto` | `AFTER UPDATE ON prestamo` `WHEN NEW.estado='devuelto' AND NEW.fecha_devuelto IS NULL` | Asigna `fecha_devuelto = datetime('now','localtime')`. Incrementa `stock_disponible` |

**Reglas de negocio:**
- Usar `DROP TRIGGER IF EXISTS` antes de cada `CREATE TRIGGER` (script re-ejecutable)
- `trg_prestamo_nuevo` usa `RAISE(ROLLBACK,'...')` — equivalente al `SIGNAL` de MySQL
- Incluir la **prueba del flujo completo** al final del script: INSERT → vista → UPDATE → vista

---


## Rúbrica de Evaluación

### Tabla de niveles de desempeño

| Nivel | % | Descripción |
|-------|---|-------------|
| **Excelente** | 100% | Cumple todos los indicadores con calidad profesional |
| **Satisfactorio B** | 75% | Cumple los indicadores principales con deficiencias menores |
| **Satisfactorio A** | 50% | Cumple parcialmente; faltan elementos importantes |
| **Deficiente** | 25% | No cumple los mínimos; errores graves |
| **No entregado** | 0% | El criterio no está presente |

### Rúbrica detallada

| Test | Criterio | Indicadores para Excelente | Pts |
|------|----------|---------------------------|-----|
| **T01.1** | Las 4 tablas existen | `autor`, `libro`, `estudiante`, `prestamo` creadas con `IF NOT EXISTS` | 5 |
| **T01.2** | PRAGMA FK activo | `PRAGMA foreign_keys = ON` al inicio. FK rechaza autor inexistente | 4 |
| **T01.3** | CHECK(precio > 0) | Precio negativo rechazado a nivel de BD | 3 |
| **T01.4** | Datos de prueba | ≥3 autores, ≥6 libros, ≥4 estudiantes, ≥5 préstamos | 4 |
| **T01.5** | Script idempotente | Ejecutar 2 veces no duplica filas ni genera error | 4 |
| **T02.1** | JOIN en consultas | INNER JOIN en al menos 2 consultas | 4 |
| **T02.2** | GROUP BY | GROUP BY + función de agregación en al menos 1 consulta | 4 |
| **T02.3** | `julianday()` | Usada para calcular días de retraso (R02.4) | 4 |
| **T02.4** | LEFT JOIN + IS NULL | LEFT JOIN con WHERE id IS NULL para libros nunca prestados | 4 |
| **T02.5** | Operador `\|\|` | Concatenación con `\|\|` (no `CONCAT`) | 4 |
| **T03.1** | Subconsulta escalar | `WHERE col > (SELECT AVG(...))` real | 5 |
| **T03.2** | NOT IN | `WHERE id NOT IN (SELECT ...)` | 5 |
| **T03.3** | Subconsulta correlacionada | Referencia columna de la consulta externa | 5 |
| **T03.4** | HAVING | `GROUP BY ... HAVING COUNT(...) >= 2` | 5 |
| **T04.1** | Vista `vw_prestamo_activo` | Creada con `julianday` para `dias_restantes` | 5 |
| **T04.2** | Vista `vw_libro_disponibilidad` | Creada con `pct_disponible` calculado | 5 |
| **T04.3** | Trigger `trg_prestamo_nuevo` | AFTER INSERT, decrementa stock | 5 |
| **T04.4** | Trigger `trg_prestamo_devuelto` | AFTER UPDATE con WHEN, asigna fecha e incrementa stock | 5 |
| **T04.5** | `RAISE(ROLLBACK,...)` | Valida stock en `trg_prestamo_nuevo` | 5 |
| | **TOTAL** | | **100** |

### Penalizaciones

| Situación | Descuento |
|-----------|-----------|
| Script SQL con error de sintaxis que impide ejecutarse | −5 pts por archivo |
| Usar `CONCAT()` en lugar de `\|\|` | −2 pts |
| `PRAGMA foreign_keys = ON` ausente en algún script | −3 pts |
| Script no idempotente (falla en segunda ejecución) | −5 pts |
| Scripts bash sin `#!/bin/bash` | −2 pts |

---

## Verificar tu Calificación Localmente

```bash
# Desde la raíz del repositorio
chmod +x tests/grade.sh
bash tests/grade.sh
```

La salida mostrará cada test con ✓ PASS o ✗ FAIL y la puntuación final.

---

## Flujo de Entrega

```bash
# 1. Completar los archivos en requerimientos/
# 2. Ejecutar el autograder local para verificar
bash tests/grade.sh

# 3. Subir al repositorio
git add requerimientos/
git commit -m "feat: implementar R01-R05 biblioteca SQLite"
git push

# 4. GitHub Actions ejecuta el autograder automáticamente
# Ver resultados en: Actions → G0401 — Autocalificación SQLite
```

GitHub Actions se ejecuta automáticamente en cada `push` y muestra el resultado en la pestaña **Actions** del repositorio.

---

## Referencia Rápida SQLite en Terminal

```bash
# Abrir BD (crea si no existe)
sqlite3 mi_base.db

# Comandos del cliente sqlite3
.tables              # listar tablas
.schema nombre       # DDL de una tabla
.headers on          # mostrar nombres de columnas
.mode column         # formato alineado
.mode csv            # formato CSV
.read archivo.sql    # ejecutar script
.quit                # salir

# Ejecutar script desde bash
sqlite3 mi_base.db < script.sql

# Ejecutar script y guardar resultado
sqlite3 mi_base.db < script.sql > resultado.txt

# Ejecutar sentencia directa
sqlite3 mi_base.db "SELECT COUNT(*) FROM tabla;"

# Heredoc (múltiples sentencias)
sqlite3 mi_base.db << 'SQL'
PRAGMA foreign_keys = ON;
.headers on
SELECT * FROM tabla;
SQL
```

---

## Recursos

- [Documentación oficial SQLite](https://www.sqlite.org/docs.html)
- [SQLite Query Language](https://www.sqlite.org/lang.html)
- [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)
- [Guía G0401 PDF](../../releases) — descarga en Releases
- [Guía G0402](../G0402) — JDBC, DAO, SwingWorker y Hibernate (próximo laboratorio)

---
