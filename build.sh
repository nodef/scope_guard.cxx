#!/usr/bin/env bash
# Fetch the latest version of the library
fetch() {
if [ -d "taskflow" ]; then return; fi
URL="https://github.com/taskflow/taskflow/archive/refs/heads/master.zip"
ZIP="${URL##*/}"
DIR="taskflow-master"
mkdir -p .build
cd .build

# Download the release
if [ ! -f "$ZIP" ]; then
  echo "Downloading $ZIP from $URL ..."
  curl -L "$URL" -o "$ZIP"
  echo ""
fi

# Unzip the release
if [ ! -d "$DIR" ]; then
  echo "Unzipping $ZIP to .build/$DIR ..."
  cp "$ZIP" "$ZIP.bak"
  unzip -q "$ZIP"
  rm "$ZIP"
  mv "$ZIP.bak" "$ZIP"
  echo ""
fi
cd ..

# Copy the libs to the package directory
echo "Copying libs to taskflow/ ..."
rm -rf taskflow
mkdir -p taskflow
cp -rf ".build/$DIR/taskflow/"* taskflow/
echo ""
}


# Test the project
test() {
echo "Running 01-simple ..."
clang++ -std=c++20 -I. -o 01.exe examples/01-simple.cxx   && ./01.exe && echo -e "\n"
echo "Running 02-pipeline ..."
clang++ -std=c++20 -I. -o 02.exe examples/02-pipeline.cxx && ./02.exe && echo -e "\n"
}


# Main script
if [[ "$1" == "test" ]]; then test
elif [[ "$1" == "fetch" ]]; then fetch
else echo "Usage: $0 {fetch|test}"; fi
