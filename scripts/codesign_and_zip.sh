#!/bin/bash

: "${SKETCH_PLUGINS_PATH?Need to set SKETCH_PLUGINS_PATH}"
: "${PLUGIN_NAME?Need to set PLUGIN_NAME}"
: "${CODESIGNING_IDENTITES_MAP?Need to set CODESIGNING_IDENTITES_MAP}"

DISTRIBUTION_DIR=${DISTRIBUTION_DIR-/tmp}
NO_CODESIGNING_IDENTITY="None"

BUILD_PLUGIN_PATH=${SKETCH_PLUGINS_PATH}/${PLUGIN_NAME}.sketchplugin
FRAMEWORK_TO_CODESIGN_PATH="Contents/Resources/DummyPlugin.framework"

codesign_and_zip(){
    local DISTRIBUTION_CODESIGNING_IDENTITY=$1
    local DISTRIBUTION_SUFFIX=$2
    local DISTRIBUTED_PLUGIN_NAME=${PLUGIN_NAME}${DISTRIBUTION_SUFFIX}.sketchplugin

    local DISTRIBUTION_TARGET_DIR=${DISTRIBUTION_DIR}/${DISTRIBUTED_PLUGIN_NAME}
    mkdir -p "${DISTRIBUTION_TARGET_DIR}"

    rsync  \
        --exclude .git  \
        --exclude .gitignore \
        --exclude .DS_Store \
        --recursive \
        --perms \
        --links \
        --keep-dirlinks \
        --delete-after \
        "${BUILD_PLUGIN_PATH}/" "${DISTRIBUTION_TARGET_DIR}"

    if [[ "$DISTRIBUTION_CODESIGNING_IDENTITY" != "$NO_CODESIGNING_IDENTITY" ]]; then
        echo "✅ Signing with identity: '${DISTRIBUTION_CODESIGNING_IDENTITY}' Zip file suffix: '${DISTRIBUTION_SUFFIX}'"

        if ! codesign --sign "${DISTRIBUTION_CODESIGNING_IDENTITY}" "${DISTRIBUTION_TARGET_DIR}/${FRAMEWORK_TO_CODESIGN_PATH}/Versions/A" 2>&1 
        then
        echo "🛑 Code signing failed for identity: '${DISTRIBUTION_CODESIGNING_IDENTITY}' (suffix: '${DISTRIBUTION_SUFFIX}'')!"
        exit 1
        fi
            
        echo "➡️  Signing details for identity: '${DISTRIBUTION_CODESIGNING_IDENTITY}' (suffix: '${DISTRIBUTION_SUFFIX}'')!"
        codesign --verify --deep --strict --verbose=5 "${DISTRIBUTION_TARGET_DIR}/${FRAMEWORK_TO_CODESIGN_PATH}"

        ditto -c -k --sequesterRsrc --keepParent  "${DISTRIBUTION_TARGET_DIR}" "${DISTRIBUTION_DIR}/${DISTRIBUTED_PLUGIN_NAME}.zip"
        echo "✅ Distribution ready zip with signed framework is located here: ${DISTRIBUTION_DIR}/${DISTRIBUTED_PLUGIN_NAME}.zip"
    else

        ditto -c -k --sequesterRsrc --keepParent  "${DISTRIBUTION_TARGET_DIR}" "${DISTRIBUTION_DIR}/${DISTRIBUTED_PLUGIN_NAME}.zip"
        echo "✅ Distribution ready zip with NOT signed framework is located here: ${DISTRIBUTION_DIR}/${DISTRIBUTED_PLUGIN_NAME}.zip"
    fi

}


mkdir -p ${DISTRIBUTION_DIR}

if [[ $CODESIGNING_IDENTITES_MAP != *":"* ]]; then
    codesign_and_zip "${CODESIGNING_IDENTITES_MAP}"
else

    # CODESIGNING_IDENTITES_MAP contains more than one entry in form: "key:value;key2:value with space;key3:yet another value"
    IFS=';' read -ra SUFFIX_IDENTITY_ARRAY <<< "$CODESIGNING_IDENTITES_MAP"
    for index in "${SUFFIX_IDENTITY_ARRAY[@]}"; do
        NAME_SUFFIX="${index%%:*}"
        CODESIGNING_IDENTITY="${index##*:}"

        #echo ">$NAME_SUFFIX< - >$CODESIGNING_IDENTITY<"
        codesign_and_zip "${CODESIGNING_IDENTITY}" "${NAME_SUFFIX}"
    done
fi

