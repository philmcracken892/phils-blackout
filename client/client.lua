local RSGCore = exports['rsg-core']:GetCoreObject()
local activeZoneStates = {}
local globalBlackoutEnabled = false
local lastBlackoutState = nil



local function DrawText3D(x, y, z, text)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return end

    local textLength = string.len(text) / 160
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 0, 0, 215)
    SetTextCentre(1)

    DrawSprite("shared", "menu_header", screenX, screenY + 0.0150, 0.015 + textLength, 0.032, 0.1, 0, 0, 0, 190, 0)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
end

local function HasPermission()
    if #Config.AllowedJobs == 0 then return true end
    
    local PlayerData = RSGCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    
    for _, job in ipairs(Config.AllowedJobs) do
        if PlayerData.job.name == job then
            if Config.MinimumJobGrade > 0 then
                return PlayerData.job.grade.level >= Config.MinimumJobGrade
            end
            return true
        end
    end
    return false
end

local function IsPlayerInZone(zone, coords)
    local z = Config.Zones[zone:lower()]
    if not z then return false end
    return #(vector3(coords.x, coords.y, coords.z) - vector3(z.x, z.y, z.z)) < z.radius
end

local function GetCurrentZone()
    local coords = GetEntityCoords(PlayerPedId())
    for zoneName, zoneData in pairs(Config.Zones) do
        if IsPlayerInZone(zoneName, coords) then
            return zoneName, zoneData.label
        end
    end
    return nil, nil
end



local function PlayFlickerEffect()
    if not Config.EnableFlickerEffect then return end
    
    for i = 1, Config.FlickerCount do
        SetArtificialLightsState(true)
        Citizen.Wait(100)
        SetArtificialLightsState(false)
        Citizen.Wait(100)
    end
end

local function PlayToggleAnimation()
    if not Config.EnableAnimations then return end
    
    local ped = PlayerPedId()
    local dict = "amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(ped, dict, "exit_front", 8.0, -8.0, 2000, 0, 0, false, false, false)
    Citizen.Wait(2000)
end



local function ShowBlackoutZoneMenu(coords)
    if not HasPermission() then
        lib.notify({
            title = 'Access Denied',
            description = 'You do not have permission to control power.',
            type = 'error',
            duration = 3000
        })
        return
    end

    local menuOptions = {
        {
            title = "🌍 Entire Map",
            description = globalBlackoutEnabled and "Currently: BLACKOUT" or "Currently: POWERED",
            icon = "fas fa-globe",
            onSelect = function()
                TriggerBlackoutToggle(coords, "global")
            end
        },
    }

   
    for zoneName, zoneData in pairs(Config.Zones) do
        local isActive = activeZoneStates[zoneName] or false
        table.insert(menuOptions, {
            title = zoneData.label,
            description = isActive and "Status: BLACKOUT" or "Status: POWERED",
            icon = isActive and "fas fa-moon" or "fas fa-sun",
            onSelect = function()
                TriggerBlackoutToggle(coords, zoneName)
            end
        })
    end

    
    table.insert(menuOptions, {
        title = "🔄 Reset All Zones",
        description = "Turn lights back on everywhere",
        icon = "fas fa-lightbulb",
        onSelect = function()
            if Config.EnableProgressBar then
                if lib.progressBar({
                    duration = Config.ProgressBarDuration,
                    label = 'Restoring Power...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                }) then
                    TriggerServerEvent('blackout:resetAllZones')
                end
            else
                TriggerServerEvent('blackout:resetAllZones')
            end
        end
    })

   
    local currentZone, currentZoneLabel = GetCurrentZone()
    if currentZone then
        table.insert(menuOptions, 1, {
            title = "⚡ Toggle Current Zone (" .. currentZoneLabel .. ")",
            description = "Quick toggle for your current location",
            icon = "fas fa-bolt",
            onSelect = function()
                TriggerBlackoutToggle(coords, currentZone)
            end
        })
    end

    lib.registerContext({
        id = 'blackout_zone_menu',
        title = '⚡ Power Control System',
        options = menuOptions
    })

    lib.showContext('blackout_zone_menu')
end

function TriggerBlackoutToggle(coords, zoneName)
    if Config.EnableProgressBar then
        if lib.progressBar({
            duration = Config.ProgressBarDuration,
            label = 'Toggling Power...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
            anim = {
                dict = 'amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop',
                clip = 'exit_front'
            },
        }) then
            PlayFlickerEffect()
            TriggerServerEvent('blackout:placeZoneTrigger', coords, zoneName)
        else
            lib.notify({
                title = 'Cancelled',
                description = 'Power toggle cancelled.',
                type = 'error',
                duration = 2000
            })
        end
    else
        PlayToggleAnimation()
        PlayFlickerEffect()
        TriggerServerEvent('blackout:placeZoneTrigger', coords, zoneName)
    end
end


for _, model in ipairs(Config.GeneratorModels) do
    exports.ox_target:addModel(model, {
        {
            name = 'open_blackout_menu',
            icon = 'fas fa-plug',
            label = 'Power Control Panel',
            distance = 2.5,
            onSelect = function(data)
                ShowBlackoutZoneMenu(GetEntityCoords(data.entity))
            end
        }
    })
end


for _, model in ipairs(Config.LightPoleModels) do
    exports.ox_target:addModel(model, {
        {
            name = 'toggle_lights_menu',
            icon = 'fas fa-lightbulb',
            label = 'Toggle Lights',
            distance = 2.5,
            onSelect = function(data)
                ShowBlackoutZoneMenu(GetEntityCoords(data.entity))
            end
        }
    })
end



if Config.EnableScheduledBlackouts then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)  
            local hour = GetClockHours()
            TriggerServerEvent('blackout:syncTime', hour)
        end
    end)
    
    
    Citizen.CreateThread(function()
        Citizen.Wait(5000)  -- Wait 5 seconds after resource start
        local hour = GetClockHours()
        TriggerServerEvent('blackout:syncTime', hour)
    end)
end



RegisterNetEvent('blackout:updateZoneState')
AddEventHandler('blackout:updateZoneState', function(zone, state)
    if zone == "global" then
        globalBlackoutEnabled = state
        return
    end
    activeZoneStates[zone] = state
end)


RegisterNetEvent('blackout:syncState')
AddEventHandler('blackout:syncState', function(zoneStates, globalState)
    activeZoneStates = zoneStates or {}
    globalBlackoutEnabled = globalState or false
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerServerEvent('blackout:requestSync')
end)



Citizen.CreateThread(function()
    while true do
        local shouldBlackout = false
        
        if globalBlackoutEnabled then
            shouldBlackout = true
        else
            local coords = GetEntityCoords(PlayerPedId())
            for zone, state in pairs(activeZoneStates) do
                if state and IsPlayerInZone(zone, coords) then
                    shouldBlackout = true
                    break
                end
            end
        end

        SetArtificialLightsState(shouldBlackout)
        lastBlackoutState = shouldBlackout

        Citizen.Wait(100)
    end
end)



RegisterCommand("blackoutmenu", function()
    ShowBlackoutZoneMenu(GetEntityCoords(PlayerPedId()))
end, false)

RegisterCommand("checkzone", function()
    local zoneName, zoneLabel = GetCurrentZone()
    if zoneName then
        local isBlackout = activeZoneStates[zoneName] or false
        lib.notify({
            title = 'Current Zone',
            description = zoneLabel .. ' - ' .. (isBlackout and 'BLACKOUT' or 'POWERED'),
            type = 'info',
            duration = 3000
        })
    else
        lib.notify({
            title = 'Current Zone',
            description = 'You are not in any defined zone',
            type = 'info',
            duration = 3000
        })
    end
end, false)
