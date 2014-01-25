package ggj14;
import gaxe.Scene;
import nme.events.KeyboardEvent;
import pug.render.Render;
import pug.render.RenderGroupStates;
import nme.ui.Keyboard;
import gaxe.Gaxe;

/**
 * ...
 * @author Jaroslav Meloun - jarnik - www.jarnik.com
 */
class CardScene extends Scene
{
	
	private var cards:RenderGroupStates;

	override private function create():Void 
	{
		addChild( cards = Render.renderGroupStates("screen", null, "cards") );
		
		setCard( 0, 0 );
		setCard( 1, 1 );
		setCard( 2, 2 );
	}
	
	private function setCard( cardIndex:Int, characterIndex:Int ):Void {
		var card:RenderGroupStates = cast( cards.fetch( "card" + cardIndex ), RenderGroupStates );
		card.fetch("person.head").render( characterIndex );
		card.fetch("person.face").render( characterIndex );
		card.fetch("person.body").render( characterIndex );
		card.fetch("name").setLabel( PlayScene.characters[ characterIndex ].name );
	}
	
	override public function handleKey(e:KeyboardEvent):Void 
	{
		super.handleKey(e);
		
		if ( e.type == KeyboardEvent.KEY_UP && e.keyCode == Keyboard.SPACE ) {
			trace("PLAY!");
			Gaxe.switchGlobalScene( PlayScene );
		}
	}
	
}