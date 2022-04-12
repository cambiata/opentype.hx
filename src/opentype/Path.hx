package opentype;

using Std;
using Lambda;

class Path {
	public function new() {}

	public var commands(default, null):Array<Dynamic> = [];
	public var fill(default, null):String = 'black';
	public var stroke(default, null):String = null;
	public var strokeWidth(default, null):Float = 1;
	public var unitsPerEm(default, null):Int = 0;

	public function moveTo(x:Float, y:Float) {
		this.commands.push({
			type: 'M',
			x: x,
			y: y
		});
	}

	public function lineTo(x:Float, y:Float) {
		this.commands.push({
			type: 'L',
			x: x,
			y: y
		});
	};

	public function curveTo(x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float) {
		this.commands.push({
			type: 'Q',
			x1: x1,
			y1: y1,
			x: x,
			y: y
		});
	}

	public function bezierCurveTo(x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float)
		return this.curveTo(x1, y1, x2, y2, x, y);

	public function quadTo(x1:Float, y1:Float, x:Float, y:Float) {
		this.commands.push({
			type: 'Q',
			x1: x1,
			y1: y1,
			x: x,
			y: y
		});
	};

	public function quadraticCurveTo(x1:Float, y1:Float, x:Float, y:Float)
		return this.quadTo(x1, y1, x, y);

	public function close() {
		this.commands.push({
			type: 'Z'
		});
	}

	public function closePath()
		return this.close();

	public function getBoundingBox() {
		final box = new BoundingBox();
		var startX = .0;
		var startY = .0;
		var prevX = .0;
		var prevY = .0;
		for (cmd in this.commands) {
			switch (cmd.type) {
				case 'M':
					box.addPoint(cmd.x, cmd.y);
					startX = prevX = cmd.x;
					startY = prevY = cmd.y;
				case 'L':
					box.addPoint(cmd.x, cmd.y);
					prevX = cmd.x;
					prevY = cmd.y;
				case 'Q':
					box.addQuad(prevX, prevY, cmd.x1, cmd.y1, cmd.x, cmd.y);
					prevX = cmd.x;
					prevY = cmd.y;
				case 'C':
					box.addBezier(prevX, prevY, cmd.x1, cmd.y1, cmd.x2, cmd.y2, cmd.x, cmd.y);
					prevX = cmd.x;
					prevY = cmd.y;
				case 'Z':
					prevX = startX;
					prevY = startY;
				default:
					throw 'Unexpected path command ' + cmd.type;
			}
		}
		if (box.isEmpty()) {
			box.addPoint(0, 0);
		}
		return box;
	};

	/**
	 * Add the given path or list of commands to the commands of this path.
	 * @param  {Array} pathOrCommands - another opentype.Path, an opentype.BoundingBox, or an array of commands.
	 */
	public function extendWithCommands(commands) {
		// if (pathOrCommands.commands) {
		//     pathOrCommands = pathOrCommands.commands;
		// } else if (pathOrCommands instanceof BoundingBox) {
		//     const box = pathOrCommands;
		//     this.moveTo(box.x1, box.y1);
		//     this.lineTo(box.x2, box.y1);
		//     this.lineTo(box.x2, box.y2);
		//     this.lineTo(box.x1, box.y2);
		//     this.close();
		//     return;
		// }
		this.commands = this.commands.concat(commands);
	};

	public function extendWithPath(path:Path) {
		this.commands = this.commands.concat(path.commands);
	}

	//-------------------------------------------------------------------

	public function toPathData(decimalPlaces:Int = 2):String {
		function floatToString(v:Float) {
			if (Math.round(v) == v) {
				return '' + Math.round(v);
			}
			v *= Math.pow(10, decimalPlaces);
			return '' + Math.round(v) / Math.pow(10, decimalPlaces);
		}

		function packValues(arguments:Array<Float>) {
			var s = '';
			for (i => v in arguments) {
				if (v >= 0 && i > 0) {
					s += ' ';
				}
				s += floatToString(v);
			}
			return s;
		}

		var d = '';
		for (cmd in this.commands) {
			if (cmd.type == 'M') {
				d += 'M' + packValues([cmd.x, cmd.y]);
			} else if (cmd.type == 'L') {
				d += 'L' + packValues([cmd.x, cmd.y]);
			} else if (cmd.type == 'C') {
				d += 'C' + packValues([cmd.x1, cmd.y1, cmd.x2, cmd.y2, cmd.x, cmd.y]);
			} else if (cmd.type == 'Q') {
				d += 'Q' + packValues([cmd.x1, cmd.y1, cmd.x, cmd.y]);
			} else if (cmd.type == 'Z') {
				d += 'Z';
			}
		}

		return d;
	}

	public function toSvg(decimalPlaces:Int = 2):String {
		var svg = '<svg><path d="';
		svg += this.toPathData(decimalPlaces);
		svg += '"';
		if (this.fill != null && this.fill != 'black') {
			if (this.fill == null) {
				svg += ' fill="none"';
			} else {
				svg += ' fill="' + this.fill + '"';
			}
		}
		if (this.stroke != null) {
			svg += ' stroke="' + this.stroke + '" stroke-width="' + this.strokeWidth + '"';
		}
		svg += '/></svg>';
		return svg;
	}

	#if js
	public function draw(ctx:js.html.CanvasRenderingContext2D) {
		ctx.beginPath();
		for (cmd in this.commands) {
			if (cmd.type == 'M') {
				ctx.moveTo(cmd.x, cmd.y);
			} else if (cmd.type == 'L') {
				ctx.lineTo(cmd.x, cmd.y);
			} else if (cmd.type == 'C') {
				ctx.bezierCurveTo(cmd.x1, cmd.y1, cmd.x2, cmd.y2, cmd.x, cmd.y);
			} else if (cmd.type == 'Q') {
				ctx.quadraticCurveTo(cmd.x1, cmd.y1, cmd.x, cmd.y);
			} else if (cmd.type == 'Z') {
				ctx.closePath();
			}
		}

		if (this.fill != null) {
			ctx.fillStyle = this.fill;
			ctx.fill();
		}

		if (this.stroke != null) {
			ctx.strokeStyle = this.stroke;
			ctx.lineWidth = this.strokeWidth;
			ctx.stroke();
		}
	};
	#end
}
