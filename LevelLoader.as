class LevelLoader
{
	var xmlData:XML;
	static var isLoaded:Boolean = false;
	public function LevelLoader() {
		
	}
	
	public function loadXML(filename:String):Void {
		xmlData = new XML();
		xmlData.ignoreWhite = true;
		xmlData.onLoad = function(success) {
			if(success) {
				LevelLoader.isLoaded = true;
			}
		}
		xmlData.load(filename); 
	}
	
	public function spawnCampaign(num:Number):Void {	
		var root:XMLNode = xmlData.firstChild;
		var campaigns = root.childNodes;
		
		var cNum = -1;
		for(var i:Number = 0; i < campaigns.length; i++) {
			if(num == parseInt(campaigns[i].attributes.num))
				cNum = i;
		}
		
		var playerType:String = campaigns[cNum].attributes.player;
		PlayerXForm.nextPlayerType = playerType;
		
		// go "infinite" with the campaigns - if we try to spawn a campaign # that hasn't been defined,
		// use the last one defined
		if(cNum == -1)
			cNum = campaigns.length - 1;
			
		if(_root.numPlayerBosses > 0) {
			movePlayerBossToNewLevel();
		}
			
		var levels = campaigns[cNum].childNodes;
		_root.totalLevel = Math.max(levels.length,_root.totalLevel);
		for(var i:Number = 0; i < levels.length; i++) {
			if((i > 0) || (i == 0 && cNum == 0)) { // don't erase level 0 in subsequent campaign loads
				eraseLevel(i);
				var newLevel = new GameLevel(i, levels[i].attributes.levelSize);
			} else {
				newLevel = _root.gameLevels[i];
			}
			newLevel.bgColor.curColor = levels[i].attributes.bgColor;
			// parse additional spawn information for this level
			if((i > 0) || (i == 0 && cNum == 0)) { // don't respawn anything for level 0
				var levelInfo = levels[i].childNodes;
				for(var j:Number = 0; j < levelInfo.length; j++) {;
					if(levelInfo[j].nodeName == "SpawnBillboard") {
						spawnBillboard(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnFood") {
						spawnFood(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnFish") {
						spawnFish(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnJellyfish") {
						spawnJellyfish(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnManta") {
						spawnManta(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnBoss") {
						spawnBoss(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnFlockfish") {
						spawnFlockfish(levelInfo[j], newLevel);
					} else if(levelInfo[j].nodeName == "SpawnGoldEgg") {
						spawnGoldEgg(levelInfo[j], newLevel); 
					}
				}
				// spawn up/down foods as appropriate
				if(i < levels.length - 1 || _root.numPlayerBosses > 0)
					newLevel.spawnFood(1,100,35,0);
				if(i > 0)
					newLevel.spawnFood(1,101,35,0);
			}
			_root.gameLevels[i] = newLevel;
		}
		
		for(var n:Number = 0; n < _root.numPlayerBosses - 1; n++) {
		//for(var n:Number = 0; n < _root.gameLevels.length; n++ ) {
			_root.gameLevels[levels.length+n].respawnPlayerBoss();
		}
		
		// only spawn the goldEgg on the last level
		for(var i:Number = 0; i < _root.gameLevels.length; i++) {
			_root.gameLevels[i].unspawnGoldEgg();
		}
		_root.gameLevels[_root.gameLevels.length-1].spawnGoldEgg(0);
		
	}
	
	function eraseLevel(num:Number):Void {
		_root.gameLevels[num].eraseData();
		_root.gameLevels[num] = null;
	}
	
	function spawnGoldEgg(node:XMLNode, newLevel:GameLevel):Void {
		newLevel.spawnGoldEgg(parseInt(node.attributes.fishNum));
	}
	function spawnBillboard(node:XMLNode, newLevel:GameLevel):Void {
		newLevel.spawnBillboard(node.attributes.name, parseInt(node.attributes.posX), parseInt(node.attributes.posY));
	}
	function spawnFood(node:XMLNode, newLevel:GameLevel):Void {
		newLevel.spawnFood(parseInt(node.attributes.num), parseInt(node.attributes.foodType), 
						   parseInt(node.attributes.hpMin), parseInt(node.attributes.hpVar));
	}
	function spawnFish(node:XMLNode, newLevel:GameLevel):Void {
		var panic:Boolean = false;
		if(node.attributes.panic == "true")
			panic = true;
		newLevel.spawnFish(parseInt(node.attributes.num), parseInt(node.attributes.numSegs),
					       parseInt(node.attributes.maxSegs), parseInt(node.attributes.randEvolve),
						   parseInt(node.attributes.segLength), parseInt(node.attributes.speedMin),
						   parseInt(node.attributes.speedVar), parseInt(node.attributes.turnMin),
						   parseInt(node.attributes.turnVar), panic);
	}
	function spawnJellyfish(node:XMLNode, newLevel:GameLevel):Void {
		var panic:Boolean = false;
		if(node.attributes.panic == "true")
			panic = true;
		newLevel.spawnJellyfish(parseInt(node.attributes.num), parseInt(node.attributes.numSegs),
					            parseInt(node.attributes.maxSegs), parseInt(node.attributes.randEvolve),
						        parseInt(node.attributes.segLength), parseInt(node.attributes.speedMin),
						        parseInt(node.attributes.speedVar), parseInt(node.attributes.turnMin),
								parseInt(node.attributes.turnVar), panic);
	}
	function spawnManta(node:XMLNode, newLevel:GameLevel):Void {
		newLevel.spawnManta(parseInt(node.attributes.num), parseInt(node.attributes.numSegs),
						    parseInt(node.attributes.segLength), parseInt(node.attributes.speedMin),
						    parseInt(node.attributes.speedVar), parseInt(node.attributes.turnMin),
						    parseInt(node.attributes.turnVar));
	}
	function spawnBoss(node:XMLNode, newLevel:GameLevel):Void {
		newLevel.spawnBoss(parseInt(node.attributes.num), parseInt(node.attributes.numSegs),
						   parseInt(node.attributes.segLength), parseInt(node.attributes.speedMin),
						   parseInt(node.attributes.speedVar), parseInt(node.attributes.turnMin),
						   parseInt(node.attributes.turnVar));
	}
	function spawnFlockfish(node:XMLNode, newLevel:GameLevel):Void {
		var panic:Boolean = false;
		if(node.attributes.panic == "true")
			panic = true;
		newLevel.spawnFlockfish(parseInt(node.attributes.num), parseInt(node.attributes.numSegs),
					       		parseInt(node.attributes.maxSegs), parseInt(node.attributes.randEvolve),
						   		parseInt(node.attributes.segLength), parseInt(node.attributes.speedMin),
						   		parseInt(node.attributes.speedVar), parseInt(node.attributes.turnMin),
						   		parseInt(node.attributes.turnVar), panic);
	}
	
	function movePlayerBossToNewLevel():Void {
		var prevLevel:GameLevel = _root.gameLevels[_root.totalLevel - 1];
		var newLevel = new GameLevel(_root.gameLevels.length, prevLevel.levelSize);
		newLevel.bgColor.copy(prevLevel.bgColor);
		newLevel.spawnFood(1,101,35,0); 
		newLevel.spawnFood(10,5,15,10);
		
		var playerBoss:Creature = prevLevel.playerBoss;
		playerBoss.ID = 0;
		playerBoss.posZ = newLevel.zDepth;
		newLevel.fish[0] = prevLevel.playerBoss;
		newLevel.fishLength = 1;
		newLevel.playerBoss = prevLevel.playerBoss;
		newLevel.clonePlayerBoss(); // clone the boss so we can respawn him every campaign
		prevLevel.remPlayerBoss();
				
		newLevel.bgMusic = _root.sndLoader.getSound(newLevel.assetPrefix+"Flow-lvl "+19+" drone");
		newLevel.bgMusicStarted = false;
		_root.gameLevels[_root.gameLevels.length] = newLevel;
		_root.totalLevel++;
	}
}