#!/bin/bash

PLUGIN_NAME="${PLUGIN_NAME:-DummyPlugin.sketchplugin}"
SKETCH_PLUGINS_PATH="${SKETCH_PLUGINS_PATH:-/tmp}"

echo "✅ Installing ${PLUGIN_NAME} to ${SKETCH_PLUGINS_PATH}"

PLUGIN_CONTENTS_PATH="${SKETCH_PLUGINS_PATH}/${PLUGIN_NAME}/Contents"

mkdir -p "${PLUGIN_CONTENTS_PATH}"/{Sketch,Resources}

rsync  \
    --exclude .git  \
    --exclude .gitignore \
    --exclude .DS_Store \
    --recursive \
    --perms \
    --links \
    --keep-dirlinks \
    --delete-after \
    "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "${PLUGIN_CONTENTS_PATH}"/Resources


rsync  \
    --exclude .git  \
    --exclude .gitignore \
    --exclude .DS_Store \
    --recursive \
    --perms \
    --links \
    --keep-dirlinks \
    --delete-after \
    "${SRCROOT}/Plugin/" "${PLUGIN_CONTENTS_PATH}"/Sketch/
