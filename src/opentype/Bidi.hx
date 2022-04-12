package opentype;

import opentype.Tokenizer;

class Bidi {
	public function new(baseDir:String = 'ltr') {
		trace('create BIDI');
		this.baseDir = baseDir;
		this.tokenizer = new Tokenizer();
		this.featureTags = {};
	}

	final baseDir:String;
	final tokenizer:Tokenizer;
	final featureTags:Dynamic;

	public function registerModifier(modifierId:String, condition:Dynamic, modifier:Dynamic) {
		// trace('Bidi. registerModifier ');
		this.tokenizer.registerModifier(modifierId, condition, modifier);
	}
}
