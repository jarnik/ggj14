package ggj14;

import nme.Assets;
import gaxe.Gaxe;
import pug.model.Library;
import nme.events.TouchEvent;
import nme.text.Font;


class Main extends Gaxe 
{
	public static var lib:Library; 
	
    public static var font:Font;

	// Entry point
	public static function main() {
		lib = new Library();
        lib.onLibLoaded.bindVoid( onLibLoaded );
        lib.importByteArrayPUG( Assets.getBytes("assets/pug/gui.pug") ); 
	}
	
	private static function onLibLoaded():Void {
		Gaxe.loadGaxe( new Main(), new Menu(), 426, 240 );
	} 

    public function new() {
        super();
		
        font = Assets.getFont ("assets/fonts/nokiafc22.ttf");
    }

    override private function init():Void {
        super.init();
        log( " progress " );		
        switchScene( PlayScene );        
    }
	
	override public function handleTouch( e:TouchEvent ):Void { 
		if ( scene != null )
			scene.handleTouch( e );
	}

}
