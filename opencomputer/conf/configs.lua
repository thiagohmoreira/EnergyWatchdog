--------------------------
-- Energy Watchdog Config
--------------------------
local configs = {
  reactor = 'br_reactor',

  turbines = {
    '850',
    '32a',
    '454',
    '7e7'
  },

  capacitor = {
    address = 'f69',

    -- Seems Ender I/O capacitor bank is not well supported,
    -- this is needed to provide more precise values for I/O
    totalCapacity = 12525000000 -- in RF
  }
}

return configs
