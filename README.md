# FGUserDefaultsInspector

[![CI Status](http://img.shields.io/travis/Goessler, Florian/FGUserDefaultsInspector.svg?style=flat)](https://travis-ci.org/Goessler, Florian/FGUserDefaultsInspector)
[![Version](https://img.shields.io/cocoapods/v/FGUserDefaultsInspector.svg?style=flat)](http://cocoadocs.org/docsets/FGUserDefaultsInspector)
[![License](https://img.shields.io/cocoapods/l/FGUserDefaultsInspector.svg?style=flat)](http://cocoadocs.org/docsets/FGUserDefaultsInspector)
[![Platform](https://img.shields.io/cocoapods/p/FGUserDefaultsInspector.svg?style=flat)](http://cocoadocs.org/docsets/FGUserDefaultsInspector)

With this pod you can explore and edit values inside your NSUserDefaults without the need of a debugger. This might be
especially helpful for your testers or to explore what's actually inside your NSUserDefaults - some 3rd party libs
leave a lot of stuff there.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use it inside your project just instantiate a FGUserDefaultsInspectorViewController and push it inside of an
UINavigationController.

## Requirements

iOS7+, although it should run under iOS6 but it's not tested there.

The search bar is only available under iOS8+ cause it uses the new UISearchController.

## Installation

FGUserDefaultsInspector is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "FGUserDefaultsInspector"

## Author

Florian Gößler, webmaster@floriangoessler.de

## License

FGUserDefaultsInspector is available under the MIT license. See the LICENSE file for more info.

