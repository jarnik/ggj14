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

enum GAME_STATE {
	STATE_START;
	STATE_PLAY;
	STATE_FINISH;
}
 
class PlayScene extends Scene
{
	
	private var left:Player;
	private var right:Player;
	private var timer:Float;
	private var screen:RenderGroupStates;
	public static var characters:Array<CHARACTER>;
	
	override private function create():Void 
	{
		super.create();
		
		addChild( left = new Player( true ) );
		addChild( right = new Player( false ) );
		right.x = Gaxe.w / 2;
		
		addChild( screen = Render.renderGroupStates("screen",null,"play") );
		
		left.onDiscard.bind( onDiscard );
		left.onPass.bind( onPass );
		right.onDiscard.bind( onDiscard );
		right.onPass.bind( onPass );
		
	}
	
	override private function reset():Void 
	{
		switchState( STATE_START );
	}
	
	override private function handleSwitchState(id:Dynamic):Bool 
	{
		switch ( cast( id, GAME_STATE ) ) {
			case STATE_START:
				screen.switchState("split", true );
				timer = 4;
				left.reset();
				right.reset();
			case STATE_PLAY:
				screen.switchState("play", true );
				timer = 300;
				left.reset();
				right.reset();
				shuffle();
			case STATE_FINISH:
				screen.switchState("finish", true );
				left.hideButtons();
				right.hideButtons();
				left.showScore( right.indexMine );
				right.showScore( left.indexMine );
		}
		return true;
	}
	
	private function shuffle():Void {
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
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		switch ( cast( state, GAME_STATE ) ) {
			case STATE_START:
				timer -= elapsed;
				timer = Math.max( 0, timer );
				screen.fetch("splitLeft.timer").setLabel( Std.string( Math.floor( timer ) ) );
				screen.fetch("splitRight.timer").setLabel( Std.string( Math.floor( timer ) ) );
				if ( timer <= 0 )
					switchState( STATE_PLAY );
			case STATE_PLAY:
				timer -= elapsed;
				timer = Math.max( 0, timer );
				left.setTime( timer );
				right.setTime( timer );
				if ( timer <= 0 )
					switchState( STATE_FINISH );
			case STATE_FINISH:
		}
	}
	
	override public function handleKey(e:KeyboardEvent):Void 
	{
		super.handleKey(e);
		
		if ( e.type != KeyboardEvent.KEY_UP )
			return;
			
		switch ( cast( state, GAME_STATE ) ) {
			case STATE_START:
			case STATE_PLAY:
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
			case STATE_FINISH:
				switch ( e.keyCode ) {
					case Keyboard.SPACE:
						//switchState( STATE_PLAY );
						Gaxe.switchGlobalScene( CardScene );
				}
		}
			
		//trace("key "+e.keyCode);
			
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