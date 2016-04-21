--------------------------
-- Util
--------------------------
local computer = require("computer")
local component = require('component')

-------------------------------------------------------------------------------

local util = {}

-------------------------------------------------------------------------------

-- From http://lua-users.org/wiki/FormattingNumbers
function util.commaInt(v)
  return util.commaValue(string.format("%d", util.round(v)))
end

function util.commaFloat(f, precision)
  precision = precision or 2
  local fmt = '%.' .. precision .. 'f'
  return util.commaValue(string.format(fmt, util.round(f, precision)))
end

function util.round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function util.commaValue(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
-- END From http://lua-users.org/wiki/FormattingNumbers

util.WEEK   = 604800
util.DAY    = 86400
util.HOUR   = 3600
util.MINUTE = 60

function util.splitSecs(secs)
    local remainder

    local weeks = math.floor(secs / util.WEEK)
    remainder = secs % util.WEEK
    local days = math.floor(remainder / util.DAY)
    remainder = remainder % util.DAY
    local hours = math.floor(remainder / util.HOUR)
    remainder = remainder % util.HOUR
    local minutes = math.floor(remainder / util.MINUTE)
    local seconds = remainder % util.MINUTE

    return weeks, days, hours, minutes, seconds
end

function util.secsToTime(s)
    local weeks, days, hours, minutes, seconds = util.splitSecs(math.abs(s))

    local time = seconds .. ' second(s), '

    if minutes > 0 then
        time  = minutes .. ' minute(s), ' .. time
    end

    if hours > 0 then
        time = hours .. ' hour(s), ' .. time
    end

    if days > 0 then
        time = days .. ' day(s), ' .. time
    end

    if weeks > 0 then
        time = weeks .. ' week(s), ' .. time
    end

    return string.sub(time, 1, -3)
end

function util.getComputerInfo()
    local reactor = require('reactor')
    local turbine = require('turbine')
    local capacitor = require('capacitor')

    local getCmpInfo = {
        ["br_turbine"] = turbine.getInfo,
        ["br_reactor"] = reactor.getInfo,
        ["tile_blockcapacitorbank_name"] = capacitor.getInfo
    }

    local componentsDetails = {}
    for address, componentType in component.list() do
      if componentsDetails[componentType] == nil then
          componentsDetails[componentType] = {}
      end

      if getCmpInfo[componentType] ~= nil then -- For known components
          local proxy = component.proxy(address)
          componentsDetails[componentType][address] = getCmpInfo[componentType](proxy)
      else -- For unknown components
          table.insert(componentsDetails[componentType], address)
      end
    end

    return {
      address = computer.address(),
      totalMemory = computer.totalMemory(),
      freeMemory = computer.freeMemory(),
      maxEnergy = computer.maxEnergy(),
      energy = computer.energy(),
      uptime = computer.uptime(),
      components = componentsDetails
    }
end

-------------------------------------------------------------------------------

return util
