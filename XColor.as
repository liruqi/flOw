class XColor {
	
	var defaultColor:Number;
	var baseColor:Number;
	var targetColor:Number;
	var curColor:Number;
	
	var bias:Number;
	
	function XColor(base:Number) {
		defaultColor = base;
		baseColor = base;
		targetColor = base;
		curColor = base;
		bias = 1;
	}
	
	function copy(color:XColor):Void {
		this.defaultColor = color.defaultColor;
		this.baseColor = color.baseColor;
		this.targetColor = color.targetColor;
		this.curColor = color.curColor;
	}
	
	function setBias(bias:Number):Void {
		var red:Number = RED(baseColor) * bias + RED(targetColor) * (1 - bias);
		var green:Number = GREEN(baseColor) * bias + GREEN(targetColor) * (1 - bias);
		var blue:Number = BLUE(baseColor) * bias + BLUE(targetColor) * (1 - bias);
		
		curColor = RGB(red, green, blue);	
		this.bias = bias;
	}
	
	// Included for convenience. Most things will only care about getting the RGB from the current color
	function getRed():Number	{ return RED(curColor); }
	function getGreen():Number	{ return GREEN(curColor); }
	function getBlue():Number	{ return BLUE(curColor); }
	
	// Helper functions
	static function RED(rgb:Number):Number 		{ return (rgb & 0x00FF0000) >> 16; }
	static function GREEN(rgb:Number):Number 	{ return (rgb & 0x0000FF00) >> 8; }
	static function BLUE(rgb:Number):Number		{ return (rgb & 0x000000FF); }
	static function RGB(r:Number, g:Number, b:Number):Number {
		return ((r << 16) | (g << 8) | b);
	}
}