package opentype.tables;

using Lambda;

import haxe.io.Bytes;
import opentype.ContourPoint;

class GlyphTable {
	public function new() {}

	public static function parse(data:Bytes, position = 0, glyphOffsets:Array<Int>, font:Font, lowMemory:Bool):GlyphSet {
		final p = new Parser(data, position);
		final glyph = new GlyphTable();
		return if (lowMemory) {
			throw("Low memory mode not implemented");
			null;
		} else {
			parseGlyfTableAll(data, position, glyphOffsets, font);
		}
	}

	static function parseGlyfTableAll(data:Bytes, start:Int, glyphOffsets:Array<Int>, font:Font) {
		final glyphs = new GlyphSet(font);
		// The last element of the loca table is invalid.
		for (i in 0...glyphOffsets.length - 1) {
			final offset = glyphOffsets[i];
			final nextOffset = glyphOffsets[i + 1];
			if (offset != nextOffset) {
				glyphs.addGlyphLoader(i, GlyphSet.ttfGlyphLoader(font, i, parseGlyph, data, start + offset, buildPath));
			} else {
				glyphs.addGlyphLoader(i, GlyphSet.glyphLoader(font, i));
			}
		}
		return glyphs;
	}

	//------------------------------------------------------------------------------------------------------------
	// Parse a TrueType glyph.
	static function parseGlyph(glyph:Glyph, data:Bytes, start:Int) {
		trace('parseGlyph ========================');
		// trace(glyph);
		// trace(data.length);
		// trace(start);

		// final p = new parse.Parser(data, start);
		final p = new Parser(data, start);
		glyph.numberOfCountours = p.parseShort();
		// trace('number ' + glyph.numberOfCountours);

		glyph._xMin = p.parseShort();
		glyph._yMin = p.parseShort();
		glyph._xMax = p.parseShort();
		glyph._yMax = p.parseShort();

		final flags = [];
		var flag:Int = 0;

		if (glyph.numberOfCountours > 0) {
			final endPointIndices = glyph.endPointIndices = [];
			// trace('endPointInd ' + endPointIndices);
			for (i in 0...glyph.numberOfCountours) {
				final ei = p.parseUShort();
				// trace('ei: ' + ei);
				endPointIndices.push(ei);
			}
			// trace(endPointIndices);
			// trace(glyph.endPointIndices);
			glyph.instructionLength = p.parseUShort();
			glyph.instructions = [];
			for (i in 0...glyph.instructionLength) {
				glyph.instructions.push(p.parseByte());
			}
			// trace(glyph.instructions);
			// trace(glyph.instructions.length);

			final numberOfCoordinates = endPointIndices[endPointIndices.length - 1] + 1;
			// trace('numberOfCoordinates ' + numberOfCoordinates);

			var i = 0;
			while (i < numberOfCoordinates) {
				// trace(i);
				flag = p.parseByte();
				flags.push(flag);
				// If bit 3 is set, we repeat this flag n times, where n is the next byte.
				if ((flag & 8) > 0) {
					final repeatCount = p.parseByte();
					// trace('repeatCount ' + repeatCount);
					for (j in 0...repeatCount) {
						flags.push(flag);
						i += 1;
					}
				}
				i += 1;
			}
			// trace(flags);

			// if (flags.length == numberOfCoordinates)
			// 	throw "Bad flags.";

			if (endPointIndices.length > 0) {
				final points = [];

				// X/Y coordinates are relative to the previous point, except for the first point which is relative to 0,0.
				if (numberOfCoordinates > 0) {
					for (i in 0...numberOfCoordinates) {
						flag = flags[i];
						var onCurve = (flag & 1) != 0;
						var point:ContourPoint = {
							x: 0,
							y: 0,
							onCurve: onCurve,
							lastPointOfContour: endPointIndices.indexOf(i) >= 0
						};
						points.push(point);
					}

					var px = 0;
					for (i in 0...numberOfCoordinates) {
						flag = flags[i];
						points[i].x = parseGlyphCoordinate(p, flag, px, 2, 16);
						px = points[i].x;
					}

					var py = 0;
					for (i in 0...numberOfCoordinates) {
						flag = flags[i];
						points[i].y = parseGlyphCoordinate(p, flag, py, 4, 32);
						py = points[i].y;
					}
				}
				glyph.points = points;
			} else {
				glyph.points = [];
			}

			glyph.points.iter(i -> trace(i));
			//
		} else if (glyph.numberOfCountours == 0) {
			glyph.points = [];
			//
		} else {
			//
			trace('IS COMPOSITE');
			glyph.isComposite = true;
			glyph.points = [];
			glyph.components = [];
			var moreComponents = true;
			var flags = null;
			while (moreComponents) {
				flags = p.parseUShort();
				trace(['moreComponents', flags]);

				var component:opentype.Component = {
					glyphIndex: p.parseUShort(),
					xScale: 1.,
					scale01: .0,
					scale10: .0,
					yScale: 1.,
					dx: 0.,
					dy: 0.,
					matchedPoints: null,
				};

				if ((flags & 1) > 0) {
					// The arguments are words
					if ((flags & 2) > 0) {
						// values are offset
						component.dx = p.parseShort();
						component.dy = p.parseShort();
					} else {
						// values are matched points
						component.matchedPoints = [p.parseUShort(), p.parseUShort()];
					}
				} else {
					// The arguments are bytes
					if ((flags & 2) > 0) {
						// values are offset
						component.dx = p.parseChar();
						component.dy = p.parseChar();
					} else {
						// values are matched points
						component.matchedPoints = [p.parseByte(), p.parseByte()];
					}
				}

				if ((flags & 8) > 0) {
					// We have a scale
					component.xScale = component.yScale = p.parseF2Dot14();
				} else if ((flags & 64) > 0) {
					// We have an X / Y scale
					component.xScale = p.parseF2Dot14();
					component.yScale = p.parseF2Dot14();
				} else if ((flags & 128) > 0) {
					// We have a 2x2 transformation
					component.xScale = p.parseF2Dot14();
					component.scale01 = p.parseF2Dot14();
					component.scale10 = p.parseF2Dot14();
					component.yScale = p.parseF2Dot14();
				}

				glyph.components.push(component);
				// moreComponents = !!(flags & 32);

				moreComponents = (flags & 32) != 0;
			}

			if ((flags & 0x100) != 0) {
				// We have instructions
				trace('instructions');
				glyph.instructionLength = p.parseUShort();
				glyph.instructions = [];
				for (i in 0...glyph.instructionLength) {
					glyph.instructions.push(p.parseByte());
				}
			}

			trace(glyph.components);
		}
	}

	static function buildPath(glyphs, glyph) {
		trace('buildPath --------------------------------');
		trace(glyphs.length);
		trace(glyph);

		if (glyph.isComposite) {
			trace('IS Composite');
			for (j in 0...glyph.components.length) {
				final component:Component = glyph.components[j];
				final componentGlyph:Glyph = glyphs.get(component.glyphIndex);
				// Force the ttfGlyphLoader to parse the glyph.
				componentGlyph.get_path();
				if (componentGlyph.points.length > 0) {
					var transformedPoints;

					// if (component.matchedPoints === undefined) {
					// 	// component positioned by offset
					// 	transformedPoints = transformPoints(componentGlyph.points, component);
					// } else {
					// 	// component positioned by matched points
					// 	if ((component.matchedPoints[0] > glyph.points.length - 1) ||
					// 		(component.matchedPoints[1] > componentGlyph.points.length - 1)) {
					// 		throw Error('Matched points out of range in ' + glyph.name);
					// 	}
					// 	const firstPt = glyph.points[component.matchedPoints[0]];
					// 	let secondPt = componentGlyph.points[component.matchedPoints[1]];
					// 	const transform = {
					// 		xScale: component.xScale, scale01: component.scale01,
					// 		scale10: component.scale10, yScale: component.yScale,
					// 		dx: 0, dy: 0
					// 	};
					// 	secondPt = transformPoints([secondPt], transform)[0];
					// 	transform.dx = firstPt.x - secondPt.x;
					// 	transform.dy = firstPt.y - secondPt.y;
					// 	transformedPoints = transformPoints(componentGlyph.points, transform);
					// }
					// glyph.points = glyph.points.concat(transformedPoints);
				}
			}
		}

		return getPath(glyph.points);
	}

	// Convert the TrueType glyph outline to a Path.
	static function getPath(points) {
		/*
			const p = new Path();
			if (!points) {
				return p;
			}

			const contours = getContours(points);

			for (let contourIndex = 0; contourIndex < contours.length; ++contourIndex) {
				const contour = contours[contourIndex];

				let prev = null;
				let curr = contour[contour.length - 1];
				let next = contour[0];

				if (curr.onCurve) {
					p.moveTo(curr.x, curr.y);
				} else {
					if (next.onCurve) {
						p.moveTo(next.x, next.y);
					} else {
						// If both first and last points are off-curve, start at their middle.
						const start = { x: (curr.x + next.x) * 0.5, y: (curr.y + next.y) * 0.5 };
						p.moveTo(start.x, start.y);
					}
				}

				for (let i = 0; i < contour.length; ++i) {
					prev = curr;
					curr = next;
					next = contour[(i + 1) % contour.length];

					if (curr.onCurve) {
						// This is a straight line.
						p.lineTo(curr.x, curr.y);
					} else {
						let prev2 = prev;
						let next2 = next;

						if (!prev.onCurve) {
							prev2 = { x: (curr.x + prev.x) * 0.5, y: (curr.y + prev.y) * 0.5 };
						}

						if (!next.onCurve) {
							next2 = { x: (curr.x + next.x) * 0.5, y: (curr.y + next.y) * 0.5 };
						}

						p.quadraticCurveTo(curr.x, curr.y, next2.x, next2.y);
					}
				}

				p.closePath();
			}
			return p;
		 */

		return null;
	}

	// Parse the coordinate data for a glyph.
	static function parseGlyphCoordinate(p, flag, previousValue, shortVectorBitMask, sameBitMask) {
		var v;
		if ((flag & shortVectorBitMask) > 0) {
			// The coordinate is 1 byte long.
			v = p.parseByte();
			// The `same` bit is re-used for short values to signify the sign of the value.
			if ((flag & sameBitMask) == 0) {
				v = -v;
			}

			v = previousValue + v;
		} else {
			//  The coordinate is 2 bytes long.
			// If the `same` bit is set, the coordinate is the same as the previous coordinate.
			if ((flag & sameBitMask) > 0) {
				v = previousValue;
			} else {
				// Parse the coordinate as a signed 16-bit delta value.
				v = previousValue + p.parseShort();
			}
		}

		return v;
	}
}
