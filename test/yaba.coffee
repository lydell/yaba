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

{assert, throws} = require "./common"

yaba = require "../src/yaba"


describe "yaba", ->

	it "is a function", ->
		assert typeof yaba is "function"


	it "does not throw if its argument is truthy", ->
		assert not throws -> yaba(true)
		assert not throws -> yaba(1)
		assert not throws -> yaba([])
		assert not throws -> yaba({})


	it "throws an error if its argument is falsy", ->
		assert throws Error, -> yaba(undefined)
		assert throws Error, -> yaba(null)
		assert throws Error, -> yaba(NaN)
		assert throws Error, -> yaba(false)
		assert throws Error, -> yaba(0)
		assert throws Error, -> yaba("")


	it "tags the thrown error", ->
		try yaba(false) catch error
		assert error.yaba is yaba.error


	it "allows to add actual and expected properties to the thrown error", ->
		yaba.actual   = "foo"
		yaba.expected = "bar"
		try yaba(false) catch error
		assert error.actual   is "foo"
		assert error.expected is "bar"
		assert yaba.actual   is undefined
		assert yaba.expected is undefined

		yaba.actual   = "foo"
		yaba.expected = "bar"
		yaba(true)
		assert yaba.actual   is undefined
		assert yaba.expected is undefined


	it "allows to extend the error message", ->
		yaba.message = "Extra message"
		try yaba(false) catch error
		assert error.message.match(/\ -- Extra message$/)
		assert yaba.message is undefined

		yaba.message = "Extra message"
		yaba(true)
		assert yaba.message is undefined


	it "has a `runs` property", ->
		assert yaba.hasOwnProperty("runs")


	it "increments the `runs` property on each run, regardless of the truthiness of the argument", ->
		yaba.runs = 10
		try yaba(false)
		yaba(true)
		assert yaba.runs is 12


	it "uses the source of its argument expression if available, otherwise the runs count", ->
		yaba.runs = 1336
		try
			# Intentionally JavaScript style.
			yaba(true && false);
		catch error

		assert error.message in ["yaba(true && false);", "Assertion 1337 failed"]
