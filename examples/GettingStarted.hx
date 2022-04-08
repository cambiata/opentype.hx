import opentype.OpenType;
import opentype.Font;
import haxe.io.Bytes;

function main() {
	OpenType.loadFromFile("../src/test/fonts/arial.ttf", (fontBytes) -> {
		final font:Font = OpenType.parse(fontBytes);
		trace(font);
	}, (e) -> {
		trace(e);
	});
}
