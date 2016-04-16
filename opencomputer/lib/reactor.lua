--------------------------
-- Reactor Controls
--------------------------

-------------------------------------------------------------------------------

local reactor = {}

-------------------------------------------------------------------------------

function reactor.getInfo(r)
    return {
        activelyCooled = r.isActivelyCooled(),
        active = r.getActive(),
        casingTemperature = r.getCasingTemperature(),
        connected = r.getConnected(),
        --controlRodLevel = r.getControlRodLevel(),
        --controlRodLocation = r.getControlRodLocation(),
        --controlRodName = r.getControlRodName(),
        coolantAmount = r.getCoolantAmount(),
        coolantAmountMax = r.getCoolantAmountMax(),
        coolantType = r.getCoolantType(),
        energyProducedLastTick = r.getEnergyProducedLastTick(),
        energyStored = r.getEnergyStored(),
        fuelAmount = r.getFuelAmount(),
        fuelAmountMax = r.getFuelAmountMax(),
        fuelConsumedLastTick = r.getFuelConsumedLastTick(),
        fuelReactivity = r.getFuelReactivity(),
        fuelTemperature = r.getFuelTemperature(),
        hotFluidAmount = r.getHotFluidAmount(),
        hotFluidAmountMax = r.getHotFluidAmountMax(),
        hotFluidProducedLastTick = r.getHotFluidProducedLastTick(),
        hotFluidType = r.getHotFluidType(),
        maximumCoordinate = r.getMaximumCoordinate(),
        minimumCoordinate = r.getMinimumCoordinate(),
        numberOfControlRods = r.getNumberOfControlRods(),
        wasteAmount = r.getWasteAmount()
    }
end

-------------------------------------------------------------------------------

return reactor
