import opentype.OpenType;
import opentype.Font;
import haxe.io.Bytes;

using buddy.Should;

class TestPath extends buddy.BuddySuite {
	public function new() {
		describe('TestPath', {
			var fontBytes:Bytes;
			var error:Dynamic;
			var font:Font;

			beforeAll(function(done) {
				OpenType.loadFromFile("fonts/Roboto-Black.ttf", (b) -> {
					fontBytes = b;
					font = OpenType.parse(fontBytes);
					done();
				}, (e) -> {
					error = e;
					done();
				});
			});
			it('should exist a path', {
				font.should.beType(Font);
			});
			// it('Font should have getPath', {
			// 	font.getPath('A', 0, 150, 72);
			// });
		});
	}
}
