class Behavior {
	var panicColor;
	var targetPlayerColor;
	var targetFishColor;
	var targetFoodColor;
	var defaultColor;
	function Behavior() {
		panicColor = new XColor(0x00BFFF);
		targetPlayerColor = new XColor(0xFF8844);
		targetFoodColor = new XColor(0xFFFFFF);
		targetFishColor = new XColor(0xFF8844);
		defaultColor = new XColor(0xFFFFFF);
	}
	function startBoost(subj, timeLeft:Number, dt:Number):Boolean {
		subj.boostTimer = Math.max(0, subj.boostTimer-dt);
		if (timeLeft>0.1) {
			subj.mc["seg0"]._xscale = subj.segLength*2;
			subj.mc["seg0"]._yscale = subj.segLength*2;
		} else {
			subj.mc["seg0"]._xscale = subj.segLength*(1+timeLeft*10);
			subj.mc["seg0"]._yscale = subj.segLength*(1+timeLeft*10);
		}
		return true;
	}
	function stopBoost(subj):Boolean {
		subj.mc["seg0"]._xscale = subj.segLength;
		subj.mc["seg0"]._yscale = subj.segLength;
		return true;
	}
	function goToRandomLocation(subj):Boolean {
		subj.targetX = random(_root.gameLevels[subj.level].levelSize*2)-_root.gameLevels[subj.level].levelSize;
		subj.targetY = random(_root.gameLevels[subj.level].levelSize*2)-_root.gameLevels[subj.level].levelSize;
		// just return to the normal color if the creature is wandering around randomly
		switchColor(subj, defaultColor);
		return true;
	}
	function panicMovement(dt:Number, subj, player, panicRange:Number, panicIntensity:Number):Boolean {
		if (player != null) {
			subj.targets[0] = player;
		}
		var temp:Number = subj.mc["seg0"]._rotation*Math.PI/180;
		if (dist(subj.posX, subj.posY, player.posX, player.posY)<=panicRange) {
			subj.targetX += subj.currentSpeed*Math.cos(temp);
			subj.targetY += subj.currentSpeed*Math.sin(temp);
		}
		// speed up the color transition time significantly, so the creature almost instantly turns 
		// the panic color
		subj.colorTransTime = 0.1;
		switchColor(subj, panicColor);
		subj.panicTimer -= dt;
		if ((dist(subj.posX, subj.posY, player.posX, player.posY)>=panicRange) || (subj.wounded && !subj.coward && subj.panicTimer<0)) {
			endPanic(subj);
			return false;
		} else {
			return true;
		}
	}
	function endPanic(subj):Void {
		subj.targetX = subj.tempTargetX;
		subj.targetY = subj.tempTargetY;
		subj.panicTimer = 0;
		// restore old color transition time now that the panic has ended
		subj.colorTransTime = subj.defaultColorTransTime;
		switchColor(subj, defaultColor);
	}
	function endCoward(subj):Void {
		if (subj.coward && !subj.wounded) {
			endPanic(subj);
		}
		subj.coward = false;
	}
	function hordeMovement(subj, player, fish:Array, food:Array, inFront:Boolean, attackDist:Number, hordeDist:Number, cowardDist:Number, hordeNum:Number):Boolean {
		var nearFish:Array = new Array();
		for (var i:Number = 0; i<fish.length; i++) {
			if (fish[i].ID != subj.ID && fish[i].type == subj.type) {
				if (!fish[i].wounded && dist(subj.posX, subj.posY, fish[i].posX, fish[i].posY)<=hordeDist) {
					nearFish.push(fish[i]);
				}
			}
		}
		if (!subj.wounded) {
			if (nearFish.length>=hordeNum) {
				endCoward(subj);
				if (player != null && dist(player.posX, player.posY, subj.posX, subj.posY)<=attackDist) {
					subj.tempMin = attackDist;
					eatPlayerOnly(subj, player, inFront);
					for (var i:Number = 0; i<nearFish.length; i++) {
						endCoward(nearFish[i]);
						if (!nearFish[i].wounded) {
							nearFish[i].tempMin = 99999;
							//nearFish[i].tempFish = -2;
							//nearFish[i].tempWeak = -1;
							nearFish[i].hasTarget = false;
							eatPlayerOnly(nearFish[i], player, inFront);
							nearFish[i].hasChosenTarget = true;
						}
					}
				} else {
					eatFoodOnly(subj, food, inFront);
				}
			} else {
				if (player != null && dist(player.posX, player.posY, subj.posX, subj.posY)<=cowardDist) {
					if (!subj.coward) {
						subj.coward = true;
						subj.tempTargetX = subj.targetX;
						subj.tempTargetY = subj.targetY;
						subj.panicIntensity = subj.panicIntensityDefault;
						subj.panicTimer = 0;
						//subj.panicTimer = subj.panicTimerDefault;
					}
				} else {
					endCoward(subj);
					eatFoodOnly(subj, food, inFront);
				}
			}
			// if we don't have a target and we aren't running, move to a random location
			if (!subj.hasTarget && !subj.coward) {
				switchColor(subj, defaultColor);
				if (dist(subj.posX, subj.posY, subj.targetX, subj.targetY)<subj.mouthSize) {
					goToRandomLocation(subj);
				}
			}
		}
		return subj.hasTarget;
	}
	function eatAnything(subj, player, fish:Array, food:Array, inFront:Boolean):Boolean {
		findClosestFood(subj, food);
		// Treat the player like any other fish. Add the player as well as
		// all other fish into a list of targets.			
		for (var i:Number = 0; i<fish.length; i++) {
			subj.targets[i] = fish[i];
		}
		if (player != null && subj.ID != -1) {
			subj.targets[fish.length] = player;
		}
		findClosestWeakpoint(subj, inFront);
		if (subj.tempFood != -1 || subj.tempFish != -2) {
			subj.hasTarget = true;
		}
		// targetting some food...    
		if (subj.tempFood != -1) {
			switchColor(subj, targetFoodColor);
		}
		// targetting some fish    
		if (subj.tempFish != -2) {
			switchColor(subj, targetFishColor);
		}
		// targetting the player specifically    
		if (subj.targets[subj.tempFish].ID == -1) {
			switchColor(subj, targetPlayerColor);
		}
		// targetting nothing  
		if (subj.tempFood == -1 && subj.tempFish == -2) {
			switchColor(subj, defaultColor);
		}
		return subj.hasTarget;
	}
	function eatFoodOnly(subj, food:Array, inFront:Boolean):Boolean {
		findClosestFood(subj, food);
		if (subj.tempFood != -1) {
			subj.hasTarget = true;
			switchColor(subj, targetFoodColor);
		}
		return subj.hasTarget;
	}
	function eatPlayerOnly(subj, player, inFront:Boolean):Boolean {
		if (player != null) {
			subj.targets[0] = player;
		}
		findClosestWeakpoint(subj, inFront);
		if (subj.tempFish != -2) {
			subj.hasTarget = true;
			// we must be targetting the player...
			switchColor(subj, targetPlayerColor);
		}
		return subj.hasTarget;
	}
	function eatPlayerAndFood(subj, player, food:Array, inFront:Boolean):Boolean {
		findClosestFood(subj, food);
		if (player != null) {
			subj.targets[0] = player;
		}
		findClosestWeakpoint(subj, inFront);
		if (subj.tempFood != -1) {
			subj.hasTarget = true;
			switchColor(subj, targetFoodColor);
		}
		if (subj.tempFish != -2) {
			subj.hasTarget = true;
			// we must be targetting the player...
			switchColor(subj, targetPlayerColor);
		}
		return subj.hasTarget;
	}
	////////////////////////////////////////////////////////////
	//Finds the the closets food item to eat
	////////////////////////////////////////////////////////////
	function findClosestFood(subj, food:Array):Void {
		//go through every thing eatable and choose the closest as target
		for (var i:Number = 0; i<food.length; i++) {
			var tempDist:Number = dist(food[i].posX, food[i].posY, subj.posX, subj.posY);
			if (subj == _root.player || food[i].foodType<100) {
				if (tempDist<subj.tempMin && food[i].alive) {
					subj.tempMin = tempDist;
					subj.tempFood = i;
					subj.targetX = food[i].posX;
					subj.targetY = food[i].posY;
				}
			}
		}
	}
	////////////////////////////////////////////////////////////
	//Finds the closest weakpoint on a creature within the
	//subject's list of targets
	////////////////////////////////////////////////////////////
	function findClosestWeakpoint(subj, inFront:Boolean):Void {
		for (var i:Number = 0; i<subj.targets.length; i++) {
			if (subj.targets[i].ID != subj.ID) {
				for (var j:Number = 0; j<subj.targets[i].weakLength; j++) {
					if (subj.targets[i].weakPointsHit[j] == subj.targets[i].weakPointsHitC) {
						var tempX:Number;
						var tempY:Number;
						if (subj.targets[i].boss == false) {
							tempX = subj.targets[i].mc["seg"+subj.targets[i].weakPoints[j]]._x;
							tempY = subj.targets[i].mc["seg"+subj.targets[i].weakPoints[j]]._y;
						} else {
							tempX = getBossWeakpointX(subj.targets[i], subj.targets[i].mc.seg0["weakPoint"+j]);
							tempY = getBossWeakpointY(subj.targets[i], subj.targets[i].mc.seg0["weakPoint"+j]);
						}
						if (inFront && DotProd2D(subj.headingX, subj.headingY, tempX-subj.posX, tempY-subj.posY)<=0) {
							// don't target this weakpoint because we specified inFront and the weakpoint
							// is behind the mouth
						} else {
							var tempDist:Number = dist(tempX, tempY, subj.posX, subj.posY);
							if (tempDist<subj.tempMin && subj.targets[i].weakPointsHit[j] == subj.targets[i].weakPointsHitC) {
								subj.tempMin = tempDist;
								subj.tempFish = i;
								subj.tempWeak = j;
								subj.targetX = tempX;
								subj.targetY = tempY;
							}
						}
					}
				}
			}
		}
	}
	////////////////////////////////////////////////////////////
	//Computes the X location of a weakpoint on a boss
	////////////////////////////////////////////////////////////
	function getBossWeakpointX(boss, wp:MovieClip):Number {
		var orient:Number = boss.mc["seg0"]._rotation*Math.PI/180;
		var x1:Number = Math.cos(orient)*wp._x-Math.sin(orient)*wp._y;
		x1 *= boss.mc["seg0"]._xscale*0.01;
		return boss.mc["seg0"]._x+x1;
	}
	////////////////////////////////////////////////////////////
	//Computes the Y location of a weakpoint on a boss
	////////////////////////////////////////////////////////////
	function getBossWeakpointY(boss, wp:MovieClip):Number {
		var orient:Number = boss.mc["seg0"]._rotation*Math.PI/180;
		var y1:Number = Math.cos(orient)*wp._y+Math.sin(orient)*wp._x;
		y1 *= boss.mc["seg0"]._yscale*0.01;
		return boss.mc["seg0"]._y+y1;
	}
	////////////////////////////////////////////////////////////
	//Math helper function to tell the distance between two dots
	////////////////////////////////////////////////////////////
	function dist(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		var distance:Number = Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
		return (distance);
	}
	////////////////////////////////////////////////////////////
	//Math helper function to determine the dot product between
	//two 2D vectors
	////////////////////////////////////////////////////////////
	function DotProd2D(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		return (x1*x2+y1*y2);
	}
	function switchColor(subj, dest):Void {
		if (subj.ID != -1) {
			// no behavior colors for the player at the current time
			if (subj.color.targetColor != dest.baseColor) {
				subj.color.baseColor = subj.color.curColor;
				subj.color.targetColor = dest.baseColor;
				subj.curTransTime = 0;
			}
		}
	}
}
