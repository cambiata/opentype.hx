package tables;

using buddy.Should;
import opentype.tables.Ltag; 
using TestUtil;

class LtagTable extends buddy.BuddySuite {
    public function new() {
        describe('tables/Ltag.hx', {
            final data =
            '00 00 00 01 00 00 00 00 00 00 00 04 00 1C 00 02 ' +
            '00 1E 00 07 00 1E 00 02 00 25 00 13 65 6E 7A 68 ' +
            '2D 48 61 6E 74 73 6C 2D 72 6F 7A 61 6A 2D 73 6F ' +
            '6C 62 61 2D 31 39 39 34';
            final tags = ['en', 'zh-Hant', 'zh', 'sl-rozaj-solba-1994'];
            /*
            it('can make a language tag table', function() {
                assert.deepEqual(data, hex(ltag.make(tags).encode()));
            });
            */
            it('can parse a language tag table', function() {
                //assert.deepEqual(tags, ltag.parse(unhex('DE AD BE EF ' + data), 4));
                Ltag.parse('DE AD BE EF $data'.unhex(), 4).should.containExactly(tags);
            });
        });
    }
}