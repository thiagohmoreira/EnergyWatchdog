--------------------------
-- Turbine Controls
--------------------------
local computer = require("computer")
local logger = require("logger")

-------------------------------------------------------------------------------

local turbine = {}

-------------------------------------------------------------------------------

function turbine.startup(t, isLowSpeed)
  local targetSpeed = 1800
  if isLowSpeed then
    targetSpeed = 800
  end

  logger.infof('Starting turbine (%s)...', t.address)
  t.setActive(true)

  local spinUptime = turbine.spinUp(t, targetSpeed)
  logger.infof('Turbine startup done (in %d secs)!', spinUptime)

  return spinUptime
end

function turbine.spinUp(t, targetSpeed)
  local startTime = computer.uptime()
  local currentSpeed = t.getRotorSpeed()
  local lastSpeed = currentSpeed

  if currentSpeed < targetSpeed then
    logger.infof('Accelerating to: %.2f rpm - Current Speed: %.2f rpm', targetSpeed, currentSpeed)
    t.setInductorEngaged(false)

    local sleepTime = 5
    while currentSpeed < targetSpeed do
      -- TODO: Make this 'adaptable' based on ETA
      os.sleep(sleepTime)

      currentSpeed = t.getRotorSpeed()
      local delta = (currentSpeed - lastSpeed) / sleepTime
      local eta = (targetSpeed - currentSpeed) / delta

      logger.infof('Current Speed: %.2f rpm - Delta speed: %f rpm/s - ETA: %.2f secs',
        currentSpeed,
        delta,
        eta
      )
      lastSpeed = currentSpeed
    end

    logger.infof('Engaging inductor. Current Speed: %.2f rpm', t.getRotorSpeed())
    t.setInductorEngaged(true)
  else
    logger.debugf('Turbine is faster then target speed. Target: %.2f rpm - Current Speed: %.2f rpm', targetSpeed, currentSpeed)
  end

  return computer.uptime() - startTime
end

function turbine.waitRotorStabilize(t)
  local stableWaitStart = computer.uptime()
  local sleepTime = 5
  local stableReads = 0
  local currentSpeed = t.getRotorSpeed()
  local lastSpeed
  logger.infof('Waitting rotor speed to stabilize.')
  while stableReads < 10 do
    -- TODO: Adjust this based on ETA
    os.sleep(sleepTime)

    lastSpeed = currentSpeed
    currentSpeed = t.getRotorSpeed()
    local deltaSpeed = (currentSpeed - lastSpeed) / sleepTime

    if (deltaSpeed ~= 0) then
      stableReads = 0
    else
      stableReads = stableReads + 1
    end

    logger.infof(
      'Current Speed: %.2f rpm - Delta Speed: %f rpm/s - Current Energy: %.2f/tick - Stable Reads: %d',
      currentSpeed,
      deltaSpeed,
      t.getEnergyProducedLastTick(),
      stableReads
    )
  end

  return computer.uptime() - stableWaitStart
end

function turbine.benchmark(t, isLowSpeed)
  local params = {}

  logger.infof('Starting benchmark')

  -- Shutdown
  if t.getActive() then
    logger.infof('Shutting down turbine.')
    t.setActive(false)
  end

  -- Slow down
  t.setInductorEngaged(true)
  while t.getRotorSpeed() > 0 do
    logger.infof('Waitting rotor to stop. Current speed: %.2f rpm.', t.getRotorSpeed())

    -- TODO: Make this 'adaptable' based on ETA
    os.sleep(10)
  end

  -- Startup
  params.spinUpWait = turbine.startup(t, isLowSpeed)
  os.sleep(1) -- Make sure it had time to generate any power
  params.peakEnergy = t.getEnergyProducedLastTick()

  -- Stabilize
  params.stableWait = turbine.waitRotorStabilize(t)
  params.stableSpeed = t.getRotorSpeed()
  params.stableEnergy = t.getEnergyProducedLastTick()

  -- Spin Up
  params.stableToIdealWait = turbine.spinUp(t, isLowSpeed)

  logger.infof(
    'SpinUp Wait: %d - Peak energy: %d RF  - Stable Speed: %.2f - Stable Energy: %d RF - Stable Wait: %d - Stable to Ideal Wait: %d',
    params.spinUpWait,
    params.peakEnergy,
    params.stableSpeed,
    params.stableEnergy,
    params.stableWait,
    params.stableToIdealWait
  )

  return params
end

function turbine.getInfo(t)
    return {
        active = t.getActive(),
        bladeEfficiency = t.getBladeEfficiency(),
        connected = t.getConnected(),
        energyProducedLastTick = t.getEnergyProducedLastTick(),
        energyStored = t.getEnergyStored(),
        fluidAmountMax = t.getFluidAmountMax(),
        fluidFlowRate = t.getFluidFlowRate(),
        fluidFlowRateMax = t.getFluidFlowRateMax(),
        fluidFlowRateMaxMax = t.getFluidFlowRateMaxMax(),
        inductorEngaged = t.getInductorEngaged(),
        inputAmount = t.getInputAmount(),
        inputType = t.getInputType(),
        maximumCoordinate = t.getMaximumCoordinate(),
        minimumCoordinate = t.getMinimumCoordinate(),
        numberOfBlades = t.getNumberOfBlades(),
        outputAmount = t.getOutputAmount(),
        outputType = t.getOutputType(),
        rotorMass = t.getRotorMass(),
        rotorSpeed = t.getRotorSpeed()
    }
end

-------------------------------------------------------------------------------

return turbine
