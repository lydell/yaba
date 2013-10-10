###
Copyright 2013 Simon Lydell

This file is part of yaba.

yaba is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

yaba is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with yaba. If not,
see <http://www.gnu.org/licenses/>.
###

{assert, throws, equal, sinon} = require "./common"

getExpression = require "../src/getExpression"


readFileSync = null

before ->
	# Just stubbing normally breaks yaba. It can no longer get the expression, and produces
	# unhelpful errors. Unfortunately, sinon does not seem to ever support this out of the box:
	# <https://github.com/cjohansen/sinon.js/pull/278>
	originalReadFileSync = getExpression.readFileSync
	returnValue = null
	readFileSync = sinon.stub getExpression, "readFileSync", (path, args...)->
		if /^stub/.test(path)
			returnValue
		else
			originalReadFileSync(path, args...)

	# `readFileSync` is actually a spy. Fake the stub method `returns`.
	readFileSync.returns = (value)->
		returnValue = value

after ->
	readFileSync.restore()

describe "getExpression", ->

	beforeEach ->
		getExpression.fileCache = {}
		readFileSync.reset()


	it "is a function", ->
		assert typeof getExpression is "function"


	it "requires an object as argument", ->
		assert throws TypeError, -> getExpression()
		assert throws TypeError, -> getExpression(null)


	it "requires the passed object to have a `filepath` property, which is a string", ->
		assert throws TypeError("file path|string"), -> getExpression({})
		assert throws TypeError("file path|string"), -> getExpression({filepath: undefined})
		assert throws TypeError("file path|string"), -> getExpression({filepath: null})
		assert throws TypeError("file path|string"), -> getExpression({filepath: 1})
		assert throws TypeError("file path|string"), -> getExpression({filepath: [1, 2]})
		assert throws TypeError("file path|string"), -> getExpression({filepath: {}})

		assert not throws TypeError("file path|string"), -> getExpression({filepath: "string"})


	it """returns the string on the given line number, from the given column number, in the given
	   file, which has been fetched using `getExpression.readFileSync`""", ->
		readFileSync.returns """
			do ->
				true and assert false
			"""
		assert getExpression({lineNumber: 2, columnNumber: 11, filepath: "stub"}) is "assert false"
		assert readFileSync.calledWith("stub")


	it "uses the first non-whitespace character if no column number is provided", ->
		readFileSync.returns """
			do ->
				true and assert false
			"""
		assert getExpression({lineNumber: 2, filepath: "stub"}) is
			"true and assert false"
		assert getExpression({lineNumber: 2, columnNumber: undefined, filepath: "stub"}) is
			"true and assert false"
		assert getExpression({lineNumber: 2, columnNumber: null, filepath: "stub"}) is
			"true and assert false"


	it "requires the line number and column number to be sane", ->
		readFileSync.returns """
			ab
			cd
			"""

		assert throws TypeError("line number|whole number|undefined"),
			-> getExpression({lineNumber: undefined, filepath: "stub"})
		assert throws TypeError("line number|whole number|null"),
			-> getExpression({lineNumber: null,      filepath: "stub"})
		assert throws TypeError("line number|whole number|string"),
			-> getExpression({lineNumber: "string",  filepath: "stub"})
		assert throws TypeError("line number|whole number|1,2"),
			-> getExpression({lineNumber: [1, 2],    filepath: "stub"})
		assert throws TypeError("line number|whole number|[object Object]"),
			-> getExpression({lineNumber: {},        filepath: "stub"})
		assert throws TypeError("line number|whole number|1.1"),
			-> getExpression({lineNumber: 1.1,       filepath: "stub"})

		assert throws RangeError("line number|3|file|max 2"),
			-> getExpression({lineNumber: 3, filepath: "stub"})
		assert throws RangeError("line number|0|file|max 2"),
			-> getExpression({lineNumber: 0, filepath: "stub"})

		assert not throws -> getExpression({lineNumber: 1, filepath: "stub"})
		assert not throws -> getExpression({lineNumber: 2, filepath: "stub"})

		assert throws TypeError("column number|whole number|string"),
			-> getExpression({lineNumber: 1, columnNumber: "string", filepath: "stub"})
		assert throws TypeError("column number|whole number|1,2"),
			-> getExpression({lineNumber: 1, columnNumber: [1, 2],   filepath: "stub"})
		assert throws TypeError("column number|whole number|[object Object]"),
			-> getExpression({lineNumber: 1, columnNumber: {},       filepath: "stub"})
		assert throws TypeError("column number|whole number|1.1"),
			-> getExpression({lineNumber: 1, columnNumber: 1.1,      filepath: "stub"})

		assert throws RangeError("column number|3|line|2"),
			-> getExpression({lineNumber: 1, columnNumber: 3, filepath: "stub"})
		assert throws RangeError("column number|0|line|2"),
			-> getExpression({lineNumber: 1, columnNumber: 0, filepath: "stub"})

		assert not throws -> getExpression({lineNumber: 1, columnNumber: 1, filepath: "stub"})
		assert not throws -> getExpression({lineNumber: 1, columnNumber: 2, filepath: "stub"})


	it "fetches a given file once and then retrieves it from `getExpression.fileCache`", ->
		readFileSync.returns """
			file contents
			over several lines
			"""
		assert getExpression({lineNumber: 1, filepath: "stub"}) is "file contents"
		assert readFileSync.calledWith("stub")
		assert equal getExpression.fileCache, {stub: ["file contents", "over several lines"]}
		assert getExpression({lineNumber: 1, filepath: "stub"}) is "file contents"
		assert readFileSync.calledOnce


	it "can use either of \\r\\n, \\r and \\n as newline characters", ->
		readFileSync.returns("a\r\nb\rc\nd")
		assert getExpression({lineNumber: 2, filepath: "stub"}) is "b"
		assert equal getExpression.fileCache, {stub: ["a", "b", "c", "d"]}


	it "handles multiline expressions by consuming subsequent lines with more indentation", ->
		readFileSync.returns """
			assert true and
				false
			assert true
			"""
		assert getExpression({lineNumber: 1, filepath: "stub"}) is """
			assert true and
				false
			"""


	it "allows blank lines in-between, and strips blank lines at the end", ->
		readFileSync.returns """
			it "bar", ->
				assert true
				assert true and

					false

			it "note the blank line above; should be stripped", ->
			"""
		assert getExpression({lineNumber: 3, filepath: "stub"}) is """
			assert true and

				false
			"""


	it "uses the end of the file if needed", ->
		readFileSync.returns """
			assert true and
				false
			"""
		assert getExpression({lineNumber: 1, filepath: "stub"}) is """
			assert true and
				false
			"""


	it """allows lines to have the same amount of indentation if they start with common "ending"
	   characters""", ->
		readFileSync.returns """
			it("intentionally not indenting", function() {
			assert( { message: [ "'
				Hello, World!
			'" ] } !== {other: obj} ); // Comment.
			});
			// The above line should not be mistaken to belong to `assert`.
			"""
		assert getExpression({lineNumber: 2, filepath: "stub"}) is """
			assert( { message: [ "'
				Hello, World!
			'" ] } !== {other: obj} ); // Comment.
			"""

		readFileSync.returns """
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
			"""
		assert getExpression({lineNumber: 2, filepath: "stub2"}) is """
			assert({
				key: value
			}, {
				key: value
			}, {

				blank_above: "works"
			});
			"""

		readFileSync.returns """
			it("blah", function () {
				assert("Next line starts with ending characters, but is not enought indented.");
			})
			"""
		assert getExpression({lineNumber: 2, filepath: "stub3"}) is """
			assert("Next line starts with ending characters, but is not enought indented.");
			"""

		readFileSync.returns """
			assert string is '''
				How can we know if the following line should be included or not?
			'''.split("s").join("S") # Comment.
			'''
				Tricky, eh?
			'''.match /./g, (match) ->
				assert match isnt "!"
			"""
		assert getExpression({lineNumber: 1, filepath: "stub4"}) is """
			assert string is '''
				How can we know if the following line should be included or not?
			"""
