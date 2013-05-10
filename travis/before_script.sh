#!/bin/sh

env
xcodebuild -list -workspace Frank.xcworkspace

brew update
brew install ios-sim

# hacky way to install frank-cucumber's dependencies but not frank-cucumber itself.
# we don't want frank-cucumber itself installed because we want to be sure we're testing our local code, not the gem's code.
gem install frank-cucumber --no-rdoc --no-ri -y 
gem uninstall frank-cucumber -x -a -I

#IOS_SIM_DIR=`brew info ios-sim | sed -n '3 p' | awk '{print $1}'`
#mkdir bin
#cp $IOS_SIM_DIR/bin/ios-sim ./bin/ios-sim
