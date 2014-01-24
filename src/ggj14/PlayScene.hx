package ggj14;
import gaxe.Scene;

import pug.render.Render;

/**
 * ...
 * @author Jaroslav Meloun - jarnik - www.jarnik.com
 */
class PlayScene extends Scene
{

	override private function create():Void 
	{
		super.create();
		
		addChild( Render.renderGroupStates("unitIcon") );
	}
	
}