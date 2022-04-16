package opentype.tables.subtables;

import opentype.tables.ValueRecord;

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
}

class PairSet {
	public function new(secondGlyph:Int, value1:ValueRecord, value2:ValueRecord) {
		this.secondGlyph = secondGlyph;
		this.value1 = value1;
		this.value2 = value2;
		trace(this.secondGlyph + ' ' + this.value1 + ' ' + this.value2);
	}

	public var secondGlyph:Int;
	public var value1:ValueRecord;
	public var value2:ValueRecord;

	function toString():String
		return 'PairSet{$secondGlyph, $value1, $value2}';
}
