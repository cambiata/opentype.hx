package opentype;

import haxe.ds.StringMap;

using Lambda;

class Tokenizer {
	public function new(?events:TokenizerEventMethods) {
		this.tokens = [];
		this.registeredContexts = new StringMap();
		this.contextCheckers = [];
		this.events = {};
		this.registeredModifiers = [];
		initializeCoreEvents(events);
	}

	public var tokens(default, null):Array<Token>;

	var events:TokenizerEvents;
	var registeredModifiers:Array<String>;

	public final contextCheckers:Array<ContextChecker>;
	public final registeredContexts:StringMap<ContextChecker>;

	public function tokenize(text:String):Array<Token> {
		this.tokens = [];
		this.resetContextsRanges();
		final chars = text.split('');

		this.dispatch('start');

		for (i => char in chars) {
			final contextParams = new ContextParams(chars, i);
			// trace(contextParams);
			this.dispatch('next', [contextParams]);

			this.runContextCheck(contextParams);

			final token = new Token(char);
			this.tokens.push(token);
			this.dispatch('newToken', [token, contextParams]);
		}
		this.dispatch('end', [this.tokens]);
		return this.tokens;
	}

	function resetContextsRanges() {
		// trace('resetContextsRanges...');
		final registeredContexts = this.registeredContexts;
		for (contextName => context in registeredContexts) {
			context.ranges = [];
		}
	}

	function runContextCheck(contextParams:ContextParams) {
		final index = contextParams.index;
		for (contextChecker in this.contextCheckers) {
			final contextName = contextChecker.contextName;
			final context:ContextChecker = this.getContext(contextName);
			var openRange = context.openRange;
			if (openRange == null && contextChecker.checkStart(contextParams)) {
				openRange = new ContextRange(index, null, contextName);
				this.getContext(contextName).openRange = openRange;
				this.dispatch('contextStart', [contextName, index]);
			}

			if (openRange != null && contextChecker.checkEnd(contextParams)) {
				final offset = (index - openRange.startIndex) + 1;
				final range = this.setEndOffset(offset, contextName);
				this.dispatch('contextEnd', [contextName, range]);
			}
		}
	}

	function setEndOffset(offset:Int, contextName:String) {
		final startIndex = this.getContext(contextName).openRange.startIndex;
		var range:ContextRange = new ContextRange(startIndex, offset, contextName);
		final ranges = this.getContext(contextName).ranges;
		range.rangeId = '${contextName}.${ranges.length}';
		ranges.push(range);
		this.getContext(contextName).openRange = null;
		return range;
	}

	static final coreEvents = [
		//
		'start',
		'end',
		'next',
		'newToken',
		'contextStart',
		'contextEnd',
		'insertToken',
		'removeToken',
		'removeRange',
		'replaceToken',
		'replaceRange',
		// 'composeRUD',
		'updateContextsRanges'
	];

	static final requiresContextUpdate = [
		//
		'insertToken',
		'removeToken',
		'removeRange',
		'replaceToken',
		'replaceRange',
		// 'composeRUD'
	];

	function initializeCoreEvents(eventMethods:TokenizerEventMethods) {
		// setup coreEvents
		coreEvents.iter(eventId -> {
			Reflect.setField(this.events, eventId, new Event(eventId));
		});

		final eventFields = Reflect.fields(eventMethods);
		eventFields.iter(eventId -> {
			final fn:Dynamic->Void = Reflect.field(eventMethods, eventId);
			final event = Reflect.field(this.events, eventId);
			event.subscribe(fn);
		});

		requiresContextUpdate.iter(eventId -> {
			final event = Reflect.field(this.events, eventId);
			event.subscribe(this.updateContextsRanges);
		});
	}

	function updateContextsRanges() {
		this.resetContextsRanges();
		final chars = this.tokens.map(token -> token.char);
		for (i in 0...chars.length) {
			final contextParams:ContextParams = new ContextParams(chars, i);
			this.runContextCheck(contextParams);
		}
		this.dispatch('updateContextsRanges', [this.registeredContexts]);
	}

	function dispatch(eventId:String, args:Array<Dynamic> = null) {
		args = args == null ? [] : args;
		final event:{subscribers:Array<Dynamic>} = Reflect.field(this.events, eventId);
		if (event == null) {
			throw 'Event ${eventId} does not exist';
			return;
		}

		event.subscribers.iter((subscriber:Dynamic->Void) -> {
			Reflect.callMethod(null, subscriber, args);
		});
	}

	public function registerModifier(modifierId:String, condition:Dynamic, modifier:Dynamic) {
		final event:Event<Token->ContextParams->Void> = this.events.newToken;

		event.subscribe((token:Token, contextParams:ContextParams) -> {
			final conditionParams:Array<Dynamic> = [token, contextParams];
			final conditionIsNull:Bool = condition == null;
			final conditionApply:Bool = Reflect.callMethod(null, condition, conditionParams);
			final canApplyModifier = conditionIsNull || conditionApply;
			if (canApplyModifier) {
				// final modifierParams:Array<Dynamic> = [token, contextParams];
				final newStateValue:Dynamic = Reflect.callMethod(null, modifier, conditionParams);
				token.setState(modifierId, newStateValue);
			}
		});

		this.registeredModifiers.push(modifierId);
	}

	public function registerContextChecker(contextName:String, contextStartCheck:ContextParams->Bool, contextEndCheck:ContextParams->Bool) {
		if (this.getContext(contextName) != null) {
			trace('context name ${contextName} is already registered');
			return null;
		}

		final contextCheckers = new ContextChecker(contextName, contextStartCheck, contextEndCheck);
		this.registeredContexts.set(contextName, contextCheckers);
		this.contextCheckers.push(contextCheckers);
		return contextCheckers;
	}

	function getContext(contextName:String):ContextChecker {
		return this.registeredContexts.get(contextName);
	}

	public function getContextRanges(contextName:String) {
		final context = this.getContext(contextName);
		if (context != null)
			return context.ranges;

		trace('context checker ${contextName} is not registered.');
		return null;
	}

	public function getRangeTokens(range:ContextRange) {
		final endIndex = range.startIndex + range.endOffset;
		return [].concat(this.tokens.slice(range.startIndex, endIndex));
	}

	public function insertToken(tokens:Array<Token>, index:Int, silent:Bool = false) {
		for (idx => token in tokens)
			this.tokens.insert(index + idx, token);
		if (!silent) {
			final args:Array<Dynamic> = [tokens, index];
			this.dispatch('insertToken', []); // args missing here!
		}
		return tokens;
	}

	public function removeToken(index:Int, silent:Bool = false) {
		if (!this.inboundIndex(index)) {
			trace('removeToken: invalid token index.');
			return null;
		}
		final token = this.tokens.splice(index, 1);
		if (!silent)
			this.dispatch('removeToken', []); // args missing here!
		return token;
	}

	function inboundIndex(index:Int):Bool
		return index >= 0 && index < this.tokens.length;

	public function removeRange(startIndex:Int, offset:Int = null, silent:Bool = false) {
		offset = offset != null ? offset : this.tokens.length;
		final tokens = this.tokens.splice(startIndex, offset);
		if (!silent)
			this.dispatch('removeRange', []); // args missing here!
		return tokens;
	}

	public function replaceToken(index:Int, token:Token, silent:Bool = false) {
		if (!this.inboundIndex(index)) {
			trace('removeToken: invalid token index.');
			return null;
		}
		final replaced = this.tokens.splice(index, 1);
		this.tokens.insert(index, token);
		if (!silent)
			this.dispatch('replaceToken', []); // args missing here!
		return [replaced[0], token];
	}

	public function replaceRange(startIndex:Int, offset:Int, tokens:Array<Token>, silent:Bool = false):Array<Array<Token>> {
		offset = offset != null ? offset : this.tokens.length;
		if (!this.inboundIndex(startIndex)) {
			trace('replaceRange: invalid token index.');
			return null;
		}
		final replaced = this.tokens.splice(startIndex, tokens.length);
		for (idx => token in tokens)
			this.tokens.insert(startIndex + idx, token);

		if (!silent)
			this.dispatch('replaceToken', []); // args missing here!

		return [replaced, tokens];
	}

	public function composeRUD(RUDs:Array<Array<Dynamic>>) {
		final silent = true;
		for (pair in RUDs) {
			final type:String = pair[0];
			switch type {
				case 'insertToken':
					final tokens:Array<Token> = cast pair[1];
					final index:Int = cast pair[2];
					this.insertToken(tokens, index);
				case 'replaceToken':
					final index:Int = cast pair[1];
					final token:Token = cast pair[2];
					this.replaceToken(index, token);
				case 'replaceRange':
					final startIndex:Int = cast pair[1];
					final offset:Int = cast pair[2];
					final tokens:Array<Token> = cast pair[3];
					this.replaceRange(startIndex, offset, tokens);
				case 'removeToken':
					final index:Int = cast pair[1];
					this.removeToken(index);
				default:
					trace(type.toUpperCase());
			}
		}
	}
}

class ContextRange {
	public function new(startIndex:Int, endOffset:Int, contextName:String) {
		this.contextName = contextName;
		this.startIndex = startIndex;
		this.endOffset = endOffset;
		this.rangeId = null;
	}

	public final contextName:String;
	public final startIndex:Int;
	public final endOffset:Int;

	public var rangeId(default, default):String;
}

class ContextChecker {
	public function new(contextName:String, checkStart:ContextParams->Bool, checkEnd:ContextParams->Bool) {
		this.contextName = contextName;
		this.openRange = null;
		this.ranges = [];
		this.checkStart = checkStart;
		this.checkEnd = checkEnd;
	}

	public final contextName:String;
	public final checkStart:ContextParams->Bool;
	public final checkEnd:ContextParams->Bool;

	public var openRange(default, default):ContextRange;
	public var ranges(default, default):Array<ContextRange>;
}

typedef TokenizerEventMethods = {
	?start:Void->Void,
	?next:ContextParams->Void,
	?end:Array<Token>->Void,
	?newToken:Token->ContextParams->Void,
	?contextStart:String->Dynamic->Void,
	?contextEnd:String->Dynamic->Void,
}

typedef TokenizerEvents = {
	?start:Event<Void->Void>,
	?next:Event<ContextParams->Void>,
	?end:Event<Array<Token>->Void>,
	?newToken:Event<Token->ContextParams->Void>,
}

class Event<EMethod> {
	public function new(eventId:String) {
		this.eventId = eventId;
		this.subscribers = [];
	}

	public final eventId:String;
	public final subscribers:Array<EMethod>;

	public function subscribe(fn:EMethod)
		this.subscribers.push(fn);
}

class ContextParams {
	public function new(context:Array<String>, currentIndex:Int) {
		this.context = context;
		this.index = currentIndex;
		this.length = context.length;
		this.current = context[currentIndex];
		this.backtrack = context.slice(0, currentIndex);
		this.lookahead = context.slice(currentIndex + 1);
	}

	public final context:Array<String>;
	public final index:Int;
	public final length:Int;
	public final current:String;
	public final backtrack:Array<String>;
	public final lookahead:Array<String>;

	public function get(offset:Int):String {
		if (offset == 0) {
			return this.current;
		} else if (offset < 0 && Math.abs(offset) <= this.backtrack.length) {
			return this.backtrack.slice(offset)[0];
		} else if (offset > 0 && offset <= this.lookahead.length) {
			return this.lookahead[offset - 1];
		}
		return null;
	}
}

class Token {
	public function new(char:String) {
		this.char = char;
		this.state = {};
		this.activeState = null;
	}

	public final char:String;
	public final state:Dynamic;
	public final activeState:Dynamic;

	public function setState(key:String, value:Dynamic) {
		Reflect.setField(this.state, key, value);
		Reflect.setField(this, 'activeState', {key: key, value: value});
	}
}
