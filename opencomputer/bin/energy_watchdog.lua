--------------------------
-- Main
--------------------------
package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local component = require('component')
local shell = require("shell")

local turbine = require("turbine")
local capacitor = require("capacitor")

local function main(args, options)
  local cfg = require("configs")

  -- Initialize components
  local r, t, c = initComponents(cfg, component)

  -- Turbine Benchmark
  if options.benchmark or options.b then
    local turbineNumber = tonumber(args[1])
    turbine.benchmark(t[turbineNumber])

  -- Turbine Startup/SpinUp
  elseif options.spinUp or options.s then
    local turbineNumber = tonumber(args[1])
    local targetSpeed = tonumber(args[2])

    turbine.spinUp(t[turbineNumber], targetSpeed)

  -- Capacitor monitoring
  elseif options.monitor or options.m then
    capacitor.monitor(c, cfg.capacitor.totalCapacity)

  -- Print Usage
  else
    printUsage()
    return -1
  end

  return 0
end

function initComponents(cfg, component)
  local r = component[cfg.reactor]
  local t = {
    component.proxy(component.get(cfg.turbines[1])),
    component.proxy(component.get(cfg.turbines[2])),
    component.proxy(component.get(cfg.turbines[3])),
    component.proxy(component.get(cfg.turbines[4]))
  }
  local c = component.proxy(component.get(cfg.capacitor.address))

  return r, t, c
end

function printUsage()
  print([[
Usage: main [option] arguments ...
  option     what it does
  [none]       shows this
]])
end

-- Parse cmd line input and run the program
local args, options = shell.parse(...)
return main(args, options)
