import opentype.tables.LookupTable;
import opentype.tables.FeatureTable.Feature;
import opentype.features.FeatureQuery;
import opentype.OpenType;
import opentype.Font;

using opentype.OpenType;
using buddy.Should;

class TestFeatureQuery extends buddy.BuddySuite {
	public function new() {
		describe('test FeatureQuery', {
			var arabicFont:Font;
			var arabicFontChanga:Font;
			var robotoFont:Font;
			var arialFont:Font;

			var arabicQuery:FeatureQuery;
			var arabicChagaQuery:FeatureQuery;
			var robotoQuery:FeatureQuery;
			var arialQuery:FeatureQuery;

			beforeAll({
				arabicFont = OpenType.loadFromFileSync('src/test/fonts/Scheherazade-Bold.ttf').parse();
				// arabicQuery = new FeatureQuery(arabicFont);
				// robotoFont = OpenType.loadFromFileSync('src/test/fonts/Roboto-Black.ttf').parse();
				// robotoQuery = new FeatureQuery(robotoFont);
				// arialFont = OpenType.loadFromFileSync('src/test/fonts/arial.ttf').parse();
				// arialQuery = new FeatureQuery(arialFont);
			});

			// it('should return features indexes of a given script tag', {
			// 	final arabFeaturesIndexes:Array<Int> = arabicQuery.getScriptFeaturesIndexes('arab');
			// 	arabFeaturesIndexes.length.should.be(24);

			// 	final latnFeaturesIndexes = robotoQuery.getScriptFeaturesIndexes('latn');
			// 	latnFeaturesIndexes.length.should.be(19);

			// 	final arialFeaturesIndexes = arialQuery.getScriptFeaturesIndexes('latn');
			// 	arialFeaturesIndexes.length.should.be(15);
			// });

			// it('should return features of a given script', {
			// 	var arabFeatures = arabicQuery.getScriptFeatures('arab');
			// 	arabFeatures.length.should.be(24);

			// 	var robotoFeatures = robotoQuery.getScriptFeatures('latn');
			// 	robotoFeatures.length.should.be(19);

			// 	var arialFeatures = arialQuery.getScriptFeatures('latn');
			// 	arialFeatures.length.should.be(15);
			// });

			it('should return a feature lookup tables', {
				/** arab */
				// final initFeature:Feature = arabicQuery.getFeature({tag: 'init', script: 'arab'});

				// initFeature.lookupListIndexes.should.containExactly([7]);

				// final initFeatureLookups:Array<LookupTable> = arabicQuery.getFeatureLookups(initFeature);
				// trace(initFeatureLookups[0].subTables);

				// trace(initFeatureLookups[0].subTables.length);
				// trace(initFeatureLookups[0].subTables);

				// final checkLookup:LookupTable = arabicFont.tables.gsub.lookups[7];
				// trace(checkLookup.subTables);

				// initFeatureLookups[0].lookupFlag.should.be(checkLookup.lookupFlag);
				// initFeatureLookups[0].lookupType.should.be(checkLookup.lookupType);
				// initFeatureLookups[0].markFilteringSet.should.be(checkLookup.markFilteringSet);
				// trace(initFeatureLookups[0].subTables);
				// initFeatureLookups[0].subTables.should.be(checkLookup.subTables);
				// trace(initFeatureLookups[0].subTables);

				// /** latin */
				// final ligaFeature = query.latin.getFeature({ tag: 'liga', script: 'latn' });
				// assert.deepEqual(ligaFeature.lookupListIndexes, [35]);
				// final ligaFeatureLookups = query.latin.getFeatureLookups(ligaFeature);
				// assert.deepEqual(ligaFeatureLookups[0], latinFont.tables.gsub.lookups[35]);
			});
		});
	}
}
