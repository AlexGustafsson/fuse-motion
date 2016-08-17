#import "Motion.hh"

//TODO: add magnetometer support
//http://stackoverflow.com/questions/11711646/why-am-i-getting-0-degrees-from-magneticfield-property-the-whole-time

@implementation Motion

-(id)init {
  if (self = [super init]) {
    self.pollingTimer = nil;
  }
  return self;
}

bool accelerometerSubscribed = false;
bool gyroscopeSubscribed = false;
bool motionSubscribed = false;

//Poll for values and call each callback with xyz
- (void) pollValues:(NSTimer *) timer {
  if(accelerometerSubscribed){
    float accelerometer_x = self.manager.accelerometerData.acceleration.x;
    float accelerometer_y = self.manager.accelerometerData.acceleration.y;
    float accelerometer_z = self.manager.accelerometerData.acceleration.z;

    self.accelerometerCallback(accelerometer_x, accelerometer_y, accelerometer_x);
  }

  if(gyroscopeSubscribed){
    float gyroscope_x = self.manager.gyroData.rotationRate.x;
    float gyroscope_y = self.manager.gyroData.rotationRate.y;
    float gyroscope_z = self.manager.gyroData.rotationRate.z;

    self.gyroscopeCallback(gyroscope_x, gyroscope_y, gyroscope_z);
  }

  if(motionSubscribed){
    float yaw = 180 / M_PI * self.manager.deviceMotion.attitude.yaw;
    float pitch = 180 / M_PI * self.manager.deviceMotion.attitude.pitch;
    float roll = 180 / M_PI * self.manager.deviceMotion.attitude.roll;

    self.motionCallback(yaw, pitch, roll);
  }
}

- (void) startTimer {
    if(self.pollingTimer == nil){
        //Start polling for data in a speed of 10Hz
        self.pollingTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(pollValues:) userInfo:nil repeats:YES];

        [[NSRunLoop mainRunLoop] addTimer:self.pollingTimer forMode:NSDefaultRunLoopMode];

        self.manager = [[CMMotionManager alloc] init];

        //Start updating accelerometer data in a speed of 20Hz
        self.manager.accelerometerUpdateInterval = 0.05;

        //Start updating gyroscope data in a speed of 20Hz
        self.manager.gyroUpdateInterval = 0.05;

        //Start updating device motion data in a speed of 20Hz
        self.manager.deviceMotionUpdateInterval = 0.05;
    }
}

- (void) stopTimer {
  if(!accelerometerSubscribed && !gyroscopeSubscribed && !motionSubscribed){
    [self.pollingTimer invalidate];
    self.pollingTimer = nil;
  }
}

/*// ACCELEROMETER //*/
- (void) subscribeAccelerometer: (void(^)(float, float, float)) callback {
  self.accelerometerCallback = callback;
  [self.manager startAccelerometerUpdates];
  accelerometerSubscribed = true;
  [self startTimer];
}
- (void) unsubscribeAccelerometer{
  [self.manager stopAccelerometerUpdates];
  accelerometerSubscribed = false;
  [self stopTimer];
}

/*// GYROSCOPE //*/
- (void) subscribeGyroscope: (void(^)(float, float, float)) callback {
  self.gyroscopeCallback = callback;
  [self.manager startGyroUpdates];
  gyroscopeSubscribed = true;
  [self startTimer];
}
- (void) unsubscribeGyroscope{
  [self.manager stopGyroUpdates];
  gyroscopeSubscribed = true;
  [self stopTimer];
}

/*// MOTION //*/
- (void) subscribeMotion: (void(^)(float, float, float)) callback {
  self.motionCallback = callback;
  [self.manager startDeviceMotionUpdates];
  motionSubscribed = true;
  [self startTimer];
}
- (void) unsubscribeMotion{
  [self.manager stopDeviceMotionUpdates];
  motionSubscribed = false;
  [self stopTimer];
}

@end
