#import <CoreMotion/CoreMotion.h>

@interface Motion : NSObject

//Static instance variables, ensures that they stay in memory
@property (strong,nonatomic) CMMotionManager *manager;
@property (strong,nonatomic) CMMotionActivityManager *activityManager;

@property (nonatomic) double previousAttitudeYaw;

- (void) getAccelerometerValues: (double)interval withCallback:(void(^)(NSString*)) callback;
- (void) stopAccelerometer;

- (void) getGyroValues: (double)interval withCallback:(void(^)(NSString*)) callback;
- (void) stopGyroscope;

- (void) getMagnetometerValues: (double)interval withCallback:(void(^)(NSString*)) callback;
- (void) stopMagnetometer;

- (void) getMotionValues: (double)interval withCallback:(void(^)(NSString*)) callback;
- (void) stopMotion;

- (void) getActivity: (double)interval withCallback:(void(^)(NSString*)) callback;
- (void) stopActivity;

@end
