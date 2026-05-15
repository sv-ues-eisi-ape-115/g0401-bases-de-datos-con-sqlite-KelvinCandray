#!/bin/bash
# =============================================================
# G0401 — APE 115 — Autograder Principal
# Archivo: tests/grade.sh
# Descripción: Evalúa automáticamente todos los requerimientos
# Ejecutado por GitHub Actions con: bash tests/grade.sh
# =============================================================

set -euo pipefail

SCORE=0
MAX=100
REPORT=""

# ── Colores para salida legible ───────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓ PASS${NC} $1"; SCORE=$((SCORE + $2)); REPORT+="PASS|$1|$2\n"; }
fail() { echo -e "  ${RED}✗ FAIL${NC} $1"; REPORT+="FAIL|$1|0\n"; }
info() { echo -e "  ${BLUE}ℹ${NC}  $1"; }
section() { echo -e "\n${YELLOW}══ $1 ══${NC}"; }

# ── Helper: ejecutar SQL y obtener resultado ──────────────────
run_sql() {
    local db="$1" sql="$2"
    sqlite3 "$db" "PRAGMA foreign_keys = ON; $sql" 2>/dev/null || echo ""
}

# ── Helper: verificar que un archivo existe ───────────────────
check_file() {
    local f="$1" pts="$2" label="$3"
    if [ -f "$f" ]; then pass "$label existe" "$pts"
    else fail "$label NO encontrado: $f"; fi
}

# ── Helper: construir BD del estudiante ──────────────────────
build_db() {
    local db="$1"
    rm -f "$db"
    sqlite3 "$db" "PRAGMA foreign_keys=ON;" 2>/dev/null
    sqlite3 "$db" < requerimientos/R01/biblioteca_ddl.sql 2>/dev/null || true
}

# ─────────────────────────────────────────────────────────────
section "SETUP — Verificar prerrequisitos"
# ─────────────────────────────────────────────────────────────

if ! command -v sqlite3 &>/dev/null; then
    echo -e "${RED}FATAL: sqlite3 no está instalado.${NC}"
    echo "Instalar con: sudo apt install -y sqlite3"
    exit 1
fi
info "sqlite3 $(sqlite3 --version | cut -d' ' -f1) disponible"

# ─────────────────────────────────────────────────────────────
section "R01 — DDL de la Biblioteca (20 pts)"
# ─────────────────────────────────────────────────────────────

check_file "requerimientos/R01/biblioteca_ddl.sql" 0 "R01/biblioteca_ddl.sql"

DB_R01="/tmp/g0401_r01_$$.db"
rm -f "$DB_R01"
sqlite3 "$DB_R01" < requerimientos/R01/biblioteca_ddl.sql 2>/dev/null || true

# T01.1 — Las 4 tablas existen
TABLES=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name IN ('autor','libro','estudiante','prestamo');")
if [ "$TABLES" = "4" ]; then
    pass "T01.1 — Las 4 tablas existen (autor, libro, estudiante, prestamo)" 5
else
    fail "T01.1 — Solo $TABLES/4 tablas encontradas. Verificar CREATE TABLE."
fi

# T01.2 — PRAGMA FK activo: intentar insertar libro con autor inexistente
FK_TEST=$(sqlite3 "$DB_R01" "PRAGMA foreign_keys = ON; INSERT OR IGNORE INTO libro(titulo,id_autor) VALUES ('X',9999);" 2>&1 || true)
LIBRO_COUNT=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM libro WHERE titulo='X';")
if [ "$LIBRO_COUNT" = "0" ]; then
    pass "T01.2 — PRAGMA foreign_keys activo (FK rechaza autor inexistente)" 4
else
    fail "T01.2 — PRAGMA foreign_keys no activo — la FK no rechazó el insert inválido"
fi

# T01.3 — Verificar CHECK en precio
CHECK_TEST=$(sqlite3 "$DB_R01" "PRAGMA foreign_keys=ON; INSERT OR ROLLBACK INTO libro(titulo,precio,id_autor) SELECT 'T',-1.0,id_autor FROM autor LIMIT 1;" 2>&1 || true)
NEG_COUNT=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM libro WHERE precio < 0;")
if [ "$NEG_COUNT" = "0" ]; then
    pass "T01.3 — CHECK(precio > 0) funciona correctamente" 3
else
    fail "T01.3 — CHECK(precio > 0) no rechazó precio negativo"
fi

# T01.4 — Datos de prueba: mínimo 3 autores, 6 libros, 4 estudiantes, 5 préstamos
AUTORES=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM autor;")
LIBROS=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM libro;")
ESTUDIANTES=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM estudiante;")
PRESTAMOS=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM prestamo;")
if [ "$AUTORES" -ge 3 ] && [ "$LIBROS" -ge 6 ] && [ "$ESTUDIANTES" -ge 4 ] && [ "$PRESTAMOS" -ge 5 ]; then
    pass "T01.4 — Datos de prueba suficientes (autores≥3, libros≥6, est.≥4, prést.≥5)" 4
else
    fail "T01.4 — Datos insuficientes: autores=$AUTORES libros=$LIBROS estudiantes=$ESTUDIANTES prestamos=$PRESTAMOS"
fi

# T01.5 — Script idempotente
sqlite3 "$DB_R01" < requerimientos/R01/biblioteca_ddl.sql 2>/dev/null || true
AUTORES2=$(run_sql "$DB_R01" "SELECT COUNT(*) FROM autor;")
if [ "$AUTORES2" = "$AUTORES" ]; then
    pass "T01.5 — Script idempotente (ejecutar 2 veces no duplica datos)" 4
else
    fail "T01.5 — Script no es idempotente. Segunda ejecución: autores=$AUTORES2 vs primera=$AUTORES"
fi

rm -f "$DB_R01"

# ─────────────────────────────────────────────────────────────
section "R02 — Consultas DML (20 pts)"
# ─────────────────────────────────────────────────────────────

check_file "requerimientos/R02/biblioteca_consultas.sql" 0 "R02/biblioteca_consultas.sql"

DB_R02="/tmp/g0401_r02_$$.db"
rm -f "$DB_R02"
sqlite3 "$DB_R02" < requerimientos/R01/biblioteca_ddl.sql 2>/dev/null || true

# T02.1 — El archivo contiene INNER JOIN (join de múltiples tablas)
if grep -qi "INNER\s*JOIN\|JOIN" requerimientos/R02/biblioteca_consultas.sql 2>/dev/null; then
    pass "T02.1 — El archivo contiene JOIN (consultas con múltiples tablas)" 4
else
    fail "T02.1 — No se encontró JOIN en biblioteca_consultas.sql"
fi

# T02.2 — Contiene GROUP BY
if grep -qi "GROUP\s*BY" requerimientos/R02/biblioteca_consultas.sql 2>/dev/null; then
    pass "T02.2 — Contiene GROUP BY (consultas de agregación)" 4
else
    fail "T02.2 — No se encontró GROUP BY en biblioteca_consultas.sql"
fi

# T02.3 — Contiene julianday (específico de SQLite para fechas)
if grep -qi "julianday" requerimientos/R02/biblioteca_consultas.sql 2>/dev/null; then
    pass "T02.3 — Usa julianday() para cálculo de días (sintaxis SQLite)" 4
else
    fail "T02.3 — No se encontró julianday() — requerido para calcular días de retraso (R02.4)"
fi

# T02.4 — Contiene LEFT JOIN con IS NULL (para libros nunca prestados)
if grep -qi "LEFT\s*JOIN" requerimientos/R02/biblioteca_consultas.sql && \
   grep -qi "IS\s*NULL" requerimientos/R02/biblioteca_consultas.sql; then
    pass "T02.4 — Contiene LEFT JOIN + IS NULL (libros nunca prestados R02.6)" 4
else
    fail "T02.4 — Falta LEFT JOIN + IS NULL para R02.6 (libros nunca prestados)"
fi

# T02.5 — Usa || para concatenar (no CONCAT — SQLite no tiene CONCAT)
if grep -q "||" requerimientos/R02/biblioteca_consultas.sql 2>/dev/null; then
    pass "T02.5 — Usa || para concatenar texto (sintaxis correcta SQLite)" 4
else
    fail "T02.5 — No usa || para concatenar. En SQLite es: nombre || ' ' || apellido (no CONCAT)"
fi

rm -f "$DB_R02"

# ─────────────────────────────────────────────────────────────
section "R03 — Subconsultas (20 pts)"
# ─────────────────────────────────────────────────────────────

check_file "requerimientos/R03/biblioteca_subconsultas.sql" 0 "R03/biblioteca_subconsultas.sql"

# T03.1 — Contiene subconsulta escalar (SELECT ... WHERE col > (SELECT ...))
if grep -qiP "WHERE\s+\w+\s*[><=]\s*\(\s*SELECT" requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null || \
   grep -qi "WHERE.*>\s*(SELECT\|<\s*(SELECT" requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null; then
    pass "T03.1 — Contiene subconsulta escalar (WHERE col > (SELECT ...))" 5
else
    fail "T03.1 — No se encontró subconsulta escalar en biblioteca_subconsultas.sql"
fi

# T03.2 — Contiene NOT IN
if grep -qi "NOT\s*IN" requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null; then
    pass "T03.2 — Contiene NOT IN (subconsulta R03.3)" 5
else
    fail "T03.2 — No se encontró NOT IN en biblioteca_subconsultas.sql"
fi

# T03.3 — La subconsulta correlacionada referencia alias de la consulta externa
# Buscamos un patrón como: WHERE tabla_externa.col = subconsulta_interna.col
if grep -qi "WHERE.*\.\(id_autor\|id_categoria\|id_libro\).*=.*\.\(id_autor\|id_categoria\|id_libro\)" \
   requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null || \
   grep -qP "WHERE\s+\w+\.\w+\s*=\s*\w+\.\w+" requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null; then
    pass "T03.3 — Contiene subconsulta correlacionada (referencia columna externa)" 5
else
    fail "T03.3 — No se encontró subconsulta correlacionada (R03.2 — referencia id_autor externo)"
fi

# T03.4 — Contiene HAVING para R03.5
if grep -qi "HAVING" requerimientos/R03/biblioteca_subconsultas.sql 2>/dev/null; then
    pass "T03.4 — Contiene HAVING (R03.5 — libros prestados al menos 2 veces)" 5
else
    fail "T03.4 — No se encontró HAVING (requerido para R03.5 con GROUP BY)"
fi

# ─────────────────────────────────────────────────────────────
section "R04 — Vistas y Triggers (25 pts)"
# ─────────────────────────────────────────────────────────────

check_file "requerimientos/R04/biblioteca_objetos.sql" 0 "R04/biblioteca_objetos.sql"

DB_R04="/tmp/g0401_r04_$$.db"
rm -f "$DB_R04"
sqlite3 "$DB_R04" < requerimientos/R01/biblioteca_ddl.sql 2>/dev/null || true
sqlite3 "$DB_R04" < requerimientos/R04/biblioteca_objetos.sql 2>/dev/null || true

# T04.1 — Vista vw_prestamo_activo existe
VW1=$(run_sql "$DB_R04" "SELECT COUNT(*) FROM sqlite_master WHERE type='view' AND name='vw_prestamo_activo';")
if [ "$VW1" = "1" ]; then
    pass "T04.1 — Vista vw_prestamo_activo creada correctamente" 5
else
    fail "T04.1 — Vista vw_prestamo_activo no encontrada"
fi

# T04.2 — Vista vw_libro_disponibilidad existe
VW2=$(run_sql "$DB_R04" "SELECT COUNT(*) FROM sqlite_master WHERE type='view' AND name='vw_libro_disponibilidad';")
if [ "$VW2" = "1" ]; then
    pass "T04.2 — Vista vw_libro_disponibilidad creada correctamente" 5
else
    fail "T04.2 — Vista vw_libro_disponibilidad no encontrada"
fi

# T04.3 — Trigger trg_prestamo_nuevo existe
TR1=$(run_sql "$DB_R04" "SELECT COUNT(*) FROM sqlite_master WHERE type='trigger' AND name='trg_prestamo_nuevo';")
if [ "$TR1" = "1" ]; then
    pass "T04.3 — Trigger trg_prestamo_nuevo creado correctamente" 5
else
    fail "T04.3 — Trigger trg_prestamo_nuevo no encontrado"
fi

# T04.4 — Trigger trg_prestamo_devuelto existe
TR2=$(run_sql "$DB_R04" "SELECT COUNT(*) FROM sqlite_master WHERE type='trigger' AND name='trg_prestamo_devuelto';")
if [ "$TR2" = "1" ]; then
    pass "T04.4 — Trigger trg_prestamo_devuelto creado correctamente" 5
else
    fail "T04.4 — Trigger trg_prestamo_devuelto no encontrado"
fi

# T04.5 — Archivo contiene RAISE(ROLLBACK,...) para validar stock
if grep -qi "RAISE\s*(ROLLBACK" requerimientos/R04/biblioteca_objetos.sql 2>/dev/null; then
    pass "T04.5 — Usa RAISE(ROLLBACK,...) para validar stock en el trigger" 5
else
    fail "T04.5 — No se encontró RAISE(ROLLBACK,...) — requerido para validar stock en trg_prestamo_nuevo"
fi

rm -f "$DB_R04"

# ─────────────────────────────────────────────────────────────
section "R05 — Scripts Bash (10 pts)"
# ─────────────────────────────────────────────────────────────

# T05.1 — setup.sh existe y tiene shebang
if [ -f "requerimientos/R05/setup.sh" ] && head -1 "requerimientos/R05/setup.sh" | grep -q "#!/bin/bash"; then
    pass "T05.1 — setup.sh existe con #!/bin/bash" 2
else
    fail "T05.1 — setup.sh no encontrado o sin shebang #!/bin/bash"
fi

# T05.2 — consultar.sh existe y usa $1 (argumento)
if [ -f "requerimientos/R05/consultar.sh" ] && grep -qE '\$1|\${1[^}]*}' "requerimientos/R05/consultar.sh" 2>/dev/null; then
    pass "T05.2 — consultar.sh existe y recibe argumento \$1" 2
else
    fail "T05.2 — consultar.sh no encontrado o no usa argumento \$1"
fi

# T05.3 — reporte.sh usa heredoc (<<)
if [ -f "requerimientos/R05/reporte.sh" ] && grep -q '<<' "requerimientos/R05/reporte.sh" 2>/dev/null; then
    pass "T05.3 — reporte.sh usa heredoc (<<) para pasar SQL a sqlite3" 3
else
    fail "T05.3 — reporte.sh no encontrado o no usa heredoc (<<)"
fi

# T05.4 — setup.sh valida instalación de sqlite3
if grep -q "command -v sqlite3\|which sqlite3\|sqlite3 --version" "requerimientos/R05/setup.sh" 2>/dev/null; then
    pass "T05.4 — setup.sh valida que sqlite3 esté instalado" 3
else
    fail "T05.4 — setup.sh no valida si sqlite3 está disponible (usar: command -v sqlite3)"
fi

# ─────────────────────────────────────────────────────────────
section "ESTÁNDARES DE CÓDIGO (5 pts)"
# ─────────────────────────────────────────────────────────────

# T06.1 — Todos los .sql tienen PRAGMA foreign_keys = ON
PRAGMA_COUNT=0
TOTAL_SQL=0
for f in requerimientos/R01/biblioteca_ddl.sql \
         requerimientos/R02/biblioteca_consultas.sql \
         requerimientos/R03/biblioteca_subconsultas.sql \
         requerimientos/R04/biblioteca_objetos.sql; do
    [ -f "$f" ] || continue
    TOTAL_SQL=$((TOTAL_SQL+1))
    grep -qi "PRAGMA foreign_keys\s*=\s*ON" "$f" && PRAGMA_COUNT=$((PRAGMA_COUNT+1)) || true
done
if [ "$PRAGMA_COUNT" -ge "$TOTAL_SQL" ] && [ "$TOTAL_SQL" -gt 0 ]; then
    pass "T06.1 — Todos los .sql tienen PRAGMA foreign_keys = ON" 2
else
    fail "T06.1 — $PRAGMA_COUNT/$TOTAL_SQL archivos SQL tienen PRAGMA foreign_keys = ON"
fi

# T06.2 — Nomenclatura estándar: prefijos idx_, fk_, vw_, trg_
STD_PASS=0
grep -qi "idx_" requerimientos/R01/biblioteca_ddl.sql 2>/dev/null && STD_PASS=$((STD_PASS+1)) || true
grep -qi "fk_"  requerimientos/R01/biblioteca_ddl.sql 2>/dev/null && STD_PASS=$((STD_PASS+1)) || true
grep -qi "vw_"  requerimientos/R04/biblioteca_objetos.sql 2>/dev/null && STD_PASS=$((STD_PASS+1)) || true
grep -qi "trg_" requerimientos/R04/biblioteca_objetos.sql 2>/dev/null && STD_PASS=$((STD_PASS+1)) || true
if [ "$STD_PASS" -ge 3 ]; then
    pass "T06.2 — Nomenclatura estándar APE115: prefijos idx_, fk_, vw_, trg_ presentes" 3
else
    fail "T06.2 — Solo $STD_PASS/4 prefijos estándar encontrados (idx_, fk_, vw_, trg_)"
fi

# ─────────────────────────────────────────────────────────────
section "RESULTADO FINAL"
# ─────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo "  PUNTUACIÓN G0401: $SCORE / $MAX puntos"
echo "════════════════════════════════════════"
echo ""

# Resumen de checks
echo -e "$REPORT" | while IFS='|' read -r status desc pts; do
    [ -z "$status" ] && continue
    if [ "$status" = "PASS" ]; then
        echo -e "  ${GREEN}✓${NC} [$pts pts] $desc"
    else
        echo -e "  ${RED}✗${NC} [  0  ] $desc"
    fi
done

echo ""
if   [ "$SCORE" -ge 90 ]; then echo -e "  ${GREEN}🏆 Excelente — $SCORE/100${NC}"
elif [ "$SCORE" -ge 75 ]; then echo -e "  ${BLUE}✔  Satisfactorio B — $SCORE/100${NC}"
elif [ "$SCORE" -ge 50 ]; then echo -e "  ${YELLOW}◑  Satisfactorio A — $SCORE/100${NC}"
elif [ "$SCORE" -ge 25 ]; then echo -e "  ${RED}✗  Deficiente — $SCORE/100${NC}"
else                            echo -e "  ${RED}✗  No entregado — $SCORE/100${NC}"; fi

# Guardar puntuación en archivo para GitHub Actions
echo "$SCORE" > /tmp/g0401_score.txt
exit 0
