import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
class GameObject {
	var mc:MovieClip;
	var posX:Number;
	var posY:Number;
	var posZ:Number;
	var level:Number;
	var screenX:Number;
	var screenY:Number;
	var colorTrans:ColorTransform;
	var colorTrans2:ColorTransform;
	var glowFilter:GlowFilter;
	var blurFilter:BlurFilter;
	var maxBlur:Number;
	var soundVolume:Number;
	var color:XColor;
	var useEffect:Boolean;
	var soundRange:Number = 500;
	var alpha:Number;
	function GameObject() {
		posX = posY=posZ=0;
		screenX = screenY=0;
		maxBlur = 16;
		useEffect = true;
		blurFilter = new BlurFilter(0, 0, 1);
		colorTrans = new ColorTransform();
		colorTrans2 = new ColorTransform();
		glowFilter = new GlowFilter(0xFFFFFF, 1, 16, 16, 1.5, 1, false, false);
		color = new XColor(0xFFFFFF);
		alpha = 1;
	}
	function updateScreenPos(camera:Camera3D):Void {
		applyCamera(camera);
	}
	function applyCamera(camera:Camera3D):Void {
		//var dx = posX - camera.posX;
		//var dy = posY - camera.posY;
		level = Math.round(posZ/GameLevel.zLevelGap);
		// calculate dz and scale for shading, blurring, and sound volume
		var dz:Number = posZ-camera.posZ+camera.zOffset;
		var scaleRatio:Number = camera.focalLength/(camera.focalLength+dz);
		var blurScale:Number = 100*scaleRatio;
		if (Math.abs(dz)<GameLevel.zLevelGap) {
			soundVolume = (GameLevel.zLevelGap-Math.abs(dz))/GameLevel.zLevelGap*100;
			var temp:Number = dist(posX, posY, _root.player.posX, _root.player.posY);
			if (temp<soundRange) {
				soundVolume *= (soundRange-temp)/soundRange;
			} else {
				soundVolume = 0;
			}
		} else {
			soundVolume = 0;
		}

		// recalculate dz and scale taking into account the offset from the camera 
		// this will be used to get the actual on-screen size and position of the objects and camera
		dz = posZ-camera.posZ+camera.zOffset;
		scaleRatio = camera.focalLength/(camera.focalLength+dz);
		mc._xscale = mc._yscale=100*scaleRatio;
		//mc._x = camera.posX*scaleRatio;
		//mc._y = camera.posY*scaleRatio;
		mc._x = camera.posX;
		mc._y = camera.posY;
		//posX = (posX - camera.posX)*scaleRatio + posX;
		//posY = (posY - camera.posY)*scaleRatio + posY;
		
		screenX = posX*scaleRatio;
		screenY = posY*scaleRatio;
		camera.zScaleRatio = scaleRatio;
		//camera.screenX = camera.posX*scaleRatio;
		//camera.screenY = camera.posY*scaleRatio;
		camera.screenX = camera.posX;
		camera.screenY = camera.posY;
		
		if (!Camera3D.inSimWindow(screenX, screenY, camera)) {
			mc._visible = false;
		}else{
			mc._visible = true;
		}
		
		if (useEffect && mc._visible) {
			var dz1:Number = posZ-camera.posZ+camera.zOffset;
			glowFilter.color = color.curColor;
			shadeImage(dz1);
			blurImage(blurScale);
		}
	}
	function blurImage(scale:Number):Void {
		var blur:Number;
		if (mc["seg0"]._xscale<=100) {
			if (scale>=100) {
				blur = 0;
				mc.filters = [glowFilter];
			} else {
				blur = (100-scale)/100;
				blurFilter.blurX = blur*maxBlur;
				blurFilter.blurY = blur*maxBlur;
				mc.filters = [blurFilter, glowFilter];
			}
		} else {
			mc.filters = [];
		}
	}
	function shadeImage(dz:Number):Void {
		var multiplier:Number = 0.3+0.7*(GameLevel.zLevelGap-dz)/GameLevel.zLevelGap;
		colorTrans.alphaMultiplier = Math.min(multiplier, alpha);
		colorTrans2.alphaMultiplier = Math.min(multiplier*0.3, alpha);
		colorTrans.redOffset = colorTrans2.redOffset=-(255-color.getRed());
		colorTrans.greenOffset = colorTrans2.greenOffset=-(255-color.getGreen());
		colorTrans.blueOffset = colorTrans2.blueOffset=-(255-color.getBlue());
	}
	function dist(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		var distance:Number = Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
		return (distance);
	}
}
