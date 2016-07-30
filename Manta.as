import flash.geom.ColorTransform;
import flash.geom.Transform;
class Manta extends Creature {
	var charging:Boolean;
	var updateChargeTarg:Boolean;
	var chargeDifficulty:Number;
	var tempTempMinDefault;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Manta(posX:Number, posY:Number, numSegs:Number, segLength:Number, speed:Number, turnSpeed:Number, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, 1, 0, segLength, speed, turnSpeed, true, mc, ID, prefix);
		this.type = 4;
	}
	function initialize() {
		numSegs = defaultNumSegs;
		chargeDifficulty = 3;
		boss = true;
		panicIntensityDefault = 7;
		charging = false;
		updateChargeTarg = false;
		var seg:MovieClip;
		seg = mc.attachMovie("manta1", "seg0", 99);
		trace("OK");
		//seg.gotoAndPlay(i*4);
		seg._xscale = segLength;
		seg._yscale = segLength;
		seg._x = posX;
		seg._y = posY;
		seg.evolveState = 1;
		// used for shading
		var trans:Transform;
		weakLength = 2;
		for (var i:Number = 0; i<weakLength; i++) {
			weakPoints[i] = i;
			weakPointsHit[i] = weakPointsHitC;
			trans = new Transform(mc.seg0["weakPoint"+i]);
			transArray.push(trans);
		}
		trans = new Transform(mc.seg0["mouth"]);
		transArray.push(trans);
		trans = new Transform(mc.seg0["body"]);
		transArray.push(trans);
		// initial sound
		sounds = new Array();
		for (var i:Number = 0; i<3; i++) {
			sounds[i] = new Sound(_root);
			sounds[i].loadSound(assetPrefix+"manta "+(i+1)+".mp3", false);
			sounds[i].setVolume(0);
		}
	}
	//////////////////////////////////////////////////////
	//Detect creature and decide target to eat
	//////////////////////////////////////////////////////
	function chooseTarget(dt:Number, player:Creature, fish:Array, food:Array):Void {
		mouthSize = mc["seg0"]._xscale*mc.seg0["mouth"]._xscale*0.0125;
		if (wounded) {
			wounded = behavior.panicMovement(dt, this, player, panicRange, panicIntensity);
			if (!wounded) {
				charging = true;
				updateChargeTarg = true;
				panicIntensity *= 1.5;
				tempTempMinDefault = tempMinDefault;
				tempMinDefault = 99999;
			}
		} else if (charging && updateChargeTarg) {
			behavior.eatPlayerOnly(this, player, false);
			if (tempMin<=mouthSize*chargeDifficulty) {
				updateChargeTarg = false;
				var temp:Number = mc["seg0"]._rotation*Math.PI/180;
				targetX = targetX+(3*segLength*Math.cos(temp));
				targetY = targetY+(3*segLength*Math.sin(temp));
				tempTargetX = targetX;
				tempTargetY = targetY;
				tempMinDefault = tempTempMinDefault;
			}
		} else if (charging && !updateChargeTarg) {
			behavior.eatPlayerOnly(this, player, false);
			targetX = tempTargetX;
			targetY = tempTargetY;
			if (dist(posX, posY, targetX, targetY)<=mouthSize*7.5) {
				charging = false;
			}
		} else {
			behavior.eatPlayerAndFood(this, player, food, true);
			if (!hasTarget) {
				if (dist(posX, posY, targetX, targetY)<mouthSize) {
					behavior.goToRandomLocation(this);
				}
			}
		}
	}
	//////////////////////////////////////////////////////
	//Update movement and IK
	//////////////////////////////////////////////////////
	function movementUpdate(dt:Number, camera:Camera3D) {
		hasTarget = true;
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
		// make the boss move fast when the player is near      
		if (charging || wounded) {
			currentSpeed = panicIntensity*speed;
		} else if (!charging && panicIntensity>1) {
			currentSpeed = panicIntensity*speed;
			panicIntensity *= 1-dt;
		} else if (hasTarget) {
			currentSpeed = speed*3;
		} else {
			currentSpeed = speed;
		}
		posX += currentSpeed*Math.cos(orient)*dt;
		posY += currentSpeed*Math.sin(orient)*dt;
		//update body IK
		drag(mc.seg0, posX, posY);
		for (var i = 0; i<numSegs; i++) {
			var segA:MovieClip = mc["seg"+i];
			var segB:MovieClip = mc["seg"+(i+1)];
			drag(segB, segA._x, segA._y);
		}
	}
	//////////////////////////////////////////////////////
	//Check to see if the creature is in range of anything eatable
	//////////////////////////////////////////////////////
	function collision(food:Array):Void {
		//detect if it eats something                
		if ((eating == -1) && (tempMin<mouthSize)) {
			//trace(mc["seg0"]._xscale*0.005*mc.seg0["mouth"]._yscale);
			//play eating sound effect
			mc.seg0["mouth"].gotoAndPlay(2);
			//if it's part of the fish, do wound()
			if (tempFish != -2) {
				targets[tempFish].wound(tempWeak);
				eating = 1;
				nutrition = 1;
				// shake camera if the fish eaten is the player
				if (targets[tempFish].ID == -1) {
					_root.camera.shake(8);
				}
				//increase length        
			} else {
				//else kill food
				nutrition = food[tempFood].nutrition;
				food[tempFood].energy = 0;
				food[tempFood].alive = false;
				eating = food[tempFood].foodType;
			}
		}
	}
	/////////////////////////////////////////////////////////////////////////////
	//If one of the weakpoints got bite, it will run wound()
	/////////////////////////////////////////////////////////////////////////////
	function wound(weakPointID:Number) {
		//Lose hitpoints
		weakPointsHit[weakPointID] = 0;
		//Dim down the wounded segbody1s
		var seg:MovieClip = mc.seg0["weakPoint"+weakPoints[weakPointID]];
		seg._alpha = 0;
		wounded = true;
		panicIntensity = panicIntensityDefault;
		panicTimer = 100;
		//spawnBullets();
		var dead:Boolean = true;
		for (var i:Number = 0; i<weakLength; i++) {
			if (weakPointsHit[i] != 0) {
				dead = false;
				break;
			}
		}
		if (dead) {
			die();
		}
	}
	/////////////////////////////////////////////////////////////////////////////
	//Spawn bullets after losing a weakpoint
	/////////////////////////////////////////////////////////////////////////////
	function spawnBullets() {
		var x:Number = 0;
		var y:Number = 0;
		for (var i:Number = 0; i<numSegs; i++) {
			var seg:MovieClip = mc.seg0.body["seg"+(i+1)];
			x = behavior.getBossWeakpointX(this, seg);
			y = behavior.getBossWeakpointY(this, seg);
			var bullet:Bullet = _root.gameLevels[level].spawnBulletAtLocation(random(4)+2, x, y, seg._xscale/2, 75, 5, 8, 0);
			bullet.targetX = -targetX;
			bullet.targetY = -targetY;
			bullet.orient = random(Math.PI*2);
			bullet.movementMode = 2;
			_root.gameLevels[level].spawnEffect(0, seg._xscale/40, seg._xscale/40, 0, x, y);
		}
	}
	function eatingUpdate(dt:Number, camera:Camera3D) {
		if (eating>-1) {
			eatingTimer -= dt*50;
			if (eatingTimer<=0) {
				mc.seg0["mouth"].gotoAndPlay(23);
				eating = -1;
				eatingTimer = 1;
				if (nutrition>0) {
					for (var i:Number = 0; i<weakLength; i++) {
						if (weakPointsHit[i]<weakPointsHitC) {
							heal(i);
							nutrition--;
							break;
						}
					}
				}
				// seg sound plays    
				var i:Number = int(random(3));
				sounds[i].setVolume(soundVolume);
				sounds[i].start(0, 1);
			}
		}
	}
	function heal(i:Number) {
		weakPointsHit[i] = weakPointsHitC;
		//trace(weakPointsHit[i]);
		var seg:MovieClip = mc["seg"+weakPoints[i]];
		//seg._alpha = 100;
		//speed += (mc["seg"+weakPoints[i]].evolveState-1)*segLength*0.4;
		var healSound:Sound = _root.sndLoader.getSound(assetPrefix+"heal");
		healSound.setVolume(soundVolume);
		healSound.start(0, 1);
		var x:Number = 0;
		var y:Number = 0;
		var seg:MovieClip = mc.seg0.body["seg"+i];
		x = behavior.getBossWeakpointX(this, seg);
		y = behavior.getBossWeakpointY(this, seg);
		_root.gameLevels[level].spawnEffect(0, 10, 1, 0.25, x, y);
	}
	function dieUpdate(dt:Number) {
		var explodedSeg:Boolean = false;
		dieExplosionRate = 0.1;
		dieTimer += dt;
		while (dieTimer>dieExplosionRate && dieSeg<numSegs) {
			dieTimer -= dieExplosionRate;
			var x:Number = 0;
			var y:Number = 0;
			for (var i:Number = dieSeg; i<numSegs; i++) {
				dieSeg++;
				var seg:MovieClip = mc.seg0.body["seg"+i];
				x = behavior.getBossWeakpointX(this, seg);
				y = behavior.getBossWeakpointY(this, seg);
				if (i != 0) {
					if (turnIntoFoodOnDeath) {
						_root.gameLevels[level].spawnFoodAtLocation(1, x, y, 15, 10);
					}
					_root.gameLevels[level].spawnEffect(0, segLength/20, segLength/20, 0, x, y);
				} else {
					if (turnIntoFoodOnDeath) {
						_root.gameLevels[level].spawnFoodAtLocation(0, mc["seg0"]._x, mc["seg0"]._y, 15, 10);
					}
					_root.gameLevels[level].spawnEffect(0, segLength/5, segLength/20, 0, mc["seg0"]._x, mc["seg0"]._y);
				}
				explodedSeg = true;
				seg.removeMovieClip();
				// if we have exploded all of the segments, we are done                  
				if (dieSeg>=numSegs) {
					// if this creature is the player, do a complete reset
					if (ID == -1) {
						_root.gameLevels[level].killAllBulletFish();
						initializeVars();
						initialize();
					} else {
						mc["seg0"].removeMovieClip();
						alive = false;
						_root[clipName].removeMovieClip();
					}
				}
				// only explode one segment per iteration                                 
				if (explodedSeg) {
					break;
				}
			}
		}
	}
}
