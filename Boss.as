import flash.geom.ColorTransform;
import flash.geom.Transform;
class Boss extends Creature {
	var charging:Boolean;
	var updateChargeTarg:Boolean;
	var chargeDifficulty:Number;
	var tempTempMinDefault;
	var spawnID:Number;
	var spawnTimer:Number;
	var spawnTime:Number;
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Boss(posX:Number, posY:Number, numSegs:Number, segLength:Number, speed:Number, turnSpeed:Number, mc:MovieClip, ID:Number, prefix:String) {
		super(posX, posY, numSegs, 1, 0, segLength, speed, turnSpeed, true, mc, ID, prefix);
		this.type = 6;
	}
	function initialize() {
		numSegs = defaultNumSegs;
		chargeDifficulty = 3;
		boss = true;
		spawnID = -1;
		spawnTimer = 0;
		spawnTime = 0.1;
		panicIntensityDefault = 10;
		charging = false;
		updateChargeTarg = false;
		var seg:MovieClip;
		seg = mc.attachMovie("boss1", "seg0", 99);
		//seg.gotoAndPlay(i*4);
		seg._xscale = segLength;
		seg._yscale = segLength;
		seg._x = posX;
		seg._y = posY;
		seg.evolveState = 1;
		// used for shading
		var trans:Transform;
		weakLength = 3;
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
		for (var i:Number = 0; i<4; i++) {
			sounds[i] = new Sound(_root);
			sounds[i].loadSound(assetPrefix+"boss "+(i+1)+".mp3", false);
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
			if (dist(posX, posY, targetX, targetY)<=mouthSize*5) {
				charging = false;
			}
		} else {
			behavior.eatPlayerOnly(this, player, true);
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
		//spawn bullet
		spawnBullets(dt);
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
				nutrition = 0.5*(mc["seg"+tempWeak]._xscale+mc["seg"+tempWeak]._yscale);
				// shake camera if the fish eaten is the player
				if (targets[tempFish].ID == -1) {
					_root.camera.shake(8);
				}
				//increase length       
			} else {
				//else kill food
				nutrition = food[tempFood].energy;
				food[tempFood].energy = 0;
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
		spawnID = 1;
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
						_root.gameLevels[level].spawnFoodAtLocation(2, x, y, 15, 10);
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
					for (var i:Number = 0; i<weakLength; i++) {
						var seg:MovieClip = mc.seg0["weakPoint"+i];
						x = behavior.getBossWeakpointX(this, seg);
						y = behavior.getBossWeakpointY(this, seg);
						_root.gameLevels[level].spawnFoodAtLocation(0, x, y, 15, 10);
						_root.gameLevels[level].spawnFoodAtLocation(99, x, y, 15, 10);
						_root.gameLevels[level].spawnEffect(0, segLength/20, segLength/20, 0, x, y);
					}
					mc["seg0"].removeMovieClip();
					alive = false;
					_root[clipName].removeMovieClip();
				}
				// only explode one segment per iteration                                 
				if (explodedSeg) {
					break;
				}
			}
		}
	}
	/////////////////////////////////////////////////////////////////////////////
	//Spawn bullets after losing a weakpoint
	/////////////////////////////////////////////////////////////////////////////
	function spawnBullets(dt:Number) {
		if (spawnID>0) {
			spawnTimer += dt;
			if (spawnTimer>spawnTime) {
				spawnTimer = 0;
				var x:Number = 0;
				var y:Number = 0;
				var seg:MovieClip = mc.seg0.body["seg"+spawnID];
				x = behavior.getBossWeakpointX(this, seg);
				y = behavior.getBossWeakpointY(this, seg);
				var bullet:Bullet = _root.gameLevels[level].spawnBulletAtLocation(random(4)+5-spawnID*0.5, x, y, seg._xscale, 100, 5, 4, 0);
				bullet.targetX = -targetX;
				bullet.targetY = -targetY;
				bullet.orient = random(Math.PI*2);
				bullet.movementMode = 2;
				_root.gameLevels[level].spawnEffect(0, seg._xscale/20, seg._xscale/20, 0, x, y);
				sounds[3].setVolume(100);
				sounds[3].start(0, 1);
				spawnID++;
				if (spawnID>=numSegs) {
					spawnID = -1;
				}
			}
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
							//heal(i);
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
		seg.play();
		x = behavior.getBossWeakpointX(this, seg);
		y = behavior.getBossWeakpointY(this, seg);
		_root.gameLevels[level].spawnEffect(0, 10, 1, 0.25, x, y);
	}
}
