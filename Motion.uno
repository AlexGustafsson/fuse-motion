using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Uno;

[Require("Xcode.Framework","CoreMotion.framework")]
[ForeignInclude(Language.ObjC, "Motion.hh")]

[UXGlobalModule]
public class MotionModule : NativeEventEmitterModule
{
	static readonly MotionModule _instance;
	extern(iOS) ObjC.Object _motion;

	//base(false, ...) -> don't cache events that are fired before initialization, ensure up to date, real-time data
	public MotionModule() : base (false, "accelerometerChanged", "gyroscopeChanged", "motionChanged", "magnetometerChanged", "activityChanged")
	{
		if(_instance != null)
      return;

		_instance = this;
		Uno.UX.Resource.SetGlobalKey(_instance, "Motion");

		AddMember(new NativeFunction("Subscribe", (NativeCallback)Subscribe));

    AddMember(new NativeFunction("Unsubscribe", (NativeCallback)Unsubscribe));

		if defined(iOS)
      _motion = AllocMotion();
	}

	[Foreign(Language.ObjC)]
	extern(iOS) ObjC.Object AllocMotion()
	@{
		return [Motion alloc];
	@}

	[Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeAccelerometer(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getAccelerometerValues: interval withCallback:callback];
    return true;
	@}
	[Foreign(Language.ObjC)]
	public extern(iOS) bool UnsubscribeAccelerometer(ObjC.Object motion)
	@{
		[(Motion *)motion stopAccelerometer];
    return true;
	@}
  void AccelerometerCallback(string accelerometer)
	{
		Emit("accelerometerChanged", accelerometer);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeGyroscope(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getGyroValues: interval withCallback:callback];
    return true;
	@}
	[Foreign(Language.ObjC)]
	public extern(iOS) bool UnsubscribeGyroscope(ObjC.Object motion)
	@{
		[(Motion *)motion stopGyroscope];
    return true;
	@}
  void GyroscopeCallback(string gyroscope)
	{
		Emit("gyroscopeChanged", gyroscope);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeMotion(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getMotionValues: interval withCallback:callback];
    return true;
	@}
	[Foreign(Language.ObjC)]
	public extern(iOS) bool UnsubscribeMotion(ObjC.Object motion)
	@{
		[(Motion *)motion stopMotion];
    return true;
	@}
  void MotionCallback(string motion)
	{
		Emit("motionChanged", motion);
	}

	[Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeMagnetometer(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getMagnetometerValues: interval withCallback:callback];
    return true;
	@}
	[Foreign(Language.ObjC)]
	public extern(iOS) bool UnsubscribeMagnetometer(ObjC.Object motion)
	@{
		[(Motion *)motion stopMagnetometer];
    return true;
	@}
  void MagnetometerCallback(string magnetometer)
	{
		Emit("magnetometerChanged", magnetometer);
	}

	[Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeActivity(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getActivity: interval withCallback:callback];
    return true;
	@}
	[Foreign(Language.ObjC)]
	public extern(iOS) bool UnsubscribeActivity(ObjC.Object motion)
	@{
		[(Motion *)motion stopActivity];
    return true;
	@}
  void ActivityCallback(string activity)
	{
		Emit("activityChanged", activity);
	}

  object Subscribe(Context c, object[] args)
	{
		if defined(iOS){
      if(args.Length != 2)
        return false;

      bool subscribed = false;

      if(args[0].ToString().Contains("accelerometer"))
        subscribed = SubscribeAccelerometer(_motion, Marshal.ToDouble(args[1]), AccelerometerCallback);
      if(args[0].ToString().Contains("gyroscope"))
        subscribed = SubscribeGyroscope(_motion, Marshal.ToDouble(args[1]), GyroscopeCallback);
      if(args[0].ToString().Contains("motion"))
        subscribed = SubscribeMotion(_motion, Marshal.ToDouble(args[1]), MotionCallback);
			if(args[0].ToString().Contains("magnetometer"))
        subscribed = SubscribeMagnetometer(_motion, Marshal.ToDouble(args[1]), MagnetometerCallback);
			if(args[0].ToString().Contains("activity"))
        subscribed = SubscribeActivity(_motion, Marshal.ToDouble(args[1]), ActivityCallback);

      return subscribed;
    } else {
      debug_log "Motion is only implemented for iOS";

      return false;
    }
	}

  object Unsubscribe(Context c, object[] args)
	{
		if defined(iOS){
      if(args.Length == 0)
        return false;

      bool unsubscribed = false;

			if(args[0].ToString().Contains("accelerometer"))
        unsubscribed = UnsubscribeAccelerometer(_motion);
      if(args[0].ToString().Contains("gyroscope"))
        unsubscribed = UnsubscribeGyroscope(_motion);
      if(args[0].ToString().Contains("motion"))
        unsubscribed = UnsubscribeMotion(_motion);
			if(args[0].ToString().Contains("magnetometer"))
        unsubscribed = UnsubscribeMagnetometer(_motion);
			if(args[0].ToString().Contains("activity"))
        unsubscribed = UnsubscribeActivity(_motion);

      return unsubscribed;
    } else {
      debug_log "Motion is only implemented for iOS";

      return false;
    }
	}
}
