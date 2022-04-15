import opentype.Font;
import opentype.Bidi;
import opentype.Tokenizer;
import opentype.Font;
import opentype.OpenType;

using buddy.Should;
using StringTools;
using opentype.utils.CharUtils;
using Lambda;

class TestBidi extends buddy.BuddySuite {
	public function new() {
		describe('Test opentype.Bidi', {
			var latinFont:Font;
			var arabicFont:Font;
			var bidiFira:Bidi;
			var bidiScheherazade:Bidi;
			var arabicTokenizer:Tokenizer;
			var error:Dynamic;
			beforeAll(done -> {
				OpenType.loadFromFile('src/test/fonts/Scheherazade-Bold.ttf', bytes -> {
					arabicFont = OpenType.parse(bytes);
					trace(arabicFont);
					done();
				}, e -> {
					error = e;
					throw error;
					done();
				});
				bidiScheherazade = new Bidi();
				trace(bidiScheherazade);
				bidiScheherazade.registerModifier('glyphIndex', null, (token:Token, contextParams:ContextParams) -> arabicFont.charToGlyphIndex(token.char));

				final requiredArabicFeatures = [
					{
						script: 'arab',
						tags: ['init', 'medi', 'fina', 'rlig']
					}
				];

				bidiScheherazade.applyFeatures(arabicFont, requiredArabicFeatures);
			});
		});
	}
}
