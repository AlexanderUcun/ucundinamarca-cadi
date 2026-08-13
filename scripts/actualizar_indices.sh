#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

is_semester_dir() {
  local dirname
  dirname="$(basename "$1")"
  [[ "$dirname" =~ ^(0[1-9]|10)- ]]
}

build_semester_index() {
  local semester_dir="$1"
  local index_file="$semester_dir/INDICE-MATERIAS.md"

  {
    echo "# Índice de materias - $(basename "$semester_dir")"
    echo
    echo "Generado automáticamente desde la estructura de carpetas."
    echo
    find "$semester_dir" -mindepth 1 -maxdepth 1 -type d \
      ! -name ".*" \
      ! -name "__*" \
      | sort \
      | while read -r subject_dir; do
          subject_name="$(basename "$subject_dir")"
          pretty_name="${subject_name//-/ }"
          echo "- [${pretty_name^}](./${subject_name}/README.md)"
        done
  } > "$index_file"
}

build_root_index() {
  local index_file="$ROOT_DIR/INDICE-MATERIAS.md"

  {
    echo "# Índice general de materias"
    echo
    echo "Generado automáticamente desde la estructura de semestres y materias."
    echo
    for semester_dir in "$ROOT_DIR"/*; do
      [ -d "$semester_dir" ] || continue
      is_semester_dir "$semester_dir" || continue
      semester_name="$(basename "$semester_dir")"
      echo "## $semester_name"
      find "$semester_dir" -mindepth 1 -maxdepth 1 -type d \
        ! -name ".*" \
        ! -name "__*" \
        | sort \
        | while read -r subject_dir; do
            subject_name="$(basename "$subject_dir")"
            pretty_name="${subject_name//-/ }"
            echo "- [${pretty_name^}](./${semester_name}/${subject_name}/README.md)"
          done
      echo
    done
  } > "$index_file"
}

for semester_dir in "$ROOT_DIR"/*; do
  [ -d "$semester_dir" ] || continue
  is_semester_dir "$semester_dir" || continue
  build_semester_index "$semester_dir"
done

build_root_index

echo "Índices actualizados correctamente."
