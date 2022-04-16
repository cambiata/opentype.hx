package opentype.tables;

import opentype.tables.subtables.Lookup;
import opentype.tables.subtables.Lookup.PairSet;
import haxe.io.Bytes;

class Gsub implements IScriptTable implements ILayoutTable {
	static function error(p):Any {
		return null;
	}

	static var subtableParsers:Array<Parser->Any> = [
		null, cast parseLookup1, cast parseLookup2, error, error, error, error, error, error, error
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
		// check.assert(false, '0x' + start.toString(16) + ': lookup type 1 format must be 1 or 2.');

		// final start = p.offset + p.relativeOffset;
		// final res = new Lookup();
		// res.posFormat = p.parseUShort();
		// Check.assert(res.posFormat == 1 || res.posFormat == 2, '${StringTools.hex(start)} : GPOS lookup type 1 format must be 1 or 2.');
		// res.coverage = p.parsePointer().parseCoverage();
		// if (res.posFormat == 1) {
		// 	res.value = p.parseValueRecord();
		// } else if (res.posFormat == 2) {
		// 	res.values = p.parseValueRecordList();
		// }
		// return res;
	};

	// https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-2-pair-adjustment-positioning-subtable
	public static function parseLookup2(p:Parser):Lookup {
		final substFormat = p.parseUShort();
		if (substFormat != 1)
			throw 'GSUB Multiple Substitution Subtable identifier-format must be 1';

		final res:Lookup = new Lookup();
		res.substFormat = substFormat;
		res.coverage = p.parsePointer().parseCoverage();
		res.sequences = p.parseListOfLists();
		return res;
	};

	// final start = p.offset + p.relativeOffset;
	// final res = new Lookup();
	// res.posFormat = p.parseUShort();
	// Check.assert(res.posFormat == 1 || res.posFormat == 2, '${StringTools.hex(start)} + : GPOS lookup type 2 format must be 1 or 2.');
	// res.coverage = p.parsePointer().parseCoverage();
	// res.valueFormat1 = p.parseUShort();
	// res.valueFormat2 = p.parseUShort();
	// if (res.posFormat == 1) {
	// 	trace('posFormat 1');
	// 	trace(res.valueFormat1);
	// 	trace(res.valueFormat2);
	// 	// Adjustments for Glyph Pairs
	// 	final pairSets:Array<Array<PairSet>> = p.parseList(() -> {
	// 		trace(111);
	// 		//
	// 		p.parseAtPointer(p -> {
	// 			trace(222);
	// 			//
	// 			p.parseList(() -> {
	// 				trace(333);
	// 				//
	// 				final pairSet = new PairSet(p.parseUShort(), p.parseValueRecordOfFormat(res.valueFormat1),
	// 					p.parseValueRecordOfFormat(res.valueFormat2));
	// 				trace(pairSet);
	// 				return pairSet;
	// 			});
	// 		});
	// 	});
	// 	trace(pairSets);
	// 	res.pairSets = pairSets;
	// } else if (res.posFormat == 2) {
	// 	trace('posFormat 2');
	// 	res.classDef1 = p.parseAtPointer(Parser.classDef);
	// 	res.classDef2 = p.parseAtPointer(Parser.classDef);
	// 	res.classCount1 = p.parseUShort();
	// 	res.classCount2 = p.parseUShort();
	// 	res.classRecords = p.parseListOfLength(res.classCount1, () -> {
	// 		p.parseListOfLength(res.classCount2, () -> {
	// 			var r:Pair<ValueRecord, ValueRecord> = {
	// 				value1: p.parseValueRecordOfFormat(res.valueFormat1),
	// 				value2: p.parseValueRecordOfFormat(res.valueFormat2)
	// 			};
	// 			return r;
	// 		});
	// 	});
	// }
	// Check.assert(false, '${StringTools.hex(start)} : GPOS lookup type 1 format must be 1 or 2.');
	// return res;
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
				gsub.lookups = p.parseLookupList(subtableParsers);
			case 1.1:
				gsub.version = tableVersion;
				gsub.scripts = p.parseScriptList();
				gsub.features = p.parseFeatureList();
				gsub.lookups = p.parseLookupList(subtableParsers);
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
