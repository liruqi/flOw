class PlayerXForm {

	static var egg:Creature;
	static var curHatchTime:Number = 0;
	static var hatchTime:Number = 1;
	static var isHatching:Boolean = false
	static var nextPlayerType:String = "";
	
	function PlayerXForm() {
		
	}
	
	static function update(dt:Number):Void {
		if(PlayerXForm.curHatchTime > 0) {
			PlayerXForm.curHatchTime -= dt;
			var lerp:Number = (hatchTime-curHatchTime)/hatchTime;
			PlayerXForm.egg.alpha = Math.max(1-lerp, 0);
			_root.player.alpha = Math.min(lerp, 1);
			//_root.player.posX = PlayerXForm.egg.posX;
			//_root.player.posY = PlayerXForm.egg.posY;
			PlayerXForm.egg.updateScreenPos(_root.camera);
			PlayerXForm.egg.updateColor(dt);
			if(PlayerXForm.curHatchTime <= 0) {
				_root.player.alpha = 1;
				PlayerXForm.egg.mc.removeMovieClip();
				PlayerXForm.egg = null;
				PlayerXForm.curHatchTime = 0;
			}
		}
	}
	
	static function turnPlayerIntoEgg(x:Number, y:Number, size:Number):Void {
		_root.formerSelf = _root.player;
		_root.formerSelf.speed *= 0.5;
		_root.gameLevels[_root.curLevel].addPlayerAsFish(_root.player);
		_root.playerNum++;
		var newMC:MovieClip = _root.createEmptyMovieClip("fish_player"+_root.playerNum, Camera3D.getNextDepth());
		_root.player = new Snakefish(0, 0, 0, 16, 0, 15, 200, (8+random(3))/180*Math.PI, false, newMC, -1, "c1_");
		var seg:MovieClip = _root.player.mc.attachMovie("c1_food102", "seg0", 99);
		seg._xscale = size;
		seg._yscale = size;
		seg._x = x;
		seg._y = y;
		_root.player.posX = x;
		_root.player.posY = y;
		_root.player.posZ = _root.formerSelf.posZ;
		_root.player.segLength = size;
		_root.player.numSegs = 1;
	}
	
	static function hatchPlayer():Void {
		if(PlayerXForm.curHatchTime == 0 && _root.player.numSegs == 1) {
			PlayerXForm.curHatchTime = PlayerXForm.hatchTime;
			PlayerXForm.egg = _root.player;
			var oldZ:Number = _root.player.posZ;
			_root.playerNum++;
			var newMC:MovieClip = _root.createEmptyMovieClip("fish_player"+_root.playerNum, Camera3D.getNextDepth());
			if(nextPlayerType == "Snakefish") {
				_root.player = new Snakefish(0, 0, 3, 16, 0, 15, 200, (8+random(3))/180*Math.PI, false, newMC, -1, "c1_");
			} else if(nextPlayerType == "Jellyfish") {
				_root.player = new Jellyfish(0, 0, 3, 16, 0, 15, 200, (8+random(3))/180*Math.PI, false, newMC, -1, "c1_");
			}
			PlayerXForm.egg.alpha = 1;
			_root.player.alpha = 0;
			_root.player.posX = PlayerXForm.egg.posX;
			_root.player.posY = PlayerXForm.egg.posY;
			_root.player.posZ = oldZ;
		}
	}
}