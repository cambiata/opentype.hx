package opentype.tables;

import opentype.tables.subtables.Coverage;
import opentype.tables.subtables.Lookup;
import opentype.tables.subtables.Lookup.PairSet;
import opentype.tables.subtables.LookupSets;
import opentype.tables.subtables.LookupSets;
import opentype.tables.subtables.ClassDefinition;
import haxe.io.Bytes;

using Lambda;

class Gsub implements IScriptTable implements ILayoutTable {
	static function error(p):Any {
		return null;
	}

	public static var subtableParsers:Array<Parser->Any> = [
		null, cast parseLookup1, cast parseLookup2, cast parseLookup3, cast parseLookup4, cast parseLookup5, cast parseLookup6, cast parseLookup7,
		cast parseLookup8, error
	];

	public function new() {
		// subtableParsers = [null, parseLookup2];         // subtableParsers[0] is unused
	}

	public var version(default, null):Float = -1;
	public var scripts:Array<ScriptRecord> = [];
	public var lookups(default, null):Array<LookupTable> = [];
	public var features(default, null):Array<FeatureTable> = [];

	public var variations(default, null):Dynamic;

	public static function parse(data:Bytes, position = 0):Gsub {
		return parseGsubTable(data, position);
	}

	// https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-1-single-adjustment-positioning-subtable
	// this = Parser instance
	public static function parseLookup1(p:Parser):Lookup {
		// trace('GSUB parserLookup 1');
		final start = p.offset + p.relativeOffset;
		final substFormat = p.parseUShort();
		final res = new Lookup();

		if (substFormat == 1) {
			res.substFormat = 1;
			res.coverage = p.parsePointer().parseCoverage();
			res.deltaGlyphId = p.parseUShort();
		} else if (substFormat == 2) {
			res.substFormat = 2;
			res.coverage = p.parsePointer().parseCoverage();
			res.substitute = p.parseOffset16List();
		}
		return res;
	};

	// https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-2-pair-adjustment-positioning-subtable
	public static function parseLookup2(p:Parser):Lookup {
		// trace('GSUB parserLookup 2');
		final substFormat = p.parseUShort();
		if (substFormat != 1)
			throw 'GSUB Multiple Substitution Subtable identifier-format must be 1';

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;
		res.coverage = p.parsePointer().parseCoverage();
		res.sequences = p.parseListOfLists();
		return res;
	};

	public static function parseLookup3(p:Parser):Lookup {
		// trace('GSUB parserLookup 3');
		final substFormat = p.parseUShort();
		if (substFormat != 1)
			throw 'GSUB Multiple Substitution Subtable identifier-format must be 1';

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;
		res.coverage = p.parsePointer().parseCoverage();
		res.alternateSets = p.parseListOfLists();
		return res;
	}

	public static function parseLookup4(p:Parser):Lookup {
		// trace('GSUB parserLookup 4');
		final substFormat = p.parseUShort();
		if (substFormat != 1)
			throw 'GSUB Multiple Substitution Subtable identifier-format must be 1';

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;
		res.coverage = p.parsePointer().parseCoverage();
		res.ligatureSets = p.parseListOfLists(() -> {
			return {
				ligaGlyph: p.parseUShort(),
				components: p.parseUShortList(p.parseUShort() - 1)
			};
		});

		return res;
	}

	public static function parseLookup5(p:Parser):Lookup {
		// trace('GSUB parserLookup 5');
		final start = p.offset + p.relativeOffset;
		final substFormat = p.parseUShort();

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;

		switch substFormat {
			case 1:
				res.coverage = p.parsePointer().parseCoverage();
				final ruleSets:Array<Array<RuleSet>> = p.parseListOfLists(() -> {
					final glyphCount = p.parseUShort();
					final substCount = p.parseUShort();
					final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort}

					final input = p.parseUShortList(glyphCount - 1);
					final lookupRecords = p.parseRecordList2(substCount, lookupRecordDesc);
					final ruleSet:RuleSet = {
						input: input,
						lookupRecords: lookupRecords
					};

					return ruleSet;
				});
				res.ruleSets = ruleSets;
			case 2:
				res.coverage = p.parsePointer().parseCoverage();
				final classDef:ClassDefinition = p.parsePointer().parseClassDef();

				final classSets:Array<Array<ClassSet>> = p.parseListOfLists(() -> {
					final glyphCount = p.parseUShort();
					final substCount = p.parseUShort();
					final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort}
					final classSet:ClassSet = {
						classes: p.parseUShortList(glyphCount - 1),
						lookupRecords: p.parseRecordList2(substCount, lookupRecordDesc)
					};
					return classSet;
				});
				res.classDef1 = classDef;
				res.classSets = classSets;

			case 3:
				final glyphCount = p.parseUShort();
				final substCount = p.parseUShort();
				final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort}
				final coverages = [];
				for (i in 0...glyphCount)
					coverages.push(p.parsePointer().parseCoverage());
				res.coverages = coverages;
				res.lookupRecords = p.parseRecordList2(substCount, lookupRecordDesc);

			default:
				throw 'lookup type 5 format must be 1, 2 or 3.';
		}
		return res;
	}

	public static function parseLookup6(p:Parser):Lookup {
		// trace('GSUB parserLookup 6');
		// throw 'Gsub parseLookup6 not implemented';
		// return null;
		final start = p.offset + p.relativeOffset;
		final substFormat = p.parseUShort();

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;
		switch substFormat {
			case 1:
				res.coverage = p.parsePointer().parseCoverage();

				final chainRuleSets:Array<Array<ChainRuleSet>> = p.parseListOfLists(() -> {
					final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort};
					final chainRuleSet:ChainRuleSet = {
						backtrack: p.parseUShortList(),
						input: p.parseUShortListOfLength(p.parseShort() - 1),
						lookahead: p.parseUShortList(),
						lookupRecords: p.parseRecordList2(null, lookupRecordDesc),
					}
					return chainRuleSet;
				});
				res.chainRuleSets = chainRuleSets;

			case 2:
				res.coverage = p.parsePointer().parseCoverage();
				res.backtrackClassDef = p.parsePointer().parseClassDef();
				res.inputClassDef = p.parsePointer().parseClassDef();
				res.lookaheadClassDef = p.parsePointer().parseClassDef();

				final chainClassSets:Array<Array<ChainClassSet>> = p.parseListOfLists(() -> {
					final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort};
					final chainClassSet:ChainClassSet = {
						backtrack: p.parseUShortList(),
						input: p.parseUShortListOfLength(p.parseShort() - 1),
						lookahead: p.parseUShortList(),
						lookupRecords: p.parseRecordList2(null, lookupRecordDesc),
					}
					return chainClassSet;
				});
				res.chainClassSets = chainClassSets;

			case 3:
				res.backtrackCoverage = p.parseList(() -> p.parsePointer().parseCoverage());
				res.inputCoverage = p.parseList(() -> p.parsePointer().parseCoverage());
				res.lookaheadCoverage = p.parseList(() -> p.parsePointer().parseCoverage());
				final lookupRecordDesc:LookupRecordDesc = {sequenceIndex: p.parseUShort, lookupListIndex: p.parseUShort};
				res.lookupRecords = p.parseRecordList2(null, lookupRecordDesc);
			default:
				throw ': lookup type 6 format must be 1, 2 or 3.';
		}
		return res;
	}

	@:access(opentype.Parser.data)
	public static function parseLookup7(p:Parser):Lookup {
		// trace('GSUB parserLookup 7');
		final substFormat = p.parseUShort();
		if (substFormat != 1)
			throw 'GSUB Extension Substitution subtable identifier-format must be 1';

		final res:Lookup = new Lookup();

		final extensionLookupType = p.parseUShort();
		final extensionParser:Parser = new Parser(p.data, p.offset + p.parseULong());
		res.substFormat = substFormat;
		res.lookupType = extensionLookupType;
		res.extension = subtableParsers[extensionLookupType](extensionParser);
		return res;
	}

	public static function parseLookup8(p:Parser):Lookup {
		trace('GSUB parserLookup 8 ');
		final substFormat = p.parseUShort();

		if (substFormat != 1)
			trace('GSUB Reverse Chaining Contextual Single Substitution Subtable identifier-format must be 1');

		final res:Lookup = new Lookup();

		res.substFormat = substFormat;
		res.coverage = p.parsePointer().parseCoverage();
		res.backtrackCoverage = p.parseList(() -> {
			final p:Parser = p.parsePointer();
			if (p == null)
				return null;
			final coverage:Coverage = p.parseCoverage();
			return coverage;
		});
		res.lookaheadCoverage = p.parseList(() -> {
			final p:Parser = p.parsePointer();
			if (p == null)
				return null;
			final coverage:Coverage = p.parseCoverage();
			return coverage;
		});

		res.substitutes = p.parseUShortList();
		return res;
	};

	/*
		subtableParsers[5] = function parseLookup5() {
			const start = p.offset + this.relativeOffset;
			const substFormat = this.parseUShort();

			if (substFormat === 1) {
				return {
					substFormat: substFormat,
					coverage: this.parsePointer(Parser.coverage),
					ruleSets: this.parseListOfLists(function() {
						const glyphCount = this.parseUShort();
						const substCount = this.parseUShort();
						return {
							input: this.parseUShortList(glyphCount - 1),
							lookupRecords: this.parseRecordList(substCount, lookupRecordDesc)
						};
					})
				};
			} else if (substFormat === 2) {
				return {
					substFormat: substFormat,
					coverage: this.parsePointer(Parser.coverage),
					classDef: this.parsePointer(Parser.classDef),
					classSets: this.parseListOfLists(function() {
						const glyphCount = this.parseUShort();
						const substCount = this.parseUShort();
						return {
							classes: this.parseUShortList(glyphCount - 1),
							lookupRecords: this.parseRecordList(substCount, lookupRecordDesc)
						};
					})
				};
			} else if (substFormat === 3) {
				const glyphCount = this.parseUShort();
				const substCount = this.parseUShort();
				return {
					substFormat: substFormat,
					coverages: this.parseList(glyphCount, Parser.pointer(Parser.coverage)),
					lookupRecords: this.parseRecordList(substCount, lookupRecordDesc)
				};
			}
			check.assert(false, '0x' + start.toString(16) + ': lookup type 5 format must be 1, 2 or 3.');
		};
	 */
	// https://docs.microsoft.com/en-us/typography/opentype/spec/gpos
	static function parseGsubTable(data:Bytes, start = 0):Gsub {
		final p = new Parser(data, start);
		final tableVersion:Float = p.parseVersion(1);
		final gsub:Gsub = new Gsub();
		// check.argument(tableVersion == = 1 || tableVersion == = 1.1, 'Unsupported GSUB table version.');
		switch tableVersion {
			case 1:
				gsub.version = tableVersion;
				gsub.scripts = p.parseScriptList();
				gsub.features = p.parseFeatureList();
				gsub.lookups = p.parseLookupList(cast subtableParsers);
			case 1.1:
				gsub.version = tableVersion;
				gsub.scripts = p.parseScriptList();
				gsub.features = p.parseFeatureList();
				gsub.lookups = p.parseLookupList(cast subtableParsers);
				gsub.variations = p.parseFeatureVariationsList();
			default:
				throw 'Unsupported GSUB table version.';
		}
		return gsub;
	}

	//------------------------------------------------------------
	// function makeGsubTable(gsub:Gsub) {
	// 	return new table.Table('GSUB', [
	// 		{name: 'version', type: 'ULONG', value: 0x10000},
	// 		{name: 'scripts', type: 'TABLE', value: new table.ScriptList(gsub.scripts)},
	// 		{name: 'features', type: 'TABLE', value: new table.FeatureList(gsub.features)},
	// 		{name: 'lookups', type: 'TABLE', value: new table.LookupList(gsub.lookups, subtableMakers)}
	// 	]);
	// }
}
