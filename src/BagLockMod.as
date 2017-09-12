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
	private var m_swfRoot: MovieClip; // Our root MovieClip
	private var m_prefs: Object; // Object to save our preferences

	private var m_waitForId: Number; // Tracking ID for calling WaitFor class
	private var m_backpackMonitor: DistributedValue; // Tracking variable to check visibility of backpack
	
    public function BagLockMod(swfRoot: MovieClip) 
    {
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;

		// Inicializes our options object
		m_prefs = {};

		// Overides our press event handler to be injected in the bags
		ReplacementPressEventHandler = function(buttonIdx: Number) {	
			var prefs = this._parent.UITweaks_BagLock_Prefs;
			
			var keyMap: Object = {
				shift: Key.SHIFT,
				ctrl: Key.CONTROL,
				alt: Key.ALT
			};
			
			// Checks to see if any of the override keys are pressed
			var isKeyPressed: Boolean;
			for (var key: String in keyMap) {		
				if (prefs["override_on_" + key]) {
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
	}
	
	public function OnUnload()
	{
	}
	
	public function Activate(config: Archive)
	{
		// Loads the preferences from the Archive with defaults in case we haven't go any
		m_prefs.enabled = Boolean(config.FindEntry("enabled", true));
		m_prefs.override_on_shift = Boolean(config.FindEntry("override_on_shift", true));
		m_prefs.override_on_ctrl = Boolean(config.FindEntry("override_on_ctrl", false));
		m_prefs.override_on_alt = Boolean(config.FindEntry("override_on_alt", false));

		StartBagpackWaitFor();
	}
	
	public function Deactivate(): Archive
	{
		StopBagpackWaitFor();

		// Some example code for saving variables to an Archive
		var config: Archive = new Archive();

		config.AddEntry("enabled", m_prefs.enabled);
		config.AddEntry("override_on_shift", m_prefs.override_on_shift);
		config.AddEntry("override_on_ctrl", m_prefs.override_on_ctrl);
		config.AddEntry("override_on_alt", m_prefs.override_on_alt);
		
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
		if (m_prefs.enabled) {
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
	public function Hook(): Void
	{
		StopBagpackWaitFor();

		var backpack = _root.backpack2;
		var bags: Array = backpack.m_IconBoxes;
		
		for (var name: String in bags) {
			var bag = bags[name];
			
			// apply or revert hook on window chrome only when inventory is open
			if (m_backpackMonitor.GetValue()) {
				HookWindowChrome(bag, m_prefs.enabled);
			}
			
			// NOTE: There was a option to lock items when a bag was pinned, due to 
			// swl locking the player to action camera the option was useless and the
			// code removed.
		}
	}

	private function HookWindowChrome(bag, setHook: Boolean): Void
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
			
			if (setHook) {
				element.UITweaks_BagLock_Press_Original = element[eventName];
				element[eventName] = Delegate.create(element, ReplacementPressEventHandler);
			}
			else {
				element[eventName] = element.UITweaks_BagLock_Press_Original;
				delete element.UITweaks_BagLock_Press_Original;
			}
			
		}

		setHook ? window.UITweaks_BagLock_Prefs = m_prefs : delete window.UITweaks_BagLock_Prefs;
	}
	
	/**
	 * previously pressDelegated. Signature of the replacement press Event handler that's
	 * injected into the bag code. The actual body is in BagLockMod constructor.
	 */
	private function ReplacementPressEventHandler(buttonIdx: Number): Void
	{
	}
	
	public function Revert(): Void
	{
		/*
		hook();
		*/
	}

	private function PrefChangeHandler(name: String, newValue, oldValue): Void
	{
		/*	
		switch ( name ) {
			
			case "items.lock.whenPinned":
			case "bags.lock.enabled":
				hook();
			break;
			
		}
		*/
	}
}