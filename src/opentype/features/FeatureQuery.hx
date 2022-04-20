package opentype.features;

import haxe.ds.StringMap;
import opentype.tables.FeatureTable;
import opentype.tables.ScriptRecord;
import haxe.DynamicAccess;
import opentype.tables.Tables;

using Lambda;

class FeatureQuery {
	public function new(font:Font) {
		trace('new FeatureQuery');
		this.font = font;
		this.features = new StringMap();
		this.featuresTags = new StringMap();
	}

	final font:Font;
	final features:StringMap<Array<FeatureTable>>;
	final featuresTags:StringMap<StringMap<Feature>>;

	public function supports(query:FeatureData):Bool {
		if (query.script == null)
			return false;
		this.getScriptFeatures(query.script);
		return null;
	}

	function mapTagsToFeatures(features:Array<FeatureTable>, scriptTag:String):Void {
		var tags:StringMap<Feature> = new StringMap();
		for (feature in features) {
			final tag = feature.tag;
			final feature:Feature = feature.feature;
			tags.set(tag, feature);
		}
		// trace('map ' + scriptTag);
		this.featuresTags.set(scriptTag, tags);
	};

	public function getScriptFeatures(scriptTag:String):Array<FeatureTable> {
		var features:Array<FeatureTable> = this.features.get(scriptTag);
		if (features != null)
			return features;

		final featuresIndexes = this.getScriptFeaturesIndexes(scriptTag);
		if (featuresIndexes == null)
			return null;

		final gsub = this.font.tables.gsub;
		features = featuresIndexes.map(idx -> gsub.features[idx]);
		this.features.set(scriptTag, features);

		this.mapTagsToFeatures(features, scriptTag);
		// TODO WIP here...
		return features;
	}

	public function getDefaultScriptFeaturesIndexes() {
		final scripts = this.font.tables.gsub.scripts;
		for (script in scripts)
			if (script.tag == 'DFLT')
				return (script.script.defaultLangSys.featureIndexes);
		return [];
	}

	public function getScriptFeaturesIndexes(scriptTag:String = null) {
		final tables:Tables = this.font.tables;
		if (tables.gsub == null)
			return [];
		if (scriptTag == null)
			return this.getDefaultScriptFeaturesIndexes();

		final scripts:Array<ScriptRecord> = this.font.tables.gsub.scripts;

		for (script in scripts) {
			if (script.tag == scriptTag && script.script.defaultLangSys != null) {
				return script.script.defaultLangSys.featureIndexes;
			} else {
				final langSysRecords = script.script.langSysRecords;
				if (langSysRecords != null) {
					for (langSysRecord in langSysRecords) {
						if (langSysRecord.tag == scriptTag) {
							var langSys = langSysRecord.langSys;
							return langSys.featureIndexes;
						}
					}
				}
			}
		}

		return this.getDefaultScriptFeaturesIndexes();
	}

	public function getLookupByIndex(index:Int) {
		final lookups = this.font.tables.gsub.lookups;
		return lookups[index];
	}

	public function getFeatureLookups(feature:Feature) {
		return feature.lookupListIndexes.map(this.getLookupByIndex);
	}

	public function getFeature(query:ScriptQuery):Feature {
		trace('getFeature');
		if (this.font == null)
			throw 'No fot was found';
		trace(111);
		if (!this.features.exists(query.script)) {
			this.getScriptFeatures(query.script);
		}
		trace(222);
		final scriptFeatures = this.features.get(query.script);
		trace(333);
		if (scriptFeatures == null) {
			throw 'No feature for script ${query.script}';
		}

		trace(444);
		// trace([for (key in this.featuresTags.keys()) key]);
		// trace(query.script);
		// trace(this.featuresTags.get(query.script).exists(query.tag));

		if (!this.featuresTags.get(query.script).exists(query.tag))
			return null;
		trace(555);
		final ret:Feature = this.featuresTags.get(query.script).get(query.tag);
		trace(ret);
		return ret;
	}
}

typedef FeatureData = {script:String, tags:Array<String>};
typedef ScriptQuery = {tag:String, script:String};
