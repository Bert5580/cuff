-- Simple broadcast of cuff state. No framework required.
RegisterNetEvent('cuff:server:syncState', function(serverId, state)
    -- Validate types to avoid nil issues
    local src = source
    if type(serverId) ~= 'number' then serverId = src end
    local isCuffed = (state == true)

    -- Forward to all clients (including sender) for idempotent application
    TriggerClientEvent('cuff:client:setState', -1, serverId, isCuffed)
end)
