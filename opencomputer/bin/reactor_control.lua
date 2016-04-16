package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path
--package.path = '../lib/?.lua;../conf/?.lua' .. package.path

local component = require('component')
local shell = require("shell")
local logger = require("logger")
local util = require("util")

local function main(args, options)
    local minEnergy = 0.5 -- %
    local maxEnergy = 0.95 -- % (we want to shutdown before 100% to reduce waste, turbines should continue producing energy for a while)
    local sleepTime = 5  -- secs

    -- Init components / data
    local reactor = component.getPrimary("br_reactor")
    local capacitor = component.getPrimary("tile_blockcapacitorbank_name")
    local maxEnergyStored = capacitor.getMaxEnergyStored() -- RF

    while true do
        local currentEnergyStored = capacitor.getEnergyStored() / maxEnergyStored -- %

        logger.debugf(
          "Max Capacity: %s RF - Current Charge: %s RF (%.2f %%)",
          util.commaInt(maxEnergyStored),
          util.commaInt(capacitor.getEnergyStored()),
          currentEnergyStored * 100
        )

        if (currentEnergyStored <= minEnergy and not reactor.getActive()) then
            logger.log(logger.INFO, "Turning ON the reactor")
            reactor.setActive(true)
        elseif (currentEnergyStored >= maxEnergy and reactor.getActive()) then
            logger.log(logger.INFO, "Turning OFF the reactor")
            reactor.setActive(false)
        end

        os.sleep(sleepTime)
    end
end

-- Parse cmd line input and run the program
local args, options = shell.parse(...)
return main(args, options)
