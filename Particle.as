import flash.geom.ColorTransform;
import flash.geom.Transform;
class Particle {
	var pNum:Number;
	var particles:Array;
	var pLife:Array;
	var pLifeMax:Number = 5;
	var totalFrame:Number = 50;
	var range:Number = 300;
	public function Particle(pNum:Number) {
		this.pNum = pNum;
		particles = new Array(pNum);
		pLife = new Array(pNum);
		for (var i:Number = 0; i<pNum; i++) {
			_root.createEmptyMovieClip("paricle_"+i, Camera3D.getNextDepth());
			particles[i] = new GameObject();
			var temp:Number = 50+random(range-50);
			particles[i].posZ = -temp;
			particles[i].posX = particles[i].mc["particle"+i]._x=random(Stage.width);
			particles[i].posY = particles[i].mc["particle"+i]._y=random(Stage.height);
			particles[i].mc = eval("paricle_"+i);
			pLife[i] = pLifeMax/pNum*i;
			var seg:MovieClip;
			seg = particles[i].mc.attachMovie("particle", "particle"+i, Camera3D.getNextDepth());
			seg._x = particles[i].posX;
			seg._y = particles[i].posY;
			seg._xscale = 15;
			seg._yscale = 15;
			particles[i].trans = new Transform(seg);
		}
	}
	public function update(dt:Number, camera:Camera3D) {
		for (var i:Number = 0; i<pNum; i++) {
			particles[i].mc["particle"+i].gotoAndStop(int(pLife[i]*totalFrame/pLifeMax));
			particles[i].updateScreenPos(camera);
			pLife[i] += dt;
			if (_root.displayPlayerTarget) {
				_root.background_mc.lineStyle(1, 0xFFFFFF, 128);
				_root.background_mc.moveTo(Stage.width/2, Stage.height/2);
				_root.background_mc.lineTo(particles[i].screenX+camera.screenX, particles[i].screenY+camera.screenY);
			}
			if (pLife[i]>pLifeMax) {
				pLife[i] = 0;
				var temp:Number = 50+random(range-50);
				var temp2:Number = Stage.width/(Stage.height+Stage.width);
				particles[i].posZ = camera.posZ-temp; 
				particles[i].posX = particles[i].mc["particle"+i]._x=(-camera.posX+_xmouse)*(1-temp/camera.focalLength)+ random(4*(range-temp))-2*(range-temp);
				particles[i].posY = particles[i].mc["particle"+i]._y=(-camera.posY+_ymouse)*(1-temp/camera.focalLength)+ random(4*(range-temp))-2*(range-temp);
			}
		}
	}
}
