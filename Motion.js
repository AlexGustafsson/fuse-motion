var Motion = require("Motion");

var Observable = require("FuseJS/Observable");

accelerometer = Observable({
  acceleration: {x: 0, y: 0, z: 0}
});
gyroscope = Observable({
  rotationRate: {x: 0, y: 0, z: 0}
});
magnetometer = Observable({
  magneticField: {x: 0, y: 0, z: 0}
})
motion = Observable({
  attitude: {yaw: 0, pitch: 0, roll: 0},
  rotationRate: {x: 0, y: 0, z: 0},
  gravity: {x: 0, y: 0, z: 0},
  magneticField: {accuracy: -1, x: 0, y: 0, z: 0},
  userAcceleration: {x: 0, y: 0, z: 0}
});

Motion.onAccelerometerChanged = function(values){
  values = JSON.parse(values);

  if(!values.error)
    accelerometer.value = values;
}

Motion.onGyroscopeChanged = function(values){
  values = JSON.parse(values);

  if(!values.error)
    gyroscope.value = values;
}

Motion.onMotionChanged = function(values){
  values = JSON.parse(values);

  if(!values.error)
    motion.value = values;
}

Motion.onMagnetometerChanged = function(values){
  values = JSON.parse(values);

  if(!values.error)
    magnetometer.value = values;
}

module.exports = {accelerometer: accelerometer, gyroscope: gyroscope, motion: motion, magnetometer: magnetometer};
