package opentype.tables.subtables;

import opentype.tables.subtables.LookupSets;
import opentype.tables.ValueRecord;

using Lambda;
using Std;

class Lookup implements ILookup {
	public function new() {}

	public var posFormat:Int;
	public var coverage:Coverage;
	public var valueFormat1:Int;
	public var valueFormat2:Int;
	public var pairSets:Array<Array<PairSet>>;
	public var classDef1:ClassDefinition;
	public var classDef2:ClassDefinition;
	public var classCount1:Int;
	public var classCount2:Int;
	public var classRecords:Array<Array<Pair<ValueRecord, ValueRecord>>>;
	public var value:ValueRecord;
	public var values:Array<ValueRecord>;

	public var substFormat:Int;
	public var substitute:Array<Int>;
	public var deltaGlyphId:Int;
	public var sequences:Array<Array<Int>>;
	public var alternateSets:Array<Array<Int>>;
	public var ligatureSets:Array<Array<LigatureSet>>;
	public var ruleSets:Array<Array<RuleSet>>;
	public var classSets:Array<Array<ClassSet>>;
	public var lookupRecords:Array<LookupRecord>;
	public var coverages:Array<Coverage>;
	public var backtrackCoverage:Array<Coverage>;
	public var lookaheadCoverage:Array<Coverage>;
	public var inputCoverage:Array<Coverage>;
	public var substitutes:Array<Int>;

	public var chainRuleSets:Array<Array<ChainRuleSet>>;
	public var backtrackClassDef:ClassDefinition;
	public var inputClassDef:ClassDefinition;
	public var lookaheadClassDef:ClassDefinition;
	public var chainClassSets:Array<Array<ChainClassSet>>;
	public var lookupType:Int;
	public var extension:Lookup;

	public function toString():String {
		return 'Lookup: {'
			+ '\n\t\t - substFormat: '
			+ this.substFormat
			+ '\n\t\t - backtrackCoverage: ' //
			+ this.backtrackCoverage.map(i -> i.string())
			+ '\n\t\t - inputCoverage: '
			+ this.inputCoverage.map(i -> i.string())
			+ '\n\t\t - lookaheadCoverage: '
			+ this.lookaheadCoverage.map(i -> i.string())
			+ '\n\t\t - lookupRecords: '
			+ this.lookupRecords
			+ '\n\t \n'
			+ '}\n';
	}
}

class PairSet {
	public function new(secondGlyph:Int, value1:ValueRecord, value2:ValueRecord) {
		this.secondGlyph = secondGlyph;
		this.value1 = value1;
		this.value2 = value2;
		// trace(this.secondGlyph + ' ' + this.value1 + ' ' + this.value2);
	}

	public var secondGlyph:Int;
	public var value1:ValueRecord;
	public var value2:ValueRecord;

	function toString():String
		return 'PairSet{$secondGlyph, $value1, $value2}';
}
