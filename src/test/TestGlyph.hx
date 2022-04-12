import opentype.Glyph;
import opentype.OpenType;
import opentype.Font;
import opentype.Path;
import haxe.io.Bytes;

using buddy.Should;

class TestGlyph extends buddy.BuddySuite {
	public function new() {
		describe('TestGlyph', {
			var fontBytes:Bytes;
			var error:Dynamic;
			var font:Font;
			var glyph:Glyph;

			beforeAll(function(done) {
				OpenType.loadFromFile("fonts/Roboto-Black.ttf", (b) -> {
					fontBytes = b;
					font = OpenType.parse(fontBytes);
					glyph = font.charToGlyph('A');
					//
					done();
				}, (e) -> {
					error = e;
					done();
				});
			});

			it('glyph properties', {
				// trace(glyph);
				font.glyphs.length.should.be(1294);

				// final glyph = font.charToGlyph('A');
				// trace(glyph);
				// trace(glyph.path);
				// trace(font.glyphs);
			});

			it('lazily loads xMin', {
				glyph.xMin.should.be(-3);
			});

			it('lazily loads xMax', {
				glyph.xMax.should.be(1399);
			});

			it('lazily loads yMin', {
				glyph.yMin.should.be(0);
			});

			it('lazily loads yMax', {
				glyph.yMax.should.be(1456);
			});

			it('lazily loads numberOfContours', {
				glyph.numberOfContours.should.be(2);
			});

			it('glyph path', {
				final path:Path = glyph.path;
				path.commands.length.should.be(15);
				path.commands[0].x.should.be(1022);
				path.commands[0].y.should.be(0);
				path.commands[0].type.should.be('M');
				path.commands[1].x.should.be(937);
				path.commands[1].y.should.be(272);
				path.commands[1].type.should.be('L');
				path.commands[14].type.should.be('Z');
				#if sys
				sys.io.File.saveContent('testA.svg', path.toSvg());
				#end
			});
		});

		describe('font path', {
			var font:Font;
			var error:Dynamic;
			beforeAll(function(done) {
				OpenType.loadFromFile("fonts/Roboto-Black.ttf", (b) -> {
					font = OpenType.parse(b);
					done();
				}, (e) -> {
					error = e;
					done();
				});
			});

			it('font.getPath', {
				final path = font.getPath('Abc', 0, 150, 72);
				trace(path);
				var svg = path.toSvg();
				#if sys
				sys.io.File.saveContent('test.svg', svg);
				#end
			});
		});

		/*
			describe('TrueType bounding box', {
				var trueTypeFont:Font;
				var error:Dynamic;
				beforeAll(function(done) {
					OpenType.loadFromFile("fonts/Roboto-Black.ttf", (b) -> {
						trueTypeFont = OpenType.parse(b);
						done();
					}, (e) -> {
						error = e;
						done();
					});
				});
				it('trueTypeFont should exist', {
					trueTypeFont.should.not.be(null);
				});

				it('calculates a box for a linear shape', {
					final glyph = trueTypeFont.charToGlyph('A');
					final box = glyph.getBoundingBox();
					box.x1.should.be(-3);
					box.y1.should.be(0);
					box.x2.should.be(1399);
					box.y2.should.be(1456);
				});

				it('calculates a box for a quadratic shape', {
					final glyph = trueTypeFont.charToGlyph('Q');
					final box = glyph.getBoundingBox();
					box.x1.should.be(72);
					box.y1.should.be(-266);
					box.x2.should.be(1345);
					box.y2.should.be(1476);
				});
				it('test path', {
					final glyph = trueTypeFont.charToGlyph('Q');
					final path = glyph.path;
					final pathData = path.toPathData();
					final svg = path.toSvg();
					trace(svg);
				});
			});
		 */

		// describe('OpenType bounding box', {
		// 	var openTypeFont:Font;
		// 	var error:Dynamic;
		// 	beforeAll(function(done) {
		// 		OpenType.loadFromFile('fonts/FiraSansMedium.woff', (b) -> {
		// 			openTypeFont = OpenType.parse(b);
		// 			trace(openTypeFont);
		// 			done();
		// 		}, (e) -> {
		// 			error = e;
		// 			done();
		// 		});
		// 	});
		// 	it('openTypeFont should exist', {
		// 		openTypeFont.should.not.be(null);
		// 		trace(openTypeFont);
		// 	});
		// });
	}
}
