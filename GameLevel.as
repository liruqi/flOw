class GameLevel {
	var level:Number;
	var fish:Array;
	var fishLength:Number;
	var food:Array;
	var foodLength:Number;
	var foodUp:Food;
	var foodDown:Food;
	var upMarker:MovieClip;
	var downMarker:MovieClip;
	var effect:Array;
	var effectLength:Number;
	var billboard:Array;
	var billboardLength;
	static var zLevelGap = 300;
	var zDepth:Number;
	var isVisible:Boolean;
	var levelSize:Number;
	var fgColor:XColor;
	// foreground color
	var bgColor:XColor;
	// background color
	var bgMusic:Sound;
	var bgMusicStarted:Boolean;
	var bgVolume:Number;
	var campaign:Number;
	var assetPrefix:String;
	static var debugLines:Boolean = false;
	var closeToCam:Boolean;
	var playerBoss:Creature;
	var clonedPlayerBoss:Creature = null;
	function GameLevel(level:Number, levelSize:Number) {
		init(level, levelSize);
	}
	function init(level:Number, levelSize:Number):Void {
		fish = new Array();
		fishLength = 0;
		food = new Array();
		foodLength = 0;
		effect = new Array();
		effectLength = 0;
		billboard = new Array();
		billboardLength = 0;
		this.level = level;
		this.levelSize = levelSize;
		this.zDepth = level*zLevelGap;
		this.isVisible = false;
		this.fgColor = new XColor(0xFFFFFF);
		this.bgColor = new XColor(0x000000);
		// create some rule for determining how many levels in a campaign. 
		//
		// if we really need more control over this (ie, each campaign will have
		// a different number of levels), we can manually set the campaign
		// for each instance through the constructor. 
		campaign = 1;
		if (campaign == 1) {
			assetPrefix = "c1_";
		} else if (campaign == 2) {
			assetPrefix = "c2_";
		} else if (campaign == 3) {
			assetPrefix = "c3_";
		} else if (campaign == 4) {
			assetPrefix = "c4_";
		}
		bgMusic = _root.sndLoader.getSound(assetPrefix+"Flow-lvl "+level+" drone");
		bgMusicStarted = false;
		downMarker = _root.createEmptyMovieClip("level_"+level+"_downMarker", Camera3D.getNextDepth());
		downMarker.attachMovie("downMarker", "downMarker", 1);
		downMarker._xscale = downMarker._yscale=100;
		downMarker._visible = false;
		upMarker = _root.createEmptyMovieClip("level_"+level+"_upMarker", Camera3D.getNextDepth());
		upMarker.attachMovie("upMarker", "upMarker", 1);
		upMarker._xscale = upMarker._yscale=100;
		upMarker._visible = false;
		closeToCam = false;
	}
	function eraseData():Void {
		for (var i:Number = 0; i<fish.length; i++) {
			if(fish[i] != playerBoss) {
				_root[fish[i].clipName].removeMovieClip();
				delete fish[i];
				fish[i] = null;
			}
		}
		for (var i:Number = 0; i<food.length; i++) {
			_root[food[i].clipName].removeMovieClip();
			delete food[i];
			food[i] = null;
		}
		for (var i:Number = 0; i<effect.length; i++) {
			_root[effect[i].clipName].removeMovieClip();
			delete effect[i];
			effect[i] = null;
		}
		for (var i:Number = 0; i<billboard.length; i++) {
			_root[billboard[i].clipName].removeMovieClip();
			delete billboard[i];
			billboard[i] = null;
		}
		fish = new Array();
		fishLength = 0;
		food = new Array();
		foodLength = 0;
		effect = new Array();
		effectLength = 0;
		billboard = new Array();
		billboardLength = 0;
		bgMusic.stop();
	}
	function update(dt:Number, camera:Camera3D, player:Creature):Void {
		var fullUpdate:Boolean;
		var dz:Number = zDepth-camera.posZ;
		if (Math.abs(dz)<GameLevel.zLevelGap) {
			if (!bgMusicStarted && SndLoader.isLoaded(bgMusic)) {
				bgMusicStarted = true;
				bgMusic.start(0, 99);
				//trace("play"+level);
			}
			bgVolume = (GameLevel.zLevelGap-Math.abs(dz))/GameLevel.zLevelGap*100;
			bgMusic.setVolume(bgVolume);
		} else if (Math.abs(dz)<2*GameLevel.zLevelGap) {
			if (!bgMusicStarted && bgMusic.getBytesTotal()>0 && SndLoader.isLoaded(bgMusic)) {
				bgMusicStarted = true;
				bgMusic.start(0, 99);
				//trace("play"+level);
				bgMusic.setVolume(0);
			}
		} else {
			bgMusic.setVolume(0);
			bgMusic.stop();
			bgMusicStarted = false;
		}
		var nearDist:Number = 0.3;
		if (closeToCam) {
			nearDist = 0.9;
		}
		if (dz<-GameLevel.zLevelGap*nearDist || dz>GameLevel.zLevelGap*1.3) {
			setVisible(false);
		} else {
			setVisible(true);
		}
		fullUpdate = isVisible;
		//fish update
		if (fullUpdate) {
			for (var i:Number = 0; i<fish.length; i++) {
				fish[i].updateScreenPos(camera);
				fish[i].update(dt, camera, player, fish, food);
				//draw lines indicating its target
				if ((dz == 0) && (fish[i].hasTarget) && GameLevel.debugLines) {
					_root.background_mc.lineStyle(1, 0xFFFFFF, 128);
					_root.background_mc.moveTo(fish[i].screenX+camera.screenX, fish[i].screenY+camera.screenY);
					_root.background_mc.lineTo(fish[i].targetX*(fish[i].mc._xscale/100)+camera.screenX, fish[i].targetY*(fish[i].mc._yscale/100)+camera.screenY);
				}
				if (fish[i].alive == false) {
					delete fish[i];
					fish[i] = null;
				}
			}
			for (var i:Number = 0; i<food.length; i++) {
				food[i].updateScreenPos(camera);
				//if (Camera3D.inWindow(food[i].screenX, food[i].screenY, camera)) {
				food[i].update(dt, camera);
				//}
				if(food[i].alive == false && food[i].respawnTime <= 0) {
					delete food[i];
					food[i] = null;
				}
			}
			for (var i:Number = 0; i<effectLength; i++) {
				if (effect[i].alive) {
					effect[i].updateScreenPos(camera);
					//if (camera.posZ != effect[i].posZ) {
					//effect[i].alive = false;
					//}
					if (fullUpdate) {
						effect[i].update(dt, camera);
					}
				}
			}
			for (var i:Number = 0; i<billboard.length; i++) {
				billboard[i].updateScreenPos(camera);
				billboard[i].update(camera);
			}
			if (foodDown != null) {
				updateLevelMarker(foodDown, downMarker, player, camera);
			}
			if (foodUp != null) {
				updateLevelMarker(foodUp, upMarker, player, camera);
			}
		} else {
			if (dz>-1.1*GameLevel.zLevelGap) {
				for (var i:Number = 0; i<food.length; i++) {
					if (food[i].foodType>99) {
						food[i].update(dt, camera);
					}
				}
			}
			downMarker._visible = false;
			upMarker._visible = false;
		}
	}
	function setVisible(vis:Boolean):Void {
		if (isVisible == vis) {
			return;
		}
		isVisible = vis;
		for (var i:Number = 0; i<fish.length; i++) {
			fish[i].mc._visible = vis;
		}
		for (var i:Number = 0; i<food.length; i++) {
			food[i].mc._visible = vis;
		}
		for (var i:Number = 0; i<effectLength; i++) {
			effect[i].mc._visible = vis;
		}
		for (var i:Number = 0; i<billboardLength; i++) {
			billboard[i].mc._visible = vis;
		}
	}
	function setAlpha(a:Number):Void {
		for (var i:Number = 0; i<fish.length; i++) {
			fish[i].alpha = a;
		}
		for (var i:Number = 0; i<food.length; i++) {
			food[i].alpha = a;
		}
		for (var i:Number = 0; i<effectLength; i++) {
			effect[i].alpha = a;
		}
	}
	function updateLevelMarker(food:Food, marker:MovieClip, player:Creature, camera:Camera3D) {
		if (player != null) {
			if (!Camera3D.inWindow(food.screenX, food.screenY, camera)) {
				var x:Number = food.screenX+camera.screenX-Stage.width*0.5;
				var y:Number = food.screenY+camera.screenY-Stage.height*0.5;
				var theta:Number = Math.atan2(y, x);
				var alpha:Number = Math.atan2(Stage.height, Stage.width);
				var h:Number;
				if (Math.abs(theta)>alpha && Math.abs(theta)<Math.PI-alpha) {
					h = Math.abs((Stage.height/2)/Math.sin(theta));
				} else {
					h = Math.abs((Stage.width/2)/Math.cos(theta));
				}
				marker._x = (Stage.width/2)+h*Math.cos(theta);
				marker._y = (Stage.height/2)+h*Math.sin(theta);
				marker._visible = true;
			} else {
				marker._visible = false;
			}
		} else {
			marker._visible = false;
		}
	}
	function unspawnGoldEgg():Void {
		for(var i:Number = 0; i < fish.length; i++) {
			fish[i].hasGoldEgg = false;
		}
	}
	function spawnGoldEgg(fishNum:Number):Void {
		if (fishNum>-1 && fishNum<fishLength) {
			fish[fishNum].hasGoldEgg = true;
		}
	}
	function clonePlayerBoss():Void {
		var mc:MovieClip = _root.createEmptyMovieClip("clonedBoss_"+level+"_"+0, Camera3D.getNextDepth());
		clonedPlayerBoss = Creature.clone(playerBoss, mc, 0);
		clonedPlayerBoss.mc._visible = false;
	}
	function respawnPlayerBoss():Void {
		if(clonedPlayerBoss != null) {
			eraseData();
			spawnFood(1,101,35,0);
			//spawnFood(1,100,35,0);
			spawnFood(10,5,15,10);
			var mc:MovieClip = _root.createEmptyMovieClip("bossClone_"+level+"_"+fishLength, Camera3D.getNextDepth());
			fish[fishLength] = Creature.clone(clonedPlayerBoss, mc, fishLength);
			fish[fishLength].spawnDownFood = true;
			mc._visible = false;
			fishLength++;
		}
	}
	function remPlayerBoss():Void {
		for(var i:Number = 0; i < fish.length; i++) {
			if(fish[i] == playerBoss) {
				fish[i] = null;
			}
		}
		playerBoss = null;
	}
	function addPlayerAsFish(player:Creature):Void {
		player.ID = fishLength;
		//player.boss = true;
		fish[fishLength] = player;
		fishLength++;
		_root.playerNum++;
		_root.numPlayerBosses++;
		playerBoss = player;
	}
	function spawnFish(numFish:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number, panic:Boolean):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("fish_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Snakefish(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, maxSegs, randEvolve, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, panic, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("fish_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnJellyfish(numFish:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number, panic:Boolean):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("jellyfish_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Jellyfish(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, maxSegs, randEvolve, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, panic, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("jellyfish_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnFlockfish(numFish:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number, panic:Boolean):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("flockfish_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Flockfish(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, maxSegs, randEvolve, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, panic, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("flockfish_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnTelefish(numFish:Number, numSegs:Number, maxSegs:Number, randEvolve:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number, panic:Boolean):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("telefish_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Jellyfish(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, maxSegs, randEvolve, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, panic, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("telefish_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnBoss(numFish:Number, numSegs:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("boss_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Boss(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("boss_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnManta(numFish:Number, numSegs:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number):Void {
		for (var i:Number = 0; i<numFish; i++) {
			var currentObj:MovieClip;
			currentObj = _root.createEmptyMovieClip("manta_"+level+"_"+fishLength, Camera3D.getNextDepth());
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			fish[fishLength] = new Manta(random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, numSegs, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, currentObj, fishLength, assetPrefix);
			fish[fishLength].posZ = zDepth;
			fish[fishLength].color.copy(fgColor);
			fish[fishLength].clipName = new String("manta_"+level+"_"+fishLength);
			fishLength++;
		}
	}
	function spawnFood(numFood:Number, foodType:Number, hitPointsMin:Number, hitPointsVar:Number):Void {
		for (var i:Number = 0; i<numFood; i++) {
			var currentObj:MovieClip;
			_root.createEmptyMovieClip("food_"+level+"_"+foodLength, Camera3D.getNextDepth());
			currentObj = eval("food_"+level+"_"+foodLength);
			currentObj._x = 0;
			currentObj._y = 0;
			currentObj._visible = false;
			food[foodLength] = new Food(foodType, random(levelSize*2)-levelSize, random(levelSize*2)-levelSize, zDepth, hitPointsMin+random(hitPointsVar), currentObj, assetPrefix);
			food[foodLength].color.copy(fgColor);
			food[foodLength].clipName = new String("food_"+level+"_"+foodLength);
			foodLength++;
			if (foodType == 100) {
				foodDown = food[foodLength-1];
			} else if (foodType == 101) {
				foodUp = food[foodLength-1];
			}
		}
	}
	function spawnBillboard(billName:String, posX:Number, posY:Number):Void {
		var currentObj:MovieClip;
		_root.createEmptyMovieClip("Billboard_"+level+"_"+0, Camera3D.getNextDepth());
		currentObj = eval("Billboard_"+level+"_"+0);
		currentObj._x = posX;
		currentObj._y = posY;
		currentObj._visible = false;
		billboard[billboardLength] = new Billboard(billName, zDepth, currentObj);
		billboard[billboardLength].color = fgColor;
		billboard[billboardLength].clipName = new String("Billboard_"+level+"_"+0);
		billboardLength++;
	}
	// I wish Flash allowed for overloaded functions........or default parameters for functions.
	// Either way, I could reorganize to allow for just one function to spawn food, but oh well. 
	function spawnFoodAtLocation(foodType:Number, xPos:Number, yPos:Number, hitPointsMin:Number, hitPointsVar:Number) {
		var currentObj:MovieClip;
		currentObj = _root.createEmptyMovieClip("food_"+level+"_"+food.length, Camera3D.getNextDepth());
		currentObj._x = 0;
		currentObj._y = 0;
		food[foodLength] = new Food(foodType, xPos, yPos, zDepth, hitPointsMin+random(hitPointsVar), currentObj, assetPrefix);
		food[foodLength].color.copy(fgColor);
		food[foodLength].clipName = new String("food_"+level+"_"+food.length);
		foodLength++;
	}
	function spawnBulletAtLocation(lifeTime:Number, xPos:Number, yPos:Number, segLength:Number, speedMin:Number, speedVar:Number, turnSpeedMin:Number, turnSpeedVar:Number):Bullet {
		var currentObj:MovieClip;
		currentObj = _root.createEmptyMovieClip("bullet_"+level+"_"+fishLength, Camera3D.getNextDepth());
		currentObj._x = 0;
		currentObj._y = 0;
		fish[fishLength] = new Bullet(lifeTime, xPos, yPos, segLength, speedMin+random(speedVar), (turnSpeedMin+random(turnSpeedVar))/180*Math.PI, currentObj, fishLength, assetPrefix);
		fish[fishLength].posZ = zDepth;
		fish[fishLength].color.copy(fgColor);
		fish[fishLength].clipName = new String("bullet_"+level+"_"+fishLength);
		fishLength++;
		return fish[fishLength-1];
	}
	function killAllBulletFish() {
		for (var i:Number = 0; i<fish.length; i++) {
			if (fish[i].clipName == "bullet_"+level+"_"+i) {
				fish[i].die();
			}
		}
	}
	function spawnEffect(eType:Number, eSize:Number, eTime:Number, eDelay:Number, posX:Number, posY:Number, camera:Camera3D):Void {
		if ((Camera3D.inWindow(posX, posY, camera)) && (level == _root.nextLevel)) {
			var currentObj:MovieClip;
			var findEmpty:Boolean = false;
			for (var i:Number = 0; i<effectLength; i++) {
				if (!effect[i].alive) {
					effect[i].reset(eType, eSize, eTime, eDelay, posX, posY, zDepth);
					findEmpty = true;
					break;
				}
			}
			if ((!findEmpty) && (effectLength<64)) {
				currentObj = _root.createEmptyMovieClip("effect_"+level+"_"+effectLength, Camera3D.getNextDepth());
				effect[effectLength] = new Effect(eType, eSize, eTime, eDelay, posX, posY, zDepth, currentObj);
				effect[effectLength].color.copy(fgColor);
				effect[effectLength].clipName = new String("effect_"+level+"_"+effectLength);
				effectLength++;
			}
		}
	}
}
