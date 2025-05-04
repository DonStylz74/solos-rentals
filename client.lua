local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
local ESX = GetResourceState('es_extended') == 'started' and exports['es_extended']:getSharedObject()
local ped = {}

local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
local plate = GetVehicleNumberPlateText(veh)

-- Utility function to create blip
local function createBlip(coords, type, size, color, visible, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, size)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, visible)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

Citizen.CreateThread(function()
    for k, v in pairs(config.locations) do
        if v.blip and v.blip.enabled then
            createBlip(v.coords, v.blip.type, v.blip.size, v.blip.color, v.blip.visible, v.blip.name)
        end
    end
end)


-- Utility function to convert milliseconds to a readable time format (minutes)
local function formatTime(milliseconds)
    local minutes = milliseconds / 60000
    return string.format("%d mins", minutes)
end

Citizen.CreateThread(function()
    for k, v in pairs(config.locations) do
        if v.ped then
            RequestModel(config.pedmodel)
            while not HasModelLoaded(config.pedmodel) do
                Wait(10)
            end
            ped[k] = CreatePed(4, config.pedmodel, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, true)
            if config.scenario then
                TaskStartScenarioInPlace(ped[k], config.scenario, 0, true)
            end
            SetEntityCoordsNoOffset(ped[k], v.coords.x, v.coords.y, v.coords.z, false, false, false, true)
            Wait(100)
            FreezeEntityPosition(ped[k], true)
            SetEntityInvincible(ped[k], true)
            SetBlockingOfNonTemporaryEvents(ped[k], true)
        end
        if not v.ped then
            if config.qbtarget then
                exports['qb-target']:AddBoxZone(k, v.coords, v.length, v.width, {
                    name = k,
                    heading = v.coords.w,
                    debugPoly = false,
                    minZ = v.coords.z,
                    maxZ = v.coords.z
                }, {
                    options = {
                        {
                            icon = 'fas fa-car',
                            label = 'Rent Vehicle',
                            action = function()
                                TriggerEvent('solos-rentals:client:checkLicense', k)
                            end
                        },
                    },
                    distance = 2.0
                })
            elseif config.oxtarget then
                local menu_options = {
                    {
                        name = 'rental_ped',
                        icon = 'fas fa-car',
                        label = 'Vehicle Rentals',
                        onSelect = function()
                            TriggerEvent('solos-rentals:client:checkLicense', k)
                        end
                    },
                }
                exports.ox_target:addBoxZone({
                    coords = v.coords,
                    size = v.size,
                    rotation = v.coords.w,
                    debug = v.debug,
                    options = menu_options
                })
            end
        else
            if config.qbtarget then
                exports['qb-target']:AddTargetEntity(ped[k], {
                    options = {
                        {
                            icon = 'fas fa-car',
                            label = 'Rent Vehicle',
                            action = function()
                                TriggerEvent('solos-rentals:client:checkLicense', k)
                            end,
                        },
                    },
                    distance = 2.0
                })
            elseif config.oxtarget then
                local options = {
                    {
                        name = 'rental_ped',
                        icon = 'fas fa-car',
                        label = 'Vehicle Rentals',
                        onSelect = function()
                            TriggerEvent('solos-rentals:client:checkLicense', k)
                        end
                    },
                }
                exports.ox_target:addLocalEntity(ped[k], options)
            end
        end
    end
end)

RegisterNetEvent('solos-rentals:client:checkLicense', function(locationKey)
    local location = config.locations[locationKey]
    TriggerServerEvent('solos-rentals:server:checkLicense', locationKey, location.licenseType)
end)

RegisterNetEvent('solos-rentals:client:rentVehicle', function(k)
    local menu_options = {}
    for location, info in pairs(config.locations) do
        if location == k then
            for vehicle, details in pairs(info.vehicles) do
			local rentalTimeFormatted = formatTime(info.rentalTime)
                table.insert(menu_options, {
                    title = vehicle:gsub("^%l", string.upper),
                    image = 'nui://solos-rentals/html/images/' .. details.image,  -- Reference local image
                    description = 'Rent Vehicle (' .. rentalTimeFormatted .. ') for: $' .. details.price,
                    onSelect = function()
                        TriggerServerEvent('solos-rentals:server:MoneyAmounts', vehicle, details.price, location)
                    end
                })
            end
        end
    end

    -- Ensure the context is properly registered
    lib.registerContext({
        id = 'vehicle_rental',
        title = 'Select a Rental Vehicle',
        options = menu_options
    })

    -- Show the context menu
    lib.showContext('vehicle_rental')
end)



RegisterNetEvent('solos-rentals:client:SpawnVehicle', function(vehiclename, location)
    local player = PlayerPedId()
    local vehicle = GetHashKey(vehiclename)
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(10)
    end

    local rental = CreateVehicle(vehicle, config.locations[location].vehiclespawncoords.x, config.locations[location].vehiclespawncoords.y, config.locations[location].vehiclespawncoords.z, config.locations[location].vehiclespawncoords.w, true, false)
    local plate = GetVehicleNumberPlateText(rental)
    SetVehicleOnGroundProperly(rental)
    TaskWarpPedIntoVehicle(player, rental, -1)
    SetVehicleEngineOn(rental, true, true)
    TriggerServerEvent('solos-rentals:server:RentVehicle', vehiclename, plate)

    -- Give keys
    if QBCore then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end
    SetModelAsNoLongerNeeded(vehicle)

    -- Retrieve rental time from the config
    local rentalTime = config.locations[location].rentalTime or 600000 -- default to 10 mins if not specified
    local warningTime = rentalTime - 120000 -- 2 minutes before the rental ends

    -- Set a timer to notify and delete the vehicle
    Citizen.CreateThread(function()
        Wait(warningTime) -- Wait until 2 minutes before the rental ends

        -- Send a notification 2 minutes before deletion
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = 'Your rental vehicle will be deleted in 2 minutes!',
            duration = 20000 -- 20 seconds
        })

        Wait(120000) -- Wait for the remaining 2 minutes

        -- Send a notification 2 minutes before deletion
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = 'Your rental vehicle time has EXPIRED! Remove all your personal items & park the vehicle!',
            duration = 20000 -- 20 seconds
        })

        -- Check if player is in the vehicle, then handle deletion accordingly
        while true do
            if not IsPedInVehicle(player, rental, false) then
                -- Player is not in the vehicle, delete it
				exports['qs-vehiclekeys']:RemoveKeys(plate, model)
                DeleteVehicle(rental)
                -- Optional: Trigger a server event to remove rental papers or any other items
                TriggerServerEvent('solos-rentals:server:removeRentalPapers')
                break
            else
                -- Player is in the vehicle, wait until they exit
                Wait(10000) -- Check every 10 seconds
            end
        end
    end)
end)
