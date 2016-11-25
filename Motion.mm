#import "Motion.hh"

@implementation Motion

-(id)init {
  if (self = [super init]) {

  }
  return self;
}

//Continously retrieve the activity
- (void) getActivity: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.activityManager == nil)
    self.activityManager = [[CMMotionActivityManager alloc] init];

  //The handler of activity updates doesn't provide a error, therefore omitted
  [self.activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
   withHandler:^(CMMotionActivity *activity)
   {
     callback([NSString stringWithFormat:@"{\"unknown\": %s, \"stationary\": %s, \"walking\": %s, \"running\": %s, \"automotive\": %s, \"cycling\": %s, \"confidence\": \"%s\"}",
       activity.unknown ? "true" : "false", activity.stationary ? "true" : "false", activity.walking ? "true" : "false", activity.running ? "true" : "false", activity.automotive ? "true" : "false", activity.cycling ? "true" : "false", activity.confidence == 0 ? "low" : (activity.confidence == 1 ? "medium" : "high")
       ]);
   }];
}
- (void) stopActivity{
  if(self.activityManager != nil)
    [self.activityManager stopActivityUpdates];
}


//Continously retrieve 3D accelerometer values measured in G:s
- (void) getAccelerometerValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
    self.manager = [[CMMotionManager alloc] init];

  if(self.manager.accelerometerAvailable && !self.manager.accelerometerActive){
    self.manager.accelerometerUpdateInterval = interval;

    [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMAccelerometerData *accelerometer, NSError *error)
     {
       if(error != nil){
         callback([NSString stringWithFormat:@"{\
           \"error\": {\"description\": %@}}",
           error.localizedDescription
           ]);

         return;
       }

        callback([NSString stringWithFormat:@"{\"acceleration\":{\"x\": %f, \"y\": %f, \"z\": %f}}",
          accelerometer.acceleration.x, accelerometer.acceleration.y, accelerometer.acceleration.z
          ]);
     }];
  } else if(!self.manager.accelerometerAvailable){
    callback([NSString stringWithFormat:@"{\
      \"error\": {\"description\": %s}}",
      "accelerometer is not available"
      ]);
  }
}
- (void) stopAccelerometer{
  if(self.manager != nil)
    [self.manager stopAccelerometerUpdates];
}

//Continously retrieve 3D rotation rates measured in angles
- (void) getGyroValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
    self.manager = [[CMMotionManager alloc] init];

  if(self.manager.gyroAvailable && !self.manager.gyroActive){
    self.manager.gyroUpdateInterval = interval;

    [self.manager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMGyroData *gyro, NSError *error)
     {
       if(error != nil){
         callback([NSString stringWithFormat:@"{\
           \"error\": {\"description\": %@}}",
           error.localizedDescription
           ]);

         return;
       }

         //Return in degrees instead of radians
         double degreesFromRadian = 180 / M_PI;

         callback([NSString stringWithFormat:@"{\"rotationRate\":{\"x\": %f, \"y\": %f, \"z\": %f}}",
           degreesFromRadian * gyro.rotationRate.x, degreesFromRadian * gyro.rotationRate.y, degreesFromRadian * gyro.rotationRate.z
           ]);
     }];
  } else if(!self.manager.gyroAvailable){
    callback([NSString stringWithFormat:@"{\
      \"error\": {\"description\": %s}}",
      "gyroscope is not available"
      ]);
  }
}
- (void) stopGyroscope{
  if(self.manager != nil)
    [self.manager stopGyroUpdates];
}

- (void) getMagnetometerValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
    self.manager = [[CMMotionManager alloc] init];

  if(self.manager.magnetometerAvailable && !self.manager.magnetometerActive){
    self.manager.magnetometerUpdateInterval = interval;

    [self.manager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMMagnetometerData *magnetometer, NSError *error)
     {
       if(error != nil){
         callback([NSString stringWithFormat:@"{\
           \"error\": {\"description\": %@}}",
           error.localizedDescription
           ]);

         return;
       }

        callback([NSString stringWithFormat:@"{\"magneticField\": {\"x\": %f, \"y\": %f, \"z\": %f}}",
          magnetometer.magneticField.x, magnetometer.magneticField.y, magnetometer.magneticField.z
          ]);
     }];
  } else if(!self.manager.magnetometerAvailable){
    callback([NSString stringWithFormat:@"{\
      \"error\": {\"description\": %s}}",
      "magnetometer is not available"
      ]);
  }
}
- (void) stopMagnetometer{
  if(self.manager != nil)
    [self.manager stopMagnetometerUpdates];
}

- (void) getMotionValues: (double)interval withCallback:(void(^)(NSString*)) callback{
    if(self.manager == nil)
      self.manager = [[CMMotionManager alloc] init];

  if(self.manager.deviceMotionAvailable && !self.manager.deviceMotionActive){
    self.manager.deviceMotionUpdateInterval = interval;

    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
       if(error != nil){
         callback([NSString stringWithFormat:@"{\
           \"error\": {\"description\": %@}}",
           error.localizedDescription
           ]);

         return;
       }

         //Return in degrees instead of radians
         double degreesFromRadian = 180 / M_PI;

         CMQuaternion quat = motion.attitude.quaternion;
         double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));

         if (self.previousAttitudeYaw == 0) {
             self.previousAttitudeYaw = yaw;
         }

         //Kalman filtering
         static float q = 0.1;   // process noise
         static float r = 0.1;   // sensor noise
         static float p = 0.1;   // estimated error
         static float k = 0.5;   // kalman filter gain

         float x = self.previousAttitudeYaw;
         p = p + q;
         k = p / (p + r);
         x = x + k*(yaw - x);
         p = (1 - k)*p;
         self.previousAttitudeYaw = x;

        callback([NSString stringWithFormat:@"{\
          \"attitude\": {\"yaw\": %f, \"pitch\": %f, \"roll\": %f}, \
           \"rotationRate\": {\"x\": %f, \"y\": %f, \"z\": %f}, \
           \"gravity\": {\"x\": %f, \"y\": %f, \"z\": %f}, \
           \"magneticField\": {\"accuracy\": %d, \"x\": %f, \"y\": %f, \"z\": %f}, \
           \"userAcceleration\": {\"x\": %f, \"y\": %f, \"z\": %f}}",
           x * degreesFromRadian, motion.attitude.pitch * degreesFromRadian, motion.attitude.roll * degreesFromRadian,
           motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z,
           motion.gravity.x, motion.gravity.y, motion.gravity.z,
           motion.magneticField.accuracy, motion.magneticField.field.x, motion.magneticField.field.y, motion.magneticField.field.z,
           motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z
           ]);
     }];
  } else if(!self.manager.deviceMotionActive){
    callback([NSString stringWithFormat:@"{\
      \"error\": {\"description\": %s}}",
      "device motion is not available"
      ]);
  }
}
- (void) stopMotion{
  if(self.manager != nil)
    [self.manager stopDeviceMotionUpdates];
}

@end
