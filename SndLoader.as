class SndLoader {
	
	var curSndIndex:Number;
	var sounds:Array;
	var filenames:Array;
	
	public function SndLoader() {
		initialize();
	}	
	
	public function initialize():Void {
		curSndIndex = 0;
		sounds = new Array();
		filenames = ["c1_Flow-lvl 0 drone.mp3",
					 "c1_red.mp3",
					 "c1_Flow-lvl 1 drone.mp3",
					 "c1_blue.mp3",
					 //"c1_grow.mp3",
					 "c1_heal.mp3",
 					 "c1_death.mp3",
					 /*"c1_Food-samples-1a.mp3",
					 "c1_Food-samples-1b.mp3",
					 "c1_Food-samples-2a.mp3",
					 "c1_Food-samples-2b.mp3",
					 "c1_Food-samples-3a.mp3",
					 "c1_Food-samples-3b.mp3",
					 "c1_Food-samples-4a.mp3",
					 "c1_Food-samples-4b.mp3",
					 "c1_Food-samples-5a.mp3",
					 "c1_Food-samples-5b.mp3",*/				 
					 "c1_Flow-lvl 2 drone.mp3",
					 "c1_Flow-lvl 3 drone.mp3",
					 "c1_Flow-lvl 4 drone.mp3",
					 "c1_Flow-lvl 5 drone.mp3",
					 "c1_Flow-lvl 6 drone.mp3",
					 "c1_Flow-lvl 7 drone.mp3",
					 "c1_Flow-lvl 8 drone.mp3",
					 "c1_Flow-lvl 9 drone.mp3",
					 "c1_Flow-lvl 10 drone.mp3",
					 "c1_Flow-lvl 11 drone.mp3",
					 "c1_Flow-lvl 12 drone.mp3",
					 "c1_Flow-lvl 13 drone.mp3",
					 "c1_Flow-lvl 14 drone.mp3",
					 "c1_Flow-lvl 15 drone.mp3",
					 "c1_Flow-lvl 16 drone.mp3",
					 "c1_Flow-lvl 17 drone.mp3",
					 "c1_Flow-lvl 18 drone.mp3",
					 "c1_Flow-lvl 19 drone.mp3" ];
		
		sounds = new Array(filenames.length);
		for(var i:Number = 0; i < sounds.length; i++) {
			sounds[i] = new Sound(_root);
		}
		loadNext();
	}
	
	public function update():Void {
		if(sounds[curSndIndex-1].getBytesTotal() == sounds[curSndIndex-1].getBytesLoaded()) {
			loadNext();
		}
	}
	
	private function loadNext():Void {
		if(curSndIndex < filenames.length) {
			trace("loading: " + filenames[curSndIndex]);
			sounds[curSndIndex].loadSound(filenames[curSndIndex], false);
			sounds[curSndIndex].stop();
			sounds[curSndIndex].setVolume(0);
			curSndIndex++;
		}
	}
	
	public function getSound(filename:String):Sound {
		filename = "" + filename + ".mp3";
		var index:Number = -1;
		for(var i:Number = 0; i < filenames.length; i++) {
			if(filename == filenames[i]) {
				index = i;
				break;
			}
		}
		if(index == -1)
			return null;
		else
			return sounds[index];
	}
	
	public static function isLoaded(snd:Sound):Boolean {
		return (snd.getBytesTotal() == snd.getBytesLoaded());
	}
}