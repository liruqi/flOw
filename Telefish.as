import flash.geom.ColorTransform;
import flash.geom.Transform;
class Telefish extends Creature {
	var teleDistance:Number;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Telefish(posX:Number, posY:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speed:Number, turnSpeed:Number, panic:Boolean, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, maxSegs, randEvolve, segLength, speed, turnSpeed, panic, mc, ID, prefix);		
		this.type = 6;
	}
	function initialize() {
		creatureType = "Telefish";
		//Creating initial creature body movieclips
		createFishMouth();	
		// create the rest of the body segments
		for(var i:Number = 1; i < defaultNumSegs; i++) {
			grow();
		}
		
		tempScaleX = mc["seg1"]._xscale;
		tempScaleY = mc["seg1"]._yscale;
		// initial sound
		sounds = new Array();
		for (var i:Number = 0; i<5; i++) {
			sounds[i] = new Sound(_root);
			sounds[i].loadSound(assetPrefix+"Food-samples-"+(i+1)+"b.mp3", false);
			sounds[i].setVolume(0);
		}
	}
	
	//////////////////////////////////////////////////////
	//Detect creature and decide target to eat
	//////////////////////////////////////////////////////
	function chooseTarget(dt:Number, player:Creature, fish:Array, food:Array):Void {
		if(wounded) {
			wounded = behavior.panicMovement(dt, this, player, panicRange, panicIntensity);
		} else {
			behavior.eatAnything(this, player, fish, food, false);
				
			//If there is nothing to eat, move to a random location                            
			if (!hasTarget) {
				if (dist(posX, posY, targetX, targetY)<mc["seg0"]._yscale) {
					behavior.goToRandomLocation(this);
				}
			}	
		}
	}
	//////////////////////////////////////////////////////
	//Update movement and IK
	//////////////////////////////////////////////////////
	function movementUpdate(dt:Number, camera:Camera3D) {
		//movment        
		var aimAngle:Number;
		if (ID == -1) {
			aimAngle = Math.atan2((_ymouse-camera.screenY-screenY), (_xmouse-camera.screenX-screenX));
		} else {
			aimAngle = Math.atan2((targetY-posY), (targetX-posX));
		}		
		var temp:Number = (aimAngle-orient)%(2*Math.PI);
		if (temp<=-Math.PI) {
			orient += turnSpeed*dt*30;
		} else if (temp>Math.PI) {
			orient -= turnSpeed*dt*30;
		} else if (temp>0) {
			orient += turnSpeed*dt*30;
		} else if (temp<0) {
			orient -= turnSpeed*dt*30;
		}
		teleDistance = segLength*numSegs*3;
		if (ID == -1) {
			if (pressed) {
				if (behavior.dist(_xmouse-camera.screenX,_ymouse-camera.screenY,screenX,screenY)<=teleDistance){
					posX = _xmouse-camera.screenX;
					posY = _ymouse-camera.screenY;
				}else{
					var aimAngle:Number = Math.atan2((_root.ymouse-camera.screenY-screenY), (_root.xmouse-camera.screenX-screenX));
					posX += teleDistance*Math.cos(aimAngle);
					posY += teleDistance*Math.sin(aimAngle);					
				}	
				pressed = false;
			}else{
			}
			currentSpeed += (speed*0.4-currentSpeed)*0.05;
		} else {
			
			if(wounded || coward) {
				currentSpeed = panicIntensity*speed;
			} else if(!wounded && !coward && panicIntensity > 1) {
				currentSpeed = panicIntensity*speed;
				panicIntensity *= 1-dt*2;
				if(panicIntensity <= 1) {
					panicIntensity = 0;
				}
			} else {
				currentSpeed = speed;
			}
		}
		posX += currentSpeed*Math.cos(orient)*dt;
		posY += currentSpeed*Math.sin(orient)*dt;
		//update body IK
		if (ID == -1 && _root.switchingLevels) {
			drag(mc.seg0, posX, posY);
			for (var i = 0; i<numSegs; i++) {
				var segA:MovieClip = mc["seg"+i];
				var segB:MovieClip = mc["seg"+(i+1)];
				drag(segB, segA._x, segA._y);
			}
		} else {
			drag(mc.seg0, posX, posY);
			for (var i = 0; i<numSegs; i++) {
				var segA:MovieClip = mc["seg"+i];
				var segB:MovieClip = mc["seg"+(i+1)];
				drag(segB, segA._x, segA._y);
			}
		}
	}
}
