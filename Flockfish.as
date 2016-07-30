import flash.geom.ColorTransform;
import flash.geom.Transform;
class Flockfish extends Creature {
	var flockDist:Number;
	var springAmount:Number = 3;
	var decay:Number = 0.90;
	var attackDist:Number;
	var hordeDist:Number;
	var cowardDist:Number;
	var hordeNum:Number;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Flockfish(posX:Number, posY:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speed:Number, turnSpeed:Number, panic:Boolean, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, maxSegs, randEvolve, segLength, speed, turnSpeed, panic, mc, ID, prefix);
		this.type = 3;
	}
	function initialize() {
		creatureType = "Flockfish";
		panicIntensityDefault = 2.5;
		attackDist = 250;
		hordeDist = 200;
		cowardDist = 250;
		hordeNum = 1;
		panicRange = Math.min(segLength*4+150+numSegs*segLength, 500);
		flockDist = segLength*4;
		createJellyMouth();
		// create the rest of the body segments
		for (var i:Number = 1; i<defaultNumSegs; i++) {
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
		if (!hasChosenTarget) {
			if (wounded) {
				wounded = behavior.panicMovement(dt, this, player, panicRange, panicIntensity);
			} else if (!panic) {
				behavior.eatAnything(this, player, fish, food, false);
			} else {
				if (coward) {
					behavior.panicMovement(dt, this, player, panicRange, panicIntensity);
				}
				behavior.hordeMovement(this, player, fish, food, false, attackDist, hordeDist, cowardDist, hordeNum);
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
		if (ID == -1) {
			if (pressed) {
				currentSpeed = Math.min(speed, currentSpeed+dt*500);
				//mc["seg0"].gotoAndPlay(23);
			}
			currentSpeed += (speed*0.2-currentSpeed)*0.05;
		} else {
			if (wounded || coward) {
				currentSpeed = panicIntensity*speed;
			} else if (!wounded && !coward && panicIntensity>1) {
				currentSpeed = panicIntensity*speed;
				panicIntensity *= 1-dt*2;
				if (panicIntensity<=1) {
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
		flockUpdate(dt);
	}
	function flockUpdate(dt:Number) {
		for (var i:Number = 1; i<numSegs; i++) {
			var particle:MovieClip = mc["seg"+i];
			particle.vx *= decay;
			particle.vy *= decay;
			particle._x += particle.vx*dt;
			particle._y += particle.vy*dt;
		}
		for (var i:Number = 0; i<numSegs-1; i++) {
			if ((i == 0) || (mc["seg"+i].evolveState>1)) {
				var partA:MovieClip = mc["seg"+i];
				for (var j:Number = 1; j<numSegs; j++) {
					if (mc["seg"+j].evolveState>1) {
						var partB:MovieClip = mc["seg"+j];
						spring(partA, partB, dt);
					}
				}
			}
		}
		for (var i:Number = 0; i<numSegs-1; i++) {
			if ((i == 0) || (mc["seg"+i].evolveState>1)) {
				var partA:MovieClip = mc["seg"+i];
				for (var j:Number = i+1; j<numSegs; j++) {
					if (mc["seg"+j].evolveState == 1) {
						var partB:MovieClip = mc["seg"+j];
						spring(partA, partB, dt);
					} else {
						i = j-1;
						break;
					}
				}
			}
		}
		for (var i:Number = 1; i<numSegs-1; i++) {
			if (mc["seg"+i].evolveState == 1) {
				var partA:MovieClip = mc["seg"+i];
				for (var j:Number = i+1; j<numSegs; j++) {
					if ((mc["seg"+j].evolveState == 1)) {
						var partB:MovieClip = mc["seg"+j];
						spring(partA, partB, dt);
					} else {
						i = j-1;
						break;
					}
				}
			}
		}
	}
	function spring(partA:MovieClip, partB:MovieClip, dt:Number):Void {
		var dx:Number = partB._x-partA._x;
		var dy:Number = partB._y-partA._y;
		var dist:Number = Math.sqrt(dx*dx+dy*dy);
		if (dist>flockDist) {
			var ax:Number = 2*dx*springAmount*dt;
			var ay:Number = 2*dy*springAmount*dt;
			partA.vx += ax;
			partA.vy += ay;
			partB.vx -= ax;
			partB.vy -= ay;
		} else if (dist<flockDist) {
			if (dx>=0) {
				dx = flockDist-dx;
			} else {
				dx = -flockDist-dx;
			}
			if (dy>=0) {
				dy = flockDist-dy;
			} else {
				dy = -flockDist-dy;
			}
			var ax:Number = dx*springAmount*dt;
			var ay:Number = dy*springAmount*dt;
			partA.vx -= ax;
			partA.vy -= ay;
			partB.vx += ax;
			partB.vy += ay;
		}
	}
	function grow() {
		if (curNumSegs<=maxSegs) {
			var seg:MovieClip;
			seg = mc.attachMovie(assetPrefix+"segbody1", "seg"+curNumSegs, 99-curNumSegs);
			segTimes[curNumSegs] = 0.25;
			segSounds[curNumSegs] = int(random(5));
			segTag[curNumSegs] = 0;
			seg._rotation = mc["seg"+(curNumSegs-1)]._rotation;
			seg._x = mc["seg"+(curNumSegs-1)]._x;
			seg._y = mc["seg"+(curNumSegs-1)]._y;
			seg.vx = 0;
			seg.vy = 0;
			seg._xscale = segLength;
			seg._yscale = segLength;
			seg.evolveState = 1;
			speed += segLength*0.5;
			if (curNumSegs == numSegs) {
				numSegs++;
			}
			curNumSegs++;
			// add transform for shading
			var trans:Transform = new Transform(seg);
			transArray.push(trans);
			if (curNumSegs == 64) {
				rebirth();
			}
			if (curNumSegs%4 == 2) {
				evolveSegment(curNumSegs-1);
			}
		} else {
			var minEvolveSeg:Number = 0;
			var minEvolveState:Number = mc["seg0"].evolveState;
			for (var i:Number = 1; i<curNumSegs; i++) {
				if (mc["seg"+i].evolveState<minEvolveState) {
					minEvolveState = mc["seg"+i].evolveState;
					minEvolveSeg = i;
				}
			}
			// For now, skip over the mouth
			evolveSegment(minEvolveSeg);
			if (minEvolveSeg == 0) {
				evolveSegment(1);
			}
		}
	}
}
