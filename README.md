Motion  - iOS accelerometer, gyroscope, magnetometer readings and more for Fuse
======

![App preview](https://github.com/AlexGustafsson/fuse-motion/raw/master/assets/preview.gif)

Motion is an easy to use integration of all iOS's sensors reflecting motion, made for [Fuse](https://fusetools.com). It enables easy creation of compasses, motion trackers, activity trackers and so on.

# Quickstart
<a name="quickstart"></a>

#### Install Motion
Right now a manual installation is required. Requires Fuse 0.30.0.

Copy the following files to your project:
- Motion.js
- Motion.hh
- Motion.mm
- Motion.uno

Update your `.unoproj` to reflect the following changes:
```json
"Packages": [
  "Fuse",
  "FuseJS",
  "Fuse.Scripting"
],
"Includes": [
  "Motion.hh:ObjCHeader:iOS",
  "Motion.mm:ObjCSource:iOS",
  "*"
],
"iOS": {
  "PList": {
    "NSMotionUsageDescription": "Motion access motivation"
  }
}
```

_note, the user is only asked to allow motion usage when subscribing to `activity`_

#### Implementing Motion

Subscribe to sensor updates:
```javascript

<JavaScript>
  var Motion = require("Motion");
  Motion.Subscribe("accelerometer magnetometer gyroscope motion activity", 0.2);
</JavaScript>
```
_Optional:_
Include Motion in your App's `MainView.ux` to export all measurements as observables:
```xml
<JavaScript File="MotionJS.js"/>
```

# Table of contents

[Quickstart](#quickstart)<br/>
[Using Motion](#how)<br/>
[Examples](#examples)<br/>
[Contributing](#contributing)<br/>
[Disclaimer](#disclaimer)

# Using Motion
<a name="how"></a>

~~Note: API is due to change, stay updated. Until then, *use the source, Luke*.~~<br />
The API is pretty final. If you've got any feedback, please make your voice heard.

#### Implementing observables

Include Motion in your App's `MainView.ux`:
```xml
<JavaScript File="MotionJS.js"/>
```

Access the values using the same names as the JS API. See the "values" example for all available values.

```xml
<Text Value="{magnetometer.magneticField.x}" FontSize="20"/>
```

#### Subscribing to updates
To save resources when they are not needed, subscription is used to only grab values from the device when needed. Subscribe only to the events you need and when you need them.

```javascript

<JavaScript>
  //Global module with a static instance - can be used anywhere
  var Motion = require("Motion");

  //Subscribe to changes from all available sensors with an interval of 0.2 seconds
  Motion.Subscribe("accelerometer magnetometer gyroscope motion activity", 0.2);
</JavaScript>
```

To release resources when they are no longer needed, unsubscribe to updates whenever possible.

```javascript
  //Unsubscribe to all changes
  Motion.Unsubscribe("accelerometer magnetometer gyroscope motion activity");
```

See the [Apple webpage](https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/motion_event_basics/motion_event_basics.html) on selecting a proper interval.

| Interval (s)  | Usage  |
|---|---|
| 0.1 - 0.05  | Suitable for determining a device’s current orientation vector.  |
| 0.03 – 0.017  | Suitable for games and other apps that use the accelerometer for real-time user input.  |
| 0.014 – 0.01  |  Suitable for apps that need to detect high-frequency motion. For example, you might use this interval to detect the user hitting the device or shaking it very quickly. |

#### Listening for updates
To retrieve the actual values, events are used.

~~**Note**: In their current state, Fuse `NativeEvents` don't allow for more than one "listener". As such you can only subscribe to the events once. Subscribing again will override any previous subscriptions. Since Motion already listens to the updates in order to share the values to UX, listening for the updates will disable that feature.~~<br />
Fuse 0.30.0 came with an overhauled event system. As such proper events are now implemented in Motion.

```javascript
<JavaScript>
  Motion.on("accelerometerChanged", function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Accelerometer values:", values);
  });

  Motion.on("gyroscopeChanged", function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Gyroscope values:", values);
  });

  Motion.on("motionChanged", function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Motion values:", values);
  });

  Motion.on("magnetometerChanged", function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Magnetometer values:", values);
  });

  Motion.on("activityChanged", function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Activity values:", values);
  });
</JavaScript>
```

#### Accessing values directly in UX
Motion exposes several values directly to UX Markup.

~~**Note**: In their current state, Fuse `NativeEvents` don't allow for more than one "listener". As such you can only subscribe to the events once. Subscribing again will override any previous subscriptions. Since Motion already listens to the updates in order to share the values to UX, listening for the updates will disable this feature.~~<br />
Fuse 0.30.0 came with an overhauled event system. As such proper events are now implemented in Motion.

The following values are exposed:

```javascript
var accelerometer = Observable({
  acceleration: {x: 0, y: 0, z: 0}
}),
gyroscope = Observable({
  rotationRate: {x: 0, y: 0, z: 0}
}),
magnetometer = Observable({
  magneticField: {x: 0, y: 0, z: 0}
}),
motion = Observable({
  attitude: {yaw: 0, pitch: 0, roll: 0},
  rotationRate: {x: 0, y: 0, z: 0},
  gravity: {x: 0, y: 0, z: 0},
  magneticField: {accuracy: -1, x: 0, y: 0, z: 0},
  userAcceleration: {x: 0, y: 0, z: 0}
}),
activity = Observable({
  unknown: true,
  stationary: false,
  walking: false,
  running: false,
  automotive: false,
  cycling: false,
  confidence: "low"
});
```

If you are unsure how to use values exposed from javascript through `Observables` check out the [Fuse documentation](https://www.fusetools.com/docs/fusejs/observable) and [this example](https://github.com/alexgustafsson/fuse-motion/tree/master/examples/values).

# Examples
<a name="examples"></a>

#### Demo app
When built, this project will act as an app showcasing all the examples.

#### [Values](https://github.com/alexgustafsson/fuse-motion/tree/master/examples/values)
Displays all available values.

#### [Gravity](https://github.com/alexgustafsson/fuse-motion/tree/master/examples/gravity)
Uses the magnetometer to apply a gravity effect to a dropshadow.

#### [Shock](https://github.com/alexgustafsson/fuse-motion/tree/master/examples/shock)
Uses the accelerometer to detect when the phone is hit.

#### [Swipe](https://github.com/alexgustafsson/fuse-motion/tree/master/examples/swipe)
No more phone thumb from "swiping right"! Train your wrist by using the gyroscope to enable a swipe like feature.

# Contributing
<a name="contributing"></a>

Any help with the project is more than welcome. This is my first take on Uno and Objective-C so some things might not be following best practices or be incorrectly implemented all together.

#### TODO:

- Integrate Motion in UX via `animators`
- ~~Implement `activity updates`~~
- ~~[Make multiple event listeners possible](https://www.fusetools.com/community/forums/howto_discussions/multiple_listeners_to_nativeevents?page=1)~~
- ~~Make API more developer-friendly~~
- ~~Improve documentation~~
- Add more examples
- Make compatible with [fusepm](https://github.com/bolav/fusepm)

# Disclaimer
<a name="disclaimer"></a>

_Although the project is very capable, it is not built with production in mind. Therefore there might be complications when trying to use Motion for large-scale projects meant for the public. Motion was created to easily integrate sensor readings on iOS and as such it might not promote best practices nor be performant._

_Built with Fuse 0.30.0 (build 8529) and Xcode Version 8.1 (8B62), tested on iPhone 6 iOS 10.2 Public Beta 2._
