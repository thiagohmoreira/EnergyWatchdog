--------------------------
-- Util
--------------------------
local JSON = require("JSON")

-------------------------------------------------------------------------------

local util = {}

-------------------------------------------------------------------------------

-- From http://lua-users.org/wiki/FormattingNumbers
function util.round(val, decimal)
  if (decimal) then
    return math.floor((val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val + 0.5)
  end
end
-- END From http://lua-users.org/wiki/FormattingNumbers

function util.applyIf(cfg, obj)
    for k,v in pairs(cfg) do
        if type(v) == 'table' then
            if obj[k] == nil then
                obj[k] = {}
            end
            util.applyIf(v, obj[k])
        elseif obj[k] == nil then
            obj[k] = v
        end
    end
end

function util.readJson(filePath)
  local file = assert(io.open(filePath, "r"))
  local jsonString = file:read("*all")
  file:close()

  return JSON:decode(jsonString)
end

function util.writeJson(filePath, data)
  local file = assert(io.open(filePath, "w"))
  file:write(JSON:encode_pretty(data))
  file:close()
end

-------------------------------------------------------------------------------

return util
