import flash.geom.ColorTransform;
import flash.geom.Transform;
class Billboard extends GameObject {
	var trans:Transform;
	public function Billboard(billName:String,zDepth:Number,mc:MovieClip) {
		this.posX = this.posY = 0; 
		this.posZ = zDepth;
		this.mc = mc;
		var seg:MovieClip;
		seg = mc.attachMovie(billName, "seg", 0);
		seg._xscale = 100;
		seg._yscale = 100;
		seg._x = posX;
		seg._y = posY;
		// used for shading
		trans = new Transform(seg);
	}
	function update(camera:Camera3D):Void {
		posX = 0;
		posY = 0;
		var seg:MovieClip = mc["seg"];
		seg._x = 0;//posX;
		seg._y = 0;//posY;
		// apply shading 
		trans.colorTransform = this.colorTrans;
	}
}
