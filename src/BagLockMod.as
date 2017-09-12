import mx.utils.Delegate;
import com.Utils.Archive;
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
	
}