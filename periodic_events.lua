--------------------------------------------------------------------------------

require("ambush")   -- Import the functions from ambush.lua.
require("travel")   -- Import the functions from travel.lua.
require("treasure") -- Import the functions from treasure.lua.
require("tempo")    -- Import the functions from tempo.lua.

--------------------------------------------------------------------------------

local denizens_of_the_spirit_world = {}


-- this should only be called when someone is logging in while dead and trying
-- to join the periodic event queues. Adjust as necessary.
local function spiritHeartbeat()
    local next = next
    if next(denizens_of_the_spirit_world) == nil then
        print("no spirits, returning")
        return
    end
    for guid, isDead in pairs(denizens_of_the_spirit_world) do
        local player = GetPlayerByGUID(guid)
        if player ~= nil then -- if player is not logged out
            if not player:IsDead() then
                print("player is no longer dead, removing from spirit world")
                denizens_of_the_spirit_world[guid] = nil
                InitialLogin(nil, player)
            end
        end
    end
    CreateLuaEvent(spiritHeartbeat, 1000, 1)
end

--------------------------------------------------------------------------------

local function periodicEvent(eventFunction, delay, repeats, player)
    if player:IsDead() then
        if denizens_of_the_spirit_world[player:GetGUID()] == nil then
            denizens_of_the_spirit_world[player:GetGUID()] = true
        end
        return
    else
        player:RegisterEvent(eventFunction, delay, repeats, player)
    end
end

function PeriodicSpawnAmbush(eventID, delay, repeats, player)
    periodicEvent(PeriodicSpawnAmbush, delay, repeats, player)
    if not player:IsStandState()                then print("no ambush - player is sitting down")
    elseif player:IsDead()                      then print("no ambush - player is dead")
    elseif player:IsInWater()                   then print("no ambush - player is in water")
    elseif player:GetData("num-ambushers") >= 3 then print("no ambush - too many ambushers")
    elseif player:GetData("is-in-boss-fight")   then print("no ambush - in boss fight")
    else
        Ambush.spawnAndAttackPlayer(nil, nil, nil, player)
    end
end

function PeriodicSpawnTravellers(eventID, delay, repeats, player)
    periodicEvent(PeriodicSpawnTravellers, delay, repeats, player)
    if player:IsDead() or player:IsInWater() or not player:IsStandState() then
        print("skipping traveller spawn")
        return
    else
        Travel.spawnAndTravel(player)
    end
end

function PeriodicSpawnTreasure(eventID, delay, repeats, player)
    periodicEvent(PeriodicSpawnTreasure, delay, repeats, player)
    if player:IsDead() or player:IsInWater() or not player:IsStandState() then
        print("skipping treasure spawn")
        return
    else
        Treasure.spawnTreasure(player)
    end
end

--------------------------------------------------------------------------------

function InitialLogin(_event, player)
    if player:IsDead() then
        denizens_of_the_spirit_world[player:GetGUID()] = true
        CreateLuaEvent(spiritHeartbeat, 1000, 1)
        return
    end

    local DELAY_PERIODIC_SPAWN_CREATURE  = 21  * 1000  -- 21  seconds
    local DELAY_PERIODIC_SPAWN_TRAVELLER = 210 * 1000  -- 210 seconds
    local DELAY_PERIODIC_SPAWN_TREASURE  = 120 * 1000  -- 120 seconds
    periodicEvent(PeriodicSpawnAmbush,
                  DELAY_PERIODIC_SPAWN_CREATURE,
                  1,
                  player)
    periodicEvent(PeriodicSpawnTravellers,
                  DELAY_PERIODIC_SPAWN_TRAVELLER,
                  1,
                  player)
    periodicEvent(PeriodicSpawnTreasure,
                  DELAY_PERIODIC_SPAWN_TREASURE,
                  1,
                  player)
end

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, InitialLogin)

--------------------------------------------------------------------------------
