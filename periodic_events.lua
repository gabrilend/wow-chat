
require("ambush") -- Import the functions from ambush.lua.
require("travel") -- Import the functions from travel.lua.
require("tempo")  -- Import the functions from tempo.lua.

function PeriodicSpawnAmbush(eventID, delay, repeats, player)
    Ambush.spawnAndAttackPlayer(player)
end

function PeriodicSpawnTravellers(eventID, delay, repeats, player)
    Travel.spawnAndTravel(player)
end

function InitialLogin(event, player)
    if player:IsDead() then
        player:RegisterEvent(InitialLogin, 1000, 1 )
        return
    end

    local DELAY_PERIODIC_SPAWNCREATURE  = 18 * 1000   -- 3 minutes
    local DELAY_PERIODIC_SPAWNTRAVELLER = 210 * 1000  -- 5 minutes
    player:RegisterEvent(PeriodicSpawnAmbush,
                         DELAY_PERIODIC_SPAWNCREATURE,
                         0)
    player:RegisterEvent(PeriodicSpawnTravellers,
                         DELAY_PERIODIC_SPAWNTRAVELLER,
                         0)
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, InitialLogin)
