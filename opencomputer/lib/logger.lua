--------------------------
-- Logging Facilities
--------------------------
local computer = require("computer")

-------------------------------------------------------------------------------

local logger = {
  [0] = "OFF",
  [100] = "FATAL",
  [200] = "ERROR",
  [300] = "WARN",
  [400] = "INFO",
  [500] = "DEBUG",
  [600]  = "TRACE",
  [9999] = "ALL"
}

-- "Inspired" in colors lib
do
  local keys = {}
  for k in pairs(logger) do
    table.insert(keys, k)
  end
  for _, k in pairs(keys) do
    logger[logger[k]] = k
  end
end

-------------------------------------------------------------------------------

logger.threshold = logger.DEBUG

function logger.log(level, msg)
  if level <= logger.threshold then
    print(string.format(
      '[%d - %s] %s', 
      computer.uptime(), 
      logger[level], 
      msg
    ))
  end
end

function logger.logf(level, formatStr, ...)
  logger.log(level, string.format(formatStr, ...))
end

function logger.infof(formatStr, ...)
  logger.logf(logger.INFO, formatStr, ...)
end

function logger.debugf(formatStr, ...)
  logger.logf(logger.DEBUG, formatStr, ...)
end

-------------------------------------------------------------------------------

return logger