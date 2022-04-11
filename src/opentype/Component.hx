package opentype;

typedef Component = {
	glyphIndex:Int,
	xScale:Float,
	scale01:Float,
	scale10:Float,
	yScale:Float,
	dx:Float,
	dy:Float,
	?matchedPoints:Array<Int>,
};
