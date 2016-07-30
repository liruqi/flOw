import flash.geom.ColorTransform;
import flash.geom.Transform;
class Snakefish extends Creature {
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Snakefish(posX:Number, posY:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speed:Number, turnSpeed:Number, panic:Boolean, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, maxSegs, randEvolve, segLength, speed, turnSpeed, panic, mc, ID, prefix);
		this.type = 1;
	}
	function initialize() {
		creatureType = "Snakefish";
		//Creating initial creature body movieclips
		panicIntensityDefault = 1.2;
		createFishMouth();		
		// create the rest of the body segments
		for(var i:Number = 1; i < defaultNumSegs; i++) {
			grow();
		}
		
		tempScaleX = mc["seg0"]._xscale;
		tempScaleY = mc["seg0"]._yscale;
		sounds = new Array();
		for (var i:Number = 0; i<5; i++) {
			sounds[i] = new Sound(_root);
			sounds[i].loadSound(assetPrefix+"Food-samples-"+(i+1)+"a.mp3", false);
			sounds[i].setVolume(0);
		}
		//panicRange = (segLength / 100 * 300) + 200;
		panicRange = Math.min(segLength * 3 + 150 + numSegs * segLength, 500);
	}
	//////////////////////////////////////////////////////
	//Detect creature and decide target to eat
	//////////////////////////////////////////////////////
	function chooseTarget(dt:Number, player:Creature, fish:Array, food:Array):Void {
		if(!toTarget) { 
			if(wounded) {
				wounded = behavior.panicMovement(dt, this, player, panicRange, panicIntensity);
			} else {
				if(ID == -1 || !panic || boss) {
					behavior.eatAnything(this, player, fish, food, false);
				} else {
					behavior.eatFoodOnly(this, food, false);			
				}
				//If there is nothing to eat, move to a random location                            
				if (!hasTarget) {
					if (dist(posX, posY, targetX, targetY)<mouthSize+speed) {
						behavior.goToRandomLocation(this);
					}
				}	
			}
		}
	}
}
