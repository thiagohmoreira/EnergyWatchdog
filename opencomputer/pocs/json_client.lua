package.path = '/EnergyWatchdog/lib/?.lua;/EnergyWatchdog/conf/?.lua;' .. package.path

local JSON = require("JSON")
local inet = require("internet")
local logger = require("logger")
local util = require("util")

local serverUrl = "http://zion.zn/mc_server.php"

local requestData = JSON:encode(util.getComputerInfo())
local req = inet.request(serverUrl, requestData)
local serverJson = ""
for line in req do
  serverJson = serverJson .. line .. "\n"
end

logger.infof(
  "Server response: \n%s\n",
  serverJson
)
