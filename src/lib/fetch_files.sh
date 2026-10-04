# download files given as http(s) URLs (array files) into a tmp dir
# shellcheck shell=bash disable=SC2154
function fetch_files() {
  local i path
  for i in "${!files[@]}"; do
    if [[ ${files[$i]} == "http://"* ]] || [[ ${files[$i]} == "https://"* ]]; then
      init_tmpdir
      path="${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"
      if ! curl -fs --location -o "${path}" "${files[$i]}"; then
        error "download of ${files[$i]} failed!"
      fi
      files[i]="${path}"
    fi
  done
}

# create tmp directory (once) that is removed on exit
function init_tmpdir() {
  if ! [[ ${tmpdir} ]]; then
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' 0 2 3 15
  fi
}
