#!/bin/bash

# This script installs the selected version of `chrome` and `chromedriver` in Semaphore's jobs.
# https://github.com/renderedtext/snippets/blob/master/chrome-setup/README.md

semaphore_versions=("115.0.5790.170" "116.0.5845.96" "117.0.5938.149" "118.0.5993.70" "119.0.6045.105" "120.0.6099.109" "121.0.6167.184" "122.0.6261.128" "123.0.6312.122" "124.0.6367.207" "125.0.6422.78")

semaphore_base_url="http://packages.semaphoreci.com/chrome"

validate_version_format() {
  local version=$1
  local regex='^[0-9]{3}\.[0-9]{1}\.[0-9]{4}\.[0-9]{1,3}$'

  if [[ $version =~ $regex ]]; then
    return 0
  else
    echo "ERROR: Version $version format NOT OK!"
    return 1
  fi
}

check_response_code() {
  url=$1
  response=$(curl -o /dev/null -s -w "%{http_code}" "$url")
  if [[ $response -eq 200 ]]; then
    return 0
  else
    echo "ERROR: Response code for $url NOT OK!"
    return 1
  fi
}

check_sha256() {
  file=$1
  if [[ $(sha256sum ${file} | awk '{print $1}') == $(cat ${file}.sha256) ]]; then
    return 0
  else
    echo "ERROR: sha256sum for ${file} NOT OK!"
    return 1
  fi
}

show_semaphore_versions() {
  echo "Supported Chrome versions in Semaphore's repository:"
  for version in "${semaphore_versions[@]}"; do
    echo "$version"
  done
}

validate_semaphore_version() {
  local version=$1
  for semaphore_version in "${semaphore_versions[@]}"; do
    if [[ "${semaphore_version}" == "${version}" ]]; then
      return 0
    fi
  done
  return 1
}

download_semaphore_version() {
  local version=$1

  if ! check_response_code ${semaphore_base_url}/chrome-linux64_${version}.zip; then return 1; fi
  if ! check_response_code ${semaphore_base_url}/chrome-linux64_${version}.zip.sha256; then return 1; fi
  if ! check_response_code ${semaphore_base_url}/chromedriver-linux64_${version}.zip; then return 1; fi
  if ! check_response_code ${semaphore_base_url}/chromedriver-linux64_${version}.zip.sha256; then return 1; fi

  wget -q "${semaphore_base_url}/chrome-linux64_${version}.zip" -O /tmp/chrome-linux64_${version}.zip
  wget -q "${semaphore_base_url}/chrome-linux64_${version}.zip.sha256" -O /tmp/chrome-linux64_${version}.zip.sha256
  wget -q "${semaphore_base_url}/chromedriver-linux64_${version}.zip" -O /tmp/chromedriver-linux64_${version}.zip
  wget -q "${semaphore_base_url}/chromedriver-linux64_${version}.zip.sha256" -O /tmp/chromedriver-linux64_${version}.zip.sha256

  if ! check_sha256 /tmp/chrome-linux64_${version}.zip; then return 1; fi
  if ! check_sha256 /tmp/chromedriver-linux64_${version}.zip; then return 1; fi

  return 0
}

download_google_versions_list() {
  if [[ ! -f /tmp/known-good-versions-with-downloads.json ]]; then
    if ! check_response_code https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json; then return 1; fi
    wget -q "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json" -O /tmp/known-good-versions-with-downloads.json
  fi

  google_versions=($(cat /tmp/known-good-versions-with-downloads.json | jq -r '.versions[].version'))
}

show_google_versions() {
  download_google_versions_list
  for version in "${google_versions[@]}"; do
    echo "$version"
  done
}

validate_google_version() {
  local version=$1
  download_google_versions_list
  for google_version in "${google_versions[@]}"; do
    if [[ "${google_version}" == "${version}" ]]; then
      return 0
    fi
  done
  return 1
}

download_google_version() {
  local version=$1

  local chrome_linux64_url=$(cat /tmp/known-good-versions-with-downloads.json | jq -r --arg version "${version}" '.versions[] | select(.version == $version ) | .downloads.chrome[] | select(.platform == "linux64" ).url')
  if ! check_response_code $chrome_linux64_url; then return 1; fi
  wget -q $chrome_linux64_url -O /tmp/chrome-linux64_${version}.zip

  local chromedriver_linux64_url=$(cat /tmp/known-good-versions-with-downloads.json | jq -r --arg version "${version}"  '.versions[] | select(.version == $version ) | .downloads.chromedriver[] | select(.platform == "linux64" ).url')
  if ! check_response_code $chromedriver_linux64_url; then return 1; fi
  wget -q $chromedriver_linux64_url -O /tmp/chromedriver-linux64_${version}.zip
}

make_chrome_wrapper() {
  local version=$1

  sudo tee /opt/chrome-${version}/chrome-linux64/google-chrome > /dev/null << 'EOF'
#!/bin/bash
export CHROME_WRAPPER="`readlink -f "$0"`"

HERE="`dirname "$CHROME_WRAPPER"`"

if ! command -v xdg-settings &> /dev/null; then
  export PATH="$HERE:$PATH"
else
  xdg_app_dir="${XDG_DATA_HOME:-$HOME/.local/share/applications}"
  mkdir -p "$xdg_app_dir"
  [ -f "$xdg_app_dir/mimeapps.list" ] || touch "$xdg_app_dir/mimeapps.list"
fi

if [[ -n "$LD_LIBRARY_PATH" ]]; then
  LD_LIBRARY_PATH="$HERE:$HERE/lib:$LD_LIBRARY_PATH"
else
  LD_LIBRARY_PATH="$HERE:$HERE/lib"
fi

export LD_LIBRARY_PATH
export GNOME_DISABLE_CRASH_DIALOG=SET_BY_GOOGLE_CHROME
exec < /dev/null
exec > >(exec cat)
exec 2> >(exec cat >&2)
exec -a "$0" "$HERE/chrome" "$@"
EOF
  sudo chmod +x /opt/chrome-${version}/chrome-linux64/google-chrome
}

install() {
  local version=$1

  sudo unzip -q -o /tmp/chrome-linux64_${version}.zip -d /opt/chrome-${version}
  sudo unzip -q -o /tmp/chromedriver-linux64_${version}.zip -d /opt/chromedriver-${version}
  sudo ln -fs /opt/chromedriver-${version}/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
  sudo rm -f /usr/bin/google-chrome
  make_chrome_wrapper ${version}
  sudo ln -fs /opt/chrome-${version}/chrome-linux64/chrome /usr/local/bin/chrome
  sudo ln -fs /opt/chrome-${version}/chrome-linux64/google-chrome /usr/local/bin/google-chrome
  google-chrome --version
  chromedriver --version
}

usage() {
  echo -e "This script setup chrome and chromedriver.

Usage:
  chrome-setup.sh [argument]

List of arguments:
  [version]		Setup selected chrome and chromedriver version (e.g. 125.0.6422.78)
  list-semaphore	List versions available in Semaphore's repository
  list-google		List versions available in Google's repository
  usage | help		Display this message"
}


main() {
  if ! [[ "$#" -eq 1 ]]; then
    echo -e "ERROR: Unsupported number of arguments provided"
    usage
    return 1
  fi

  argument=$1
  case $argument in
    usage | help)
      usage
      ;;
    list-semaphore)
      show_semaphore_versions
      ;;
    list-google)
      show_google_versions
      ;;
    *)
      if validate_version_format $argument; then
        if validate_semaphore_version $argument; then
          download_semaphore_version $argument
          install $argument
        elif validate_google_version $argument; then
          download_google_version $argument
          install $argument
        else
          echo "ERROR: Wrong argument: $argument"
        fi
      else
        usage
        return 1
      fi
      ;;
  esac
}

main $@
