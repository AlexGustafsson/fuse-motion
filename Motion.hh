#import <CoreMotion/CoreMotion.h>

@interface Motion : NSObject

@property (strong,nonatomic) CMMotionManager *manager;
@property (strong,nonatomic) NSTimer *pollingTimer;
@property (strong, nonatomic) void(^accelerometerCallback)(float, float, float);
@property (strong, nonatomic) void(^gyroscopeCallback)(float, float, float);
@property (strong, nonatomic) void(^motionCallback)(float, float, float);

- (void) startTimer;

- (void) pollValues:(NSTimer *) timer;

- (void) subscribeAccelerometer: (void(^)(float, float, float)) callback;
- (void) unsubscribeAccelerometer;

- (void) subscribeGyroscope: (void(^)(float, float, float)) callback;
- (void) unsubscribeGyroscope;

- (void) subscribeMotion: (void(^)(float, float, float)) callback;
- (void) unsubscribeMotion;

@end
