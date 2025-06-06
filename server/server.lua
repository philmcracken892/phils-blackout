local RSGCore = exports['rsg-core']:GetCoreObject()

local generatorStates = {}


local function getIdentifierKey(identifier)
    if identifier.type == 'netId' then
        return 'net_' .. identifier.value
    elseif identifier.type == 'coords' then
        local coords = identifier.value
        return string.format('coords_%.2f_%.2f_%.2f', coords.x, coords.y, coords.z)
    end
    return nil
end


RegisterNetEvent('generator_toggle:togglePower')
AddEventHandler('generator_toggle:togglePower', function(identifier)
    local src = source
    local key = getIdentifierKey(identifier)
    if not key then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Generator Error',
            description = 'Invalid identifier for generator.',
            type = 'error',
            duration = 3000
        })
        return
    end

    
    generatorStates[key] = not generatorStates[key] or false
   
    TriggerClientEvent('generator_toggle:updatePowerState', -1, identifier, generatorStates[key])
    
end)