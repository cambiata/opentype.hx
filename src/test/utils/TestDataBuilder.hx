package utils;

import opentype.tables.subtables.Lookup;
import haxe.io.Bytes;
import TestUtil.unhex;

using buddy.Should;

class TestDataBuilder extends buddy.BuddySuite {
	public function new() {
		describe('testDataBuilder', {
			it('should be true', {
				final a = true;
				a.should.be(true);

				buildTestData(1);
			});
		});
	}

	//-----------------------------------
	static function buildTestData(lookupType:Int, substFormat:Int = 1):Bytes {
		final bytes:Bytes = switch lookupType {
			case 1:
				switch substFormat {
					case 1:
						final data = '0001 0006 00C0 0002 0001 004E 0058 0000';
						createData(lookupType, data);
					case 2:
						final data = '0002 000E 0004 0131 0135 013E 0143   0001 0004 003C 0040 004B 004F';
						createData(lookupType, data);
					default:
						throw 'should not happen';
						null;
				}
			case 2:
				final data = '0001 0008 0001 000E   0001 0001 00F1   0003 001A 001A 001D';
				createData(lookupType, data);
			case 3:
				final data = '0001 0008 0001 000E   0001 0001 003A   0002 00C9 00CA';
				createData(lookupType, data);
			case 4:
				final data = '0001 000A 0002 0014 0020' // LigatureSubstFormat1
					+ '0002 0001 0019 001A 0000' // coverage format 2
					+ '0001 0004 015B 0003 0028 0017' // Ligature set "etc"
					+ '0002 0006 000E 00F1 0003 001A 001D 00F0 0002 001D'; // Ligature set "ffi" and "fi"
				createData(lookupType, data);
			case 5:
				switch substFormat {
					case 1:
						final data = '0001 000A 0002 0012 0020' // ContextSubstFormat1
							+ '0001 0002 0028 005D' // coverage format 1
							+ '0001 0004 0002 0001 005D 0000 0001' // sub rule set "space and dash"
							+ '0001 0004 0002 0001 0028 0001 0001'; // sub rule set "dash and space"
						createData(lookupType, data);
					case 2:
						final data = '0002 0010 001C 0004 0000 0000 0032 0040' // ContextSubstFormat2
							+ '0001 0004 0030 0031 0040 0041' // coverage format 1
							+ '0002 0003 0030 0031 0002 0040 0041 0003 00D2 00D3 0001' // class def format 2
							+ '0001 0004 0002 0001 0001 0001 0001' // sub class set "set marks high"
							+ '0001 0004 0002 0001 0001 0001 0002'; // sub class set "set marks very high"
						createData(lookupType, data);
					case 3:
						final data = '0003 0003 0002 0014 0030 0052 0000 0001 0002 0002'
							+ '0001 000C 0033 0035 0037 0038 0039 003B 003C 003D 0041 0042 0045 004A'
							+ '0001 000F 0032 0034 0036 003A 003E 003F 0040 0043 0044 0045 0046 0047 0048 0049 004B'
							+ '0001 0005 0038 003B 0041 0042 004A'; // coverage format 1
						createData(lookupType, data);

					default:
						throw 'should not happen';
						null;
				}
			case 8:
				final data = '0001 0068 0001 0000 0001 0026 000C 00A7 00B9 00C5 00D4 00EA 00F2 00FD 010D 011B 012B 013B 0141' // ReverseChainSingleSubstFormat1
					+ '0001 001F 00A5 00A9 00AA 00E2 0167 0168 0169 016D 016E 0170 0183' // coverage format 1
					+ '0184 0185 0189 018A 018C019F 01A0 01A1 01A2 01A3 01A4 01A5 01A6'
					+ '01A7 01A8 01A9 01AA 01AB 01AC 01EC'
					+ '0001 000C 00A6 00B7 00C3 00D2 00E9 00F1 00FC 010C 0119 0129 013A 0140'; // coverage format 1
				createData(lookupType, data);
			default:
				throw 'not implemented lookupType: $lookupType';
				null;
		}
		return bytes;
	}

	static function createData(lookupType:Int, subTableData:String):Bytes {
		final data:Bytes = unhex('00010000 000A 000C 000E' // header
			+ '0000' // ScriptTable - 0 scripts
			+ '0000' // FeatureListTable - 0 features
			+ '0001 0004' // LookupListTable - 1 lookup table
			+ '000'
			+ lookupType
			+ '0000 0001 0008' // Lookup table - 1 subtable
			+ subTableData); // sub table start offset: 0x1a
		return data;
	}
}
