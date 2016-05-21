--------------------------
-- prettyTable
--
-- This library is inspired in https://github.com/Automattic/cli-table
--------------------------

local unicode = require("unicode")
local util = require("util") -- for applyIf

-------------------------------------------------------------------------------

local prettyTable = {
    defaults = {
        chars = {
            topLeft = '┌',
            top = '─',
            topMid = '┬',
            topRight = '┐',

            left = '│',
            middle = '│',
            right = '│',

            midLeft = '├',
            mid = '─',
            midMid = '┼',
            midRight = '┤',

            bottomLeft = '└',
            bottom = '─',
            bottomMid = '┴',
            bottomRight = '┘',

            truncate = '…'
        },

        style = {
            paddingLeft = 1,
            paddingRight = 1,

            marginLeft = 0,

            compact = false
        },

        colWidths = {},
        head = {},
        rows = {}
    }
}

-------------------------------------------------------------------------------

function prettyTable:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Apply defaults
    util.applyIf(self.defaults, o)

    return o
end

function prettyTable:push (row)
    table.insert(self.rows, row)
end

function prettyTable:toString ()
    if #self.head == 0 and #self.rows == 0 then
        return ''
    end

    --Alias
    local char = self.chars
    local style = self.style

    if #self.colWidths == 0 then
        local firstRow = #self.head ~= 0 and self.head or self.rows[1]

        for i, col in ipairs(firstRow) do
            self.colWidths[i] = -#tostring(col);
        end
    end

    local line = function (left, fill, mid, right)
        local totalPadding = style.paddingLeft + style.paddingRight
        local line = string.rep(' ', style.marginLeft) .. left
        for i, width in ipairs(self.colWidths) do
            line = line .. string.rep(fill, math.abs(width) + totalPadding) .. mid
        end

        return unicode.sub(line, 1, -2) .. right
    end

    local truncate = function (str, len, truncateChar)
        truncateChar = truncateChar or '…'
        return unicode.len(str) > len and unicode.sub(str, 1, len - 1) .. truncateChar or str
    end

    local dataRow = function (row, left, mid, right, truncateChar, forceLeft)
        local line = string.rep(' ', style.marginLeft) .. left
        for i, width in ipairs(self.colWidths) do
            line = line ..
                string.rep(' ', style.paddingLeft) ..
                string.format('%' .. (forceLeft and -math.abs(width) or width) .. 's',
                    truncate(row[i], math.abs(width), truncateChar)
                ) ..
                string.rep(' ', style.paddingRight) .. mid
        end

        return unicode.sub(line, 1, -2) .. right
    end

    local content = ''

    if #self.head ~= 0 then
        content = content .. dataRow(self.head, char.left, char.middle, char.right, char.truncate, true) .. "\n"
    end

    for i, row in ipairs(self.rows) do
        if (i == 1 and #self.head ~= 0) or (i ~= 1 and not style.compact) then
            content = content .. line(char.midLeft, char.mid, char.midMid, char.midRight) .. "\n"
        end
        content = content .. dataRow(self.rows[i], char.left, char.middle, char.right, char.truncate, false) .. "\n"
    end

    return line(char.topLeft, char.top, char.topMid, char.topRight) .. "\n" ..
           content ..
           line(char.bottomLeft, char.bottom, char.bottomMid, char.bottomRight) .. "\n"
end

-------------------------------------------------------------------------------

return prettyTable
