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

function util.secsToTime(s)
  local days = 0
  if s >= 86400 then
    days = math.floor(s/86400)
    return string.format("%02d", days) .. ":" .. os.date("!%X", s - (days * 86400))
  else
    return os.date("!%X", s)
  end
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
