config = {}

-- target resource (only one of these can be true)
-------------------------------------------------------
config.qbtarget = false  
config.oxtarget = true  
-------------------------------------------------------


config.pedmodel = 'a_m_m_prolhost_01' -- ped model hash

config.scenario = 'WORLD_HUMAN_CLIPBOARD' -- scenario for ped to play, false to disable

config.locations = {
-----  Land Vehicles  -----
---------------------------

    ['legion'] = {
        licenseType = 'drive', -- Specify license type for this location
        rentalTime = 600000, -- Rental time in milliseconds (e.g., 600000 for 10 minutes)
        ped = true, -- if false uses boxzone (below)
        coords = vector4(214.79, -806.52, 30.81, 337.16),
        -------- boxzone (only used if ped is false) --------
        length = 1.0,
        width = 1.0,
        minZ = 30.81,
        maxZ = 30.81,
        debug = false,
        -----------------------------------------------------
        vehicles = {
            ['faggio'] = { -- vehicle model name
                price = 250, -- ['vehicle'] = price
                image = 'faggio.png', -- local image filename
            },
            ['nemesis'] = { -- vehicle model name
                price = 250, -- ['vehicle'] = price
                image = 'nemesis.png', -- local image filename
            },
            ['asbo'] = {
                price = 500,
                image = 'asbo.png', -- local image filename
            },
            ['asea'] = {
                price = 500,
                image = 'asea.png', -- local image filename
            },
            ['premier'] = {
                price = 500,
                image = 'premier.png', -- local image filename
            },
            ['vigero'] = {
                price = 500,
                image = 'vigero.png', -- local image filename
            },
            ['cavalcade'] = {
                price = 1500,
                image = 'cavalcade.png', -- local image filename
            },
            ['bison'] = {
                price = 2000,
                image = 'bison.png', -- local image filename
            },
            ['speedo'] = {
                price = 2000,
                image = 'speedo.png', -- local image filename
            },
            ['sentinel'] = {
                price = 500,
                image = 'sentinel.png', -- local image filename
            },
            ['comet2'] = {
                price = 1000,
                image = 'comet2.png', -- local image filename
            },
        },
        vehiclespawncoords = vector4(212.64, -797.12, 30.87, 339.09), -- where vehicle spawns when rented
        blip = {
            enabled = true,  -- option to turn on/off blip
			name = 'Rental Vehicles',
            type = 642,        -- blip type (icon)
            size = 0.5,      -- blip size
            color = 3,       -- blip color
            visible = true   -- blip visibility
        }
    },

-----  Water Vehicles  -----
----------------------------

    ['Vespucci Pier'] = {
        licenseType = 'boat', -- Specify license type for this location
        rentalTime = 600000, -- Rental time in milliseconds (e.g., 600000 for 10 minutes)
        ped = true, -- if false uses boxzone (below)
        coords = vector4(-704.0577, -1398.0048, 5.4951, 115.6911),
        -------- boxzone (only used if ped is false) --------
        length = 1.0,
        width = 1.0,
        minZ = 30.81,
        maxZ = 30.81,
        debug = false,
        -----------------------------------------------------
        vehicles = {
            ['seashark'] = { -- vehicle model name
                price = 250, -- ['vehicle'] = price
                image = 'seashark.png', -- local image filename
            },
            ['dinghy'] = {
                price = 500,
                image = 'dinghy.png', -- local image filename
            },
            ['dinghy2'] = {
                price = 1000,
                image = 'dinghy2.png', -- local image filename
            },
            ['suntrap'] = {
                price = 1500,
                image = 'suntrap.png', -- local image filename
            },
            ['tropic2'] = {
                price = 2000,
                image = 'tropic2.png', -- local image filename
            },
        },
        vehiclespawncoords = vector4(-731.8972, -1376.5371, 0.1195, 140.1311), -- where vehicle spawns when rented
        blip = {
            enabled = true,  -- option to turn on/off blip
			name = 'Rental Boats',
            type = 642,        -- blip type (icon)
            size = 0.5,      -- blip size
            color = 3,       -- blip color
            visible = true   -- blip visibility
        }
    },

-----  Air Vehicles  -----
--------------------------
    ['LSIA Airfield'] = {
        licenseType = 'aircraft', -- Specify license type for this location
        rentalTime = 600000, -- Rental time in milliseconds (e.g., 600000 for 10 minutes)
        ped = true, -- if false uses boxzone (below)
        coords = vector4(-1070.1261, -2867.3345, 14.3058, 156.1940),
        -------- boxzone (only used if ped is false) --------
        length = 1.0,
        width = 1.0,
        minZ = 30.81,
        maxZ = 30.81,
        debug = false,
        -----------------------------------------------------
        vehicles = {
            ['microlight'] = { -- vehicle model name
                price = 250, -- ['vehicle'] = price
                image = 'microlight.png', -- local image filename
            },
            ['stunt'] = {
                price = 500,
                image = 'stunt.png', -- local image filename
            },
            ['duster'] = {
                price = 1000,
                image = 'duster.png', -- local image filename
            },
            ['havok'] = {
                price = 1500,
                image = 'havok.png', -- local image filename
            },
            ['seasparrow2'] = {
                price = 2000,
                image = 'seasparrow2.png', -- local image filename
            },
        },
        vehiclespawncoords = vector4(-1112.7260, -2883.8022, 13.9460, 240.6057), -- where vehicle spawns when rented
        blip = {
            enabled = true,  -- option to turn on/off blip
			name = 'Rental Aircraft',
            type = 642,        -- blip type (icon)
            size = 0.5,      -- blip size
            color = 3,       -- blip color
            visible = true   -- blip visibility
        }
    },

    -- add as many locations as you'd like with any type of vehicle (air, water, land) follow same format as above
}



