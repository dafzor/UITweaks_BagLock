// implement commands http://legacy.tswdb.com/miscellaneous/chat-scripts
import com.Utils.Archive;

/**
 * This is your entrypoing class for your addon. The static member "main" is called when the addon is loaded and - thanks to a little
 * initialization - your onLoad, OnUnload, OnActivated and OnDeactivated functions are called from here when TSW deems it necessary.
 * 
 * Please note that this is *not* a style guide! I have tried to keep the code as simple as possible and that mean avoiding some
 * abstractions. This doesn't mean that you should do the same!
 * @author Icarus James
 * @author daf
 */
class BagLockMain 
{
	private static var s_app: BagLockMod;
	
	/**
	 * This is the main entry point for you mod. It's main purpose is to provide the root MovieClip on which to build the rest of your addon.
	 * I recommend that you:
	 * 		Keep a reference to the swfRoot variable (you're going to need it later)
	 * 		Set up the varirous callbacks (see below) required by TSW. Your addon will not work without it.
	 * 		Do very little else here. Initialization code is better off in your OnLoad function, where it can be torn down by OnUnload
	 * @param	swfRoot
	 */
	public static function main(swfRoot:MovieClip):Void 
	{
		s_app = new BagLockMod(swfRoot);
		
		// Here we initialize some events that TSW uses to communicated with your addon. Note the lower case used in onLoad.
		swfRoot.onLoad = OnLoad;
		swfRoot.OnUnload = OnUnload;
		swfRoot.OnModuleActivated = OnActivated;
		swfRoot.OnModuleDeactivated = OnDeactivated;
	}

	/**
	 * This is the non-static constructor for your entrypoint class. It is best ignored as it is (as far as I know) never called.
	 */
	public function BagLockMain() { }
	
	/**
	 * This is your OnLoad event handler. OnLoad is called after login.
	 * I recommend that you:
	 * 		Perform initialization for your addon here
	 */
	public static function OnLoad()
	{
		s_app.OnLoad();
	}	
	
	/**
	 * This is your OnLoad event handler. OnLoad is called on logout.
	 * I recommend that you:
	 * 		Tear down your initialization here
	 */
	public static function OnUnload()
	{
		s_app.OnUnload();
	}	
	
	/**
	 * This is your OnActivated event handler. It is called when your addon is activated and is used to load state from the TSW persistance database. Activation
	 * can occur in some strange places - whoosh portals in Agartha cause a handlful of calls to OnActivated, as does logging in, teleporting and dying.
	 * 
	 * @param	config - config is passed to OnActivated by TSW. The archive will contain all the things place in it in your last call to 
	 * 						OnDeactivated.
	 * 
	 * I recommend that you:
	 * 		Load user preferences here
	 * 		Do nothing that might take a long time
	 */
	public static function OnActivated(config: Archive)
	{
		s_app.Activate(config);
	}
	
	/**
	 * This is your OnDeactivated event handler. It is called when your addon is deactivated and is used to save state to the TSW persistance database. Deactivation
	 * can occur in some strange places - whoosh portals in Agartha cause a handlful of calls to OnDeactivated, as does logging out, teleporting and dying.
	 * 
	 * @return - this function should return an instance of com.Utils.Archive, into which you have stored your user preferences
	 * 
 	 * I recommend that you:
	 * 		Save user preferences here
	 * 		Do nothing that might take a long time
	 */
	public static function OnDeactivated(): Archive
	{		
		return s_app.Deactivate();
	}
}