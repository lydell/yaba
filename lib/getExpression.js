// Generated by CoffeeScript 1.6.3
/*
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
*/

var getExpression, readFileSync, validate;

readFileSync = require("./readFileSync");

getExpression = function(_arg) {
  var additionalLinesRegex, columnNumber, emptyLine, expression, file, filepath, indentation, lastLine, lastMatchWasLastLine, line, lineNumber, match, moreIndentedLine, _base, _i, _len, _ref, _ref1, _ref2, _ref3;
  filepath = _arg.filepath, lineNumber = _arg.lineNumber, columnNumber = _arg.columnNumber;
  if (typeof filepath !== "string") {
    throw new TypeError("The file path (`" + filepath + "`) must be a string.");
  }
  file = (_base = getExpression.fileCache)[filepath] != null ? (_base = getExpression.fileCache)[filepath] : _base[filepath] = getExpression.readFileSync(filepath, "utf-8").split(/\r\n|\r|\n/);
  validate(lineNumber, "line number", file.length, "file");
  lineNumber -= 1;
  line = file[lineNumber];
  indentation = line.match(/^\s*/)[0];
  if (columnNumber != null) {
    validate(columnNumber, "column number", line.length, "line");
    columnNumber -= 1;
  } else {
    columnNumber = indentation.length;
  }
  expression = [];
  expression.push(line.slice(columnNumber));
  additionalLinesRegex = RegExp("^(?:(\\s*)|" + indentation + "(?:(\\s+.*)|(['\"\\s]*[)}\\]].*)))$");
  lastMatchWasLastLine = false;
  _ref = file.slice(lineNumber + 1);
  for (_i = 0, _len = _ref.length; _i < _len; _i += 1) {
    line = _ref[_i];
    _ref2 = (_ref1 = line.match(additionalLinesRegex)) != null ? _ref1 : [], match = _ref2[0], emptyLine = _ref2[1], moreIndentedLine = _ref2[2], lastLine = _ref2[3];
    if (match == null) {
      break;
    }
    if (lastMatchWasLastLine && lastLine) {
      break;
    }
    expression.push((_ref3 = emptyLine != null ? emptyLine : moreIndentedLine) != null ? _ref3 : lastLine);
    lastMatchWasLastLine = lastLine != null;
  }
  return expression.join("\n").replace(/\s+$/, "");
};

getExpression.fileCache = {};

getExpression.readFileSync = readFileSync;

validate = function(number, numberName, limit, limitName) {
  if (!(typeof number === "number" && Math.floor(number) === number)) {
    throw new TypeError("The " + numberName + " (`" + number + "`) must be a whole number.");
  }
  if (!((1 <= number && number <= limit))) {
    throw new RangeError("The " + numberName + " (`" + number + "`) must be within the " + limitName + " (max " + limit + ").");
  }
};

module.exports = getExpression;
