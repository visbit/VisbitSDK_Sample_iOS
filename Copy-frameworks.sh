#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

install_framework()
{
  local source=""
  echo "check ==> ${BUILT_PRODUCTS_DIR}/$1"
  echo "check ==> ${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  echo "check ==> $1"
  
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi
  

  local destination="${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi
  
  # iOS doesn't support nested frameworks. We will flat it here  
  if [ -d "${source}/Frameworks" ]; then
  	for embedded in ${source}/Frameworks/*.framework; do
	  	install_framework $embedded
	  	rm -rf $embedded
	done
	rm -rf "${source}/Frameworks"
  fi
  
  # use filter instead of exclude so missing patterns dont' throw errors
  echo "rsync -av --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync -av --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  embeded_framework_path="${destination}/${basename}.framework/Frameworks"
  if [ -d "${embeded_framework_path}" ]; then
    for file in `find "${embeded_framework_path}" -name "*.framework"`;
      do echo $file
          local embeded_basename
          embeded_basename="$(basename -s .framework "$file")"
          embeded_binary="${file}/${embeded_basename}"
          echo $embeded_binary
          echo "======"
          strip_invalid_archs "$embeded_binary"
          code_sign_if_enabled "$file"
      done
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements \"$1\""
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$1"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current file
  archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)"
  stripped=""
  for arch in $archs; do
    if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
}

find . -iname "VideoPlayer_iOS_Native.framework" | head -1 | xargs -I {} cp -r {} "${BUILT_PRODUCTS_DIR}"
install_framework "VideoPlayer_iOS_Native.framework"

# Cleanup other frameworks
final_cleanup() {
  local destination="${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
  for framework in ${destination}/*.framework; do
	local basename
	basename="$(basename -s .framework "$framework")"
  	binary="${destination}/${basename}.framework/${basename}"
	if ! [ -r "$binary" ]; then
      binary="${destination}/${basename}"
	fi

	# Strip invalid architectures so "fat" simulator / device frameworks work on device
  	if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
      strip_invalid_archs "$binary"
  	fi
  done
}

final_cleanup 
