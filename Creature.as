import flash.geom.ColorTransform;
import flash.geom.Transform;
class Creature extends GameObject {
	//How long each segbody1s are
	var defaultSegLength:Number;
	var segLength:Number;
	var segTag:Array;
	var segSounds:Array;
	var segTimes:Array;
	//How many segbody1s
	var defaultNumSegs:Number;
	var curNumSegs:Number;
	var numSegs:Number;
	var segName:String;
	//How fast the creature moves	
	var defaultSpeed:Number;
	var speed:Number;
	var currentSpeed:Number;
	//mouse click tracking
	var pressed:Boolean = false;
	//How quickly the creature turns
	var turnSpeed:Number;
	//Where the creature is facing
	var orient:Number = 0;
	//Each creature has an ID, -1 represents the one controlled by player
	var ID:Number;
	//This is used to tell which part of the body is glowing	
	var glowID:Number;
	//Times that creature rebrithed
	var lifeCycle:Number = 0;
	//Used to restore the original scale after the eating effect
	var tempScaleX:Number = 1;
	var tempScaleY:Number = 1;
	//How long the eating animation last, it will change as it grows
	var eatingTimerC:Number = 1/3.0;
	//The eatingTimer for eating animation
	var eatingTimer:Number = eatingTimerC;
	//What is the creature eating, -1 means ready to eat
	var eating:Number = -1;
	//How much energy is in the food
	var nutrition:Number = 0;
	//Weakpoints number of the segbody1s
	var weakPoints:Array;
	//Hit points on each weak points
	var weakPointsHit:Array;
	//How long is the actual weakPoints array
	var weakLength:Number;
	//Hit points cap on each weakpoints
	var weakPointsHitC:Number = 3;
	//Transforms for shading for each segbody1 in the creature
	var transArray:Array;
	// sound
	var sounds:Array;
	var soundLoops:Array;
	// Performs targetting
	var behavior;
	// used for targetting, accessed by Behavior object
	var targets:Array;
	var tempMinDefault:Number;
	var tempMin:Number;
	var tempFood:Number;
	var tempFish:Number;
	var tempWeak:Number;
	var hasTarget:Boolean;
	//Target the creature is going after
	var targetX:Number;
	var targetY:Number;
	var tempTargetX:Number;
	var tempTargetY:Number;
	// is this creature a boss?
	var boss:Boolean;
	// is this creature alive?
	var alive:Boolean;
	// is this creature in the process of dieing?
	var dieing:Boolean;
	// how quickly the body segments turn into food
	var dieExplosionRate:Number;
	var dieTimer:Number;
	var dieSeg:Number;
	var turnIntoFoodOnDeath:Boolean;
	// base clipname, set by gameLevel
	var clipName:String;
	var assetPrefix:String;
	// how long has this creature been alive
	var aliveTime:Number;
	// maximum amount of time to keep this creature alive... set to -1 by default (infinite)
	var lifeTime:Number;
	var headingX:Number;
	var headingY:Number;
	var mouthSize:Number;
	var wounded:Boolean;
	var panicIntensity:Number;
	var panicIntensityDefault:Number;
	var panicRange:Number;
	var panicTimerDefault:Number;
	var panicTimer:Number;
	var panic:Boolean;
	var boostMax:Number = 12;
	var boostTimer:Number = 0;
	var defaultColorTransTime:Number;
	var colorTransTime:Number;
	var curTransTime:Number;
	var maxEvolveStates:Number;
	var maxSegs:Number;
	// what type of fish is this -- snakefish, jellyfish, etc - used in hordeMovement behavior
	var type:Number;
	var hasChosenTarget:Boolean;
	var coward:Boolean;
	var toTarget:Boolean; // forces the player to move toward the target
	var hasGoldEgg:Boolean; // if true, this creature will drop the golden egg when it dies
	var spawnDownFood:Boolean; // will spawn the down food when it dies
	var creatureType:String; // used with clone() to figure out what kind of creature to create
	//////////////////////////////////////////////////////
	//Initiate and create the creature with MovieClips
	//////////////////////////////////////////////////////
	public function Creature(posX:Number, posY:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speed:Number, turnSpeed:Number, panic:Boolean, mc:MovieClip, ID:Number, prefix:String) {
		//passing data from game to class
		this.posX = posX;
		this.posY = posY;
		this.defaultNumSegs = numSegs;
		this.defaultSegLength = segLength;
		this.segLength = segLength;
		this.defaultSpeed = speed;
		this.speed = speed;
		this.currentSpeed = speed;
		this.turnSpeed = turnSpeed;
		this.panic = panic;
		this.mc = mc;
		this.ID = ID;
		this.assetPrefix = prefix;
		segName="segbody1";
		maxEvolveStates = 4;
		this.maxSegs = maxSegs;
		initializeVars();
		initialize();
		for (var i = 0; i<randEvolve; i++) {
			evolveRandomSeg();
		}
	}
	//////////////////////////////////////////////////////
	//Create and return an exact copy of an existing creature
	//////////////////////////////////////////////////////
	static function clone(c:Creature, mc:MovieClip, ID:Number):Creature {
		var nc:Creature;
		if(c.creatureType == "Snakefish") {
			nc = new Snakefish(0, 0, 0, 16, 0, 15, 200, (8+random(3))/180*Math.PI, false, mc, ID, "c1_");
		} else if(c.creatureType == "Jellyfish") {
			nc = new Jellyfish(0, 0, 0, 16, 0, 15, 200, (8+random(3))/180*Math.PI, false, mc, ID, "c1_");
		}

		nc.posX = c.posX;
		nc.posY = c.posY;
		nc.posZ = c.posZ;
		
		nc.defaultNumSegs = c.defaultNumSegs;
		nc.defaultSegLength = c.defaultSegLength;
		nc.panic = c.panic;
		nc.panicRange = c.panicRange;
		nc.assetPrefix = c.assetPrefix;
		nc.maxEvolveStates = c.maxEvolveStates;
		nc.maxSegs = c.maxSegs;
		
		for(var i:Number = 1; i < c.numSegs; i++) {
			nc.grow();
		}
		for(var j:Number = 0; j < c.numSegs; j++) {
			while(c.mc["seg"+j].evolveState > nc.mc["seg"+j].evolveState) {
				nc.evolveSegment(j);
			}
		}
		
		nc.segLength = c.segLength;
		nc.defaultSpeed = c.defaultSpeed;
		nc.speed = c.speed;
		nc.currentSpeed = c.currentSpeed;
		nc.turnSpeed = c.turnSpeed;
		
		return nc;
	}
	//////////////////////////////////////////////////////
	//Update the Creature in each frames
	//////////////////////////////////////////////////////
	function update(dt:Number, camera:Camera3D, player:Creature, fish:Array, food:Array):Void {
		mouthSize = mc["seg0"]._yscale;
		aliveTime += dt;
		if (boostTimer>0) {
			behavior.startBoost(this, boostTimer/boostMax,dt);
		} else {
			behavior.stopBoost(this);
		}
		if (aliveTime>=lifeTime && lifeTime>=0 && alive && !dieing) {
			die();
		}
		// reset state                                     
		while (targets.length>0) {
			targets.pop();
		}
		if (!hasChosenTarget) {
			tempMin = tempMinDefault;
			tempFood = -1;
			tempFish = -2;
			tempWeak = -1;
			hasTarget = false;
		}
		var dir:Number = mc["seg0"]._rotation*Math.PI/180;
		headingX = Math.cos(dir);
		headingY = Math.sin(dir);
		// if we are in the process of dieing, just die and do nothing else!
		if (dieing && level == _root.nextLevel) {
			dieUpdate(dt);
		} else {
			//choose target and eat
			chooseTarget(dt, player, fish, food);
			//check to see if the creature is in range of anything eatable
			collision(food);
			//eating animation and it's consequence           
			eatingUpdate(dt, camera);
			// movement
			movementUpdate(dt, camera);
		}
		updateColor(dt);
	
		hasChosenTarget = false;
	}
	//////////////////////////////////////////////////////
	//Called directly before intialize(). Sets all variables
	// to their initial states.
	//////////////////////////////////////////////////////
	function initializeVars() {
		targets = new Array();
		transArray = new Array();
		segTag = new Array(64);
		segSounds = new Array(64);
		segTimes = new Array(64);
		weakPoints = new Array(64);
		weakPointsHit = new Array(64);
		speed = defaultSpeed;
		this.currentSpeed = speed*0.2;
		segLength = defaultSegLength;
		numSegs = 0;
		curNumSegs = 0;
		glowID = 0;
		targetX = posX;
		targetY = posY;
		tempTargetX = targetX;
		tempTargetY = targetY;
		weakLength = 0;
		hasTarget = false;
		boss = false;
		panicTimer = 0;
		alive = true;
		dieing = false;
		dieExplosionRate = 0;
		dieTimer = 0;
		dieSeg = 0;
		turnIntoFoodOnDeath = true;
		aliveTime = 0;
		lifeTime = -1;
		tempMinDefault = 15*segLength;
		behavior = new Behavior();
		wounded = false;
		panicIntensity = 0;
		panicIntensityDefault = 4;
		panicRange = Math.min((segLength*3)+200, 500);
		panicTimerDefault = 3;
		panicTimer = 0;
		defaultColorTransTime = .66;
		colorTransTime = defaultColorTransTime;
		curTransTime = 0;
		hasChosenTarget = false;
		coward = false;
		toTarget = false;
		hasGoldEgg = false;
		spawnDownFood = false;
	}
	//////////////////////////////////////////////////////
	//Initilize and generate creature
	//////////////////////////////////////////////////////
	function initialize() {
		// should be implemented in subclasses
	}
	//////////////////////////////////////////////////////
	//Detect creature and decide target to eat
	//////////////////////////////////////////////////////
	function chooseTarget(dt:Number, player:Creature, fish:Array, food:Array) {
		// should be implemented in subclasses	
	}
	//////////////////////////////////////////////////////
	//Transitions the creature from the current color
	//to the target color
	//////////////////////////////////////////////////////
	function updateColor(dt:Number):Void {
		if (color.curColor != color.targetColor) {
			curTransTime += dt;
			color.setBias((colorTransTime-curTransTime)/colorTransTime);
			if (color.bias<=0) {
				color.baseColor = color.targetColor;
				color.setBias(1);
				curTransTime = 0;
			}
		}
		
		// apply shading
		for (var i:Number = 0; i<transArray.length; i++) {
			transArray[i].colorTransform = this.colorTrans;
		}
		for (var i:Number = 0; i<weakLength; i++) {
			if (weakPointsHit[i] == 0) {
				transArray[weakPoints[i]].colorTransform = this.colorTrans2;
			}
		}
	}
	function createFishMouth():Void {
		var seg:MovieClip = mc.attachMovie(assetPrefix+"seghead1", "seg0", 99);
		createMouth(seg);
	}
	function createJellyMouth():Void {
		var seg:MovieClip = mc.attachMovie(assetPrefix+"jellyhead1", "seg0", 99);
		createMouth(seg);
	}
	function createMouth(seg:MovieClip):Void {
		segSounds[0] = 0;
		segTag[0] = 0;
		seg._xscale = segLength;
		seg._yscale = segLength;
		seg.evolveState = 1;
		this.curNumSegs++;
		this.numSegs++;
		// used for shading
		var trans:Transform = new Transform(seg);
		transArray.push(trans);
	}
	//////////////////////////////////////////////////////
	//Check to see if the creature is in range of anything eatable
	//////////////////////////////////////////////////////
	function collision(food:Array):Void {
		var blueRed:Boolean = false;
		//detect if it eats something                              
		//mc["seg0"]._xscale is the mouth gap scale
		if ((eating == -1) && (tempMin<mouthSize)) {
			//play eating sound effect
			mc["seg0"].gotoAndPlay(2);
			//if it's part of the fish, do wound()
			if (tempFish != -2) {
				targets[tempFish].wound(tempWeak);
				eating = 1;
				nutrition = 1;
				// camera shake if the fish is eating the player
				if (targets[tempFish].ID == -1) {
					_root.camera.shake(0);
				}
				//increase length                                               
			} else {
				//else kill food
				eating = food[tempFood].foodType;
				nutrition = food[tempFood].nutrition;
				//trace("nutrition = " + nutrition);
				food[tempFood].alive = false;
				if (eating == 100) {
					_root.switchLevel(_root.curLevel+1);
					eating = 0;
					blueRed = true;
					var redSound:Sound = _root.sndLoader.getSound(assetPrefix+"red");
					redSound.setVolume(100);
					redSound.start(0, 1);
				} else if (eating == 101) {
					_root.switchLevel(_root.curLevel-1);
					eating = 0;
					blueRed = true;
					var redSound:Sound = _root.sndLoader.getSound(assetPrefix+"blue");
					redSound.setVolume(100);
					redSound.start(0, 1);
				} else if (eating == 102) {
					nutrition = 102;
					eating = 1;
					for(var i:Number = 1; i < numSegs; i++) {
						nutrition += mc["seg"+i].evolveState - segTag[i];
					}
					for(var j:Number = 0; j < weakLength; j++) {
						if(weakPointsHit[j]<weakPointsHitC) {
							nutrition++;
						}
					}
					nutrition++;
				}
			}
			if(!blueRed) {
				var i:Number = int(random(5));
				//segSounds[glowID];
				sounds[i].setVolume(soundVolume);
				sounds[i].start(0, 1);
			}
		}
	}
	//////////////////////////////////////////////////////
	//Update movement and IK
	//////////////////////////////////////////////////////
	function movementUpdate(dt:Number, camera:Camera3D) {
		// default implementation:                                
		var aimAngle:Number;
		if (ID == -1 && !toTarget) {
			aimAngle = Math.atan2((_root.ymouse-camera.screenY-screenY), (_root.xmouse-camera.screenX-screenX));
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
			if (pressed && !toTarget) {
				currentSpeed = Math.min(speed, currentSpeed+dt*400);
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
	////////////////////////////////////////////////////////////
	//IK animation function called for update the body movement
	////////////////////////////////////////////////////////////
	function drag(seg:MovieClip, x:Number, y:Number) {
		var dx:Number = x-seg._x;
		var dy:Number = y-seg._y;
		var angle:Number = Math.atan2(dy, dx);
		seg._rotation = angle*180/Math.PI;
		if (seg.evolveState<0) {
			seg._x = x-Math.cos(angle)*seg._xscale*2;
			seg._y = y-Math.sin(angle)*seg._xscale*2;
		} else {
			seg._x = x-Math.cos(angle)*seg._xscale;
			seg._y = y-Math.sin(angle)*seg._xscale;
		}
	}
	////////////////////////////////////////////////////////////
	//Math function to tell the distance between two dots
	////////////////////////////////////////////////////////////
	function dist(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		var distance:Number = Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
		return (distance);
	}
	/////////////////////////////////////////////////////////////////
	//After reaching 64 segbody1s the creature rebirth with 1 segbody1
	/////////////////////////////////////////////////////////////////
	function rebirth() {
		lifeCycle++;
		numSegs = 3;
		weakLength = 0;
		for (var i:Number = 3; i<=64; i++) {
			var seg:MovieClip = mc["seg"+i];
			seg.removeMovieClip();
		}
	}
	/////////////////////////////////////////////////////////////////
	//after eating animation is finished, it adds one more segbody1
	/////////////////////////////////////////////////////////////////
	function grow() {
		if (curNumSegs<=maxSegs) {
			var seg:MovieClip;
			seg = mc.attachMovie(assetPrefix+segName, "seg"+curNumSegs, 99-curNumSegs);
			segTimes[curNumSegs] = 0.25;
			segSounds[curNumSegs] = int(random(5));
			segTag[curNumSegs] = 0;
			seg._rotation = mc["seg"+(curNumSegs-1)]._rotation;
			seg._x = mc["seg"+(curNumSegs-1)]._x;
			seg._y = mc["seg"+(curNumSegs-1)]._y;
			seg._xscale = segLength;
			seg._yscale = segLength;
			seg.evolveState = 1;
			speed += segLength*0.2;
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
			if (curNumSegs == 2) {
				evolveSegment(1);
			}
		} else {
			// For now, skip over the mouth -- evolve again if the mouth
			// seg if the one that evolved
			if (evolveMinSeg() == 0) {
				evolveMinSeg();
			}
		}
	}
	function evolveMinSeg():Number {
		var minEvolveSeg:Number = 0;
		var minEvolveState:Number = mc["seg0"].evolveState;
		for (var i:Number = 1; i<curNumSegs; i++) {
			if (mc["seg"+i].evolveState<minEvolveState) {
				minEvolveState = mc["seg"+i].evolveState;
				minEvolveSeg = i;
			}
		}
		evolveSegment(minEvolveSeg);
		return minEvolveSeg;
	}
	function evolveRandomSeg():Void {
		var minEvolveState:Number = mc["seg1"].evolveState;
		for (var i:Number = 1; i<curNumSegs; i++) {
			if (mc["seg"+i].evolveState<minEvolveState) {
				minEvolveState = mc["seg"+i].evolveState;
			}
		}
		var randomSeg = Math.max(random(curNumSegs), 1);
		while (mc["seg"+randomSeg].evolveState>minEvolveState) {
			randomSeg = random(curNumSegs);
		}
		evolveSegment(randomSeg);
	}
	/////////////////////////////////////////////////////////////////////////////
	//each time the creature eats, all the weakpoints without full HP will regen
	/////////////////////////////////////////////////////////////////////////////
	function heal(i:Number) {
		weakPointsHit[i] = weakPointsHitC;
		//trace(weakPointsHit[i]);
		var seg:MovieClip = mc["seg"+weakPoints[i]];
		//seg._alpha = 100;
		speed += (mc["seg"+weakPoints[i]].evolveState-1)*segLength*0.4;
		var healSound:Sound = _root.sndLoader.getSound(assetPrefix+"heal");
		healSound.setVolume(soundVolume);
		healSound.start(0, 1);
		_root.gameLevels[level].spawnEffect(0, 10, 1, 0.25, mc["seg"+(glowID-1)]._x, mc["seg"+(glowID-1)]._y);
	}
	/////////////////////////////////////////////////////////////////////////////
	//If one of the weakpoints got bite, it will run wound()
	/////////////////////////////////////////////////////////////////////////////
	function wound(weakPointID:Number) {
		if (level != _root.curLevel) {
			return;
		}
		if (panic) {
			wounded = true;
			tempTargetX = targetX;
			tempTargetY = targetY;
			panicIntensity = panicIntensityDefault;
			panicTimer = panicTimerDefault;
		}
		//Lose hitpoints                              
		weakPointsHit[weakPointID] = 0;
		speed -= (mc["seg"+weakPoints[weakPointID]].evolveState-1)*segLength*0.4;
		//Dim down the wounded segbody1s
		var seg:MovieClip = mc["seg"+weakPoints[weakPointID]];
		seg._alpha = 0;
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
	//If all the hitpoints are gone, run die()
	/////////////////////////////////////////////////////////////////////////////
	function die() {
		if (ID == -1) {
			_root.switchLevel(_root.curLevel-1);
			var blueSound:Sound = _root.sndLoader.getSound(assetPrefix+"death");
			blueSound.setVolume(100);
			blueSound.start(0, 1);
			if (numSegs>3) {
				dieExplosionRate = 1;
				dieTimer = dieExplosionRate;
				dieing = true;
				dieSeg = numSegs-1;
			}
		} else {
			//alive = false;  
			dieing = true;
			dieExplosionRate = 2/numSegs;
			dieTimer = dieExplosionRate;
		}
	}
	/////////////////////////////////////////////////////////////////////////////	
	//Run every frame when the creature is dieing -- make the weakpoints 
	//turn into foods 1 by 1. 
	/////////////////////////////////////////////////////////////////////////////
	function dieUpdate(dt:Number) {
		if (_root.switchingLevels) {
			return;
		}
		var explodedSeg:Boolean = false;
		dieTimer += dt;
		while (dieTimer>dieExplosionRate && dieSeg<numSegs) {
			dieTimer -= dieExplosionRate;
			var tempX:Number = 0;
			var tempY:Number = 0;
			for (var i:Number = dieSeg; i<numSegs; i++) {
				dieSeg++;
				tempX = mc["seg"+i]._x;
				tempY = mc["seg"+i]._y;
				//trace("dieUpdate: " + tempX+","+tempY);
				if (i != 0) {
					if (turnIntoFoodOnDeath && segTag[i]>0) {
						_root.gameLevels[level].spawnFoodAtLocation(segTag[i], tempX, tempY, 15, 10);
					}
					_root.gameLevels[level].spawnEffect(0, segLength/20, segLength/20, 0, tempX, tempY);
				} else {
					if (turnIntoFoodOnDeath) {
						_root.gameLevels[level].spawnFoodAtLocation(0, tempX, tempY, 15, 10);
						if (numSegs>10) {
							_root.gameLevels[level].spawnFoodAtLocation(99, tempX, tempY, 15, 10);
						}
						if(hasGoldEgg) { 
							_root.gameLevels[level].spawnFoodAtLocation(102, tempX, tempY, 25, 10);
						}
						if(spawnDownFood){
							_root.gameLevels[level].spawnFoodAtLocation(100, tempX, tempY, 35, 0);
						}
					}
					_root.gameLevels[level].spawnEffect(0, segLength/5, segLength/20, 0, tempX, tempY);
				}
				speed -= segLength*0.2;
				mc["seg"+i].removeMovieClip();
				explodedSeg = true;
				// if we have exploded all of the segments, we are done                  
				if (dieSeg>=numSegs) {
					// if this creature is the player, do a complete reset
					if (ID == -1) {
						_root.gameLevels[level].killAllBulletFish();
						numSegs--;
						curNumSegs = numSegs;
						dieing = false;
						heal(0);
						_root.gameLevels[level].spawnFoodAtLocation(1, tempX, tempY, 15, 10);
						_root.gameLevels[level].spawnEffect(0, segLength/4, segLength/10, 0, tempX, tempY);
						//initializeVars();
						//initialize();
					} else {
						alive = false;
						mc.removeMovieClip();
					}
				}
				// only explode one segment per iteration                                             
				if (explodedSeg) {
					break;
				}
			}
		}
	}
	/////////////////////////////////////////////////////////////////////////////
	//eating animation is done here
	/////////////////////////////////////////////////////////////////////////////
	function eatingUpdate(dt:Number, camera:Camera3D) {
		var lastTaggedSeg:Number = 0;
		for (var i:Number = 0; i<numSegs; i++) {
			if (segTag[i]>=1) {
				lastTaggedSeg = i;
			}
		}
		if (eating>-1) {
			if (nutrition<=0) {
				//set to no food
				glowID = 0;
				eating = -1;
				eatingTimer = 0;
				tempScaleX = mc["seg0"]._xscale;
				tempScaleY = mc["seg0"]._yscale;
				// play open mouth animation
				mc["seg0"].gotoAndPlay(23);
			} else {
				mc["seg"+glowID]._xscale = tempScaleX*(1+eatingTimer/eatingTimerC);
				mc["seg"+glowID]._yscale = tempScaleY*(1+eatingTimer/eatingTimerC);
				if (boostTimer>0) {
					eatingTimer -= dt*2.5;//(1+boostTimer/boostMax*2);
				} else {
					eatingTimer -= dt;
				}
				if (eatingTimer<=0) {
					// scale reset
					mc["seg"+glowID]._xscale = tempScaleX;
					mc["seg"+glowID]._yscale = tempScaleY;
					// move to next seg 
					glowID = Math.min(glowID+1, numSegs);
					// save original scale for future reset
					tempScaleX = mc["seg"+glowID]._xscale;
					tempScaleY = mc["seg"+glowID]._yscale;
					// if it's normal segment and is eating growing food
					if (eating>0 && eating<10) {
						if (nutrition>0) {
							if (!panic) {
								for (var i:Number = 0; i<weakLength; i++) {
									if ((weakPoints[i] == glowID) && (weakPointsHit[i]<weakPointsHitC)) {
										heal(i);
										nutrition--;
										break;
									}
								}
							}
							while ((segTag[glowID]<mc["seg"+glowID].evolveState) && (nutrition>0)) {
								segTag[glowID]++;
								mc["seg"+glowID].gotoAndStop(segTag[glowID]+1);
								nutrition--;
							}
							if ((glowID == numSegs-1) && (segTag[glowID] == mc["seg"+glowID].evolveState) && (nutrition>0)) {
								for (var i:Number = 1; i<numSegs; i++) {
									segTag[i] = 0;
									mc["seg"+i].gotoAndStop(1);
								}
								nutrition--;
								grow();
								_root.gameLevels[level].spawnEffect(0, segLength, segLength/20, segTimes[glowID], mc["seg"+glowID]._x, mc["seg"+glowID]._y);
								if (nutrition>0) {
									var x:Number = mc["seg"+(numSegs-1)]._x;
									var y:Number = mc["seg"+(numSegs-1)]._y;
									
									_root.gameLevels[level].spawnEffect(0, segLength/20, segLength/20+1, 0, x, y);
									if(nutrition == 102 && ID == -1) {
										PlayerXForm.turnPlayerIntoEgg(x, y, 25);
										_root.floatToTop();
									} else {
										_root.gameLevels[level].spawnFoodAtLocation(nutrition, x, y, 15, 10);
									}
									nutrition = 0;
								}
							}
						}
					} else if (eating == 99) {
						boostTimer = boostMax;
						nutrition--;
					} else if (eating == 0) {
						if (glowID == lastTaggedSeg || lastTaggedSeg<=1) {
							// evolve the currently lit segment
							// for now, if no segments are lit, evolve the first 
							if (lastTaggedSeg<1) {
								lastTaggedSeg = 1;
							}
							if (mc["seg"+glowID].evolveState<maxEvolveStates) {
								nutrition--;
								evolveSegment(lastTaggedSeg);
							} else {
								for (var i:Number = 1; i<numSegs; i++) {
									if (mc["seg"+i].evolveState<maxEvolveStates) {
										evolveSegment(i);
										break;
									}
								}
								nutrition--;
							}
						}
					}
					//reset timer                    
					eatingTimer = segTimes[glowID];
					// spawn ring effect
					_root.gameLevels[level].spawnEffect(0, segLength/20, segLength/20, 0, mc["seg"+(glowID-1)]._x, mc["seg"+(glowID-1)]._y);
					// seg sound plays  
					var i:Number = int(random(5));
					sounds[i].setVolume(soundVolume);
					sounds[i].start(0, 1);
				}
			}
		}
	}
	function evolveSegment(segNum:Number):Void {
		// don't evolve the mouth for now
		if (segNum == 0) {
			mc["seg"+segNum].evolveState++;
			return;
		}
		var evolveState:Number = mc["seg"+segNum].evolveState;
		evolveState++;
		if (evolveState<=maxEvolveStates) {
			if (evolveState == 2) {
				weakPoints[weakLength] = segNum;
				weakPointsHit[weakLength] = weakPointsHitC;
				weakLength++;
			}
			var prevX:Number = mc["seg"+segNum]._x;
			var prevY:Number = mc["seg"+segNum]._y;
			var prevVX:Number = mc["seg"+segNum].vx;
			var prevVY:Number = mc["seg"+segNum].vy;
			var prefix:String = "c"+evolveState+"_";
			mc["seg"+segNum].removeMovieClip();
			var seg:MovieClip = mc.attachMovie(prefix+segName, "seg"+segNum, 99-segNum);
			seg.evolveState = evolveState;
			speed += segLength*0.4;
			seg._xscale = segLength;
			seg._yscale = segLength;
			segTimes[curNumSegs] = 0.25*evolveState;
			seg._x = prevX;
			seg._y = prevY;
			seg.vx = prevVX;
			seg.vy = prevVY;
			seg.gotoAndStop(segTag[segNum]+1);
			segSounds[curNumSegs] = 0;
			var trans:Transform = new Transform(seg);
			transArray[segNum] = trans;
		}
	}
}
