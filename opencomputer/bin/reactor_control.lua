package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local component = require('component')
local shell = require("shell")
local util = require("util")
local term = require("term")
local computer = require("computer")

local function main(args, options)
    local minChargePercentage = 0.5 -- %
    local maxChargePercentage = 0.95 -- % (we want to shutdown before 100% to reduce waste, turbines should continue producing energy for a while)
    local sleepTime = 1  -- secs

    -- Init components / data
    local reactor = component.getPrimary("br_reactor")
    local capacitor = component.getPrimary("tile_blockcapacitorbank_name")
    local maxEnergyStored = capacitor.getMaxEnergyStored() -- RF

    -- Clear the terminal screen
    term.clear()

    local lastUpdate
    local lastEnergyStored = capacitor.getEnergyStored()
    while true do
        -- Gather needed data
        local now = computer.uptime()
        local currentEnergyStored = capacitor.getEnergyStored()

        -- Calculate the charge I/O
        local deltaCharge = (currentEnergyStored - lastEnergyStored) / sleepTime -- RF/sec
        local emptyFullETA = math.abs(math.floor(currentEnergyStored / deltaCharge)) -- sec => Time to empty/fill capacitor

        -- Calculate the charge percentage and ativate or deactivate reactor accordingly
        local chargePercentage = currentEnergyStored / maxEnergyStored -- %
        if (chargePercentage <= minChargePercentage and not reactor.getActive()) then
            reactor.setActive(true)
            lastUpdate = now
        elseif (chargePercentage >= maxChargePercentage and reactor.getActive()) then
            reactor.setActive(false)
            lastUpdate = now
        end

        -- Write output
        -- TODO: Check if not cleanning screen, only writing to it won't be an issue
        term.setCursor(1, 1)
        term.write(string.format(
                "Current Time: %s\n\n" ..

                "Capacitor Monitoring\n" ..
                "  Charge: %s / %s RF (%.2f %%)\n" ..
                "  I/O: %s RF/sec | ETA: %s\n\n" ..

                "Reactor Monitoring\n" ..
                "  State: %s | Last update: %s",

            util.commaInt(now),

            util.commaInt(capacitor.getEnergyStored()),
            util.commaInt(maxEnergyStored),
            chargePercentage * 100,

            util.commaFloat(deltaCharge, 2),
            util.secsToTime(emptyFullETA),

            reactor.getActive() and 'Active' or 'Inactive',
            lastUpdate == nil and '-' or util.commaInt(lastUpdate)
        ))

        -- Update the last energy read
        lastEnergyStored = currentEnergyStored

        -- Sleep for a while ^^
        os.sleep(sleepTime)
    end
end

-- Parse cmd line input and run the program
local args, options = shell.parse(...)
return main(args, options)
