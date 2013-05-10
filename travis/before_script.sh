#!/bin/sh

env
xcodebuild -list -workspace Frank.xcworkspace

brew update
brew install ios-sim
#IOS_SIM_DIR=`brew info ios-sim | sed -n '3 p' | awk '{print $1}'`
#mkdir bin
#cp $IOS_SIM_DIR/bin/ios-sim ./bin/ios-sim
