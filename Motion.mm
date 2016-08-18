#import "Motion.hh"

//TODO: add magnetometer support
//http://stackoverflow.com/questions/11711646/why-am-i-getting-0-degrees-from-magneticfield-property-the-whole-time

@implementation Motion

-(id)init {
  if (self = [super init]) {

  }
  return self;
}

/*
//Register for Coremotion notifications
[self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity)
{
  NSLog(@"Got a core motion update");
  NSLog(@"Current activity date is %f",activity.timestamp);
  NSLog(@"Current activity confidence from a scale of 0 to 2 - 2 being best- is: %ld",activity.confidence);
  NSLog(@"Current activity type is unknown: %i",activity.unknown);
  NSLog(@"Current activity type is stationary: %i",activity.stationary);
  NSLog(@"Current activity type is walking: %i",activity.walking);
  NSLog(@"Current activity type is running: %i",activity.running);
  NSLog(@"Current activity type is automotive: %i",activity.automotive);
}];
*/

//Continously retrieve 3D accelerometer values measured in G:s
- (void) getAccelerometerValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
      self.manager = [[CMMotionManager alloc] init];

  if(self.manager.accelerometerAvailable){
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
  }
}

//Continously retrieve 3D rotation rates measured in angles
- (void) getGyroValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
      self.manager = [[CMMotionManager alloc] init];

  if(self.manager.gyroAvailable){
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
  }
}

- (void) getMagnetometerValues: (double)interval withCallback:(void(^)(NSString*)) callback{
  if(self.manager == nil)
      self.manager = [[CMMotionManager alloc] init];

  if(self.manager.magnetometerAvailable){
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
  }
}

- (void) getMotionValues: (double)interval withCallback:(void(^)(NSString*)) callback{
    if(self.manager == nil)
        self.manager = [[CMMotionManager alloc] init];

  if(self.manager.deviceMotionAvailable){
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

         //Return in degrees instead of radians
         double degreesFromRadian = 180 / M_PI;

         CMQuaternion quat = motion.attitude.quaternion;
         double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));

         if (self.previousAttitudeYaw == 0) {
             self.previousAttitudeYaw = yaw;
         }

         // kalman filtering
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
  }
}

@end
