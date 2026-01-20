#!/usr/bin/env bash
# Fetch the latest version of the library
fetch() {
if [ -f "scope_guard.hpp" ]; then return; fi
URL="https://github.com/Neargye/scope_guard/raw/refs/heads/master/include/scope_guard.hpp"
FILE="scope_guard.hpp"

# Download the release
if [ ! -f "$FILE" ]; then
  echo "Downloading $FILE from $URL ..."
  curl -L "$URL" -o "$FILE"
  echo ""
fi
}


# Test the project
test() {
echo "Running 01-scope_exit.cxx ..."
g++ -I. -o 01.exe examples/01-scope_exit.cxx     && ./01.exe && echo -e "\n"
echo "Running 02-scope_fail.cxx ..."
g++ -I. -o 02.exe examples/02-scope_fail.cxx     && ./02.exe && echo -e "\n"
echo "Running 03-scope_success.cxx ..."
g++ -I. -o 03.exe examples/03-scope_success.cxx  && ./03.exe && echo -e "\n"
}


# Main script
if [[ "$1" == "test" ]]; then test
elif [[ "$1" == "fetch" ]]; then fetch
else echo "Usage: $0 {fetch|test}"; fi
