package opentype;

class Tokenizer {
	public function new() {
		this.tokens = [];
	}

	var tokens:Array<Token>;

	public function registerModifier(modifierId:String, condition:Dynamic, modifier:Dynamic) {}

	public function tokenize(text:String):Array<Token> {
		this.tokens = [];
		this.resetContextsRanges();
		final chars = text.split('');
		trace(chars);
		for (i => char in chars) {
			final contextParams = new ContextParams(chars, i);
			// trace(contextParams);
			this.runContextCheck(contextParams);
			final token = new Token(char);
			this.tokens.push(token);
		}

		return this.tokens;
	}

	function resetContextsRanges() {
		// trace('resetContextsRanges...');
	}

	function runContextCheck(contextParams:ContextParams) {
		final index = contextParams.index;
		// trace('runContextCheck...');
	}
}

class ContextParams {
	public function new(context:Array<String>, currentIndex:Int) {
		this.context = context;
		this.index = currentIndex;
		this.length = context.length;
		this.current = context[currentIndex];
		this.backtrack = context.slice(0, currentIndex);
		this.lookahead = context.slice(currentIndex + 1);
	}

	public final context:Array<String>;
	public final index:Int;
	public final length:Int;
	public final current:Dynamic;
	public final backtrack:Array<String>;
	public final lookahead:Array<String>;
}

class Token {
	public function new(char:String) {
		this.char = char;
		this.state = {};
		this.activeState = null;
	}

	public final char:String;
	public final state:Dynamic;

	final activeState:Null<Bool>;
}
