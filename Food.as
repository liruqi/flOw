import flash.geom.ColorTransform;
import flash.geom.Transform;
class Food extends GameObject {
	var fSize:Number = 0;
	var alive:Boolean;
	var speed:Number = .1;
	var turnSpeed:Number = 0.05;
	var currentAim:Number = 0;
	var timer;
	var respawnTime;
	var nutrition:Number;
	//foodType 
	//0 grow up in fSize 
	//1 increase segments
	//2 regenerate & speed
	var foodType:Number;
	var trans:Transform;
	var gfxPrefix:String;
	var headingX:Number;
	var headingY:Number;
	public function Food(foodType:Number, posX:Number, posY:Number, posZ:Number, fSize:Number, mc:MovieClip, prefix:String) {
		this.posX = posX;
		this.posY = posY;
		this.posZ = posZ;
		this.fSize = fSize;
		this.mc = mc;
		this.speed = fSize;
		this.foodType = foodType;
		this.gfxPrefix = prefix;
		currentAim = random(2*Math.PI);
		alive = true;
		var seg:MovieClip;
		nutrition = foodType;
		seg = mc.attachMovie(gfxPrefix+"food"+foodType, "dot", 0);
		timer = 0;
		respawnTime = 0;
		if (foodType == 0) {
			nutrition = 1;
			respawnTime = 0;
		}else if (foodType == 99) {
			nutrition = 1;
			respawnTime = 0;
		}else if (foodType == 100) {
			nutrition = 0;
			respawnTime = 3;
		}else if (foodType == 101) {
			nutrition = 0;
			respawnTime = 3;
		} else if (foodType == 102) { // egg
			nutrition = 102;
			respawnTime = 0;
		}
		seg._xscale = fSize;
		seg._yscale = fSize;
		seg._x = posX;
		seg._y = posY;
		// used for shading 
		trans = new Transform(seg);
	}
	function update(dt:Number, camera:Camera3D):Void {
		
		//targeting
		if (!alive) {
			var seg:MovieClip = mc["dot"];
			seg._xscale = 0;
			seg._yscale = 0;
			if (respawnTime>0) {		
				timer += dt;
				if (timer>respawnTime) {
					alive = true;
					timer = 0;
					seg._x = posX;
					seg._y = posY;
					seg._xscale = fSize;
					seg._yscale = fSize;
					//mc._visible = true;
				}
			}
		} else {
			var dir:Number = mc["dot"]._rotation*Math.PI/180;
			headingX = Math.cos(dir);
			headingY = Math.sin(dir);
			
			turnRandom();
				
			posX += speed*Math.cos(currentAim)*dt;
			posY += speed*Math.sin(currentAim)*dt;
			
			var seg:MovieClip = mc["dot"];
			seg._rotation = currentAim*180/Math.PI;
			seg._x = posX;
			seg._y = posY;
		}
		// apply shading 
		trans.colorTransform = this.colorTrans;
	}	
	function turnRandom():Void {
		var temp = random(3);
		if (temp>1.5) {
			currentAim += turnSpeed;
		} else {
			currentAim -= turnSpeed;
		}
	}
}
