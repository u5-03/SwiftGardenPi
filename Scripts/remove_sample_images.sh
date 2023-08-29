for file in Sources/SwiftGardenPi/Images/*; do
    if [ "$(basename "$file")" != "sample.jpeg" ]; then
        rm "$file"
    fi
done