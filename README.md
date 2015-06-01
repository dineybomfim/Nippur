![Nippur](http://db-in.com/nippur/images/nippur.png)

[![Version](https://img.shields.io/cocoapods/v/Nippur.svg?style=flat)](http://cocoapods.org/pods/Nippur)
[![License](https://img.shields.io/cocoapods/l/Nippur.svg?style=flat)](http://cocoapods.org/pods/Nippur)
[![Platform](https://img.shields.io/cocoapods/p/Nippur.svg?style=flat)](http://cocoapods.org/pods/Nippur)
[![CI Status](https://img.shields.io/travis/dineybomfim/Nippur.svg?style=flat)](https://travis-ci.org/dineybomfim/Nippur)
[![Coverage](https://img.shields.io/coveralls/dineybomfim/Nippur.svg?style=flat)](https://coveralls.io/r/dineybomfim/Nippur)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation

Nippur is compatible with iOS 6 or later.

<img src="http://db-in.com/nippur/images/logo_small.png" width="100" height="100"></img>

Nippur is available through [CocoaPods](http://cocoapods.org/pods/Nippur). To install
it, simply add the following line to your Podfile:

```ruby
pod "Nippur"
```

<img src="http://db-in.com/nippur/images/logo_core_small.png" width="100" height="100"></img>
<img src="http://db-in.com/nippur/images/logo_animation_small.png" width="100" height="100"></img>
<img src="http://db-in.com/nippur/images/logo_interface_small.png" width="100" height="100"></img>
<img src="http://db-in.com/nippur/images/logo_geolocation_small.png" width="100" height="100"></img>
<img src="http://db-in.com/nippur/images/logo_media_small.png" width="100" height="100"></img>

Nippur is made by 5 packages (modules), which you can import and use individually.
You can also leave extra code outside your binary file by using the subspecs, use the following lines on your Podfile:

```ruby
pod "Nippur/Core"
pod "Nippur/Animation"
pod "Nippur/Interface"
pod "Nippur/Geolocation"
pod "Nippur/Media"
```

Now just add to your Prefix Header (.pch)

```objc
#import "NippurCore.h"
#import "NippurAnimation.h"
#import "NippurInterface.h"
#import "NippurGeolocation.h"
#import "NippurMedia.h"
```


## Core
The Core is ready to the daily needs like connections, JSON, easy creation of blocks, models, singletons, logs, timers, loops and more.

```objc
[NPPConnector connectorWithURL:@"https://httpbin.org/post"
							method:NPPHTTPMethodPOST
						   headers:nil
							  body:nil
						completion:^(NPPConnector *connector)
	{
		nppLog(@"%@", [NPPJSON objectWithData:connector.receivedData]);
	}];
```

## Animation
The Nippur Actions (NPPAction) can animating everything.

```objc
NPPAction *move = [NPPAction moveKey:@"transform.translation.x" by:2 duration:1.0];
NPPAction *rotate = [NPPAction moveKey:@"transform.rotation.x" to:2.0 duration:1.0];
NPPAction *group = [NPPAction group:@[ move, rotate ]];
move.ease = NPPActionEaseElasticOut;

[myView runAction:group];

// Any numerical property can be interpolated
AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:mySoundData error:nil];
[player runAction:[NPPAction moveKey:@"volume" from:0.0 to:1.0 duration:3.0f]];
[player play];
```

## Interface

## Geolocation

## Media

## Author

Diney Bomfim, diney@db-in.com

## License

Nippur is available under the MIT license. See the LICENSE file for more info.
