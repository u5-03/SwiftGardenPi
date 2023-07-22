build:
	swift build --configuration release
run:
	.build/release/SwiftGardenPi
setBinary:
	sudo cp .build/release/SwiftGardenPi /usr/local/bin/
runBinary:
	SwiftGardenPi
removeSampleImages:
	sh Scripts/remove_sample_images.sh
resolve:
	swift package resolve
gitReset:
	git fetch
	git reset --hard origin/main
