#!/bin/bash
command -v sqlite3 >/dev/null 2>&1 || exit 1
BUSQUEDA="${1:-}"
echo "Buscando: $BUSQUEDA"
