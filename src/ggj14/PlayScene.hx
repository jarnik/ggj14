package ggj14;

import gaxe.Scene;
import nme.events.KeyboardEvent;
import pug.render.RenderGroupStates;
import gaxe.Gaxe;
import pug.render.Render;
import nme.ui.Keyboard;
import ggj14.Player;

/**
 * ...
 * @author Jaroslav Meloun - jarnik - www.jarnik.com
 */

typedef CHARACTER = {
	name:String
}
 
class PlayScene extends Scene
{
	
	private var left:Player;
	private var right:Player;
	private var characters:Array<CHARACTER>;
	
	override private function create():Void 
	{
		super.create();
		
		addChild( left = new Player( true ) );
		addChild( right = new Player( false ) );
		right.x = Gaxe.w / 2;
		
		left.onDiscard.bind( onDiscard );
		left.onPass.bind( onPass );
		right.onDiscard.bind( onDiscard );
		right.onPass.bind( onPass );
		
		characters = [
			{ name: "DOG" },
			{ name: "GRANDMA" }
		];
		
		var stash:Array<ITEM> = [];
		for ( i in 0...characters.length ) {
			stash.push( { part:HEAD, index: i } );
			stash.push( { part:FACE, index: i } );
			stash.push( { part:BODY, index: i } );
		}
		
		var randomizedStash:Array<ITEM> = [];
		var item:ITEM;
		while ( stash.length > 0 ) {
			item = stash[ Math.floor( stash.length * Math.random() ) ];
			stash.remove( item );
			randomizedStash.push( item );
		}
		
		var half:Int = Math.floor(characters.length * 3 / 2);
		for ( i in 0...half ) {
			left.receiveToStashPile( randomizedStash.pop() );
			right.receiveToStashPile( randomizedStash.pop() );
		}
		if ( randomizedStash.length > 0 ) {
			if ( Math.random() > 0.5 )
				right.receiveToStashPile( randomizedStash.pop() );
			else
				left.receiveToStashPile( randomizedStash.pop() );
		}
	}
	
	override public function handleKey(e:KeyboardEvent):Void 
	{
		super.handleKey(e);
		
		if ( e.type != KeyboardEvent.KEY_UP )
			return;
			
		//trace("key "+e.keyCode);
			
		switch ( e.keyCode ) {
			// LEFT
			case Keyboard.Q:
				left.fromOpponentDiscard();
			case Keyboard.W:
				left.fromOpponentUse();
			case Keyboard.S:
				left.fromPileUse();
			case Keyboard.D:
				left.fromPilePass();
			case Keyboard.E:
				left.changeGuess();
			case Keyboard.X:
				left.changeMine();
			// RIGHT
			case Keyboard.NUMPAD_6:
				right.fromOpponentDiscard();
			case Keyboard.NUMPAD_5:
				right.fromOpponentUse();
			case Keyboard.NUMPAD_2:
				right.fromPileUse();
			case Keyboard.NUMPAD_1:
				right.fromPilePass();
			case Keyboard.NUMPAD_8:
				right.changeGuess();
			case Keyboard.NUMPAD_0:
				right.changeMine();
		}
	}
	
	private function onDiscard( m:ITEM_MOVE ):Void {
		var other:Player = null;
		if ( m.p == left )
			other = right;
		else
			other = left;
		other.receiveToStashPile( m.i );
	}
	
	private function onPass( m:ITEM_MOVE ):Void {
		var other:Player = null;
		if ( m.p == left )
			other = right;
		else
			other = left;
		other.receiveToStashOpponent( m.i );
	}
	
}