import mx.utils.Delegate;
import com.Utils.Archive;
import com.GameInterface.DistributedValue;
/**
 * This is the unholy mash of ElTorquiro_UITweaks BagLock plugin and the Skeleton mod example
 * from the Official Discord #modding channel. It's intended to provide most of the plugin
 * functionality as a stand alone mod.
 * 
 * @author daf
 */
class BagLockMod
{    
	private var m_swfRoot: MovieClip; // Our root MovieClip
	
    public function SkeletonMod(swfRoot: MovieClip) 
    {
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;
    }
	
	public function OnLoad()
	{
	}
	
	public function OnUnload()
	{
	}
	
	public function Activate(config: Archive)
	{
	}
	
	public function Deactivate(): Archive
	{
		// Some example code for saving variables to an Archive
		var archive: Archive = new Archive();
		return archive;
	}

	public function BagLock() {
		/*
		prefs.add( "bags.lock.enabled", true );
		prefs.add( "override.shift", true );
		prefs.add( "override.control", true );
		prefs.add( "override.alt", false );
		
		prefs.add( "items.lock.whenPinned", true );
		
		pressDelegate = function( buttonIdx:Number ) {
			
			var prefs = this._parent.UITweaks_BagLock_Prefs;
			
			var map:Object = {
				shift: Key.SHIFT,
				control: Key.CONTROL,
				alt: Key.ALT
			};
			
			var override:Boolean;
			for ( var s:String in map ) {
				var pref:Boolean = prefs.getVal( "override." + s );
				
				if ( pref ) {
					override = Key.isDown( map[s] );
					if ( !override ) break;
				}
			}
			
			if ( override ) {
				this.UITweaks_BagLock_Press_Original( buttonIdx );
			}
		}
		*/
	}

	public function onLoad() : Void {
		/*
		super.onLoad();
		
		backpackMonitor = DistributedValue.Create("inventory_visible");
		backpackMonitor.SignalChanged.Connect( apply, this );
		*/
		
	}
	
	public function apply() : Void {
		/*
		stopWaitFor();
		
		// only apply if enabled
		if ( enabled ) {
			waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 100, 3000, Delegate.create( this, hook ) );
		}
		*/
	}
	
	public function waitForTest() : Boolean {
		/*
		return _root.backpack2.m_ModuleActivated;
		*/
		return false;
	}
	
	public function onModuleDeactivated() : Void {
		/*
		stopWaitFor();
		*/
	}

	public function stopWaitFor() : Void {
		/*
		WaitFor.stop( waitForId );
		waitForId = undefined;
		*/
	}
	
	public function hook() : Void {
		/*
		stopWaitFor();

		var backpack = _root.backpack2;
		var bags:Array = backpack.m_IconBoxes;
		
		for ( var s:String in bags ) {
			
			var bag = bags[s];
			
			// apply or revert hook on window chrome only when inventory is open
			if ( backpackMonitor.GetValue() ) {
				hookWindowChrome( bag, enabled && prefs.getVal( "bags.lock.enabled" ) );
			}
					
			// apply or revert hook on item slots
			if ( bag["m_IsPinned"] ) {
				
				var lockSlots:Boolean = enabled && !backpackMonitor.GetValue() && prefs.getVal("items.lock.whenPinned");
				
				if ( (lockSlots && !bag.UITweaks_BagLock_SlotsLocked) || (!lockSlots && bag.UITweaks_BagLock_SlotsLocked) ) {

					var funcName:String = lockSlots ? "Disconnect" : "Connect";
					
					bag.SignalMouseDownItem[funcName]( backpack.SlotMouseDownItem, backpack );
					bag.SignalStartDragItem[funcName]( backpack.SlotStartDragItem, backpack );
					
					lockSlots ? bag.UITweaks_BagLock_SlotsLocked = true : delete bag.UITweaks_BagLock_SlotsLocked;
				}
			}
		}
		*/
	}

	private function hookWindowChrome( bag, setHook:Boolean ) : Void {
		/*
		var window:MovieClip = bag.m_WindowMC;

		// only take action if it is needed
		if ( (setHook && window.UITweaks_BagLock_Prefs) || (!setHook && !window.UITweaks_BagLock_Prefs ) ) return;
		
		var funcMap:Object = {
			i_Background: "onMousePress",
			i_FrameName: "onPress",
			i_TopBar: "onPress",
			i_ResizeButton: "onMousePress",
			i_TrashButton: "onPress",
			i_SortButton: "onPress"
		};

		for ( var elementName:String in funcMap ) {
			
			var element:MovieClip = window[ elementName ];
			var funcName:String = funcMap[ elementName ];
			
			if ( setHook ) {
				element.UITweaks_BagLock_Press_Original = element[ funcName ];
				element[ funcName ] = Delegate.create( element, pressDelegate );
			}
			
			else {
				element[ funcName ] = element.UITweaks_BagLock_Press_Original;
				delete element.UITweaks_BagLock_Press_Original;
			}
			
		}

		setHook ? window.UITweaks_BagLock_Prefs = prefs : delete window.UITweaks_BagLock_Prefs;
		*/
	}
	
	private function pressDelegate( buttonIdx:Number ) : Void { }
	
	public function revert() : Void {
		/*
		hook();
		*/
	}

	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		/*	
		switch ( name ) {
			
			case "items.lock.whenPinned":
			case "bags.lock.enabled":
				hook();
			break;
			
		}
		*/
	}
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var backpackMonitor:DistributedValue;
}