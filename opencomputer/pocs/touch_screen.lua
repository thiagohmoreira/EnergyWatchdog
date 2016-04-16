-- ABC: Noobagem!
local e = require("event")
local comp = require("component")
local gpu = comp.gpu

while true do
  local _,_,x,y = e.pull("touch")
  gpu.set(x,y,"X")
end
