local isCuffed = false
local lastCommandAt = 0

-- Statebag for other resources to query
LocalPlayer.state.isCuffed = false

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function ensureAnim(dict, timeout)
    local expire = GetGameTimer() + (timeout or 2500)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
    end
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() > expire then
            return false
        end
    end
    return true
end

local function stopAnim(dict, name)
    if IsEntityPlayingAnim(PlayerPedId(), dict, name, 3) then
        StopAnimTask(PlayerPedId(), dict, name, 1.0)
    end
    RemoveAnimDict(dict)
end

local function applyCuffedState(state)
    local ped = PlayerPedId()
    isCuffed = state
    LocalPlayer.state.isCuffed = state

    SetEnableHandcuffs(ped, state)     -- sets correct movement style
    DisablePlayerFiring(PlayerId(), state)

    if state then
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        -- Play looping arresting idle
        if ensureAnim(Config.AnimDict, Config.AnimLoadTimeoutMs) then
            TaskPlayAnim(ped, Config.AnimDict, Config.AnimName, 8.0, -8.0, -1, Config.AnimFlags, 0, false, false, false)
        end
    else
        stopAnim(Config.AnimDict, Config.AnimName)
    end
end

-- Control disabler loop
CreateThread(function()
    while true do
        if isCuffed then
            for _, control in ipairs(Config.DisableControls) do
                DisableControlAction(0, control, true)
            end
            -- prevent weapon wheel & aiming every frame
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 24, true)
        end
        Wait(0)
    end
end)

-- Optional auto-uncuff on death/respawn
if Config.AutoUncuffOnDeath then
    AddEventHandler('baseevents:onPlayerDied', function() if isCuffed then applyCuffedState(false) end end)
    AddEventHandler('baseevents:onPlayerKilled', function() if isCuffed then applyCuffedState(false) end end)
    AddEventHandler('playerSpawned', function() if isCuffed then applyCuffedState(false) end end)
end

-- Command helpers
local function cooldownReady()
    local now = GetGameTimer()
    if (now - lastCommandAt) >= Config.CooldownMs then
        lastCommandAt = now
        return true
    end
    return false
end

local function tryCuff()
    if not cooldownReady() then return end
    if isCuffed and Config.ToggleOnSingleCommand then
        TriggerServerEvent('cuff:server:syncState', GetPlayerServerId(PlayerId()), false)
        applyCuffedState(false)
        notify('~g~You removed your cuffs.')
        return
    end
    if isCuffed then
        notify('~r~You are already cuffed. Use /' .. Config.Commands.Uncuff .. ' to remove cuffs.')
        return
    end
    TriggerServerEvent('cuff:server:syncState', GetPlayerServerId(PlayerId()), true)
    applyCuffedState(true)
    notify('~y~You cuffed yourself.')
end

local function tryUncuff()
    if not cooldownReady() then return end
    if not isCuffed then
        notify('~r~You are not cuffed.')
        return
    end
    TriggerServerEvent('cuff:server:syncState', GetPlayerServerId(PlayerId()), false)
    applyCuffedState(false)
    notify('~g~You removed your cuffs.')
end

-- Register commands
CreateThread(function()
    RegisterCommand(Config.Commands.Cuff, tryCuff, false)
    RegisterCommand(Config.Commands.Uncuff, tryUncuff, false)

    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Cuff, 'Cuff yourself (toggle if enabled).')
    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Uncuff, 'Remove your cuffs.')
end)

-- Receive state from server (other players update and late joiners)
RegisterNetEvent('cuff:client:setState', function(serverId, state)
    local myServerId = GetPlayerServerId(PlayerId())
    if serverId == myServerId then
        -- Reinforce local state (server echo)
        applyCuffedState(state)
    else
        -- For now we only handle local player visuals; remote visibility is already handled by SetEnableHandcuffs and animation replication.
        -- If in the future you want to attach props or advanced effects, handle remote ped lookup here.
    end
end)

-- Export
exports('IsSelfCuffed', function()
    return isCuffed
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if isCuffed then
            applyCuffedState(false)
        end
    end
end)
