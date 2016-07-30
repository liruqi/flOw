import flash.geom.ColorTransform;
import flash.geom.Transform;
class Jellyfish extends Creature {
	var radius:Number;
	var ringAngle:Number;
	var radiusTarget:Number;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Jellyfish(posX:Number, posY:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speed:Number, turnSpeed:Number, panic:Boolean, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, maxSegs, randEvolve, segLength, speed, turnSpeed, panic, mc, ID, prefix);		
		this.type = 2;
	}
	function initialize() {
		creatureType = "Jellyfish";
		//Creating initial creature body movieclips
		createJellyMouth();		
		segName = "jellybody1";
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
		ringAngle = orient;
		radius=0;
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
		ringAngle += dt/numSegs*5;
		if (ID == -1) {
			if (pressed) {
				currentSpeed = Math.min(speed, currentSpeed+dt*500);
				//mc["seg0"].gotoAndPlay(23);
				radiusTarget = (segLength+numSegs);
				ringAngle += dt*5;
			}else{
				radiusTarget = (segLength+numSegs)*2.5;
			}
			currentSpeed += (speed*0.2-currentSpeed)*0.05;
		} else {
			radiusTarget = (segLength+numSegs)*(2.5+Math.sin(_root.curTime/1000*Math.PI));
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
		drag(mc["seg0"], posX, posY);
		radius+=(radiusTarget-radius)*dt*5;
		for (var i = 1; i<numSegs; i++) {
			var segB:MovieClip = mc["seg"+i];
			var angle:Number = ringAngle+i/(numSegs-1)*2*Math.PI;		
			drag(segB, posX+radius*Math.cos(angle), posY+radius*Math.sin(angle));
			//segB._rotation = angle*180/Math.PI;
			//segB._x = posX+radius*Math.cos(angle);
			//segB._y = posY+radius*Math.sin(angle);
		}
	}
}
