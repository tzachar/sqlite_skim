#!/bin/bash
set -e

echo "--- Starting sqlite_skim installation script ---"

# 1. Compile the Rust project
echo "[1/4] Compiling the sqlite_skim extension..."
cargo build --release
if [ $? -ne 0 ]; then
    echo "Error: Compilation failed." >&2
    exit 1
fi
echo "Compilation successful."

# 2. Set up paths and create the installation directory
INSTALL_DIR="${HOME}/sqlite"
SO_SOURCE_PATH="target/release/libsqlite_skim.so"
SO_DEST_PATH="${INSTALL_DIR}/libsqlite_skim.so"
SQLITERC_PATH="${HOME}/.sqliterc"

echo "[2/4] Preparing installation directory at ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"
echo "Directory ensured."

# 3. Copy the compiled shared library
echo "[3/4] Copying shared library to destination..."
cp "${SO_SOURCE_PATH}" "${SO_DEST_PATH}"
echo "Copied ${SO_SOURCE_PATH} to ${SO_DEST_PATH}"

# 4. Update the .sqliterc file
# Get the fully expanded, absolute path for the home directory
EXPANDED_HOME=$(eval echo ~)
LOAD_LINE=".load ${EXPANDED_HOME}/sqlite/libsqlite_skim.so"

echo "[4/4] Updating user's .sqliterc file at ${SQLITERC_PATH}..."

# Check if the file exists and if the line is already present
if [ -f "${SQLITERC_PATH}" ] && grep -Fxq "${LOAD_LINE}" "${SQLITERC_PATH}"; then
    echo "Load command already exists in ${SQLITERC_PATH}. No changes needed."
else
    echo "Adding load command to ${SQLITERC_PATH}."
    echo "" >> "${SQLITERC_PATH}" # Add a newline for separation
    echo "${LOAD_LINE}" >> "${SQLITERC_PATH}"
    echo "Configuration file updated."
fi

echo "--- Installation complete! ---"
echo "To use the extension, simply run 'sqlite3'. The 'skim_score' function will be available automatically."
