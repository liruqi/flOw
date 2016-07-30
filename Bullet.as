import flash.geom.ColorTransform;
import flash.geom.Transform;
class Bullet extends Creature {
	var movementMode;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Bullet(lifeTime:Number, posX:Number, posY:Number, segLength:Number, speed:Number, turnSpeed:Number, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, 1, 1, 0, segLength, speed, turnSpeed, false, mc, ID, prefix);		
		this.lifeTime = lifeTime;
		turnIntoFoodOnDeath = false;
		movementMode = 1;
		this.type = 5;
	}
	
	function initialize() {
		creatureType = "Bullet";
		numSegs = defaultNumSegs;
		defaultColorTransTime = 0.1;
		colorTransTime = defaultColorTransTime;
		//Creating initial creature body movieclips
		var seg:MovieClip;
		seg = mc.attachMovie(assetPrefix+"bullet1", "seg0", 99);
		segSounds[0] = int(random(6));
		segTimes[0] = 0.25;
		segTag[0] = 0;
		seg._xscale = segLength;
		seg._yscale = segLength;
		seg.evolveState = 1;
		
		var trans:Transform = new Transform(seg);
		transArray.push(trans);
		
		tempScaleX = mc["seg0"]._xscale;
		tempScaleY = mc["seg0"]._yscale;
		
		sounds = new Array();
		soundLoops = new Array();
		for (var i:Number = 0; i<5; i++) {
			sounds[i] = _root.sndLoader.getSound(assetPrefix+"Food-samples-"+(i+1)+"a");
			soundLoops[i] = _root.sndLoader.getSound(assetPrefix+"Food-loop-"+(i+1)+"a");
		}
	}
	//////////////////////////////////////////////////////
	//Detect creature and decide target to eat
	//////////////////////////////////////////////////////
	function chooseTarget(dt:Number, player:Creature, fish:Array, food:Array):Void {
		if(movementMode == 1) {
			// do nothing, this is 'move constantly towards target' mode
		} else if(movementMode == 2) {
			// seek mode
			behavior.eatPlayerOnly(this, player, false);
		} 
			
	/*
		behavior.eatAnything(this, player, fish, food);
			
		//If there is nothing to eat, move to a random location                            
		if (!hasTarget) {
			if (dist(posX, posY, targetX, targetY)<mc["seg0"]._yscale) {
				behavior.goToRandomLocation(this);
			}
		}	
		*/
		//behavior.goToRandomLocation(this);
	}
	
	function grow() {
	}
	
	function eatingUpdate(dt:Number, camera:Camera3D){
		if(eating > -1)
			die();
	}
}