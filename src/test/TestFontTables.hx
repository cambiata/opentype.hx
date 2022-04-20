import opentype.tables.subtables.RangeRecord;
import opentype.Font;
import opentype.OpenType;
import opentype.tables.subtables.Lookup;

using opentype.OpenType;
using buddy.Should;

class TestFontTables extends buddy.BuddySuite {
	public function new() {
		describe('fontTables.js basic tests', function() {
			var arabicFont:Font;
			var arabicFontChanga:Font;
			var latinFont:Font;
			var arialFont:Font;

			beforeAll(function() {
				arabicFont = OpenType.loadFromFileSync('src/test/fonts/Scheherazade-Bold.ttf').parse();
				arabicFontChanga = OpenType.loadFromFileSync('src/test/fonts/Changa-Regular.ttf').parse();
				latinFont = OpenType.loadFromFileSync('src/test/fonts/Roboto-Black.ttf').parse();
				arialFont = OpenType.loadFromFileSync('src/test/fonts/arial.ttf').parse();
			});

			describe('Arabic font', function() {
				it('tables.cmap', {
					arabicFont.tables.cmap.version.should.be(.0);
					arabicFont.tables.cmap.numTables.should.be(3);
					arabicFont.tables.cmap.format.should.be(4);
					arabicFont.tables.cmap.length.should.be(1092);
					arabicFont.tables.cmap.language.should.be(0);
					arabicFont.tables.cmap.segCount.should.be(58);
					arabicFont.tables.cmap.glyphIndexMap.get(32).should.be(3);
					arabicFont.tables.cmap.glyphIndexMap.get(33).should.be(5);
					arabicFont.tables.cmap.glyphIndexMap.get(65279).should.be(268);
				});

				it('tables.gpos', {
					arabicFont.tables.gpos.version.should.be(1);
					arabicFont.tables.gpos.scripts.length.should.be(2);
					arabicFont.tables.gpos.scripts[0].tag.should.be('arab');
					arabicFont.tables.gpos.scripts[1].tag.should.be('latn');
					arabicFont.tables.gpos.features.length.should.be(19);
					arabicFont.tables.gpos.features[0].tag.should.be('curs');
					arabicFont.tables.gpos.features[0].feature.lookupListIndexes.should.containExactly([0]);
					arabicFont.tables.gpos.lookups.length.should.be(79);
					arabicFont.tables.gpos.lookups[0].lookupType.should.be(3);
					arabicFont.tables.gpos.lookups[0].markFilteringSet.should.be(0); // null
					arabicFont.tables.gpos.features[4].tag.should.be('kern');
				});

				it('tables.gsub', {
					arabicFont.tables.gsub.version.should.be(1);
					arabicFont.tables.gsub.scripts.length.should.be(2);
					arabicFont.tables.gsub.scripts[0].tag.should.be('arab');
					// arabicFont.tables.gsub.scripts[0].script.defaultLangSys.should.be('arab');
					arabicFont.tables.gsub.scripts[0].script.defaultLangSys.reserved.should.be(0);
					arabicFont.tables.gsub.scripts[0].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arabicFont.tables.gsub.scripts[0].script.defaultLangSys.featureIndexes.should.containExactly([
						 0,  5, 10, 14, 17, 18, 22, 27,
						30, 35, 40, 45, 50, 55, 60, 62,
						67, 72, 77, 81, 85, 89, 93, 98
					]);
					arabicFont.tables.gsub.scripts[1].tag.should.be('latn');
					arabicFont.tables.gsub.scripts[1].script.defaultLangSys.reserved.should.be(0);
					arabicFont.tables.gsub.scripts[1].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arabicFont.tables.gsub.scripts[1].script.defaultLangSys.featureIndexes.should.containExactly([4, 9, 26, 29, 34, 39, 44, 49, 54, 59, 66, 71, 76, 97]);
					arabicFont.tables.gsub.features.length.should.be(102);
					arabicFont.tables.gsub.features[0].tag.should.be('calt');
					arabicFont.tables.gsub.features[0].feature.featureParams.should.be(0);
					arabicFont.tables.gsub.features[0].feature.lookupListIndexes.should.containExactly([15, 16, 17, 18]);

					arabicFont.tables.gsub.lookups[0].lookupType.should.be(1);
					arabicFont.tables.gsub.lookups[0].lookupFlag.should.be(1);
					final subTable:Lookup = arabicFont.tables.gsub.lookups[0].subTables[0];
					subTable.substFormat.should.be(2);
					subTable.coverage.format.should.be(1);
					subTable.coverage.glyphs.should.containExactly([269, 520, 1085, 1337, 1355]);
					subTable.substitute.should.containExactly([270, 521, 1086, 1338, 1356]);
					arabicFont.tables.gsub.lookups[0].markFilteringSet.should.be(0);
				});
			});

			describe('Arabic Chaga font', function() {
				it('tables.cmap', {
					arabicFontChanga.tables.cmap.version.should.be(0);
					arabicFontChanga.tables.cmap.numTables.should.be(2);
					arabicFontChanga.tables.cmap.format.should.be(4);
					arabicFontChanga.tables.cmap.length.should.be(2334);
					arabicFontChanga.tables.cmap.language.should.be(0);
					arabicFontChanga.tables.cmap.segCount.should.be(150);
					arabicFontChanga.tables.cmap.glyphIndexMap.get(32).should.be(3);
					arabicFontChanga.tables.cmap.glyphIndexMap.get(33).should.be(624);
				});
				it('tables.gpos', {
					arabicFontChanga.tables.gpos.version.should.be(1);
					arabicFontChanga.tables.gpos.scripts.length.should.be(3);
					arabicFontChanga.tables.gpos.scripts[0].tag.should.be('DFLT');
					arabicFontChanga.tables.gpos.scripts[1].tag.should.be('arab');
					arabicFontChanga.tables.gpos.features.length.should.be(12);
					arabicFontChanga.tables.gpos.features[0].tag.should.be('curs');
					arabicFontChanga.tables.gpos.features[0].feature.lookupListIndexes.should.containExactly([2]);
					arabicFontChanga.tables.gpos.lookups.length.should.be(10);
					arabicFontChanga.tables.gpos.lookups[0].lookupType.should.be(2);
					arabicFontChanga.tables.gpos.lookups[0].markFilteringSet.should.be(0);
					arabicFontChanga.tables.gpos.features[4].tag.should.be('kern');
				});

				it('tables.gsub', {
					arabicFontChanga.tables.gsub.version.should.be(1);
					arabicFontChanga.tables.gsub.scripts.length.should.be(3);
					arabicFontChanga.tables.gsub.scripts[0].tag.should.be('DFLT');
					// arabicFontChanga.tables.gsub.scripts[0].script.defaultLangSys.should.be('arab');
					arabicFontChanga.tables.gsub.scripts[0].script.defaultLangSys.reserved.should.be(0);
					arabicFontChanga.tables.gsub.scripts[0].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arabicFontChanga.tables.gsub.scripts[0].script.defaultLangSys.featureIndexes.should.containExactly([0, 14, 26, 38, 50, 62, 74, 95, 107, 119, 131, 143, 155]);
					arabicFontChanga.tables.gsub.scripts[1].tag.should.be('arab');
					arabicFontChanga.tables.gsub.scripts[1].script.defaultLangSys.reserved.should.be(0);
					arabicFontChanga.tables.gsub.scripts[1].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arabicFontChanga.tables.gsub.scripts[1].script.defaultLangSys.featureIndexes.should.containExactly([1, 12, 15, 27, 39, 51, 63, 75, 96, 108, 120, 132, 144, 156]);
					arabicFontChanga.tables.gsub.features.length.should.be(167);
					arabicFontChanga.tables.gsub.features[0].tag.should.be('aalt');
					arabicFontChanga.tables.gsub.features[0].feature.featureParams.should.be(0);
					arabicFontChanga.tables.gsub.features[0].feature.lookupListIndexes.should.containExactly([0, 1]);

					arabicFontChanga.tables.gsub.lookups[0].lookupType.should.be(1);
					arabicFontChanga.tables.gsub.lookups[0].lookupFlag.should.be(0);
					final subTables:Lookup = arabicFontChanga.tables.gsub.lookups[0].subTables[0];
					subTables.substFormat.should.be(2);
					subTables.coverage.format.should.be(1);
					subTables.coverage.glyphs.should.containExactly([
						4, 75, 97, 103, 132, 187, 206, 228, 235, 275, 279, 281, 283, 285, 327, 329, 331, 333, 335, 337, 339, 385, 415, 425, 431, 433, 435,
						437, 439, 453, 455, 458, 460, 462, 464, 466, 492, 494, 496, 498, 500, 502, 504, 506, 508, 510, 512, 609, 612, 613, 633
					]);
					subTables.substitute.should.containExactly([
						269, 270, 99, 104, 269, 188, 270, 230, 236, 276, 280, 282, 284, 286, 328, 330, 332, 334, 336, 338, 340, 386, 416, 426, 432, 434, 436,
						438, 440, 454, 456, 459, 461, 463, 465, 467, 493, 495, 497, 499, 501, 503, 505, 507, 509, 511, 513, 610, 601, 614, 545
					]);
					arabicFontChanga.tables.gsub.lookups[0].markFilteringSet.should.be(0);
				});
			});

			describe('Latin font: Roboto-Black', {
				it('tables.cmap', {
					latinFont.tables.cmap.version.should.be(0);
					latinFont.tables.cmap.numTables.should.be(3);
					latinFont.tables.cmap.format.should.be(12); // OOOPS
					latinFont.tables.cmap.length.should.be(3004);
					latinFont.tables.cmap.language.should.be(0);
					latinFont.tables.cmap.segCount.should.be(0);
					latinFont.tables.cmap.glyphIndexMap.get(32).should.be(4);
					latinFont.tables.cmap.glyphIndexMap.get(33).should.be(5);
				});

				it('tables.gpos', {
					latinFont.tables.gpos.version.should.be(1);
					latinFont.tables.gpos.scripts.length.should.be(4);
					latinFont.tables.gpos.scripts[0].tag.should.be('DFLT');
					latinFont.tables.gpos.scripts[1].tag.should.be('cyrl');
					latinFont.tables.gpos.features.length.should.be(2);
					latinFont.tables.gpos.features[0].tag.should.be('cpsp');
					latinFont.tables.gpos.features[1].tag.should.be('kern');

					latinFont.tables.gpos.features[0].feature.lookupListIndexes.should.containExactly([0]);
					latinFont.tables.gpos.lookups.length.should.be(2);
					latinFont.tables.gpos.lookups[0].lookupType.should.be(1);
					latinFont.tables.gpos.lookups[0].markFilteringSet.should.be(0);
				});

				it('tables.gsub', {
					latinFont.tables.gsub.version.should.be(1);
					latinFont.tables.gsub.scripts.length.should.be(4);
					latinFont.tables.gsub.scripts[0].tag.should.be('DFLT');
					latinFont.tables.gsub.scripts[0].script.defaultLangSys.reserved.should.be(0);
					latinFont.tables.gsub.scripts[0].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					latinFont.tables.gsub.scripts[0].script.defaultLangSys.featureIndexes.should.containExactly([0, 1, 2, 3, 4, 8, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]);
					latinFont.tables.gsub.scripts[1].tag.should.be('cyrl');

					latinFont.tables.gsub.scripts[1].script.defaultLangSys.reserved.should.be(0);
					latinFont.tables.gsub.scripts[1].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					latinFont.tables.gsub.scripts[1].script.defaultLangSys.featureIndexes.should.containExactly([0, 1, 2, 3, 4, 8, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]);
					latinFont.tables.gsub.features.length.should.be(24);
					latinFont.tables.gsub.features[0].tag.should.be('c2sc');
					latinFont.tables.gsub.features[0].feature.featureParams.should.be(0);
					latinFont.tables.gsub.features[0].feature.lookupListIndexes.should.containExactly([0]);

					latinFont.tables.gsub.lookups[0].lookupType.should.be(1);
					latinFont.tables.gsub.lookups[0].lookupFlag.should.be(0);
					final subTable:Lookup = latinFont.tables.gsub.lookups[0].subTables[0];
					subTable.substFormat.should.be(2);
					subTable.coverage.format.should.be(1);
					subTable.coverage.glyphs.should.containExactly([
						8, 10, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58,
						59, 60, 61, 62, 101, 103, 129, 131, 132, 140, 143, 145, 147, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 210, 211, 212, 213,
						214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 303, 307, 309, 311, 313, 315, 321,
						323, 325, 329, 331, 332, 344, 345, 407, 413, 418, 421, 634, 635, 637, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651,
						652, 653, 654, 655, 656, 657, 658, 659, 660, 661, 662, 663, 664, 665, 694, 696, 698, 700, 702, 704, 706, 708, 710, 712, 714, 716, 718,
						720, 722, 724, 726, 728, 730, 732, 734, 736, 738, 739, 741, 743, 745, 747, 749, 751, 753, 755, 757, 760, 762, 764, 766, 768, 770, 772,
						774, 776, 778, 780, 782, 784, 786, 788, 790, 792, 794, 796, 798, 800, 802, 804, 805, 807, 809, 811, 813, 902, 903, 904, 905, 906, 907,
						908, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950,
						951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 979, 981, 983, 985, 1006, 1008, 1010, 1031, 1037, 1043, 1149, 1154, 1158,
						1287, 1289
					]);
				});
			});

			describe('Latin font: Arial', {
				it('tables.cmap', {
					arialFont.tables.cmap.version.should.be(0);
					arialFont.tables.cmap.numTables.should.be(3);
					arialFont.tables.cmap.format.should.be(4); // OOOPS
					arialFont.tables.cmap.length.should.be(4934);
					arialFont.tables.cmap.language.should.be(0);
					arialFont.tables.cmap.segCount.should.be(162);
					arialFont.tables.cmap.glyphIndexMap.get(32).should.be(3);
					arialFont.tables.cmap.glyphIndexMap.get(33).should.be(4);
				});

				it('tables.gpos', {
					arialFont.tables.gpos.version.should.be(1);
					arialFont.tables.gpos.scripts.length.should.be(5);
					arialFont.tables.gpos.scripts[0].tag.should.be('arab');
					arialFont.tables.gpos.scripts[1].tag.should.be('cyrl');
					arialFont.tables.gpos.features.length.should.be(36);
					arialFont.tables.gpos.features[0].tag.should.be('cpsp');
					arialFont.tables.gpos.features[1].tag.should.be('cpsp');

					arialFont.tables.gpos.features[0].feature.lookupListIndexes.should.containExactly([18, 19, 20]);
					arialFont.tables.gpos.lookups.length.should.be(132);
					arialFont.tables.gpos.lookups[0].lookupType.should.be(9);
					arialFont.tables.gpos.lookups[0].markFilteringSet.should.be(0);
				});

				it('tables.gsub', {
					arialFont.tables.gsub.version.should.be(1);
					arialFont.tables.gsub.scripts.length.should.be(5);
					arialFont.tables.gsub.scripts[0].tag.should.be('arab');
					arialFont.tables.gsub.scripts[0].script.defaultLangSys.reserved.should.be(0);
					arialFont.tables.gsub.scripts[0].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arialFont.tables.gsub.scripts[0].script.defaultLangSys.featureIndexes.should.containExactly([5, 10, 20, 31, 41, 46, 51, 67, 87, 92, 108]);
					arialFont.tables.gsub.scripts[1].tag.should.be('cyrl');

					arialFont.tables.gsub.scripts[1].script.defaultLangSys.reserved.should.be(0);
					arialFont.tables.gsub.scripts[1].script.defaultLangSys.reqFeatureIndex.should.be(65535);
					arialFont.tables.gsub.scripts[1].script.defaultLangSys.featureIndexes.should.containExactly([0, 26, 36, 56, 72, 77, 82, 98, 103, 113, 118, 123, 128, 133]);
					arialFont.tables.gsub.features.length.should.be(138);
					arialFont.tables.gsub.features[0].tag.should.be('c2sc');
					arialFont.tables.gsub.features[0].feature.featureParams.should.be(0);
					arialFont.tables.gsub.features[0].feature.lookupListIndexes.should.containExactly([43, 44, 45]);

					arialFont.tables.gsub.lookups[0].lookupType.should.be(7);
					arialFont.tables.gsub.lookups[0].lookupFlag.should.be(256);
					arialFont.tables.gsub.lookups[0].subTables.length.should.be(1);
					final subTable:Lookup = arialFont.tables.gsub.lookups[0].subTables[0];
					subTable.substFormat.should.be(1);
					subTable.lookupType.should.be(6);
					subTable.extension.substFormat.should.be(3);

					subTable.extension.backtrackCoverage.length.should.be(0);
					subTable.extension.inputCoverage[0].format.should.be(1);
					subTable.extension.inputCoverage[0].glyphs.should.containExactly([76, 77, 435, 1850]);

					subTable.extension.inputCoverage[0].format.should.be(1);
					subTable.extension.inputCoverage[0].glyphs.should.containExactly([76, 77, 435, 1850]);

					subTable.extension.lookaheadCoverage[0].format.should.be(2);
					subTable.extension.lookaheadCoverage[0].ranges.length.should.be(18);
					final range0:RangeRecord = subTable.extension.lookaheadCoverage[0].ranges[0];
					range0.end.should.be(1140);
					range0.start.should.be(1140);
					range0.value.should.be(0);
					final range17:RangeRecord = subTable.extension.lookaheadCoverage[0].ranges[17];
					range17.end.should.be(3352);
					range17.start.should.be(3352);
					range17.value.should.be(63);
				});
			});
		});
	}
}
