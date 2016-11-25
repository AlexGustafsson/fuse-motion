var Motion = require("Motion");

var Observable = require("FuseJS/Observable");

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

Motion.on("accelerometerChanged", function(values){
  values = JSON.parse(values);

  if(!values.error)
    accelerometer.value = values;
});

Motion.on("gyroscopeChanged", function(values){
  values = JSON.parse(values);

  if(!values.error)
    gyroscope.value = values;
});

Motion.on("motionChanged", function(values){
  values = JSON.parse(values);

  if(!values.error)
    motion.value = values;
});

Motion.on("magnetometerChanged", function(values){
  values = JSON.parse(values);

  if(!values.error)
    magnetometer.value = values;
});

Motion.on("activityChanged", function(values){
  values = JSON.parse(values);

  if(!values.error)
    activity.value = values;
});

module.exports = {
  accelerometer: accelerometer,
  gyroscope: gyroscope,
  motion: motion,
  magnetometer: magnetometer,
  activity: activity
};
