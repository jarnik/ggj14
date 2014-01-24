package ggj14;

import nme.geom.Rectangle;
import gaxe.Debug;
import gaxe.Gaxe;
import gaxe.IMenu;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.MouseEvent;

import gaxe.SoundLib;

class Menu extends Sprite implements IMenu
{   
    private var mute:Bool;

    public function new() {
        super();
        mute = false;
		initGui();
    }

    private function initGui():Void {        
    }

    public function show( state:EnumValue, params:Dynamic = null ):Void {
    }
	
	public function resize( width:Float, height:Float ):Void {
	}

    public function update( elapsed:Float ):Void {}
    public function getDisplayObject():DisplayObject { return this; }
    public function hide():Void { visible = false; }
    public function init( params:Dynamic ):Void {}
    public function isVisible():Bool { return visible; }

}
