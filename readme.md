[![Build Status](https://travis-ci.org/lydell/yaba.png?branch=master)](https://travis-ci.org/lydell/yaba)

Overview
========

Yet Another Better Assert. `assert(expression)`. If truthy–yay! If falsy: Error _with the
expression!_ **Cross-browser.**

Example:

```javascript
var assert = require("yaba")
describe("maths", function () {
	it("is hard", function () {
		assert(3 < 2)
	})
})
```
```
Error: assert(3 < 2)
```

More examples: (in CoffeeScript)

- [Comparison with LearnBoost/expect.js](example/assertVsExpect.md)
- yaba uses itself to [test](test/) itself!


Installation
============

`npm install yaba`
`component install lydell/yaba`

CommonJS: `var assert = require("yaba")`

AMD and regular old browser globals: Use ./yaba.js


Tests
=====

Node.js: `npm test`

Browser: Open ./test/browser/index.html


Usage
=====

`yaba(expression)`
------------------

Pretty much already explained.

`yaba.actual && yaba.expected && yaba.message`
----------------------------------------------

You can give extra information to yaba by assigning the above properties, which it will use during
the next run—and only then. This way, you can let other tools make yaba show details about why an
assertion failed. An example:

```coffeescript
assert = require "yaba"
equals = require "equals" # https://github.com/jkroso/equals
equal = (actual, expected)->
  assert.actual   = actual
  assert.expected = expected
  equals(actual, expected)
# require compiler, fs/read, etc.

assert equal compiler.compile(read("input.file")), read("input.file.expected")
```

Now, each time you call `equal` it will set up `.actual` and `.expected` for the next yaba call.
yaba then puts those properties on the error it throws.

If your testing frameworks supports `error.actual` and `error.expected` (like [mocha]) you will now
get nice diffs if the `compiler` is buggy, etc.

Just make sure that you always call `equal` inside `yaba`, so you don't leak the information to the
next yaba call.

`yaba.message` will be appended to the message of the thrown error. That is used by the [throws]
module. An example:

```coffeescript
assert = require "assert"
throws = require "throws"
throws.messageHolder = assert

assert throws TypeError, -> throw new Error
```
```
Error: assert throws TypeError, -> throw new Error -- Expected the error to be an instance of TypeError.
```

throws sets `.message` for the next yaba call. Just like `equal`, only call it inside `yaba`.

You can of course set it manually, to display a custom message:

```coffeescript
assert.message = "My custom extra message"
assert false
```
```
Error: assert false -- My custom extra message
```

But it is probably a better idea to use a comment:

```coffeescript
assert false # My custom extra message
```
```
Error: assert false # My custom extra message
```

That's why yaba only takes one parameter, as opposed to many other assert functions which take two:
an expression and an optional message.

[throws]: https://github.com/lydell/throws
[mocha]: https://github.com/visionmedia/mocha

`error.yaba && yaba.error`
--------------------------

Initially I wanted to throw a custom `AssertionError` so you could `error instanceof AssertionError`
check stuff. However, subclassing `Error` sucks in JavaScript, so I took a different approach. You
may check if `error.yaba` is truthy or not, or, for the paranoid, if `error.yaba === yaba.error`.


How it works
============

Modern browsers put a [`stack` property][stack] on error objects, containing a stack trace. yaba
constructs a new error, and then uses [parse-stack] to get the file path to the file containing the
`yaba()` call, as well as the line number and column number (if available) of the call. It then
reads the source file ([note about local testing][local-xhr]), and cuts out the `assert` expression
at the given position.

Better yet, if you're running CoffeeScript files via the `coffee` command, the stack trace will
point to the original CoffeeScript source, giving you the expression in CoffeeScript. (Requires
CoffeeScript > 1.6.3). That's currently not possible in any browser.

If the environment does not put a `stack` property on error objects, yaba still works. You just
don't get the expression in the error message. Instead you get something like "Assertion 15 failed".
The number of runs is actually stored in `assert.runs`. If you plan to use it a lot in some old
browser, you perhaps would like to reset that before each test, like `beforeEach -> assert.runs =
0`, to ease the debugging.

[stack]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/Stack
[parse-stack]: https://github.com/lydell/parse-stack
[local-xhr]: http://leaverou.github.io/prefixfree/#local-xhr


Quirks
======

tl;dr: Format your code sanely and you'll be fine.

The expression will start at the given column number, or if none is available, the beginning of the
line. So if you care about for example Firefox and iOS Safari, put all asserts at the beginning of
the line (after any indentation). If not, do it anyway. It's readable.

The expression will end at the end of the line. So don't put other stuff on the same line as an
assert, if you don't want it to show up in the error messages. It's not worth parsing the JavaScript
to find the exact end of the expression. Moreover, compile-to-js languages should be supported too.
Last but not least, it could be seen as a feature: Any useful comments after an assert will be
included. Even if you don't care: Don't put anything after an assert anyway. Why would you?

I said that the expression ends at the end of the line. That's not really true. Multi-line asserts
are supported—as long as you indent each subsequent line more than the first one. Do that anyway.
It's readable.

Well, the last thing I said wasn't _really_ true either. The last line of a multi-line expression
can be on the same indentation level if it starts with common "ending" characters, such as `]})"'`.
And if such a line is immediately followed by a more indented line, the process starts over. So the
following should work:

```javascript
it("intentionally not indenting", function() {
assert({
  key: value
}, {
  key: value
}, {

  blank_above: "works"
});
});
// The above line should not be mistaken to belong to `assert`.
```

One caveat, for CoffeeScript users:

```coffeescript
assert string is """
	The three ending quotes are going to be missing.
"""
assert string is """
	You could write it this way instead.
	"""
```

While talking about indentation. Never mix spaces and tabs. That'll confuse yaba, you and everyone
else. Don't.


Why "yaba"? What's the difference compared to other assertion libs?
===================================================================

It's an acronym for "Yet Another Better Assert" since it is inspired by [visionmedia/better-assert],
[this fork of it][Pingdom/better-assert] for CoffeeScript support, [rhoot/cassert] and
[component/assert].

The difference is that it works not only in Node.js or V8-powered browsers, but a lot of other
browsers as well. It has the potential to support compile-to-js languages, and currently does so for
CoffeeScript in Node.js. And when it cannot get the expression, it is helpful by giving you the
assertion count. Oh, and don't forget the `.actual`, `.expected` and `.message`.

As a Star Wars fan, I also like that "yaba" sounds a bit like "Jabba" [the Hutt].

[visionmedia/better-assert]: https://github.com/visionmedia/better-assert
[Pingdom/better-assert]: https://github.com/Pingdom/better-assert/tree/feature-coffee
[rhoot/cassert]: https://github.com/rhoot/cassert
[component/assert]: https://github.com/component/assert


License
=======

[LGPLv3](COPYING).
