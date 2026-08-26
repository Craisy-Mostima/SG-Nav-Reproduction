#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="/root/autodl-tmp/Habitat/projects/SG-Nav-original"
ORIGINAL_FILE="${PROJECT_DIR}/SG_Nav.py"
DIAGNOSTIC_FILE="${PROJECT_DIR}/SG_Nav_diagnostic.py"
EXPECTED_ORIGINAL_SHA="902ea13508c74c1323dfc5f198148819e9e757bdc50bf38345f5987f6a953284"

if [[ ! -f "${ORIGINAL_FILE}" ]]; then
  echo "ERROR: official SG_Nav.py was not found: ${ORIGINAL_FILE}" >&2
  exit 1
fi

ACTUAL_ORIGINAL_SHA="$(sha256sum "${ORIGINAL_FILE}" | awk '{print $1}')"
if [[ "${ACTUAL_ORIGINAL_SHA}" != "${EXPECTED_ORIGINAL_SHA}" ]]; then
  echo "ERROR: SG_Nav.py is not the audited official file." >&2
  echo "Expected: ${EXPECTED_ORIGINAL_SHA}" >&2
  echo "Actual:   ${ACTUAL_ORIGINAL_SHA}" >&2
  exit 1
fi

if [[ -f "${DIAGNOSTIC_FILE}" ]]; then
  BACKUP_DIR="${PROJECT_DIR}/patches/stop_diagnostic_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "${BACKUP_DIR}"
  cp "${DIAGNOSTIC_FILE}" "${BACKUP_DIR}/SG_Nav_diagnostic.py"
  echo "Existing diagnostic copy backed up to: ${BACKUP_DIR}"
fi

cp "${PACKAGE_DIR}/SG_Nav_diagnostic.py" "${DIAGNOSTIC_FILE}"
python -m py_compile "${DIAGNOSTIC_FILE}"

echo "STOP diagnostic installed successfully."
echo "Official file was NOT modified: ${ORIGINAL_FILE}"
echo "Diagnostic copy: ${DIAGNOSTIC_FILE}"
echo "Official SHA256: $(sha256sum "${ORIGINAL_FILE}" | awk '{print $1}')"
echo "Diagnostic SHA256: $(sha256sum "${DIAGNOSTIC_FILE}" | awk '{print $1}')"

