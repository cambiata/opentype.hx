package opentype.tables.subtables;

class LookupSets {}

typedef LigatureSet = {
	ligaGlyph:Int,
	components:Array<Int>,
}

typedef RuleSet = {
	input:Array<Int>,
	lookupRecords:Array<LookupRecord>,
}

typedef LookupRecord = {
	sequenceIndex:Int,
	lookupListIndex:Int,
}

typedef LookupRecordDesc = {
	sequenceIndex:Void->Int,
	lookupListIndex:Void->Int
};

typedef ClassSet = {
	classes:Array<Int>,
	lookupRecords:Array<LookupRecord>,
}

typedef ChainRuleSet = {
	backtrack:Array<Int>,
	input:Array<Int>,
	lookahead:Array<Int>,
	lookupRecords:Array<LookupRecord>,
}

typedef ChainClassSet = ChainRuleSet;

typedef ExtensionSet = {
	substFormat:Int,
	backtrackCoverage:Array<Coverage>,
	inputCoverage:Array<Coverage>,
	// backtrackCoverage:Array<Coverage>,
}
