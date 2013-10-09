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

if typeof XMLHttpRequest is "function"
	readFileSync = (path)->
		request = new XMLHttpRequest
		request.open("GET", path, false) # `false` makes the request synchronous.
		request.send(null) # `null` indicates that no body content is needed.

		if request.status is 200
			return request.responseText
		else
			throw new Error "Could not fetch #{path}:\n#{request.responseText}"
else
	{readFileSync} = require "fs"

module.exports = readFileSync
