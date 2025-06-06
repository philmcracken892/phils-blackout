local RSGCore = exports['rsg-core']:GetCoreObject()
local isBlackoutEnabled = false 

local isGeneratorOn = false


local function toggleGeneratorPower(entity)
    if not DoesEntityExist(entity) then
        lib.notify({
            title = 'Generator Error',
            description = 'Generator entity not found.',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    
    local identifier
    if NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        if netId then
            identifier = { type = 'netId', value = netId }
        else
            lib.notify({
                title = 'Generator Warning',
                description = 'Failed to get network ID, using coordinates as fallback.',
                type = 'warning',
                duration = 3000
            })
            local coords = GetEntityCoords(entity)
            identifier = { type = 'coords', value = { x = coords.x, y = coords.y, z = coords.z } }
        end
    else
        local coords = GetEntityCoords(entity)
        identifier = { type = 'coords', value = { x = coords.x, y = coords.y, z = coords.z } }
    end
    
    
    TriggerServerEvent('generator_toggle:togglePower', identifier)
end

local generatorModels = {
    'p_streetlightnbx07x',
    'p_streetlampnbx01x',
	's_dov_lab_panel02x',
	'p_canalpolenbx01a',
	'p_lampstreet01x',
	'p_telegraphpole06x',
    -- Add more models here as needed
}

for _, model in ipairs(generatorModels) do
    exports.ox_target:addModel(model, {
        {
            name = 'toggle_generator',
            icon = 'fas fa-power-off',
            label = 'Toggle Generator',
            onSelect = function(data)
                toggleGeneratorPower(data.entity)
            end,
            distance = 2.5,
            canInteract = function(entity, distance, coords, name)
                local PlayerData = RSGCore.Functions.GetPlayerData()
                return DoesEntityExist(entity) and PlayerData.job.name == 'vallaw' -- Change 'vallaw' to your desired job
            end
        }
    })
end


RegisterNetEvent('generator_toggle:updatePowerState')
AddEventHandler('generator_toggle:updatePowerState', function(identifier, state)
    isGeneratorOn = state
    
    
    if isGeneratorOn then
        lib.notify({
            title = 'Generator Status',
            description = 'The electric has been toggled.',
            type = 'success',
            duration = 3000
        })
       
        isBlackoutEnabled = false
        SetArtificialLightsState(isBlackoutEnabled)
    else
        lib.notify({
            title = 'Generator Status',
            description = 'The electric has been toggled.',
            type = 'success',
            duration = 3000
        })
        
        isBlackoutEnabled = true
        SetArtificialLightsState(isBlackoutEnabled)
    end
end)

RegisterCommand("toggleblackout", function(source, args, rawCommand)
    isBlackoutEnabled = not isBlackoutEnabled
    SetArtificialLightsState(isBlackoutEnabled)
    lib.notify({
        title = 'Blackout Toggle',
        description = 'Blackout ' .. (isBlackoutEnabled and 'enabled' or 'disabled'),
        type = 'info',
        duration = 3000
    })
end, false)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        SetArtificialLightsState(isBlackoutEnabled)
    end
end)