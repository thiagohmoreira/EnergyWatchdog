package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local term = require("term")
local prettyTable = require("prettyTable")

local t0 = prettyTable:new()

t0:push({1, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t0:push({2, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

local t1 = prettyTable:new{
    colWidths = { 1, -8, -8, 11, 18, 13 }
}

t1:push({3, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t1:push({4, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

local t2 = prettyTable:new{
    head = {
        '#',
        'State',
        'Inductor',
        'Speed (RPM)',
        'Fluid / Max (mB/t)',
        'Output (RF/t)'
    }
}

t2:push({5, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t2:push({6, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

local t3 = prettyTable:new{
    head = {
        '#',
        'State',
        'Inductor',
        'Speed (RPM)',
        'Fluid / Max (mB/t)',
        'Output (RF/t)'
    },
    colWidths = { 1, -8, -8, 11, 18, 13 }
}

t3:push({7, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t3:push({8, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

local t4 = prettyTable:new{
    head = {
        '#',
        'State',
        'Inductor',
        'Speed (RPM)',
        'Fluid / Max (mB/t)',
        'Output (RF/t)'
    },
    colWidths = { 1, -8, -8, 11, 18, 13 },
    style = {
        compact = true
    }
}

t4:push({9, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t4:push({10, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

local t5 = prettyTable:new{
    colWidths = { 1, -8, -8, 11, 18, 13 },
    style = {
        compact = true
    }
}

t5:push({1, 'Active', 'Active', '0.00', '0 / 2,000', '0.00'})
t5:push({2, 'Inactive', 'Active', '0.00', '0 / 2,000', '0.00'})

term.clear()
term.write(t0:toString() .. "\n")
term.write(t1:toString() .. "\n")
term.write(t2:toString() .. "\n")
term.write(t3:toString() .. "\n")
term.write(t4:toString() .. "\n")
term.write(t5:toString() .. "\n")
