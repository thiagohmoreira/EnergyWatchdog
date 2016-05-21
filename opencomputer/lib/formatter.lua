--------------------------
-- formatter
--------------------------

local util = require('util') -- for round()

-------------------------------------------------------------------------------

local formatter = {}

-------------------------------------------------------------------------------

-- From http://lua-users.org/wiki/FormattingNumbers
function formatter.commaInt(v)
  return formatter.commaValue(string.format("%d", util.round(v)))
end

function formatter.commaFloat(f, precision)
  precision = precision or 2
  local fmt = '%.' .. precision .. 'f'
  return formatter.commaValue(string.format(fmt, util.round(f, precision)))
end

function formatter.commaValue(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
-- END From http://lua-users.org/wiki/FormattingNumbers

formatter.WEEK   = 604800
formatter.DAY    = 86400
formatter.HOUR   = 3600
formatter.MINUTE = 60

function formatter.splitSecs(secs)
    local weeks = math.floor(secs / formatter.WEEK)

    local remainder = secs % formatter.WEEK
    local days = math.floor(remainder / formatter.DAY)

    remainder = remainder % formatter.DAY
    local hours = math.floor(remainder / formatter.HOUR)

    remainder = remainder % formatter.HOUR
    local minutes = math.floor(remainder / formatter.MINUTE)

    local seconds = math.floor(remainder % formatter.MINUTE)

    return weeks, days, hours, minutes, seconds
end

function formatter.secsToTime(s)
    local weeks, days, hours, minutes, seconds = formatter.splitSecs(math.abs(s))

    local time = ''

    if s == 0 or seconds > 0 then
        time = seconds .. ' second' .. (seconds > 1 and 's' or '') .. ', '
    end

    if minutes > 0 then
        time  = minutes .. ' minute' .. (minutes > 1 and 's' or '') .. ', ' .. time
    end

    if hours > 0 then
        time = hours .. ' hour' .. (hours > 1 and 's' or '') .. ', ' .. time
    end

    if days > 0 then
        time = days .. ' day' .. (days > 1 and 's' or '') .. ', ' .. time
    end

    if weeks > 0 then
        time = weeks .. ' week' .. (weeks > 1 and 's' or '') .. ', ' .. time
    end

    return string.sub(time, 1, -3)
end

return formatter
