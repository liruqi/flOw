class Effect extends GameObject {
	var eType:Number;
	var eSize:Number;
	var eTime:Number;
	var eDelay:Number;
	var timer:Number;
	var alive:Boolean;
	public function Effect(eType:Number, eSize:Number, eTime:Number, eDelay:Number, posX:Number, posY:Number, posZ:Number, mc:MovieClip) {
		this.mc = mc;
		reset(eType, eSize, eTime, eDelay, posX, posY, posZ);
	}
	function reset(eType:Number, eSize:Number, eTime:Number, eDelay:Number, posX:Number, posY:Number, posZ:Number) {
		this.posX = posX;
		this.posY = posY;
		this.posZ = posZ;
		this.eType = eType;
		this.eSize = eSize;
		this.eTime = eTime;
		this.eDelay = eDelay;
		alive = true;
		timer = 0;
		if (eType == 0) {
			var eff:MovieClip = mc.attachMovie("ping", "eff", 0);
			eff._x = posX;
			eff._y = posY;
			eff._xscale = eSize*10;
			eff._yscale = eSize*10;
		} else if (eType == 1) {
			var eff:MovieClip = mc.attachMovie("pong", "eff", 0);
			eff._x = posX;
			eff._y = posY;
			eff._xscale = eSize*10;
			eff._yscale = eSize*10;
		}
	}
	function update(dt:Number, camera:Camera3D):Void {
		timer += dt;
		if (timer>eDelay) {
			if ((timer<eTime) && (alive)) {
				mc["eff"].gotoAndStop(int(timer/eTime*100));
			} else {
				timer = 0;
				alive = false;
				mc["eff"].removeMovieClip();
			}
		}
	}
}
