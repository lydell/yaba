# Expect

Minimalistic BDD assertion toolkit based on
[should.js](http://github.com/visionmedia/should.js)

```js
expect(window.r).to.be(undefined);
expect({ a: 'b' }).to.eql({ a: 'b' })
expect(5).to.be.a('number');
expect([]).to.be.an('array');
expect(window).not.to.be.an(Image);
```

```coffee
assert window.r is undefined
alt: assert typeof r is "undefined"
alt: type(window.r) is "undefined"
assert equal {a: "b"}, {a: "b"}
assert typeof 5 is "number"
alt: assert 5.constructor is Number
alt: assert type(5) is "number"
assert [] instanceof Array
alt: [].constructor is Array
alt: assert {}.toString.call([]) is "[object Array]"
alt: assert type([]) is "array"
assert window not instanceof Image
alt: window.constructor isnt Image
```

## How to use

### Node

Install it with NPM or add it to your `package.json`:

```
$ npm install expect.js
```

```
$ npm install yaba
```

Then:

```js
var expect = require('expect.js');
```

```coffee
assert = require "yaba"
type   = require "your-favorite-type-checker" # (*)
equal  = require "some-equal-module" # (*)
throws = require "throws" # https://github.com/lydell/throws
```

(*) Note: There is no perfect solution for type-checking and deep equality in JavaScript. Use
something that you like, identifies what you need and works where it should. [component/type] and
[substack/node-deep-equal] might be good choices sometimes.

[component/type]: https://github.com/component/type
[substack/node-deep-equal]: https://github.com/substack/node-deep-equal

### Browser

Expose the `expect.js` found at the top level of this repository.

```html
<script src="expect.js"></script>
```

```html
<script src="yaba-bundle.js"></script>
```

## API

**ok**: asserts that the value is _truthy_ or not

```js
expect(1).to.be.ok();
expect(true).to.be.ok();
expect({}).to.be.ok();
expect(0).to.not.be.ok();
```

```coffee
assert 1
assert true
assert {}
assert not 0
```

**be** / **equal**: asserts `===` equality

```js
expect(1).to.be(1)
expect(NaN).not.to.equal(NaN);
expect(1).not.to.be(true)
expect('1').to.not.be(1);
```

```coffee
assert 1 == 1
assert NaN != NaN
assert 1 isnt true
assert '1' isnt 1
```

**eql**: asserts loose equality that works with objects

```js
expect({ a: 'b' }).to.eql({ a: 'b' });
expect(1).to.eql('1');
```

```coffee
assert equal {a: "b"}, {a: "b"}
assert equal 1, "1"


**a**/**an**: asserts `typeof` with support for `array` type and `instanceof`

```js
// typeof with optional `array`
expect(5).to.be.a('number');
expect([]).to.be.an('array');  // works
expect([]).to.be.an('object'); // works too, since it uses `typeof`

// constructors
expect(5).to.be.a(Number);
expect([]).to.be.an(Array);
expect(tobi).to.be.a(Ferret);
expect(person).to.be.a(Mammal);
```

```coffee
assert typeof 5 is "number"
alt: assert 5.constructor is Number
alt: assert type(5) is "number"
assert [] instanceof Array
alt: [].constructor is Array
alt: assert {}.toString.call([]) is "[object Array]"
alt: assert type([]) is "array"
assert type([]) isnt "object"
assert tobi instanceof Ferret
alt: assert tobi.constructor is Ferret
# Same thing for `person`.
```

**match**: asserts `String` regular expression match

```js
expect(program.version).to.match(/[0-9]+\.[0-9]+\.[0-9]+/);
```

```coffee
assert program.version.match(/[0-9]+\.[0-9]+\.[0-9]+/)
```

**contain**: asserts indexOf for an array or string

```js
expect([1, 2]).to.contain(1);
expect('hello world').to.contain('world');
```

```coffee
assert 1 in [1, 2]
assert "hello world".indexOf("world") >= 0
alt: assert ~"hello world".indexOf("world")
alt: assert "world" in "hello world".split(" ")
alt: assert "hello world".contains("hello") # Might need polyfill.
```

**length**: asserts array `.length`

```js
expect([]).to.have.length(0);
expect([1,2,3]).to.have.length(3);
```

```coffee
assert [].length is 0
assert [1,2,3].length is 3
```

**empty**: asserts that an array is empty or not

```js
expect([]).to.be.empty();
expect({}).to.be.empty();
expect({ length: 0, duck: 'typing' }).to.be.empty();
expect({ my: 'object' }).to.not.be.empty();
expect([1,2,3]).to.not.be.empty();
```

```coffee
assert [].length is 0
assert Object.keys({}).length is 0
assert {length: 0, duck: "typing"}.length is 0
assert Object.keys({my: "object"}).length isnt 0
assert [1, 2, 3].length isnt 0
```

**property**: asserts presence of an own property (and value optionally)

```js
expect(window).to.have.property('expect')
expect(window).to.have.property('expect', expect)
expect({a: 'b'}).to.have.property('a');
```

```coffee
# `.hasOwnProperty()` might have been modified, yes, I know.
assert window.hasOwnProperty("expect")
assert window.expect is expect
assert {a: "b"}.hasOwnProperty("a")

# This might be enough sometimes.
assert window.expect?
assert window.expect is expect
assert {a: "b"}.a?
```

**key**/**keys**: asserts the presence of a key. Supports the `only` modifier

```js
expect({ a: 'b' }).to.have.key('a');
expect({ a: 'b', c: 'd' }).to.only.have.keys('a', 'c');
expect({ a: 'b', c: 'd' }).to.only.have.keys(['a', 'c']);
expect({ a: 'b', c: 'd' }).to.not.only.have.key('a');
```

```coffee
assert "a" of {a: "b"}
alt: assert "a" in Object.keys({a: "b"})
assert equal Object.keys({a: "b", c: "d"}), ["a", "c"]
assert not equal Object.keys({a: "b", c: "d"}), ["a"]
```

**throwException**/**throwError**: asserts that the `Function` throws or not when called

```js
expect(fn).to.throwError(); // synonym of throwException
expect(fn).to.throwException(function (e { // get the exception object
  expect(e).to.be.a(SyntaxError);
};
expect(fn).to.throwException(/matches the exception message/);
expect(fn2).to.not.throwException();
```

```coffee
assert try fn() and false catch then true
alt: do ->
    try fn()
    catch error
    assert error?
alt: assert throws fn
assert try fn() and false catch error then error instanceof SyntaxError
alt: do ->
    try fn()
    catch error
    assert error instanceof SyntaxError
alt: assert throws SyntaxError, fn
assert try fn() and false catch error then error.message.match(/matches the exception message/)
alt: do ->
    try fn()
    catch error
    assert error?.message.match(/matches the exception message/)
alt: assert throws Error(/matches the exception message/), fn
assert try fn2() and true catch then false
alt: do ->
    try fn2()
    catch error
    assert not error?
alt: assert not throws fn2
```

**withArgs**: creates anonymous function to call fn with arguments

```js
expect(fn).withArgs(invalid, arg).to.throwException();
expect(fn).withArgs(valid, arg).to.not.throwException();
```

```coffee
assert try fn(invalid, arg) and false catch then true
alt: do ->
    try fn(invalid, arg)
    catch error
    assert error?
alt: assert throws -> fn(invalid, arg)
alt: assert throws fn, invalid, arg
assert try fn(valid, arg) and true catch then false
alt: do ->
    try fn(valid, arg)
    catch error
    assert not error?
alt: assert not throws -> fn(valid, arg)
alt: assert not throws fn, valid, arg
```

**within**: asserts a number within a range

```js
expect(1).to.be.within(0, Infinity);
```

```coffee
assert 0 <= 1 <= Infinity
```

**greaterThan**/**above**: asserts `>`

```js
expect(3).to.be.above(0);
expect(5).to.be.greaterThan(3);
```

```coffee
assert 3 > 0
assert 5 > 3
```

**lessThan**/**below**: asserts `<`

```js
expect(0).to.be.below(3);
expect(1).to.be.lessThan(3);
```

```coffee
assert 0 < 3
assert 1 < 3
```

**fail**: explicitly forces failure.

```js
expect().fail()
expect().fail("Custom failure message")
```

```coffee
assert false
assert false and "Custom failure message"
alt: assert "Custom failure message".fail
alt: assert false # Custom failure message
alt: do ->
    assert.message = "Custom failure message"
    assert false
```

## Using with a test framework

For example, if you create a test suite with
[mocha](http://github.com/visionmedia/mocha).

Let's say we wanted to test the following program:

**math.js**

```js
function add (a, b) { return a + b; };
```

```coffee
add = (a, b)-> a + b
```

Our test file would look like this:

```js
describe('test suite', function () {
  it('should expose a function', function () {
    expect(add).to.be.a('function');
  });

  it('should do math', function () {
    expect(add(1, 3)).to.equal(4);
  });
});
```

```coffee
describe "test suite", ->
	it "exposes a function", ->
		assert typeof add is "function"
		assert add instanceof Function
		assert add.constructor is Function
		assert type(add) is "function"

	it "does math", ->
		assert add(1, 3) == 4
```
