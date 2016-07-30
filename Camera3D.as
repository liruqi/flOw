class Camera3D extends GameObject {
	var targetX:Number;
	var targetY:Number;
	var targetZ:Number;
	var focalLength:Number;
	var zOffset:Number;
	var zScaleRatio:Number;
	// used for shaking the camera
	var shaking:Boolean;
	var shakeTimePassed:Number;
	var shakeDelay:Number;
	var shakeMax:Number;
	static var nextDepth:Number = 0;
	var toTarget:Boolean;
	function Camera3D() {
		targetX = targetY = targetZ = 0;
		focalLength = 400;
		zOffset = 0;
		zScaleRatio = 1;
		shaking = false;
		shakeTimePassed = 0;
		shakeDelay = 0.1;
		// larger number = faster shaking
		toTarget = false;
	}
	function updateMovement(dt:Number):Void {
		var speed:Number = _root.player.currentSpeed;
		if(toTarget) {
			if(Math.abs(targetX - posX) < speed*dt*0.5 && Math.abs(targetY - posY) < speed*dt*0.5) {
				posX = targetX;
				posY = targetY;
			} else {
				var aimAngle:Number = Math.atan2((targetY-posY), (targetX-posX));
				posX += speed*Math.cos(aimAngle)*dt;
				posY += speed*Math.sin(aimAngle)*dt;
			}
		}
	}
	function shake(shakeMagnitude:Number):Void {
		shaking = true;
		if (shakeMagnitude<=0) {
			// set to default of 4
			shakeMax = 4;
		} else {
			shakeMax = shakeMagnitude;
		}
		shakeMax = 20;
	}
	function updateShake(dt:Number):Void {
		if (!shaking) {
			zOffset += (0-zOffset)*dt;
		} else {
			shakeTimePassed += dt;
			zOffset -= shakeMax*dt/shakeDelay;
			if (shakeTimePassed>shakeDelay) {
				shakeTimePassed = 0;
				shaking = false;
			}
		}
	}
	static function inWindow(xx, yy, camera:Camera3D):Boolean {
		if ((Math.abs(xx+camera.screenX-Stage.width*0.5)>Stage.width*0.5) || (Math.abs(yy+camera.screenY-Stage.height*0.5)>Stage.height*0.5)) {
			return (false);
		} else {
			return (true);
		}
	}
	static function inSimWindow(xx, yy, camera:Camera3D):Boolean {
		if ((Math.abs(xx+camera.screenX-Stage.width*0.5)>Stage.width) || (Math.abs(yy+camera.screenY-Stage.height*0.5)>Stage.height)) {
			return (false);
		} else {
			return (true);
		}
	}
	static function getNextDepth():Number {
		return nextDepth++;
	}
	static function drawRectangle(target_mc:MovieClip, boxWidth:Number, boxHeight:Number, fillColor:Number, fillAlpha:Number):Void {
		with (target_mc) {
			beginFill(fillColor, fillAlpha);
			moveTo(0, 0);
			lineTo(boxWidth, 0);
			lineTo(boxWidth, boxHeight);
			lineTo(0, boxHeight);
			lineTo(0, 0);
			endFill();
		}
	}
}
