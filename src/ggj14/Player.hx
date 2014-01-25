package ggj14;

import ggj14.Player.ITEM;
import ggj14.Player.KEYLABELS;
import hsl.haxe.DirectSignaler.DirectSignaler;
import nme.display.BitmapData;
import nme.display.Sprite;
import pug.render.Render;
import pug.render.RenderGroupStates;
import pug.render.RenderImage;
import ggj14.PlayScene;

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

typedef KEYLABELS = {
	opponentUse:String,
	opponentDiscard:String,
	pileUse:String,
	pilePass:String,
	changeMine:String,
	changeGuess:String
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
	
	public var indexMine:Int;
	public var indexGuess:Int;

	public function new( left:Bool ) 
	{
		super();
		
		indexMine = Math.floor( PlayScene.characters.length * Math.random() );
		indexGuess = Math.floor( PlayScene.characters.length * Math.random() );
		
		stashPile = [];
		stashOpponent = [];
		
		onDiscard = new DirectSignaler(this);
		onPass = new DirectSignaler(this);
		
		var keys:KEYLABELS;
		if ( left ) {
			keys = { 
				opponentUse:"W",
				opponentDiscard:"Q",
				pileUse:"S",
				pilePass:"D",
				changeMine:"X",
				changeGuess:"E"
			};
		} else {
			keys = { 
				opponentUse:"5",
				opponentDiscard:"6",
				pileUse:"2",
				pilePass:"1",
				changeMine:"0",
				changeGuess:"8"
			};
		}
		
		addChild( gui = Render.renderGroupStates("half", null, left ? "left" : "right" ) );
		labelKeys( keys );
		update();
	}
	
	private function labelKeys( keys:KEYLABELS ):Void {
		gui.fetch("btnUseOpponent.lbl").setLabel( keys.opponentUse );
		gui.fetch("btnDiscardOpponent.lbl").setLabel( keys.opponentDiscard );
		gui.fetch("btnUsePile.lbl").setLabel( keys.pileUse );
		gui.fetch("btnPassPile.lbl").setLabel( keys.pilePass );
		gui.fetch("stats.changeGuess.lbl").setLabel( keys.changeGuess );
		gui.fetch("stats.changeMine.lbl").setLabel( keys.changeMine );
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
		
		gui.fetch("stats.mine").setLabel( PlayScene.characters[ indexMine ].name );
		gui.fetch("stats.opponent").setLabel( PlayScene.characters[ indexGuess ].name );
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
		var discard:ITEM = null;
		switch ( i.part ) {
			case HEAD:
				if ( currentHead != null )
					discard = currentHead;
				currentHead = i;
			case FACE:
				if ( currentFace != null )
					discard = currentFace;
				currentFace = i;
			case BODY:
				if ( currentBody != null )
					discard = currentBody;
				currentBody = i;
		}
		
		if ( discard != null )
			onDiscard.dispatch( { p:this, i:discard } );
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
		indexMine = (indexMine + 1) % PlayScene.characters.length;
		update();
	}
	
	public function changeGuess():Void {
		indexGuess = (indexGuess + 1) % PlayScene.characters.length;
		update();
	}
}