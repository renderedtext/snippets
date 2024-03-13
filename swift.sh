#!/bin/bash

SWVersion=$(lsb_release -rs)

wget http://packages.semaphoreci.com/swift/swift-5.10-RELEASE-ubuntu${SWVersion}.tar.gz -O /tmp/swift-5.10-RELEASE-ubuntu${SWVersion}.tar.gz
cd /tmp/
tar -zxf swift-5.10-RELEASE-ubuntu${SWVersion}.tar.gz
sudo mv /tmp/swift-5.10-RELEASE-ubuntu${SWVersion} /opt/swift
echo "export PATH=/opt/swift/usr/bin:$PATH" >> ~/.bashrc 
source ~/.bashrc
swift --version
if [[ $? -eq 0 ]]; then 
  echo "Installed swift $(swift --version)"
else
  echo "Swift didn't install correctly"
fi

