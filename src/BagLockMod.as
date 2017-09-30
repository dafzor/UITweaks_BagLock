import mx.utils.Delegate;
import com.Utils.Archive;
import com.GameInterface.DistributedValue;
import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;
/**
 * This is the unholy mash of ElTorquiro_UITweaks BagLock plugin and the Skeleton mod example
 * from the Official Discord #modding channel. It's intended to provide most of the plugin
 * functionality as a stand alone mod.
 * 
 * @author ElTorquiro
 * @author Icarus James
 * @author daf
 */
class BagLockMod
{
	private var m_prefSuffix: String = "UITweaks_BagLock_";
	
	private var m_swfRoot: MovieClip; // Our root MovieClip
	private var m_prefs: Object; // Object to save our preferences DistributedValues

	private var m_waitForId: Number; // Tracking ID for calling WaitFor class
	private var m_backpackMonitor: DistributedValue; // Tracking variable to check visibility of backpack
	
    public function BagLockMod(swfRoot: MovieClip) 
    {
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;

		// Inicializes our options object, needs to be created now so when we make our
		// DistributedValue monitors the list actually has elements...
		m_prefs = {
			Enabled: undefined,
			OverrideOnShift: undefined,
			OverrideOnCtrl: undefined,
			OverrideOnAlt: undefined,
			AffectSort: undefined
		};

		// Overides our press event handler to be injected in the bags
		ReplacementPressEventHandler = function(buttonIdx: Number) {			
			var keyMap: Object = {
				Shift: Key.SHIFT,
				Ctrl: Key.CONTROL,
				Alt: Key.ALT
			};
			
			// Checks to see if any of the override keys are pressed
			var isKeyPressed: Boolean;
			for (var key: String in keyMap) {		
				if (DistributedValue.GetDValue("UITweaks_BagLock_OverrideOn" + key)) {
					isKeyPressed = Key.isDown(keyMap[key]);

					// NOTE: In the original code this was inverted, wonder why...
					// only makes sence to break if we found a pressed key.
					if (isKeyPressed) break;
				}
			}

			// If the override key is pressed pass the even to the default handler
			if (isKeyPressed) {
				this.UITweaks_BagLock_Press_Original(buttonIdx);
			}
		}
    }
	
	public function OnLoad()
	{
		m_backpackMonitor = DistributedValue.Create("inventory_visible");
		m_backpackMonitor.SignalChanged.Connect(StartBagpackWaitFor, this);
		
		// Creates a public distributed value so it's possible to change settings
		// while the game is running.
		for (var pref in m_prefs) {
			m_prefs[pref] = DistributedValue.Create(m_prefSuffix + pref);
			m_prefs[pref].SignalChanged.Connect(OptionChangeHandler, this);
		}
	}
	
	public function OnUnload():Void 
	{
		m_backpackMonitor.SignalChanged.Disconnect(StartBagpackWaitFor, this);
		m_backpackMonitor = undefined;
		
		for (var name in m_prefs) {
			m_prefs[name].SignalChanged.Disconnect(OptionChangeHandler, this);
			m_prefs[name] = undefined;
		}		
	}
	
	public function Activate(config: Archive)
	{
		// Loads the preferences from the Archive with defaults in case we haven't go any
		m_prefs.Enabled.SetValue(Boolean(config.FindEntry("Enabled", true)));
		m_prefs.OverrideOnShift.SetValue(Boolean(config.FindEntry("OverrideOnShift", true)));
		m_prefs.OverrideOnCtrl.SetValue(Boolean(config.FindEntry("OverrideOnCtrl", false)));
		m_prefs.OverrideOnAlt.SetValue(Boolean(config.FindEntry("OverrideOnAlt", false)));
		m_prefs.AffectSort.SetValue(Boolean(config.FindEntry("AffectSort", true)));

		StartBagpackWaitFor();
	}
	
	public function Deactivate(): Archive
	{
		StopBagpackWaitFor();

		// Some example code for saving variables to an Archive
		var config: Archive = new Archive();

		for (var pref in m_prefs) {
			config.AddEntry(pref, m_prefs[pref].GetValue());
		}
		
		return config;
	}
	
	/**
	 * Previously waitForTest(). Tests to see if the backpack is available. Used with the WaitFor
	 * class.
	 * @return true if backpack is available, false otherwise.
	 */
	public function IsBackpackAvailable(): Boolean
	{
		return _root.backpack2.m_ModuleActivated;
	}

	/**
	 * Previously apply. Stops the WaitFor and restarts it if the enabled option is set to true.
	 */
	public function StartBagpackWaitFor(): Void
	{
		StopBagpackWaitFor();
		
		// only apply if enabled
		if (m_prefs.Enabled.GetValue()) {
			m_waitForId = WaitFor.start(Delegate.create(this, IsBackpackAvailable),
				100, 3000, Delegate.create(this, Hook));
		}
	}
	
	/**
	 * Previously stopWaitFor. Stops WaitFor that's checking if the backpack becomes
	 * available.
	 */
	public function StopBagpackWaitFor(): Void
	{
		WaitFor.stop(m_waitForId);
		m_waitForId = undefined;
	}
	
	/**
	 * Applies or removes the event override to each opened bag 
	 * depending on if it's setting enabled is true or not.
	 */
	public function Hook(enabled: Boolean): Void
	{
		StopBagpackWaitFor();

		var backpack = _root.backpack2;
		var bags: Array = backpack.m_IconBoxes;
		
		for (var name: String in bags) {
			var bag = bags[name];
			
			// apply or revert hook on window chrome only when inventory is open
			if (m_backpackMonitor.GetValue()) {
				HookWindowChrome(bag, enabled);
			}
			
			// NOTE: There was a option to lock items when a bag was pinned, due to 
			// swl locking the player to action camera the option was useless and the
			// code removed.
		}
	}

	public function HookWindowChrome(bag, setHook: Boolean): Void
	{
		var window:MovieClip = bag.m_WindowMC;

		// only take action if it is needed
		if ((setHook && window.UITweaks_BagLock_Prefs) || (!setHook && !window.UITweaks_BagLock_Prefs)) {
			return;
		}
		
		var elementEventMap: Object = {
			i_Background: "onMousePress",
			i_FrameName: "onPress",
			i_TopBar: "onPress",
			i_ResizeButton: "onMousePress",
			i_TrashButton: "onPress",
			i_SortButton: "onPress"
		};
		
		for (var name: String in elementEventMap) {
			var element: MovieClip = window[name];
			var eventName: String = elementEventMap[name];
			
			// If it's the sort button and affectSort = false, don't hook
			if (setHook && !(name == "i_SortButton" && !m_prefs.AffectSort.GetValue())) {
				element.UITweaks_BagLock_Press_Original = element[eventName];
				element[eventName] = Delegate.create(element, ReplacementPressEventHandler);
			}
			else {
				// Only remove if it's actually been hooked since i_SortButton may or may not be hooked
				if (element.hasOwnProperty("UITweaks_BagLock_Press_Original")) {
					element[eventName] = element.UITweaks_BagLock_Press_Original;
					delete element.UITweaks_BagLock_Press_Original;
				}
			}
		}
		
		// In the original mod this passed an array of prefs, it was changed to DistributedValues
		// so the it's no longer needed so we just pass the suffix we  using.
		setHook ? window.UITweaks_BagLock_Prefs = true : delete window.UITweaks_BagLock_Prefs;
	}
	
	/**
	 * previously pressDelegated. Signature of the replacement press Event handler that's
	 * injected into the bag code. The actual body is in BagLockMod constructor.
	 */
	public function ReplacementPressEventHandler(buttonIdx: Number): Void
	{
	}

	/**
	 * Previously prefChangeHandler. Called everytime an exposed Distributed Value is changed
	 * @param	dv DistributedValue that triggered the event.
	 */
	public function OptionChangeHandler(dv: DistributedValue): Void
	{
		// calls the hook to change the state acording to new enabled state
		if (dv.GetName() == m_prefSuffix + "Enabled") {
			Hook(m_prefs.Enabled.GetValue());
		}
		else if (dv.GetName() == m_prefSuffix + "AffectSort") {
			// We changed the affect sort option, so we need to remove the old hooks
			// and apply a new one, so we cheat by setting enabled to fase to remove
			// the old hooks and then calling it again with to setup the new hook
			Hook(false);
			Hook(m_prefs.Enabled.GetValue());
		}
	}
}