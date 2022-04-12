import opentype.Bidi;
import opentype.Tokenizer;

using buddy.Should;
using StringTools;

class TestTokenizer extends buddy.BuddySuite {
	public function new() {
		describe('TestTokenizer', {
			var tokenizer:Tokenizer;
			beforeAll({
				tokenizer = new Tokenizer();
			});
			it('should map some text to a list of tokens', function() {
				final tokens = tokenizer.tokenize('AB');
				trace(tokens);
				tokens[0].char.should.be('A');
				tokens[1].char.should.be('B');
			});
		});

		describe('StateModifier', {
			var tokenizer:Tokenizer;
			beforeAll({
				tokenizer = new Tokenizer();
			});
			it('should register and apply a state modifier to a token or more', {
				final isChar = (token:Token) -> {
					final char = token.char;
					final isC = (char != null && char.length == 1);
					trace('run isChar ' + token + ' ' + isC);
				}

				final charToCodePoint = (token:Token) -> token.char.charCodeAt(0);
				tokenizer.registerModifier('charToCodePoint', isChar, charToCodePoint);
				final tokens = tokenizer.tokenize('Jello World');
				final jToken:Token = tokens[0];
				trace(jToken);
			});
		});
	}
}
