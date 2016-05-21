package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local component = require('component')
local term = require("term")
local computer = require("computer")

local f = require("formatter")
local prettyTable = require("prettyTable")

-- General configs
local minChargePercentage = 0.5 -- %
local maxChargePercentage = 0.95 -- % (we want to shutdown before 100% to reduce waste, turbines should continue producing energy for a while)
local sleepTime = 1  -- secs

-- Init components / data
local reactor = component.getPrimary("br_reactor")
local capacitor = component.getPrimary("capacitor_bank")

local maxEnergyStored = capacitor.getMaxEnergyStored()
local minEnergyValue = maxEnergyStored * minChargePercentage

-- TODO: Ensure same turbine order across restarts
local turbines = {}
for addr in component.list("br_turbine") do
  table.insert(turbines, component.proxy(addr))
end

-- Clear the terminal screen
term.clear()

local lastUpdate
while true do
    -- Gather needed data
    local now = computer.uptime()

    -- Create reactor rod monitoring table
    local reactorRodsInfo = prettyTable:new{
        head = {
            '#',
            'Name',
            'Level (%)',
            'Location'
        },
        colWidths = { 1, -15, 9, -10 },
        style = { marginLeft = 2, compact = true }
    }

    for i = 0, reactor.getNumberOfControlRods() - 1 do
        local x, y, z = reactor.getControlRodLocation(i)
        reactorRodsInfo:push({
            i + 1,
            reactor.getControlRodName(i),
            reactor.getControlRodLevel(i),
            string.format('%d, %d, %d', x, y, z)
        })
    end


    -- Capacitor bank data gathering
    local energyStored = capacitor.getEnergyStored()
    local energyStoredPer = (energyStored / maxEnergyStored)
    local averageChangePerTick = capacitor.getAverageChangePerTick()

    local emptyFullETA
    if averageChangePerTick == 0 then
        emptyFullETA = 0
    else
        local energy
        if averageChangePerTick > 0 then
            energy = maxEnergyStored - energyStored
        else
            energy = energyStored - minEnergyValue
        end

        emptyFullETA = math.floor(energy / (averageChangePerTick * 20))
    end

    -- Create capacitor monitoring table
    local capacitorsInfo = prettyTable:new{
        head = {
            '#',
            'Charge (RF | %)',
            'I/O (RF/t)',
            'ETA ' .. (averageChangePerTick > 0 and 'to fill' or 'to reactor startup')
        },
        colWidths = { 1, 45, 12, -50 },
        style = { marginLeft = 2, compact = true }
    }

    capacitorsInfo:push({
        1,
        f.commaInt(energyStored) .. ' / ' ..
        f.commaInt(maxEnergyStored) .. ' (' ..
        f.commaFloat(energyStoredPer * 100, 2) .. ')',
        f.commaFloat(averageChangePerTick, 2),
        f.secsToTime(emptyFullETA)
    })


    -- Check for reactor activation need
    if energyStoredPer <= minChargePercentage and not reactor.getActive() then
        reactor.setActive(true)
        lastUpdate = now
    elseif energyStoredPer >= maxChargePercentage and reactor.getActive() then
        reactor.setActive(false)
        lastUpdate = now
    end

    -- Create tubine monitoring table
    local turbinesInfo = prettyTable:new{
        head = {
            '#',
            'State',
            'Inductor',
            'Speed (RPM)',
            'Fluid / Max (mB/t)',
            'Output (RF/t)'
        },
        colWidths = { 1, -8, -8, 11, 18, 13 },
        style = { marginLeft = 2, compact = true }
    }
    for i, turbine in ipairs(turbines) do
        turbinesInfo:push({
            i,
            turbine.getActive() and 'Active' or 'Inactive',
            turbine.getInductorEngaged() and 'Active' or 'Inactive',
            f.commaFloat(turbine.getRotorSpeed(), 2),
            f.commaInt(turbine.getFluidFlowRate()) .. ' / ' ..  f.commaInt(turbine.getFluidFlowRateMax()),
            f.commaFloat(turbine.getEnergyProducedLastTick(), 2)
        })
    end

    -- Write output
    term.setCursor(1, 1)
    term.write(string.format(
            "Uptime: %s\n\n" ..

            "Reactor Monitoring\n\n" ..
            "  State: %s | Last change: %s\n" ..
            "  Hot Fluid: %s / %s | %s mB/t%s\n" ..
            "  Coolant: %s / %s\n" ..
            "%s\n" ..

            "Capacitor Monitoring\n\n" ..
            "%s\n" ..

            "Turbine Monitoring\n\n" ..
            "%s\n",

        f.secsToTime(now) .. string.rep(string.char(32), 50),

        reactor.getActive() and 'Active' or 'Inactive',
        lastUpdate == nil and '-' or f.secsToTime(lastUpdate) .. string.rep(string.char(32), 50),
        f.commaInt(reactor.getHotFluidAmount()),
        f.commaInt(reactor.getHotFluidAmountMax()),
        f.commaInt(reactor.getHotFluidProducedLastTick()),
        string.rep(string.char(32), 10),
        f.commaInt(reactor.getCoolantAmount()),
        f.commaInt(reactor.getCoolantAmountMax()) .. string.rep(string.char(32), 10),
        reactorRodsInfo:toString(),
        capacitorsInfo:toString(),
        turbinesInfo:toString()
    ))

    -- Sleep for a while ^^
    os.sleep(sleepTime)
end
