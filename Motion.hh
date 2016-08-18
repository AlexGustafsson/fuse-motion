#import <CoreMotion/CoreMotion.h>

@interface Motion : NSObject

@property (strong,nonatomic) CMMotionManager *manager;

@property (nonatomic) double previousAttitudeYaw;

- (void) getAccelerometerValues: (double)interval withCallback:(void(^)(NSString*)) callback;

- (void) getGyroValues: (double)interval withCallback:(void(^)(NSString*)) callback;

- (void) getMagnetometerValues: (double)interval withCallback:(void(^)(NSString*)) callback;

- (void) getMotionValues: (double)interval withCallback:(void(^)(NSString*)) callback;

@end
