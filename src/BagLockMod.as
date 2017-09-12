import mx.utils.Delegate;
import com.Utils.Archive;
/**
 * SkeletonMod provides a very simple implementation for drawing and dragging a coloured box about the screen.
 * 
 * @author Icarus James
 */
class SkeletonMod
{    
	private var m_swfRoot: MovieClip; // Our root MovieClip
	
	private var m_boxClip: MovieClip; // A child clip on which we will draw our coloured box
	private var m_boxText: TextField; // A text field to be placed upon our box
	
    public function SkeletonMod(swfRoot: MovieClip) 
    {
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;
    }
	
	public function OnLoad()
	{
		// Create a new MovieClip on which to draw
		m_boxClip = m_swfRoot.createEmptyMovieClip("BoxClip", m_swfRoot.getNextHighestDepth());
				
		
		// Draw a semi-transparent rectangle
		m_boxClip.lineStyle(3, 0xFF99FF, 75);
		m_boxClip.beginFill(0xFF00FF, 75);
		m_boxClip.moveTo(50, 50);
		m_boxClip.lineTo(500, 50);
		m_boxClip.lineTo(500, 500);
		m_boxClip.lineTo(50, 500);
		m_boxClip.lineTo(50, 50);
		m_boxClip.endFill();
		
		// Hookup some callbacks to provide dragging functionality - flash does most of the hard work for us
		m_boxClip.onPress = Delegate.create(this, function() { this.m_boxClip.startDrag(); } );
		m_boxClip.onRelease = Delegate.create(this, function() { this.m_boxClip.stopDrag(); } );
		
		// Create a textfield on our coloured box
		m_boxText = m_boxClip.createTextField("BoxText", m_boxClip.getNextHighestDepth(), 50, 50, 450, 20);
		m_boxText.embedFonts = true; // we're using an embedded font from src/assets/fonts/
		m_boxText.selectable = false; // we don't want to be able to select this text
		
		// Specify some style information for this text
		var format: TextFormat = new TextFormat("src.assets.fonts.FuturaMDBk.ttf", 20, 0xFFFFFF, true, false, true); 
		format.align = "center";
		m_boxText.setNewTextFormat(format);	// Apply this style to all new text
		m_boxText.setTextFormat(format); // Apply this style to all existing text
		
		// Finally, specify some text
		m_boxText.text = "I'm a box!";
	}
	
	public function OnUnload()
	{
		// Clear and remove our box MovieClip
		m_boxClip.clear();
		m_boxClip.removeMovieClip();
	}
	
	public function Activate(config: Archive)
	{
		// Some example code for loading variables from an Archive
		var testVariable: String = String(config.FindEntry("MyTestVariableToStore", "Not found"));
		var testVariableNumber: Number = Number(config.FindEntry("MyTestVariableNumberToStore", 15));
	}
	
	public function Deactivate(): Archive
	{
		// Some example code for saving variables to an Archive
		var archive: Archive = new Archive();	
		archive.AddEntry("MyTestVariableToStore", "Hello");
		
		return archive;
	}
	
}