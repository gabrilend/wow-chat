
require("ambush") -- Import the functions from ambush.lua.
require("travel") -- Import the functions from travel.lua.

function PeriodicSpawnAmbush(eventID, delay, repeats)
    for _, player in pairs(GetPlayersInWorld()) do
        Ambush.spawnAndAttackPlayer(player)
    end
end

function PeriodicSpawnTravellers(eventID, delay, repeats)
    for _, player in pairs(GetPlayersInWorld()) do
        Travel.spawnAndTravel(player)
    end
end

function InitialLogin(event, player)
    local DELAY_PERIODIC_SPAWNCREATURE  = 12 * 1000 -- 12 seconds
    local DELAY_PERIODIC_SPAWNTRAVELLER = 300 * 1000 -- 5 minutes
    player:RegisterEvent(PeriodicSpawnAmbush,
                         DELAY_PERIODIC_SPAWNCREATURE,
                         0)
    player:RegisterEvent(PeriodicSpawnTravellers,
                         DELAY_PERIODIC_SPAWNTRAVELLER,
                         0)
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, InitialLogin)
