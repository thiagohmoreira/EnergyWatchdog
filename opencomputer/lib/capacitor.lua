--------------------------
-- Capacitor
--------------------------

local component = require('component')

-------------------------------------------------------------------------------

local Capacitor = {}

-------------------------------------------------------------------------------

function Capacitor:new (addr, now)
    local proxy = component.proxy(addr)
    o = {
        addr = addr,
        proxy = proxy,
        avgChargeIO,      -- RF/sec
        emptyFullETA,     -- sec
        chargePercentage, -- %

        lastUpdate = now,
        lastEnergyStored = proxy.getEnergyStored(), -- RF
        maxEnergyStored = proxy.getMaxEnergyStored() -- RF
    }

    setmetatable(o, self)
    self.__index = self

    return o
end

function Capacitor:update(now)
    -- Gather needed data
    local currentEnergyStored = self.proxy.getEnergyStored()

    -- Calculate the 'instant' charge I/O
    local chargeIO = (currentEnergyStored - self.lastEnergyStored) / (now - self.lastUpdate) -- RF/sec

    -- Calculates the charge I/O moving average
    if self.avgChargeIO == nil then
        self.avgChargeIO = chargeIO
    else
        self.avgChargeIO = (self.avgChargeIO + chargeIO) / 2
    end

    -- Calculates the time needed to empty or fill the capacitor
    if self.avgChargeIO == 0 then
        self.emptyFullETA = 0
    else
        local energy
        if self.avgChargeIO > 0 then
            energy = self.maxEnergyStored - currentEnergyStored
        else
            energy = currentEnergyStored
        end

        self.emptyFullETA = math.floor(energy / self.avgChargeIO)
    end

    -- Calculate the charge percentage and ativate or deactivate reactor accordingly
    self.chargePercentage = currentEnergyStored / self.maxEnergyStored

    -- Update date for next iterations
    self.lastEnergyStored = currentEnergyStored
    self.lastUpdate = now
end

-------------------------------------------------------------------------------

function Capacitor.getInfo(c)
    return {
        energyStored = c.getEnergyStored(),
        maxEnergyStored = c.getMaxEnergyStored(),
        energyProvider = c.isEnergyProvider(),
        energyReceiver = c.isEnergyReceiver()
    }
end

-------------------------------------------------------------------------------

return Capacitor
