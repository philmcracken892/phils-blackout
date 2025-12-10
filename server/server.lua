local RSGCore = exports['rsg-core']:GetCoreObject()

local blackoutZones = {}
local globalBlackoutEnabled = false
local currentGameHour = 0  



local function LogAction(source, action, zone)
    if not Config.EnableLogging then return end
    
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local identifier = RSGCore.Functions.GetIdentifier(source, 'license')
    
    local embed = {
        {
            title = "⚡ Power Control Log",
            color = 16776960,
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Action", value = action, inline = true },
                { name = "Zone", value = zone, inline = true },
                { name = "Identifier", value = identifier, inline = false },
            },
            footer = { text = os.date("%Y-%m-%d %H:%M:%S") }
        }
    }
    
    PerformHttpRequest(Config.LogWebhook, function(err, text, headers) end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end

local function HasPermission(source)
    if #Config.AllowedJobs == 0 then return true end
    
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local job = Player.PlayerData.job
    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if job.name == allowedJob then
            if Config.MinimumJobGrade > 0 then
                return job.grade.level >= Config.MinimumJobGrade
            end
            return true
        end
    end
    return false
end



RegisterServerEvent('blackout:syncTime')
AddEventHandler('blackout:syncTime', function(hour)
    currentGameHour = hour
end)



RegisterServerEvent('blackout:requestSync')
AddEventHandler('blackout:requestSync', function()
    local src = source
    TriggerClientEvent('blackout:syncState', src, blackoutZones, globalBlackoutEnabled)
end)

RegisterServerEvent('blackout:resetAllZones')
AddEventHandler('blackout:resetAllZones', function()
    local src = source

    if not HasPermission(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Access Denied",
            description = "You don't have permission to do this.",
            type = "error",
            duration = 3000
        })
        return
    end

    
    local oldZones = blackoutZones
    local wasGlobalEnabled = globalBlackoutEnabled

    
    blackoutZones = {}
    globalBlackoutEnabled = false

    
    TriggerClientEvent('blackout:updateZoneState', -1, "global", false)
    for zoneName, _ in pairs(oldZones) do
        TriggerClientEvent('blackout:updateZoneState', -1, zoneName, false)
    end

    
    LogAction(src, "Reset All Zones", "All")

    
    TriggerClientEvent('ox_lib:notify', src, {
        title = "Power System",
        description = "All blackout zones have been reset.",
        type = "success",
        duration = 4000
    })
end)

RegisterServerEvent('blackout:placeZoneTrigger')
AddEventHandler('blackout:placeZoneTrigger', function(coords, zoneName)
    local src = source

    if not HasPermission(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Access Denied",
            description = "You don't have permission to control power.",
            type = "error",
            duration = 3000
        })
        return
    end

    if zoneName == "global" then
        globalBlackoutEnabled = not globalBlackoutEnabled
        TriggerClientEvent('blackout:updateZoneState', -1, "global", globalBlackoutEnabled)

        LogAction(src, globalBlackoutEnabled and "Enabled Global Blackout" or "Disabled Global Blackout", "Global")

        TriggerClientEvent('ox_lib:notify', src, {
            title = "Global Power Control",
            description = ("Global blackout %s"):format(globalBlackoutEnabled and "enabled" or "disabled"),
            type = globalBlackoutEnabled and "warning" or "success",
            duration = 4000
        })
        return
    end

    blackoutZones[zoneName] = not blackoutZones[zoneName]

    TriggerClientEvent('blackout:updateZoneState', -1, zoneName, blackoutZones[zoneName])

    LogAction(src, blackoutZones[zoneName] and "Enabled Blackout" or "Disabled Blackout", zoneName)

    TriggerClientEvent('ox_lib:notify', src, {
        title = "Zone Power Control",
        description = ("%s blackout for %s"):format(
            blackoutZones[zoneName] and "Enabled" or "Disabled",
            zoneName
        ),
        type = blackoutZones[zoneName] and "warning" or "success",
        duration = 3000
    })
end)



if Config.EnableScheduledBlackouts then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60000)  -- Check every minute
            
            for _, schedule in ipairs(Config.ScheduledBlackouts) do
                local shouldBeBlackout = false
                
                
                if schedule.startHour > schedule.endHour then
                    shouldBeBlackout = currentGameHour >= schedule.startHour or currentGameHour < schedule.endHour
                else
                    shouldBeBlackout = currentGameHour >= schedule.startHour and currentGameHour < schedule.endHour
                end
                
                if schedule.zone == "global" then
                    if shouldBeBlackout ~= globalBlackoutEnabled then
                        globalBlackoutEnabled = shouldBeBlackout
                        TriggerClientEvent('blackout:updateZoneState', -1, "global", shouldBeBlackout)
                        print("[Blackout] Scheduled global blackout: " .. tostring(shouldBeBlackout) .. " (Hour: " .. currentGameHour .. ")")
                    end
                else
                    local currentState = blackoutZones[schedule.zone] or false
                    if shouldBeBlackout ~= currentState then
                        blackoutZones[schedule.zone] = shouldBeBlackout
                        TriggerClientEvent('blackout:updateZoneState', -1, schedule.zone, shouldBeBlackout)
                        print("[Blackout] Scheduled " .. schedule.zone .. " blackout: " .. tostring(shouldBeBlackout) .. " (Hour: " .. currentGameHour .. ")")
                    end
                end
            end
        end
    end)
end



RSGCore.Commands.Add('forceblackout', 'Force blackout on a zone (Admin)', {
    { name = 'zone', help = 'Zone name or "global"' },
    { name = 'state', help = 'on/off' }
}, true, function(source, args)
    local zoneName = args[1]
    local state = args[2] == 'on'

    if zoneName == 'global' then
        globalBlackoutEnabled = state
        TriggerClientEvent('blackout:updateZoneState', -1, "global", state)
    else
        blackoutZones[zoneName] = state
        TriggerClientEvent('blackout:updateZoneState', -1, zoneName, state)
    end

    TriggerClientEvent('ox_lib:notify', source, {
        title = "Admin Power Control",
        description = ("Set %s to %s"):format(zoneName, state and "BLACKOUT" or "POWERED"),
        type = "info",
        duration = 3000
    })
end, 'admin')

RSGCore.Commands.Add('blackoutstatus', 'Check blackout status (Admin)', {}, false, function(source, args)
    print("=== BLACKOUT STATUS ===")
    print("Global: " .. tostring(globalBlackoutEnabled))
    print("Current Game Hour: " .. currentGameHour)
    for zone, state in pairs(blackoutZones) do
        print(zone .. ": " .. tostring(state))
    end
    print("========================")
end, 'admin')
