using Uno;
using Uno.Collections;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;
using Uno.UX;
using Uno.Threading;

[Require("Xcode.Framework","CoreMotion.framework")]
[ForeignInclude(Language.ObjC, "Motion.hh")]

[UXGlobalModule]
public class MotionModule : NativeModule
{
	static readonly MotionModule _instance;
	extern(iOS) ObjC.Object _motion;
	NativeEvent _accelerometerChanged, _gyroscopeChanged, _motionChanged, _magnetometerChanged;

	public MotionModule()
	{
		if(_instance != null)
      return;

		_instance = this;

		Resource.SetGlobalKey(_instance, "Motion");

		AddMember(new NativeFunction("Subscribe", (NativeCallback)Subscribe));

    AddMember(new NativeFunction("Unsubscribe", (NativeCallback)Unsubscribe));

		_accelerometerChanged = new NativeEvent("onAccelerometerChanged");
    AddMember(_accelerometerChanged);

		_gyroscopeChanged = new NativeEvent("onGyroscopeChanged");
    AddMember(_gyroscopeChanged);

    _motionChanged = new NativeEvent("onMotionChanged");
    AddMember(_motionChanged);

		_magnetometerChanged = new NativeEvent("onMagnetometerChanged");
		AddMember(_magnetometerChanged);

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
  void AccelerometerCallback(string accelerometer)
	{
		_accelerometerChanged.RaiseAsync(accelerometer);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeGyroscope(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getGyroValues: interval withCallback:callback];
    return true;
	@}
  void GyroscopeCallback(string gyroscope)
	{
		_gyroscopeChanged.RaiseAsync(gyroscope);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeMotion(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getMotionValues: interval withCallback:callback];
    return true;
	@}
  void MotionCallback(string motion)
	{
		_motionChanged.RaiseAsync(motion);
	}

	[Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeMagnetometer(ObjC.Object motion, double interval, Action<string> callback)
	@{
		[(Motion *)motion getMagnetometerValues: interval withCallback:callback];
    return true;
	@}
  void MagnetometerCallback(string motion)
	{
		_magnetometerChanged.RaiseAsync(motion);
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
      /*
      if(args[0].Contains("accelerometer"))
        unsubscribed = SubscribeAccelerometer(_motion, AccelerometerCallback);
      if(args[0].Contains("gyroscope"))
        unsubscribed = SubscribeGyroscope(_motion, GyroscopeCallback);
      if(args[0].Contains("motion"))
        unsubscribed = SubscribeMotion(_motion, MotionCallback);
      */
      return unsubscribed;
    } else {
      debug_log "Motion is only implemented for iOS";

      return false;
    }
	}
}
