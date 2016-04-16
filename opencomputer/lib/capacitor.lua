--------------------------
-- Capacitor
--------------------------
local computer = require("computer")
local logger = require("logger")
local util = require("util")

-------------------------------------------------------------------------------

local capacitor = {}

-------------------------------------------------------------------------------

function capacitor.monitor(cap, totalCapacity)
  totalCapacity = totalCapacity or cap.getMaxEnergyStored()

  local maxEnergyStored = cap.getMaxEnergyStored() -- in RF
  local currentEnergyStored = cap.getEnergyStored() -- in RF
  local sleepTime = 5 -- in secs
  local multiplier = (maxEnergyStored / totalCapacity) * 20 -- fraction of total capacity * 20 ticks in a sec

  logger.debugf(
    "Total Bank Capacity: %s RF - Single Cap Capacity: %s RF - Current Charge: %s RF - Multiplier: %f",
    util.commaInt(totalCapacity),
    util.commaInt(maxEnergyStored),
    util.commaInt(currentEnergyStored),
    multiplier
  )

  local lastEnergyStored
  while true do
    os.sleep(sleepTime)

    lastEnergyStored = currentEnergyStored
    currentEnergyStored = cap.getEnergyStored()

    local delta = (currentEnergyStored - lastEnergyStored) / sleepTime -- in RF/sec
    local deltaio = delta / multiplier -- in RF/tick
    local eta = math.abs(math.floor(currentEnergyStored / delta)) -- in secs => Time to empty capacitor

    logger.debugf("Energy: %s RF - Delta: %s RF/sec - IO: %s RF/tick - ETA: %s",
      util.commaInt(currentEnergyStored),
      util.commaFloat(delta, 2),
      util.commaFloat(deltaio, 2),
      util.secsToTime(eta)
    )
  end
end

function capacitor.getInfo(c)
    return {
        energyStored = c.getEnergyStored(),
        maxEnergyStored = c.getMaxEnergyStored(),
        energyProvider = c.isEnergyProvider(),
        energyReceiver = c.isEnergyReceiver()
    }
end

-------------------------------------------------------------------------------

return capacitor
