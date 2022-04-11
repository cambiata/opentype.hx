import opentype.Glyph;
import opentype.OpenType;
import opentype.Font;
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
				OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
					fontBytes = b;
					font = OpenType.parse(fontBytes);

					//
					done();
				}, (e) -> {
					error = e;
					done();
				});
			});

			it('glyph properties', {
				// trace(glyph);
				font.glyphs.length.should.be(251);

				final glyph = font.charToGlyph('Å');
				trace(glyph);
				trace(glyph.path);
				// trace(font.glyphs);
			});

			// it('lazily loads xMin', {
			// 	glyph.xMin.should.be(-3);
			// });
			// it('Font should have getPath', {
			// 	font.getPath('A', 0, 150, 72);
			// });
		});
	}
}
