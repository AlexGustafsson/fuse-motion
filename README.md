Motion  - iOS accelerometer, gyroscope and magnetometer readings for Fuse
======

Motion is an easy to use integration of all iOS's sensors reflecting motion, made for [Fuse](https://fusetools.com). It enables easy creation of compasses, motion trackers, activity trackers and so on.

# Quickstart
<a name="quickstart"></a>

#### Install Motion
Right now a manual installation is required.

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
]
```

#### Implementing Motion

Include Motion in your App's `MainView.ux`:
```xml
<JavaScript File="Motion.js"/>
```

Subscribe to sensor updates:
```javascript

<JavaScript>
  var Motion = require("Motion");
  Motion.Subscribe("accelerometer magnetometer gyroscope motion", 0.2);
</JavaScript>
```

# Table of contents

[Quickstart](#quickstart)<br/>
[Using Motion](#how)<br/>
[Examples](#examples)<br/>
[Contributing](#contributing)<br/>
[Disclaimer](#disclaimer)

# Using Motion
<a name="how"></a>

Note: API is due to change, stay updated. Until then, *use the source, Luke*.

#### Implementing
Include Motion in your App's `MainView.ux`:
```xml
<JavaScript File="Motion.js"/>
```

#### Subscribing to updates
To save resources when they are not needed, subscription is used to only grab values from the device when needed. Subscribe only to the events you need and when you need them.

```javascript

<JavaScript>
  //Global module with a static instance - can be used anywhere
  var Motion = require("Motion");

  //Subscribe to changes from all available sensors with an interval of 0.2 seconds
  Motion.Subscribe("accelerometer magnetometer gyroscope motion", 0.2);
</JavaScript>
```

#### Listening for updates
To retrieve the actual values, events are used.

**Note**: In their current state, Fuse `NativeEvents` don't allow for more than one "listener". As such you can only subscribe to the events once. Subscribing again will override any previous subscriptions. Since Motion already listens to the updates in order to share the values to UX, listening for the updates will disable that feature.

```javascript
<JavaScript>
  Motion.onAccelerometerChanged = function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Accelerometer values: ", values);
  }

  Motion.onGyroscopeChanged = function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Gyroscope values: ", values);
  }

  Motion.onMotionChanged = function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Device motion values: ", values);
  }

  Motion.onMagnetometerChanged = function(values){
    values = JSON.parse(values);

    if(!values.error)
      console.log("Magnetometer values: ", values);
  }
</JavaScript>
```

#### Accessing values directly in UX
Motion exposes several values directly to UX Markup.

**Note**: In their current state, Fuse `NativeEvents` don't allow for more than one "listener". As such you can only subscribe to the events once. Subscribing again will override any previous subscriptions. Since Motion already listens to the updates in order to share the values to UX, listening for the updates will disable this feature.

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
});
```

If you are unsure how to use values exposed from javascript through `Observables` check out the [Fuse documentation](https://www.fusetools.com/docs/fusejs/observable) and [this example](https://github.com/alexgustafsson/fuse-motion/examples/values).

# Examples
<a name="examples"></a>

#### [Values](https://github.com/alexgustafsson/fuse-motion/examples/values)
Displays all available values.

#### [Gravity](https://github.com/alexgustafsson/fuse-motion/examples/gravity)
Uses the magnetometer to apply a gravity effect to a dropshadow.

#### [Shock](https://github.com/alexgustafsson/fuse-motion/examples/shock)
Uses the accelerometer to detect when the phone is hit.

#### [Swipe](https://github.com/alexgustafsson/fuse-motion/examples/swipe)
No more phone thumb from "swiping right"! Train your wrist by using the gyroscope to enable a swipe like feature.

# Contributing
<a name="contributing"></a>

Any help with the project is more than welcome. This is my first take on Uno and Objective-C so some things might not be following best practices or incorrectly implemented all together.

#### TODO:

- Integrate Motion in UX via `animators`
- Implement `activity updates`
- [Make multiple event listeners possible](https://www.fusetools.com/community/forums/howto_discussions/multiple_listeners_to_nativeevents?page=1)
- Make API more developer-friendly
- Improve documentation
- Add more examples
- Make compatible with [fusepm](https://github.com/bolav/fusepm)

# Disclaimer
<a name="disclaimer"></a>

_Although the project is very capable, it is not built with production in mind. Therefore there might be complications when trying to use Motion for large-scale projects meant for the public. Motion was created to easily integrate sensor readings on iOS and as such it might not promote best practices nor be performant._
