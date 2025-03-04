#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


variant_for_slice()
{
  case "$1" in
  "NERtcAiDenoise.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcAiDenoise.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcAiHowling.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcAiHowling.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcBeauty.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcBeauty.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcFaceDetect.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcFaceDetect.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcFaceEnhance.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcFaceEnhance.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcnn.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcnn.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcSDK.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcSDK.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcReplayKit.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcReplayKit.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcPersonSegment.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcPersonSegment.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcAudio3D.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcAudio3D.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcSuperResolution.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcSuperResolution.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  "NERtcVideoDenoise.xcframework/ios-arm64_armv7")
    echo ""
    ;;
  "NERtcVideoDenoise.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "simulator"
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "NERtcAiDenoise.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcAiDenoise.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcAiHowling.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcAiHowling.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcBeauty.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcBeauty.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcFaceDetect.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcFaceDetect.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcFaceEnhance.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcFaceEnhance.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcnn.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcnn.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcSDK.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcSDK.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcReplayKit.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcReplayKit.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcPersonSegment.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcPersonSegment.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcAudio3D.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcAudio3D.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcSuperResolution.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcSuperResolution.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  "NERtcVideoDenoise.xcframework/ios-arm64_armv7")
    echo "arm64 armv7"
    ;;
  "NERtcVideoDenoise.xcframework/ios-arm64_i386_x86_64-simulator")
    echo "arm64 i386 x86_64"
    ;;
  esac
}

copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
        matched_all_archs="0"
        break
      fi

      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcAiDenoise.xcframework" "NERtcSDK/AiDenoise" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcAiHowling.xcframework" "NERtcSDK/AiHowling" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcBeauty.xcframework" "NERtcSDK/Beauty" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcFaceDetect.xcframework" "NERtcSDK/FaceDetect" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcFaceEnhance.xcframework" "NERtcSDK/FaceEnhance" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcnn.xcframework" "NERtcSDK/Nenn" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcSDK.xcframework" "NERtcSDK/RtcBasic" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcReplayKit.xcframework" "NERtcSDK/ScreenShare" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcPersonSegment.xcframework" "NERtcSDK/Segment" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcAudio3D.xcframework" "NERtcSDK/SpatialSound" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcSuperResolution.xcframework" "NERtcSDK/SuperResolution" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"
install_xcframework "${PODS_ROOT}/NERtcSDK/NERTC/NERtcSDK/NERtcVideoDenoise.xcframework" "NERtcSDK/VideoDenoise" "framework" "ios-arm64_armv7" "ios-arm64_i386_x86_64-simulator"

