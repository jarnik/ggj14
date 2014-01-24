package ggj14;

import gaxe.Scene;
import pug.render.RenderGroupStates;
import gaxe.Gaxe;
import pug.render.Render;

/**
 * ...
 * @author Jaroslav Meloun - jarnik - www.jarnik.com
 */
class PlayScene extends Scene
{
	
	private var left:RenderGroupStates;
	private var right:RenderGroupStates;

	override private function create():Void 
	{
		super.create();
		
		
		addChild( left = Render.renderGroupStates("half") );
		addChild( right = Render.renderGroupStates("half") );
		right.x = Gaxe.w / 2;
	}
	
}