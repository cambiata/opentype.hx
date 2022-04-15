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
	var query:FeatureQuery;

	public function registerModifier(modifierId:String, condition:Token->ContextParams->Bool, modifier:Token->ContextParams->Dynamic) {
		// trace('Bidi. registerModifier ');
		this.tokenizer.registerModifier(modifierId, condition, modifier);
	}

	public function applyFeatures(font:Font, features:Array<FeatureData>) {
		if (font == null)
			throw 'No valid font was provided to apply features';

		if (this.query == null)
			this.query = new FeatureQuery(font);

		for (feature in features) {
			if (!this.query.supports({script: feature.script}))
				continue;
		}
	}
}

class FeatureQuery {
	public function new(font:Font) {
		this.font = font;
		this.features = {};
	}

	final font:Font;
	final features:DynamicAccess<Dynamic>;

	public function supports(query:FeatureData):Bool {
		if (query.script == null)
			return false;
		this.getScriptFeatures(query.script);
	}

	public function getScriptFeatures(scriptTag:String) {
		var features = this.features.get(scriptTag);
		if (features != null)
			return features;

		final featuresIndex = this.getScriptFeaturesIndexes(scriptTag);
		if (featuresIndex == null)
			return null;

		// final gsub = this.font.tables.gsub;
		// TODO WIP here...
		return null;
	}

	public function getScriptFeaturesIndexes(scriptTag:String) {
		return null;
	}
}

typedef FeatureData = {script:String, tags:Array<String>};
