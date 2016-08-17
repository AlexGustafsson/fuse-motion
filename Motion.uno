using Uno;
using Uno.Collections;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;
using Uno.UX;

[Require("Xcode.Framework","CoreMotion.framework")]
[ForeignInclude(Language.ObjC, "Motion.hh")]

[UXGlobalModule]
public class MotionModule : NativeModule
{
	static readonly MotionModule _instance;
	extern(iOS) ObjC.Object _motion;
	NativeEvent _accelerometerChanged, _gyroscopeChanged, _motionChanged;

	public MotionModule()
	{
		if(_instance != null)
      return;

		_instance = this;

		Resource.SetGlobalKey(_instance, "Motion");

		AddMember(new NativeFunction("Subscribe", (NativeCallback)Subscribe));

    AddMember(new NativeFunction("Unsubscribe", (NativeCallback)Unsubscribe));

		_accelerometerChanged = new NativeEvent("onAcceleratorChanged");
    AddMember(_accelerometerChanged);

		_gyroscopeChanged = new NativeEvent("onGyroscopeChanged");
    AddMember(_gyroscopeChanged);

    _motionChanged = new NativeEvent("onMotionChanged");
    AddMember(_motionChanged);

		if defined(iOS)
      _motion = AllocMotion();
	}

	[Foreign(Language.ObjC)]
	extern(iOS) ObjC.Object AllocMotion()
	@{
		return [Motion alloc];
	@}

	[Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeAccelerometer(ObjC.Object motion, Action<float, float, float> callback)
	@{
		[(Motion *)motion subscribeAccelerometer: callback];
    return true;
	@}

  void AccelerometerCallback(float x, float y, float z)
	{
		_accelerometerChanged.RaiseAsync(x, y, z);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeGyroscope(ObjC.Object motion, Action<float, float, float> callback)
	@{
		[(Motion *)motion subscribeGyroscope: callback];
    return true;
	@}

  void GyroscopeCallback(float x, float y, float z)
	{
		_gyroscopeChanged.RaiseAsync(x, y, z);
	}

  [Foreign(Language.ObjC)]
	public extern(iOS) bool SubscribeMotion(ObjC.Object motion, Action<float, float, float> callback)
	@{
		[(Motion *)motion subscribeMotion: callback];
    return true;
	@}

  void MotionCallback(float yaw, float pitch, float roll)
	{
		_motionChanged.RaiseAsync(yaw, pitch, roll);
	}

  object Subscribe(Context c, object[] args)
	{
		if defined(iOS){
      if(args.Length == 0)
        return false;

      bool subscribed = false;

      if(args[0].ToString().Contains("accelerometer"))
        subscribed = SubscribeAccelerometer(_motion, AccelerometerCallback);
      if(args[0].ToString().Contains("gyroscope"))
        subscribed = SubscribeGyroscope(_motion, GyroscopeCallback);
      if(args[0].ToString().Contains("motion"))
        subscribed = SubscribeMotion(_motion, MotionCallback);

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
