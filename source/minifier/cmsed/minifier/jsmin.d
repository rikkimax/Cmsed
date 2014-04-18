module cmsed.minifier.jsmin;
import std.string : indexOf, strip, chomp, toLower;
import std.conv : to;
import std.regex;

/**
 * Ported from https://code.google.com/p/minify/source/browse/min/lib/JSMin.php
 * 
 * JSMin.php - modified PHP implementation of Douglas Crockford's JSMin.
 *
 * <code>
 * $minifiedJs = JSMin::minify($js);
 * </code>
 *
 * This is a modified port of jsmin.c. Improvements:
 *
 * Does not choke on some regexp literals containing quote wcharacters. E.g. /'/
 *
 * Spaces are preserved after some add/sub operators, so they are not mistakenly
 * converted to post-inc/dec. E.g. a + ++b -> a+ ++b
 *
 * Preserves multi-line comments that begin with /*!
 *
 * PHP 5 or higher is required.
 *
 * Permission is hereby granted to use this version of the library under the
 * same terms as jsmin.c, which has the following license:
 *
 * --
 * Copyright (c) 2002 Douglas Crockford  (www.crockford.com)
 *
 * Permission is hereby granted, free of wcharge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * The Software shall be used for Good, not Evil.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * --
 *
 * @package JSMin
 * @author Ryan Grove <ryan@wonko.com> (PHP port)
 * @author Steve Clay <steve@mrclay.org> (modifications + cleanup)
 * @author Andrea Giammarchi <http://www.3site.eu> (spaceBeforeRegExp)
 * @copyright 2002 Douglas Crockford <douglas@crockford.com> (jsmin.c)
 * @copyright 2008 Ryan Grove <ryan@wonko.com> (PHP port)
 * @license http://opensource.org/licenses/mit-license.php MIT License
 * @link http://code.google.com/p/jsmin-php/
 */

wstring minify(wstring js) {
	JSMin jsmin = new JSMin(js);
	return jsmin.min();
}

enum ORD_LF = 10;
enum ORD_SPACE = 32;
enum ACTION_KEEP_A = 1;
enum ACTION_DELETE_A = 2;
enum ACTION_DELETE_A_B = 3;

class JSMin {
	protected {
		wchar a = '\n';
		wchar b;
		wstring input = "";
		size_t inputIndex = 0;
		size_t inputLength = 0;
		wchar lookAhead = wchar.init;
		wstring output = "";
		wchar lastByteOut;
		wstring keptComment = "";
	}
	
	this(wstring input) {
		this.input = input;
	}
	
	wstring min() {
		size_t command;
		
		if (output != "") {
			return output;
		}
		
		wstring mbIntEnc;
		
		input = input.replace("\r\n", "\n");
		inputLength = input.length;
		
		action(ACTION_DELETE_A_B);
		
		while (a != wchar.init) {
			command = ACTION_KEEP_A;
			if (a == ' ') {
				if (lastByteOut == '+' || lastByteOut == '-') {
				} else if (!isAlphaNum(b)) {
					command = ACTION_DELETE_A;
				}
			} else if (a == '\n') {
				if (b == ' ') {
					command = ACTION_DELETE_A_B;
				} else if (b == wchar.init || ("{[(+-!~".indexOf(b) == -1 && !isAlphaNum(b))) {
					command = ACTION_DELETE_A;
				}
			} else if (!isAlphaNum(a)) {
				if (b == ' ' || (b == '\n' && "}])+-\"'".indexOf(a))) {
					command = ACTION_DELETE_A_B;
				}
			}
			action(command);
		}
		output = output.strip();
		
		if (mbIntEnc !is null) {
			//mb_internal_encoding(mbIntEnc);
		}
		
		return output;
	}
	
	void action(size_t command) {
		if (command == ACTION_DELETE_A_B && b == ' ' && (a == '+' || a == '-')) {
			if (input[inputIndex] == a) {
				command = ACTION_KEEP_A;
			}
		}
		
		switch(command) {
			case ACTION_KEEP_A:
				output ~= a;
				
				if(keptComment != "") {
					output = output.chomp("\n");
					output ~= keptComment;
					keptComment = "";
				}
				
				lastByteOut = a;
				
				goto case ACTION_DELETE_A;
				
			case ACTION_DELETE_A:
				a = b;
				
				if (a =='\'' || a == "\""[0]) {
					wstring str = a ~ ""w;
					
					while(true) {
						output ~= a;
						lastByteOut = a;
						
						a = get();
						
						if (a == b) {
							break;
						}
						
						if (isEOF(a)) {
							size_t byte_ = inputIndex - 1;
							throw new JSMin_UnterminatedstringException(
								"JSMin: Unterminated string at byte " ~ to!string(byte_) ~ ": " ~ to!string(str));
						}
						
						str ~= a;
						
						if (a == '\\') {
							output ~= a;
							lastByteOut = a;
							a = get();
							str ~= a;
						}
					}
				}
				
				goto case ACTION_DELETE_A_B;
				
			case ACTION_DELETE_A_B:
				b = next();
				
				if (b == '/' && isRegexpLiteral()) {
					output ~= a  ~ ""w ~ b;
					wstring pattern = "/";
					
				F1: while(true) {
						a = get();
						pattern ~= a;
						if (a == '[') {
						F2: while(true) {
								output ~= a;
								a = get();
								pattern ~= a;
								
								if (a == ']') {
									break F2;
								}
								if (a == '\\') {
									output ~= a;
									a = get();
									pattern ~= a;
								}
								if (isEOF(a)) {
									throw new JSMin_UnterminatedRegExpException(
										"JSMin: Unterminated set in RegExp at byte " ~ to!string(inputIndex) ~ ": " ~ to!string(pattern));
								}
							}
						}
						
						if (a == '/') {
							break F1;
						} else if (a == '\\') {
							output ~= a;
							a = get();
							pattern ~= a;
						} else if (isEOF(a)) {
							size_t byte_ = inputIndex - 1;
							throw new JSMin_UnterminatedRegExpException(
								"JSMin: Unterminated RegExp at byte " ~ to!string(byte_) ~ ": " ~ to!string(pattern));
						}
						
						output ~= a;
						lastByteOut = a;
					}
					
					b = next();
				}
				
				break;
				
			default:
				break;
		}
	}
	
	bool isRegexpLiteral() {
		if ("(,=:[!&|?+-~*{;".indexOf(a) >= 0) {
			return true;
		}
		
		wstring recentOutput = output[$-10 .. $];
		
		foreach(keyword; ["return"w, "typeof"w]) {
			if (a != keyword[$-1]) {
				continue;
			}
			
			auto regex = regex("~(^|[\\s\\S])"w ~ keyword[0 .. $-1] ~ "$~"w);
			auto matches = matchAll(recentOutput, regex);
			
			if (!matches.empty) {
				matches.popFront();
				if (!matches.empty) {
					wstring m = matches.front.hit;
					if (m == "" || (m.length == 1 && !isAlphaNum(m[0]))) {
						return true;
					}
				}
			}
		}
		
		if (a == ' ' || a == '\n') {
			auto regex = ctRegex!("~(^|[\\s\\S])(?:case|else|in|return|typeof)$~"w);
			auto matches = matchAll(recentOutput, regex);
			
			if (!matches.empty) {
				matches.popFront();
				if (!matches.empty) {
					wstring m = matches.front.hit;
					if (m == ""w || (m.length == 1 && !isAlphaNum(m[0]))) {
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	wchar get() {
		wchar c = lookAhead;
		lookAhead = wchar.init;
		
		if (c == wchar.init) {
			if (inputIndex < inputLength) {
				c = input[inputIndex];
				inputIndex++;
			} else {
				c = wchar.init;
			}
		}
		
		if ((cast(uint)c) >= ORD_SPACE || c == '\n' || c == wchar.init) {
			return c;
		}
		
		if (c == '\r') {
			return '\n';
		}
		
		return ' ';
	}
	
	bool isEOF(wchar a) {
		return (cast(uint)a) <= ORD_LF;
	}
	
	wchar peek() {
		lookAhead = get();
		return lookAhead;
	}
	
	bool isAlphaNum(wchar c) {
		switch(c) {
			case '$':
			case '_':
			case 0: .. case 9:
			case 'A': .. case 'Z':
			case 'a': .. case 'z':
				return true;
				
			default:
				return (cast(uint)c) > ubyte.max;
		}
	}
	
	void consumeSingleLineComment() {
		wstring comment = "";
		
		while(true) {
			wchar get = get();
			comment ~= get;
			
			if ((cast(uint)get) <= ORD_LF) {
				auto regex = ctRegex!("/^\\/@(?:cc_on|if|elif|else|end)\\b/"w);
				auto matches = matchAll(comment, regex);
				if (!matches.empty) {
					keptComment = "/" ~ comment;
				}
				
				return;
			}
		}
	}
	
	void consumeMultipleLineComment() {
		get();
		wstring comment = "";
		
		while(true) {
			wchar get = this.get();
			
			if (get == '*') {
				if (peek() == '/') {
					this.get();
					if (comment.indexOf("!") == 0) {
						if (keptComment != "") {
							keptComment = "\n";
						}
						keptComment ~= "/*!" ~ comment[1 .. $] ~ "*/\n";
					} else {
						auto regex = ctRegex!("/^\\/@(?:cc_on|if|elif|else|end)\\b/"w);
						auto matches = matchAll(comment, regex);
						if (!matches.empty) {
							keptComment = "/*" ~ comment ~ "*/";
						}
					}
					
					return;
				}
			} else if (get == wchar.init) {
				throw new JSMin_UnterminatedCommentException(
					"JSMin: Unterminated comment at byte " ~ to!string(inputIndex) ~ ": /*" ~ cast(string)comment);
			}
			
			comment ~= get;
		}
	}
	
	wchar next() {
		wchar get = get();
		if (get == '/') {
			switch(peek()) {
				case '/':
					consumeSingleLineComment();
					get = '\n';
					break;
				case '*':
					consumeMultipleLineComment();
					get = ' ';
					break;
				default:
					break;
			}
		}
		return get;
	}
}

class JSMin_UnterminatedstringException : Exception {
	@safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}

class JSMin_UnterminatedCommentException : Exception {
	@safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}

class JSMin_UnterminatedRegExpException : Exception {
	@safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}

private {
	pure wstring replace(wstring text, wstring oldText, wstring newText, bool caseSensitive = true, bool first = false) {
		wstring ret;
		wstring tempData;
		bool stop;
		foreach(wchar c; text) {
			if (tempData.length > oldText.length && !stop) {
				ret ~= tempData;
				tempData = ""w;
			}
			if (((oldText[0 .. tempData.length] != tempData && caseSensitive) || (oldText[0 .. tempData.length].toLower() != tempData.toLower() && !caseSensitive)) && !stop) {
				ret ~= tempData;
				tempData = ""w;
			}
			tempData ~= c;
			if (((tempData == oldText && caseSensitive) || (tempData.toLower() == oldText.toLower() && !caseSensitive)) && !stop) {
				ret ~= newText;
				tempData = ""w;
				stop = first;
			}
		}
		if (tempData != ""w) {
			ret ~= tempData;	
		}
		return ret;
	}
}