#!/bin/sh

# Go to the repository root
cd "$(dirname "$0")/../.."

rm -rf dist

find expaghetti -type f -name "*.lua" | while IFS= read -r file; do
	echo "Processing $file"
	lua scripts/luvit/build.lua "$file"
done

find expaghetti -type f ! -name "*.lua" | while IFS= read -r file; do
	mkdir -p "dist/$(dirname "$file")"
	cp "$file" "dist/$file"
done

cp package.lua dist/expaghetti/
cp README.md dist/expaghetti/