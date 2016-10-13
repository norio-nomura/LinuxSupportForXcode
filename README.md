# LinuxSupport for Xcode
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

LinuxSupport for Xcode is an Xcode Extension.

## Functions
- Generate available for enumcases that changed to uppercase/lowercase
- Generate allTests for subclasses of `XCTestCase`

## Requirements
- Xcode 8.0

## Install

1. Install Xcode 8
2. If you are using OS X 10.11, running `sudo /usr/libexec/xpccachectl` and rebooting are required for using Xcode Extension.
3. Clone this repository. _(Using submodules!)_
4. Run `xcodebuild -workspace LinuxSupportForXcode.xcworkspace -scheme LinuxSupportForXcode install DSTROOT=~` and install `~/Applications/LinuxSupportForXcode.app`

## Author

Norio Nomura

## License

LinuxSupport for Xcode is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
