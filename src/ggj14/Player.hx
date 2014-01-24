package ggj14;

import ggj14.Player.ITEM;
import hsl.haxe.DirectSignaler.DirectSignaler;
import nme.display.BitmapData;
import nme.display.Sprite;
import pug.render.Render;
import pug.render.RenderGroupStates;
import pug.render.RenderImage;

/**
 * ...
 * @author Jaroslav Meloun - jarnik - www.jarnik.com
 */

enum PART {
	HEAD;
	FACE;
	BODY;
}

typedef ITEM = {
	part:PART,
	index:Int
}

typedef ITEM_MOVE = {
	p:Player,
	i:ITEM
}
 
class Player extends Sprite
{
	
	private var gui:RenderGroupStates;
	private var currentFromPile:ITEM;
	private var currentFromOpponent:ITEM;
	
	private var currentHead:ITEM;
	private var currentFace:ITEM;
	private var currentBody:ITEM;
	
	private var stashPile:Array<ITEM>;
	private var stashOpponent:Array<ITEM>;
	
	public var onDiscard:DirectSignaler<ITEM_MOVE>;
	public var onPass:DirectSignaler<ITEM_MOVE>;

	public function new() 
	{
		super();
		
		stashPile = [];
		stashOpponent = [];
		
		onDiscard = new DirectSignaler(this);
		onPass = new DirectSignaler(this);
		
		addChild( gui = Render.renderGroupStates("half") );
		update();
	}
	
	public function receiveToStashPile( i:ITEM ):Void {
		stashPile.unshift( i );
		if ( currentFromPile == null )
			currentFromPile = stashPile.pop();
		update();
	}
	public function receiveToStashOpponent( i:ITEM ):Void {
		stashOpponent.unshift( i );
		if ( currentFromOpponent == null )
			currentFromOpponent = stashOpponent.pop();
		update();
	}
	
	private function update():Void {
		gui.fetch( "person.head" ).visible = false;
		gui.fetch( "person.face" ).visible = false;
		gui.fetch( "person.body" ).visible = false;
		if ( currentHead != null )
			showUsedPart("head", currentHead.index );
		
		if ( currentFace != null )
			showUsedPart( "face", currentFace.index );
			
		if ( currentBody != null )
			showUsedPart( "body", currentBody.index );
			
		showItem( "itemUp", currentFromOpponent );
		showItem( "itemDown", currentFromPile );
	}
	
	private function showUsedPart( prefix:String, index:Int ):Void {
		var part:RenderImage = cast( gui.fetch( "person." + prefix ), RenderImage );
		part.render( index );
		part.visible = true;
	}
	
	private function showItem(prefix:String, i:ITEM):Void {
		cast( gui.fetch( prefix ), RenderGroupStates ).hideContents();
		
		if ( i == null )
			return;
			
		var name:String = "head";
		switch ( i.part ) {
			case HEAD:
				name = "head";
			case FACE:
				name = "face";
			case BODY:
				name = "body";
		}
		cast( gui.fetch( prefix + "." + name ), RenderImage ).visible = true;
		cast( gui.fetch( prefix + "." + name ), RenderImage ).render( i.index );
	}
	
	private function use( i:ITEM ):Void {
		switch ( i.part ) {
			case HEAD:
				currentHead = i;
			case FACE:
				currentFace = i;
			case BODY:
				currentBody = i;
		}
	}
	
	public function fromOpponentUse():Void {
		if ( currentFromOpponent == null )
			return;
		
		use( currentFromOpponent );
		nextFromOpponent();
	}
	
	public function fromOpponentDiscard():Void {
		if ( currentFromOpponent == null )
			return;
					
		var i:ITEM = currentFromOpponent;
		nextFromOpponent();
		onDiscard.dispatch( { p:this, i:i } );
	}
	
	private function nextFromOpponent():Void {
		if ( stashOpponent.length > 0 )
			currentFromOpponent = stashOpponent.pop();
		else
			currentFromOpponent = null;
		update();
	}
	
	public function fromPileUse():Void {
		if ( currentFromPile == null )
			return;
		
		use( currentFromPile );
		nextFromPile();
	}
	
	public function fromPilePass():Void {
		if ( currentFromPile == null )
			return;
					
		var i:ITEM = currentFromPile;
		nextFromPile();
		onPass.dispatch( { p:this, i:i } );
	}
	
	private function nextFromPile():Void {
		if ( stashPile.length > 0 )
			currentFromPile = stashPile.pop();
		else
			currentFromPile = null;
		update();
	}
	
	public function changeMine():Void {
		
	}
	
	public function changeGuess():Void {
		
	}
}