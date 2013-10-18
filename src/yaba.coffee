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

parseStack     = require "parse-stack"
getExpression  = require "./getExpression"


yaba = (value)->
	yaba.runs += 1
	if value
		clean()
		return

	# Internet Explorer set the `stack` property not until an error is thrown.
	try throw new Error catch error

	# There is a lot that could go wrong with getting the expression. Don't let that disturb tests.
	# The fallback will be used if needed.
	#TODO: Tests?
	try
		stack = parseStack(error)
		if stack
			# At this point the stack trace is: `yaba` > call of `yaba`.
			expression = getExpression(stack[1])
	catch error
		console?.log "yaba: #{error}"

	message = expression or "Assertion #{yaba.runs} failed"
	message += " -- #{yaba.message}" if yaba.message

	assertionError = new Error message
	assertionError.yaba = yaba.error

	assertionError.actual   = yaba.actual
	assertionError.expected = yaba.expected

	clean()

	throw assertionError

yaba.runs = 0
yaba.error = {}

clean = -> yaba.actual = yaba.expected = yaba.message = undefined

module.exports = yaba
