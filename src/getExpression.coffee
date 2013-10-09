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

readFileSync = require "./readFileSync"


getExpression = ({filepath, lineNumber, columnNumber})->
	unless typeof filepath is "string"
		throw new TypeError "The file path (`#{filepath}`) must be a string."

	file = getExpression.fileCache[filepath] ?=
		getExpression.readFileSync(filepath, "utf-8").split(/\r\n|\r|\n/)

	validate lineNumber, "line number", file.length, "file"
	lineNumber -= 1
	line = file[lineNumber]

	[indentation] = line.match(/^\s*/)

	if columnNumber?
		validate columnNumber, "column number", line.length, "line"
		columnNumber -= 1
	else
		columnNumber = indentation.length

	expression = []
	expression.push(line[columnNumber..])

	additionalLinesRegex = ///
		^
		(?:
			(\s*)                     # emptyLine
			|
			#{indentation}
			(?:
				(\s+.*)               # moreIndentedLine
				|
				( ['"\s]* [)}\]] .* ) # lastLine
			)
		)
		$
		///

	lastMatchWasLastLine = no
	for line in file[lineNumber+1..] by 1
		[match, emptyLine, moreIndentedLine, lastLine] = line.match(additionalLinesRegex) ? []
		break unless match?
		break if lastMatchWasLastLine and lastLine
		expression.push(emptyLine ? moreIndentedLine ? lastLine)
		lastMatchWasLastLine = lastLine?

	expression.join("\n").replace(/\s+$/, "") # The regex might result in a blank line at the end.

getExpression.fileCache = {}
getExpression.readFileSync = readFileSync

validate = (number, numberName, limit, limitName)->
	unless typeof number is "number" and Math.floor(number) == number
		throw new TypeError "The #{numberName} (`#{number}`) must be a whole number."

	unless 1 <= number <= limit
		throw new RangeError """
			The #{numberName} (`#{number}`) must be within the #{limitName} (max #{limit}).
			"""

module.exports = getExpression
