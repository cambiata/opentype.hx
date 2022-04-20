package opentype.tables;

import opentype.tables.subtables.Lookup;

@:structInit
class LookupTable {
	public function new(lookupType:Int, lookupFlag:Int, subTables:Array<Lookup>, markFilteringSet:Int) {
		// trace('Creater LookupTable! $lookupType $lookupFlag ${subTables.length}');

		this.lookupType = lookupType;
		this.lookupFlag = lookupFlag;
		this.subTables = subTables;
		this.markFilteringSet = markFilteringSet;
	}

	public var lookupType:Int;
	public var lookupFlag:Int;
	public var subTables:Array<Any>;
	public var markFilteringSet:Int;

	function toString() {
		final pSub = (this.subTables == null) ? 'subTables==null' : '' + this.subTables;
		return 'LookupTable:{$lookupType:$lookupFlag:$pSub:$markFilteringSet}';
	}
}
