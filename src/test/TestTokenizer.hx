import opentype.Bidi;
import opentype.Tokenizer;

using buddy.Should;
using StringTools;
using opentype.utils.CharUtils;
using Lambda;

class TestTokenizer extends buddy.BuddySuite {
	public function new() {
		describe('tokenize', {
			var tokenizer:Tokenizer;
			beforeAll({
				tokenizer = new Tokenizer();
			});
			it('should map some text to a list of tokens', function() {
				final tokens = tokenizer.tokenize('AB');
				tokens[0].char.should.be('A');
				tokens[1].char.should.be('B');
			});
		});

		describe('tokenizer events', {
			it('should dispatch events start, next, newToken and end', {
				var start = false;
				var end = false;
				var chars = '';
				var tokens = [];
				final tokenizerEvents = new Tokenizer({
					start: () -> {
						// trace('Helooooooo from START event');
						start = true;
					},
					next: (contextParams:ContextParams) -> {
						// trace('Hellllooo from NEXT event');
						chars += contextParams.current;
					},
					end: (args:Dynamic) -> {
						// trace('Helllooo from END event');
						end = true;
					},
					newToken: (token, contextParams) -> tokens.push(token),
				});
				tokenizerEvents.tokenize('AB');
				start.should.be(true);
				end.should.be(true);
				chars.should.be('AB');
				tokens.length.should.be(2);
			});
		});

		describe('Test unicode', {
			it('try unicode charCodeAt for icons', {
				final icons = '☃★♲';
				icons.charCodeAt(0).should.be(9731);
				icons.charCodeAt(1).should.be(9733);
				icons.charCodeAt(2).should.be(9842);
			});
		});

		describe('StateModifier', {
			var tokenizer:Tokenizer;
			beforeAll({
				tokenizer = new Tokenizer();
			});
			it('should register and apply a state modifier to a token or more', {
				// condition method
				final isChar:Token->ContextParams->Bool = (token:Token, contextParams:ContextParams) -> {
					final char = token.char;
					final isC:Bool = (char != null && char.length == 1);
					return isC;
				}

				// modifyer method
				final charToCodePoint:Token->ContextParams->Dynamic = (token:Token, contextParams:ContextParams) -> token.char.charCodeAt(0);

				tokenizer.registerModifier('charToCodePoint', isChar, charToCodePoint);

				final tokens = tokenizer.tokenize('Jello world');
				final jToken:Token = tokens[0];
				jToken.state.charToCodePoint.should.be(74);
				jToken.activeState.key.should.be('charToCodePoint');
				jToken.activeState.value.should.be(74);
			});
		});

		describe('registerContextChecker', {
			var tokenizerContextual:Tokenizer = null;
			var text = 'Hello World';
			var wordStartIndexes = [];
			var wordEndOffsets = [];
			beforeAll({
				final onContextStart = (contextName, startIndex) -> {
					if (contextName == 'word')
						wordStartIndexes.push(startIndex);
				};

				final onContextEnd = (contextName, range) -> {
					if (contextName == 'word')
						wordEndOffsets.push(range.endOffset);
				};

				tokenizerContextual = new Tokenizer({
					contextStart: onContextStart,
					contextEnd: onContextEnd
				});

				function wordStartCheck(contextParams:ContextParams):Bool {
					final char = contextParams.current;
					final prevChar = contextParams.get(-1);
					final check = ((!char.isWhiteSpace() && prevChar.isWhiteSpace()) || prevChar == null && !char.isWhiteSpace());
					return check;
				}

				function wordEndCheck(contextParams:ContextParams):Bool {
					final nextChar = contextParams.get(1);
					final check = (nextChar.isWhiteSpace() || nextChar == null);
					return check;
				}

				function spaceStartCheck(contextParams:ContextParams) {
					return contextParams.current.isWhiteSpace();
				}

				function spaceEndCheck(contextParams:ContextParams) {
					return !contextParams.get(1).isWhiteSpace();
				}

				tokenizerContextual.registerContextChecker('word', wordStartCheck, wordEndCheck);
				tokenizerContextual.registerContextChecker('whitespace', spaceStartCheck, spaceEndCheck);
				tokenizerContextual.tokenize(text);
			});

			it('should dispatch contextual event contextStart and contextEnd', {
				wordStartIndexes.should.containExactly([0, 6]);
				wordEndOffsets.should.containExactly([5, 5]);
			});

			it('should retrieve found ranges of a registered context (word)', {
				final whitespaceRanges = tokenizerContextual.getContextRanges('whitespace');
				var whiteSpacesCount = 0;
				whitespaceRanges.iter(range -> {
					whiteSpacesCount += tokenizerContextual.getRangeTokens(range).length;
				});
				whiteSpacesCount.should.be(1);

				var wordRanges = tokenizerContextual.getContextRanges('word');
				var words = wordRanges.map(range -> {
					final tokens = tokenizerContextual.getRangeTokens(range);
					return tokens.map(token -> token.char).join('');
				});
				words.should.containExactly(['Hello', 'World']);
			});
		});

		describe('insert, delete, and replace a token or a range of tokens', {
			var tokens = [];
			var tokenizer;
			beforeEach(function() {
				// trace('beforeEach');
				tokenizer = new Tokenizer();

				function aanStartCheck(contextParams:ContextParams) {
					final char = contextParams.current;
					final prevChar = contextParams.get(-1);
					final a = (char.toLowerCase() == 'a' && (prevChar == null || prevChar.isWhiteSpace()));
					return a;
				}

				function aanEndCheck(contextParams:ContextParams) {
					final char = contextParams.current;
					final nextChar = contextParams.get(1);
					return ((char.toLowerCase() == 'a' && nextChar.isWhiteSpace()) || (char == 'n' && nextChar.isWhiteSpace()));
				}
				tokenizer.registerContextChecker('Aan', aanStartCheck, aanEndCheck);

				// function arabicWordStartCheck(contextParams:ContextParams) {
				// 	final char = contextParams.current;
				// 	final prevChar = contextParams.get(-1);
				// 	return ((char.isArabicChar() && prevChar.isWhiteSpace()) || (char.isArabicChar() && prevChar == null));
				// }

				// function arabicWordEndCheck(contextParams:ContextParams) {
				// 	final char = contextParams.current;
				// 	final nextChar = contextParams.get(1);
				// 	return ((char.isArabicChar() && nextChar.isWhiteSpace()) || (char.isArabicChar() && nextChar == null));
				// }
				// tokenizer.registerContextChecker('arabicWord', arabicWordStartCheck, arabicWordEndCheck);
				tokens = tokenizer.tokenize('B a voice not an echo');
			});

			function getAan() {
				final aanRanges = tokenizer.getContextRanges('Aan');
				final aanTokens = aanRanges.map(range -> tokenizer.getRangeTokens(range));
				return aanTokens.map(tokens -> tokens.map(token -> token.char).join(''));
			}

			it('should insert a token or more at a specified index', {
				tokenizer.insertToken([new Token('e')], 1);
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be('Be a voice not an echo');
				getAan().should.containExactly(['a', 'an']);
			});

			it('should delete a token at a specific index', {
				tokenizer.removeToken(0); // [0:B] a voice not an echo
				tokenizer.removeToken(0); // [0: ]a voice not an echo
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be('a voice not an echo');
				getAan().should.containExactly(['a', 'an']);
			});

			it('should remove a range of tokens', {
				tokenizer.removeRange(9); // ' not an echo'
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be('B a voice');
				getAan().should.containExactly(['a']);
			});

			it('should replace a token with another token', {
				tokenizer.replaceToken(0, new Token('ß')); // B
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be('ß a voice not an echo');
				getAan().should.containExactly(['a', 'an']);
			});

			it('should replace a range of tokens with tokens list', {
				var rangesBefore = tokenizer.getContextRanges('Aan');
				rangesBefore.iter(range -> {
					var startIndex = range.startIndex;
					var endOffset = range.endOffset;
					var newTokens = tokenizer.getRangeTokens(range).map(r -> new Token('…'));
					tokenizer.replaceRange(startIndex, endOffset, newTokens); // null => end
				});
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be('B … voice not …… echo');
				getAan().should.containExactly([]);
				// assert.equal(quote, 'B … voice not …… echo');
				// assert.deepEqual(getAan(), [], 'make sure to update contexts ranges after insert, delete, and replace!');
			});
			it('should compose a set of operations', {
				// input: 'B a voice not an echo'
				tokenizer.composeRUD([
					['insertToken', "Don't ".split('').map(c -> new Token(c)), 0], // 'Don't B a voice not an echo'
					['replaceToken', 6, new Token('b')], // 'Don't b a voice not an echo'
					['insertToken', [new Token('e')], 7], // 'Don't be a voice not an echo'
					[
						'replaceRange',
						11,
						null,
						"follower be a student!".split('').map(c -> new Token(c))
					], // 'Don't be a follower be a student!'
					['removeToken', 32]
				]);
				final quote = tokenizer.tokens.map(t -> t.char).join('');
				quote.should.be("Don't be a follower be a student");
				getAan().should.containExactly(['a', 'a']);
			});
		});

		describe('test opentype.utils.CharUtils', {
			it('regex should match ', {
				'a'.isLatinChar().should.be(true);
				'å'.isLatinChar().should.be(false);
			});
		});
	}
}
