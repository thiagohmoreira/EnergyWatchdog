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
    local avgChargeIO
    local lastEnergyStored = capacitor.getEnergyStored()
    while true do
        -- Gather needed data
        local now = computer.uptime()
        local currentEnergyStored = capacitor.getEnergyStored()

        -- Calculate the 'instant' charge I/O
        local chargeIO = (currentEnergyStored - lastEnergyStored) / sleepTime -- RF/sec

        -- Calculates the charge I/O moving average
        if avgChargeIO == nil then
            avgChargeIO = chargeIO
        else
            avgChargeIO = (avgChargeIO + chargeIO) / 2
        end

        -- Calculates the time needed to empty or fill the capacitor
        local emptyFullETA -- sec
        if avgChargeIO == 0 then
            emptyFullETA = 0
        else
            local energy
            if avgChargeIO > 0 then
                energy = maxEnergyStored - currentEnergyStored
            else
                energy = currentEnergyStored
            end

            emptyFullETA = math.floor(energy / avgChargeIO)
        end

        -- Calculate the charge percentage and ativate or deactivate reactor accordingly
        local chargePercentage = currentEnergyStored / maxEnergyStored -- %
        if chargePercentage <= minChargePercentage and not reactor.getActive() then
            reactor.setActive(true)
            lastUpdate = now
        elseif chargePercentage >= maxChargePercentage and reactor.getActive() then
            reactor.setActive(false)
            lastUpdate = now
        end

        -- Write output
        -- term.clear()
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

            util.commaFloat(avgChargeIO, 2),
            util.secsToTime(emptyFullETA) .. string.rep(string.char(32), 50),

            reactor.getActive() and 'Active' or 'Inactive',
            lastUpdate == nil and '-' or util.commaInt(lastUpdate) .. string.rep(string.char(32), 50)
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
