#!/bin/bash

#
#  Version can be selected by 'source swift.sh [5.10|6.1]' or '. swift.sh [5.10|6.1]'
#  The default version is 5.10. If version is missing, default is used
#

swiftVersion="${1:-'5.10'}"
SWVersion=$(lsb_release -rs)

wget http://packages.semaphoreci.com/swift/swift-${swiftVersion}-RELEASE-ubuntu${SWVersion}.tar.gz -O /tmp/swift-${swiftVersion}-RELEASE-ubuntu${SWVersion}.tar.gz
cd /tmp/
tar -zxf swift-${swiftVersion}-RELEASE-ubuntu${SWVersion}.tar.gz
sudo mv /tmp/swift-${swiftVersion}-RELEASE-ubuntu${SWVersion} /opt/swift
echo "export PATH=/opt/swift/usr/bin:$PATH" >> ~/.bashrc 
source ~/.bashrc
swift --version
if [[ $? -eq 0 ]]; then 
  echo "Installed swift $(swift --version)"
else
  echo "Swift didn't install correctly"
fi

