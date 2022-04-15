package opentype;

import opentype.tables.Tables;
import opentype.Encoding.IEncoding;
import opentype.Encoding.DefaultEncoding;
import opentype.Tokenizer.Token;
import opentype.Tokenizer.ContextParams;

class Font {
	public function new(?options:FontOptions) {
		tables = options != null && options.tables != null ? options.tables : new Tables();
		// names = options != null && options.names != null ? options.names : new FontNames();

		if (options != null) {}

		glyphs = new GlyphSet(this, options != null && options.glyphs != null ? options.glyphs : []);

		encoding = new DefaultEncoding(this);
		position = new Position(this);
	}

	public var names:Map<String, Map<String, String>> = [];
	public var outlinesFormat:Flavor;
	public var tables(default, null):Tables;
	public var position(default, null):Position;
	public var unitsPerEm:Int;
	public var numGlyphs:Int;
	public var numberOfHMetrics:Int;
	public var glyphs:GlyphSet;
	public var _hmtxTableData:Array<HorizontalMetrics>;
	public var kerningPairs:Map<Int, Map<Int, Int>>;
	public var encoding:IEncoding;

	/**
	 * Retrieve the value of the kerning pair between the left glyph index)
	 * and the right glyph (or its index). If no kerning pair is found, return 0.
	 * The kerning value gets added to the advance width when calculating the spacing
	 * between glyphs.
	 * For GPOS kerning, this method uses the default script and language, which covers
	 * most use cases. To have greater control, use font.position.getKerningValue .
	 * @param  {opentype.Glyph} leftGlyph
	 * @param  {opentype.Glyph} rightGlyph
	 * @return {Number}
	 */
	public function getKerningValueForIndexes(leftIndex:Int, rightIndex:Int) {
		var kerning = 0;
		if (position.hasKerningTables()) {
			kerning = position.getKerningValue(leftIndex, rightIndex);
		}
		if (kerning != 0) {
			return kerning;
		} else {
			// fallback to kerning tables
			var kp = leftIndex + ',' + rightIndex;
			return kerningPairs.exists(leftIndex) && kerningPairs[leftIndex].exists(rightIndex) ? kerningPairs[leftIndex][rightIndex] : 0;
		}
	}

	/**
	 * Retrieve the value of the kerning pair between the left glyph
	 * and the right glyph. If no kerning pair is found, return 0.
	 * The kerning value gets added to the advance width when calculating the spacing
	 * between glyphs.
	 * For GPOS kerning, this method uses the default script and language, which covers
	 * most use cases. To have greater control, use font.position.getKerningValue .
	 * @param  {opentype.Glyph} leftGlyph
	 * @param  {opentype.Glyph} rightGlyph
	 * @return {Number}
	 */
	public function getKerningValue(leftGlyph:Glyph, rightGlyph:Glyph) {
		return getKerningValueForIndexes(leftGlyph.index, rightGlyph.index);
	}

	/**
	 * Check if the font has a glyph for the given character.
	 * @param  {string}
	 * @return {Boolean}
	 */
	public function hasChar(code:Int) {
		return encoding.hasChar(code);
	}

	/**
	 * Convert the given character to a single glyph index.
	 * Note that this function assumes that there is a one-to-one mapping between
	 * the given character and a glyph; for complex scripts this might not be the case.
	 * @param  {string}
	 * @return {Number}
	 */
	public function charToGlyphIndex(s:String) {
		return encoding.charToGlyphIndex(s.charCodeAt(0));
	}

	/**
	 * Convert the given character to a single Glyph object.
	 * Note that this function assumes that there is a one-to-one mapping between
	 * the given character and a glyph; for complex scripts this might not be the case.
	 * @param  {string}
	 * @return {opentype.Glyph}
	 */
	public function charToGlyph(c:String):Glyph {
		// final charCode = c.charCodeAt(0);

		final glyphIndex = charToGlyphIndex(c);
		return getGlyphByIndex(glyphIndex);
	}

	public function getGlyphByIndex(glyphIndex):Glyph {
		var glyph = glyphs.get(glyphIndex);
		if (glyph == null) {
			// .notdef
			glyph = glyphs.get(0);
		}
		return glyph;
	}

	public function getChars():Array<Int> {
		return encoding.getChars();
	}

	public function getGlyphIndicies():Array<Int> {
		return encoding.getIndicies();
	}

	public function getKerningPairs(index:Int) {
		// Get kernings found in the 'gpos' table
		var kernings = position.getKerningPairs(index).copy();
		// Also include kerning found in the 'kern' table
		if (kerningPairs.exists(index)) {
			for (k => v in kerningPairs[index]) {
				kernings.push([k, v]);
			}
		}
		return kernings;
	}

	/**
	 * Create a Path object that represents the given text.
	 * @param  {string} text - The text to create.
	 * @param  {number} [x=0] - Horizontal position of the beginning of the text.
	 * @param  {number} [y=0] - Vertical position of the *baseline* of the text.
	 * @param  {number} [fontSize=72] - Font size in pixels. We scale the glyph units by `1 / unitsPerEm * fontSize`.
	 * @param  {GlyphRenderOptions=} options
	 * @return {opentype.Path}
	 */
	public function getPath(text:String, x:Float, y:Float, fontSize:Float, options:Dynamic = null) {
		final fullPath = new Path();
		this.forEachGlyph(text, x, y, fontSize, options, function(font, glyph, gX, gY, gFontSize, options) {
			final glyphPath:Path = glyph.getPath(gX, gY, gFontSize, options, this);
			trace(glyphPath);
			fullPath.extendWithPath(glyphPath);
		});
		trace(fullPath);
		return fullPath;
	};

	/**
	 * Helper function that invokes the given callback for each glyph in the given text.
	 * The callback gets `(glyph, x, y, fontSize, options)`.* @param  {string} text
	 * @param {string} text - The text to apply.
	 * @param  {number} [x=0] - Horizontal position of the beginning of the text.
	 * @param  {number} [y=0] - Vertical position of the *baseline* of the text.
	 * @param  {number} [fontSize=72] - Font size in pixels. We scale the glyph units by `1 / unitsPerEm * fontSize`.
	 * @param  {GlyphRenderOptions=} options
	 * @param  {Function} callback
	 */
	function forEachGlyph(text:String, x:Float, y:Float, fontSize:Float, options:Dynamic, callback:Font->Glyph->Float->Float->Float->Dynamic->Void) {
		trace('text ' + text);
		x = x != null ? x : 0;
		y = y != null ? y : 0;
		fontSize = fontSize != null ? fontSize : 72;

		// options = Object.assign({}, this.defaultRenderOptions, options);

		final fontScale = 1 / this.unitsPerEm * fontSize;
		final glyphs = this.stringToGlyphs(text, options);

		// var kerningLookups;
		// if (options.kerning) {
		// 	final script = options.script || this.position.getDefaultScriptName();
		// 	kerningLookups = this.position.getKerningTables(script, options.language);
		// }

		for (i in 0...glyphs.length) {
			final glyph = glyphs[i];

			callback(this, glyph, x, y, fontSize, options);

			if (glyph.advanceWidth != null) {
				x += glyph.advanceWidth * fontScale;
			}

			// if (options.kerning && i < glyphs.length - 1) {
			// 	// We should apply position adjustment lookups in a more generic way.
			// 	// Here we only use the xAdvance value.
			// 	final kerningValue = kerningLookups ? this.position.getKerningValue(kerningLookups, glyph.index,
			// 		glyphs[i + 1].index) : this.getKerningValue(glyph, glyphs[i + 1]);
			// 	x += kerningValue * fontScale;
			// }

			// if (options.letterSpacing) {
			// 	x += options.letterSpacing * fontSize;
			// } else if (options.tracking) {
			// 	x += (options.tracking / 1000) * fontSize;
			// }
		}
		return x;
	};

	/**
	 * Convert the given text to a list of Glyph objects.
	 * Note that there is no strict one-to-one mapping between characters and
	 * glyphs, so the list of returned glyphs can be larger or smaller than the
	 * length of the given string.
	 * @param  {string}
	 * @param  {GlyphRenderOptions} [options]
	 * @return {opentype.Glyph[]}
	 */
	function stringToGlyphs(s:String, options:Dynamic):Array<Glyph> {
		final bidi = new Bidi();
		// // Create and register 'glyphIndex' state modifier
		final charToGlyphIndexMod = (token:Token, contextParams:ContextParams) -> this.charToGlyphIndex(token.char);
		bidi.registerModifier('glyphIndex', null, charToGlyphIndexMod);

		// bidi.registerModifier('glyphIndex', null, charToGlyphIndexMod);
		// // roll-back to default features
		// var features = options ? this.updateFeatures(options.features) : this.defaultRenderOptions.features;
		// bidi.applyFeatures(this, features);
		// final indexes = bidi.getTextGlyphs(s);
		// var length = indexes.length;

		trace(s);
		final indexes:Array<Int> = s.split('').map(s -> s.charCodeAt(0));
		trace(indexes);

		// convert glyph indexes to glyph objects
		final glyphs = [];
		for (i in 0...indexes.length) {
			final glyph = this.glyphs.get(indexes[i]);
			glyphs[i] = glyph != null ? glyph : this.glyphs.get(0);
		}
		return glyphs;
	};
}

class HorizontalMetrics {
	public function new(advanceWidth, leftSideBearing) {
		this.advanceWidth;
		this.leftSideBearing;
	}

	public var advanceWidth:Int;
	public var leftSideBearing:Int;
}

@:structInit
class FontOptions {
	public function new(?names, ?unitsPerEm, ?ascender, ?descender, ?createdTimestamp, ?weightClass, ?widthClass, ?fsSelection, ?glyphs, ?tables) {
		this.names = names;
		this.unitsPerEm = unitsPerEm;
		this.ascender = ascender;
		this.descender = descender;
		this.createdTimestamp = createdTimestamp;
		this.weightClass = weightClass;
		this.widthClass = widthClass;
		this.fsSelection = fsSelection;
		this.glyphs = glyphs;
		this.tables = tables;
	}

	public var names:FontNames;
	public var unitsPerEm:Int;
	public var ascender:Int;
	public var descender:Int;
	public var createdTimestamp:Int;
	public var weightClass:String;
	public var widthClass:String;
	public var fsSelection:Int;
	public var glyphs:Array<Glyph>;
	public var tables:Tables;
}

@:structInit
class FontNames {
	public function new(?fontFamily, ?styleName, ?fontSubfamily, ?fullName, ?postScriptName, ?designer, ?designerURL, ?manufacturer, ?manufacturerURL,
			?license, ?licenseURL, ?version, ?description, ?copyright, ?trademark) {
		this.fontFamily = fontFamily;
		this.styleName = styleName;
		this.fontSubfamily = fontSubfamily;
		this.fullName = fullName;
		this.postScriptName = postScriptName;
		this.designer = designer;
		this.designerURL = designerURL;
		this.manufacturer = manufacturer;
		this.manufacturerURL = manufacturerURL;
		this.license = license;
		this.licenseURL = licenseURL;
		this.version = version;
		this.description = description;
		this.copyright = copyright;
		this.trademark = trademark;
	}

	public var fontFamily:String;
	public var styleName:String;
	public var fontSubfamily:String;
	public var fullName:String;
	public var postScriptName:String;
	public var designer:String;
	public var designerURL:String;
	public var manufacturer:String;
	public var manufacturerURL:String;
	public var license:String;
	public var licenseURL:String;
	public var version:String;
	public var description:String;
	public var copyright:String;
	public var trademark:String;
}
