package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local component = require('component')
local shell = require("shell")
local term = require("term")
local computer = require("computer")

local util = require("util")
local prettyTable = require("prettyTable")
local Capacitor = require("Capacitor")


local function main(args, options)
    local minChargePercentage = 0.5 -- %
    local maxChargePercentage = 0.95 -- % (we want to shutdown before 100% to reduce waste, turbines should continue producing energy for a while)
    local sleepTime = 1  -- secs

    -- Init components / data
    local reactor = component.getPrimary("br_reactor")

    -- TODO: Ensure same capacitor order across restarts
    local capacitors = {}
    for addr in component.list("tile_blockcapacitorbank_name") do
      table.insert(capacitors, Capacitor:new(addr, computer.uptime()))
    end

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

        -- Create capacitor monitoring table
        local capacitorsInfo = prettyTable:new{
            head = {
                '#',
                'Charge (RF | %)',
                'I/O (RF/sec)',
                'ETA'
            },
            colWidths = { 1, 32, 12, -50 },
            style = { marginLeft = 2, compact = true }
        }
        local minCharge

        local chargePercentage = 1
        for i, capacitor in ipairs(capacitors) do
            capacitor:update(now)
            capacitorsInfo:push({
                i,
                util.commaInt(capacitor.proxy.getEnergyStored()) .. ' / ' ..
                util.commaInt(capacitor.maxEnergyStored) .. ' (' ..
                util.commaFloat(capacitor.chargePercentage * 100, 2) .. ')',
                util.commaFloat(capacitor.avgChargeIO, 2),
                util.secsToTime(capacitor.emptyFullETA)
            })

            -- Get the emptier capacitor
            if capacitor.chargePercentage < chargePercentage then
                chargePercentage = capacitor.chargePercentage
            end
        end

        -- Check for reactor activation need
        if chargePercentage <= minChargePercentage and not reactor.getActive() then
            reactor.setActive(true)
            lastUpdate = now
        elseif chargePercentage >= maxChargePercentage and reactor.getActive() then
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
                util.commaFloat(turbine.getRotorSpeed(), 2),
                util.commaInt(turbine.getFluidFlowRate()) .. ' / ' ..  util.commaInt(turbine.getFluidFlowRateMax()),
                util.commaFloat(turbine.getEnergyProducedLastTick(), 2)
            })
        end

        -- Write output
        term.setCursor(1, 1)
        term.write(string.format(
                "Uptime: %s\n\n" ..

                "Reactor Monitoring\n\n" ..
                "  State: %s | Last update: %s\n\n\n" ..

                "Capacitor Monitoring\n\n" ..
                "%s\n" ..

                "Turbine Monitoring\n\n" ..
                "%s\n",

            util.commaInt(now),

            reactor.getActive() and 'Active' or 'Inactive',
            lastUpdate == nil and '-' or util.commaInt(lastUpdate) .. string.rep(string.char(32), 50),
            capacitorsInfo:toString(),
            turbinesInfo:toString()
        ))

        -- Sleep for a while ^^
        os.sleep(sleepTime)
    end
end

-- Parse cmd line input and run the program
local args, options = shell.parse(...)
return main(args, options)
