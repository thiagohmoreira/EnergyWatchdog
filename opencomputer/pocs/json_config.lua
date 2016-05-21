--[[
    Script to demonstrate the readJson and writeJson utilization
]]--
package.path = '../lib/?.lua;' .. package.path

local util = require("util")

-- Open last state and calculate current run count
local filePath = "./config.json"
local config = util.readJson(filePath)
config.runs = config.runs + 1

-- Print state
print("runs:" .. config.runs .. "\n")
print("reactors[1].address: " .. config.reactors[1].address .. "\n")
print("reactors[2].address: " .. config.reactors[2].address .. "\n")

-- Persist state
util.writeJson(filePath, config)

print("Done!\n")
