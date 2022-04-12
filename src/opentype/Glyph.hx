package opentype;

import opentype.ContourPoint;

class Glyph {
	public function new(options:GlyphOptions) {
		this.index = options.index > 0 ? options.index : 0;

		// These three values cannot be deferred for memory optimization:
		this.name = options.name;
		this.unicode = options.unicode > 0 ? options.unicode : 0;
		this.unicodes = options.unicodes != null ? options.unicodes : options.unicode > 0 ? [options.unicode] : [];
	}

	public var name:String;
	public var unicode:Int;
	public var unicodes:Array<Int>;

	public var index:Int;
	public var advanceWidth:Int;
	public var leftSideBearing:Int;

	/**
	 * @param {number}
	 */
	public function addUnicode(unicode:Int) {
		if (unicodes.length == 0) {
			this.unicode = unicode;
		}

		unicodes.push(unicode);
	};

	public var path(get, null):Path;

	dynamic public function get_path():Path
		return null;

	//----------------------------------------------------------------------------------
	public var numberOfContours(default, null):Int = 0;

	var _xMin:Int;
	var _xMax:Int;
	var _yMin:Int;
	var _yMax:Int;

	public var endPointIndices(default, null):Array<Int> = [];
	public var instructionLength(default, null):Int = 0;
	public var instructions(default, null):Array<Int> = [];
	public var points(default, null):Array<ContourPoint> = [];
	public var isComposite(default, null):Bool = false;
	public var components(default, null):Array<Component> = [];

	//--------------------------------------------------
	public var xMin(get, null):Float;

	dynamic public function get_xMin():Float
		return null;

	public var xMax(get, null):Float;

	dynamic public function get_xMax():Float
		return null;

	public var yMin(get, null):Float;

	dynamic public function get_yMin():Float
		return null;

	public var yMax(get, null):Float;

	dynamic public function get_yMax():Float
		return null;

	public function getBoundingBox()
		return this.path.getBoundingBox();

	/**
	 * Convert the glyph to a Path we can draw on a drawing context.
	 * @param  {number} [x=0] - Horizontal position of the beginning of the text.
	 * @param  {number} [y=0] - Vertical position of the *baseline* of the text.
	 * @param  {number} [fontSize=72] - Font size in pixels. We scale the glyph units by `1 / unitsPerEm * fontSize`.
	 * @param  {Object=} options - xScale, yScale to stretch the glyph.
	 * @param  {opentype.Font} if hinting is to be used, the font
	 * @return {opentype.Path}
	 */
	public function getPath(x:Float, y:Float, fontSize:Float, options:Dynamic, font:Font) {
		x = x != null ? x : 0;
		y = y != null ? y : 0;
		fontSize = fontSize != null ? fontSize : 72;
		var commands = [];
		var hPoints = null;
		if (!options)
			options = {};
		var xScale = options.xScale;
		var yScale = options.yScale;

		// if (options.hinting != null && font != null && font.hinting != null) {
		// 	// in case of hinting, the hinting engine takes care
		// 	// of scaling the points (not the path) before hinting.
		// 	hPoints = this.path != null && font.hinting.exec(this, fontSize);
		// 	// in case the hinting engine failed hPoints is undefined
		// 	// and thus reverts to plain rending
		// }

		// if (hPoints != null) {
		// 	// // Call font.hinting.getCommands instead of `glyf.getPath(hPoints).commands` to avoid a circular dependency
		// 	// commands = font.hinting.getCommands(hPoints);
		// 	// x = Math.round(x);
		// 	// y = Math.round(y);
		// 	// // TODO in case of hinting xyScaling is not yet supported
		// 	// xScale = yScale = 1;
		// } else {
		commands = this.path.commands;

		var upe = this.path.unitsPerEm != null ? this.path.unitsPerEm : 1000;

		final scale = 1 / upe * fontSize;
		if (xScale == null)
			xScale = scale;
		if (yScale == null)
			yScale = scale;
		// }

		final p = new Path();
		for (cmd in commands) {
			if (cmd.type == 'M') {
				p.moveTo(x + (cmd.x * xScale), y + (-cmd.y * yScale));
			} else if (cmd.type == 'L') {
				p.lineTo(x + (cmd.x * xScale), y + (-cmd.y * yScale));
			} else if (cmd.type == 'Q') {
				p.quadraticCurveTo(x + (cmd.x1 * xScale), y + (-cmd.y1 * yScale), x + (cmd.x * xScale), y + (-cmd.y * yScale));
			} else if (cmd.type == 'C') {
				p.curveTo(x
					+ (cmd.x1 * xScale), y
					+ (-cmd.y1 * yScale), x
					+ (cmd.x2 * xScale), y
					+ (-cmd.y2 * yScale), x
					+ (cmd.x * xScale),
					y
					+ (-cmd.y * yScale));
			} else if (cmd.type == 'Z') {
				p.closePath();
			}
		}

		return p;
	};
}

@:structInit
class GlyphOptions {
	public function new(?name:String, ?index:Int, ?unicode:Int, ?advanceWidth:Int, ?path:Path) {
		this.name = name;
		this.index = index;
		this.unicode = unicode;
		this.advanceWidth = advanceWidth;
		this.path = path;
	}

	public var index:Int;
	public var name:String;
	public var unicode:Int;
	public var unicodes:Array<Int>;
	public var xMin:Int;
	public var yMin:Int;
	public var xMax:Int;
	public var yMax:Int;
	public var advanceWidth:Int;
	public var path:Path;
}
