local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
local ESX = GetResourceState('es_extended') == 'started' and exports.es_extended:getSharedObject()


local function PlayerName(src)
    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
    elseif ESX then 
        local Player = ESX.GetPlayerFromId(src)
        local first, last
        if Player.get and Player.get('firstName') and Player.get('lastName') then
            first = Player.get('firstName')
            last = Player.get('lastName')
        else
            local name = MySQL.Sync.fetchAll('SELECT `firstname`, `lastname` FROM `users` WHERE `identifier`=@identifier', { ['@identifier'] = ESX.GetIdentifier(source) })
            first, last = name[1]?.firstname or ESX.GetPlayerName(source), name[1]?.lastname or ''
        end
        return first..' '..last
    end
end

RegisterNetEvent('solos-rentals:server:checkLicense', function(locationKey, licenseType)
    local src = source
    local xPlayer = ESX and ESX.GetPlayerFromId(src) or QBCore and QBCore.Functions.GetPlayer(src)
    local hasLicense = false

    if xPlayer then
        if ESX then
            -- Fetch licenses directly from the database
            local identifier = xPlayer.getIdentifier()
            local result = MySQL.Sync.fetchAll('SELECT type FROM user_licenses WHERE owner = @owner', {
                ['@owner'] = identifier
            })

            -- Check if player has the required license
            for _, license in pairs(result) do
                if license.type == licenseType then
                    hasLicense = true
                    break
                end
            end
        elseif QBCore then
            -- Check if player has the required item (licenseType)
            hasLicense = xPlayer.Functions.HasItem(licenseType)
        end
    else
        print("Player not found with source: " .. src)
    end

    -- Notify the player and trigger appropriate client event
    if hasLicense then
        TriggerClientEvent('solos-rentals:client:rentVehicle', src, locationKey)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = "You don't have a valid License!",
            duration = 5000
        })
    end
end)

RegisterNetEvent('solos-rentals:server:RentVehicle', function(vehicle, plate)
    local src = source
    local player_name = PlayerName(src)
    exports.ox_inventory:AddItem(src, 'rentalpapers', 1, 
        {description = 'Owner: '..player_name..' | Plate: '..plate..' | Vehicle: '..vehicle:gsub("^%l", string.upper)}
    )

end)

RegisterNetEvent('solos-rentals:server:MoneyAmounts', function(vehiclename, price, location)
    local src = source
    local moneytype = 'bank'
    local price = tonumber(price)
    local bank 
    local cash
    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        bank = Player.PlayerData.money.bank
        cash = Player.PlayerData.money.cash
    elseif ESX then 
        local Player = ESX.GetPlayerFromId(src)
        bank = Player.getAccount('bank').money
        cash = Player.getAccount('money').money
    end

    if bank < price then 
        moneytype = 'cash'
        if cash < price then 
            TriggerClientEvent('ox_lib:notify', src, {
                id = 'not_enough_money',
                description = 'You don\'t have enough money to rent this vehicle.',
                position = 'center-right',
                icon = 'ban',
                iconColor = '#C53030'
            })
            return 
        end    
    end

    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney(moneytype, price)
    elseif ESX then
        local Player = ESX.GetPlayerFromId(src)
        if moneytype == 'cash' then
            Player.removeMoney(price)
        elseif moneytype == 'bank' then
            Player.removeAccountMoney('bank', price)
        end
    end
    TriggerClientEvent('ox_lib:notify', src, {
        id = 'rental_success',
        description = vehiclename:gsub("^%l", string.upper)..' rented for $'..price..'.',
        position = 'center-right',
        icon = 'car',
        iconColor = 'white'
    })
    TriggerClientEvent('solos-rentals:client:SpawnVehicle', src, vehiclename, location)

end)

RegisterNetEvent('solos-rentals:server:removeRentalPapers', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src) or QBCore.Functions.GetPlayer(src)

    if xPlayer then
        if ESX then
            xPlayer.removeInventoryItem('rentalpapers', 1) -- Replace 'rental_papers' with your actual item name
        elseif QBCore then
            xPlayer.Functions.RemoveItem('rentalpapers', 1) -- Replace 'rental_papers' with your actual item name
        end

        -- Notify the player
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'Rental papers have been removed from your inventory.',
            duration = 5000 -- 5 seconds
        })
    end
end)
