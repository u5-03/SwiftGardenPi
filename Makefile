# can't build release build(extra research is required!)
build:
	swift build
run:
	.build/debug/SwiftGardenPi
setBinary: build
	sudo cp .build/debug/SwiftGardenPi /usr/local/bin/
runBinaryDataCapture:
	SwiftGardenPi --captureData
runBinaryDrainWater:
	SwiftGardenPi --drainWater
runBinarySwitchLightON:
	SwiftGardenPi --switchLight isOn
runBinarySwitchLightOFF:
	SwiftGardenPi --switchLight isOff
removeSampleImages:
	sh Scripts/remove_sample_images.sh
resolve:
	swift package resolve
gitReset:
	git fetch
	git reset --hard origin/main
