#!/bin/bash
DB="biblioteca.db"
FECHA=$(date +%Y%m%d)
sqlite3 "$DB" << 'SQL'
PRAGMA foreign_keys = ON;
SELECT COUNT(*) FROM libro;
SQL
echo "Reporte generado"
