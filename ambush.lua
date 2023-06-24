-----------------------------------------------------------------------------------------------

            Ambush = {} -- table to hold the functions.
local AmbushQueues = {} -- table to hold monsters that are queued to attack.

-- add more when you find them
-- 7074 and 7073 are maybes, try fighting them and see if they're too hard
-- 11141 on thin ice
Ambush.BANNED_CREATURE_IDS = { 17887, 19416, 2673,  3569,  16422, 16423, -- {{{
                               16437, 16438, 17206, 1946,  5893,  4789,
                               5894,  7050,  7067,  7310,  7849,  5723,
                               11876, 17207, 2794,  11560, 11195, 13736,
                               7767,  6388,  14638, 14639, 14603, 14604,
                               14640, 8608,  1800,  1801,  4476,  22408,
                               13022, 13279, 7149,  10940, 10943, 14467,
                               28654, 28768, 10387, 10836, 11076, 18978,
                               10479, 10482, 11078, 19136, 14385, 16141,
                               16298, 16299, 16043, 20145, 20496, 22461,
                               16992, 17399, 17477, 19016, 16939, 20680,
                               21040, 20498, 20918, 21233, 21817, 21820,
                               21821, 19493, 19494, 19757, 19760, 19966,
                               19971, 20480, 20927, 20983, 22025, 25296,
                               19759, 21778, 21779, 25382, 26224, 18605,
                               18606, 19967, 20310, 20311, 20312, 20313,
                               20320, 20321, 20323, 20643, 20655, 21531,
                               21552, 21554, 21555, 21646, 21916, 22009,
                               22201, 22202, 22286, 22289, 23100, 23386,
                               24564, 24597, 24598, 24599, 24600, 24602,
                               24603, 24604, 24621, 24622, 24623, 24624,
                               24625, 24626, 24627, 25766, 30763, 30773,
                               18614, 20309, 20322, 20784, 20789, 22221,
                               22327, 22392, 24029, 24790, 26045, 26225,
                               27513, 25678, 25682, 26490, 26517, 26573,
                               26966, 25712, 25716, 26232, 26518, 26526,
                               26702, 26703, 26811, 26812, 27614, 27821,
                               29117, 29118, 26872, 28750, 28006, 28170,
                               28669, 28320, 28875, 28752, 30633, 26536,
                               30053, 30432, 31812, 33499, 29775, 30055,
                               30791, 30843, 30902, 30921, 30957, 30958,
                               30960, 31042, 31141, 31274, 31321, 31325,
                               31326, 31327, 31468, 31554, 31555, 31671,
                               31681, 31692, 31798, 32161, 32767, 32769,
                               33289
                             } -- }}}

Ambush.BANNED_RARE_IDS = { 0, -- {{{
                         } -- }}}

-----------------------------------------------------------------------------------------------

function Ambush.spawnAndAttackPlayer(_eventID, _delay, _repeats, player) -- {{{

    -- if there are no monsters queued for this player, then query the database
    local next = next
    if next(player:GetData("queue")) == nil then
        local playerLevel = player:GetLevel()
        if next(player:GetData("rare-queue")) == nil then
            -- playtest this
            if player:IsInGroup() and player:GetGroup():GetMembersCount() > 2 then
                print("Heh, thought you could escape us? Think again! (group rare mob spawning)")
                Ambush.setupGroupRareQueue(playerLevel)
            else
                print("Heh, thought you could escape me? Think again! (solo rare mob spawning)")
                Ambush.setupSoloRareQueue(playerLevel)
            end
        else
            print("Heh, thought you could escape me? Think again! (rare mob spawning)")
            Ambush.randomSpawnRare(playerLevel)
        end
        -- player:RegisterEvent(Ambush.spawnAndAttackPlayer, 3000, 1)
        Ambush.setupQueue(playerLevel)
    else
        Ambush.randomSpawn(player)
    end
end -- }}}

-----------------------------------------------------------------------------------------------

function Ambush.setupQueue(playerLevel) -- {{{
    local QUEUE_SIZE = 25
    WorldDBQueryAsync("SELECT entry, minlevel, maxlevel FROM creature_template WHERE minlevel <= " .. playerLevel .. " AND maxlevel >= " .. playerLevel .. " AND rank = 0 AND npcflag = 0 AND lootid != 0 AND (type = 2 OR type = 3 OR type = 4 OR type = 5 OR type = 6 OR type = 9 OR type = 10) LIMIT " .. QUEUE_SIZE .. ";", Ambush.pushToAmbushQueue)
end -- }}}

function Ambush.setupSoloRareQueue(playerLevel) -- {{{
    local LEVEL_MAX = playerLevel - 1 -- must be set in pushToRareQueue() as well
    local LEVEL_MIN = playerLevel + 1
    WorldDBQueryAsync("SELECT entry, minlevel, maxlevel FROM creature_template WHERE minlevel <= " .. LEVEL_MIN .. " AND maxlevel >= " .. LEVEL_MAX .. " AND rank = 4 AND npcflag = 0 AND lootid != 0 AND (type = 2 OR type = 3 OR type = 4 OR type = 5 OR type = 6 OR type = 9 OR type = 10);", Ambush.pushToRareQueue)
end -- }}}

function Ambush.setupGroupRareQueue(playerLevel) -- {{{
    local LEVEL_MAX = playerLevel - 1 -- differential between player level and monster level
    local LEVEL_MIN = playerLevel + 1 -- larger numbers mean a larger range of monster level
    WorldDBQueryAsync("SELECT entry, minlevel, maxlevel FROM creature_template WHERE minlevel <= " .. LEVEL_MIN .. " AND maxlevel >= " .. LEVEL_MAX .. " AND rank = 2 AND npcflag = 0 AND lootid != 0 AND (type = 2 OR type = 3 OR type = 4 OR type = 5 OR type = 6 OR type = 9 OR type = 10);", Ambush.pushToRareQueue)
end -- }}}

function Ambush.pushToAmbushQueue(query) -- {{{

    local creatures = {}
    if query then
        repeat
            local creature = {
                id       = query:GetUInt32(0),
                minLevel = query:GetUInt32(1),
                maxLevel = query:GetUInt32(2)
            }
            if not Ambush.isCreatureBanned(creature.id) then
                table.insert(creatures, creature)
            end
        until not query:NextRow()
    else
        print("no query found wtf")
        return
    end

    all_players = { alliance = GetPlayersInWorld(0, false),
                    horde    = GetPlayersInWorld(1, false),
                    neutral  = GetPlayersInWorld(2, false)
                  }

    -- for each player currently logged in
    for _, faction in pairs(all_players) do
        for _, player in pairs(faction) do
            local playerLevel = player:GetLevel()
            if playerLevel ~= 0 then
                -- for each creature that we just queried
                for _, creature in ipairs(creatures) do
                    -- if this creature is appropriate for this player
                    if playerLevel >= creature.minLevel and
                       playerLevel <= creature.maxLevel then
                        -- queue this creature for this player
                        tempTable = player:GetData("queue")
                        table.insert(tempTable, creature.id)
                        player:SetData("queue", tempTable)
                    end
                end
            else
                print("player level == 0 which is weird")
            end
        end
    end
end -- }}}

function Ambush.pushToRareQueue(query) -- {{{
    local LEVEL_MAX = 1 -- differential between player level and monster level
    local LEVEL_MIN = 1 -- MAKE SURE YOU ALSO SET IN setup[Solo/Group]RareQueue()

    local creatures = {}
    if query then
        repeat
            local creature = {
                id       = query:GetUInt32(0),
                minLevel = query:GetUInt32(1),
                maxLevel = query:GetUInt32(2)
            }
            if not Ambush.isRareCreatureBanned(creature.id) then
                table.insert(creatures, creature)
            end
        until not query:NextRow()
    else
        print("no query found wtf")
        return
    end

    all_players = { alliance = GetPlayersInWorld(0, false),
                    horde    = GetPlayersInWorld(1, false),
                    neutral  = GetPlayersInWorld(2, false)
                  }

    -- for each player currently logged in
    for _, faction in pairs(all_players) do
        for _, player in pairs(faction) do
            if not player:GetData("is-in-boss-fight") then
                return
            end
            local playerLevel = player:GetLevel()
            if playerLevel ~= 0 then
                -- for each creature that we just queried
                for _, creature in ipairs(creatures) do
                    -- if this creature is appropriate for this player
                    if playerLevel >= creature.minLevel - 1 and
                       playerLevel <= creature.maxLevel + 1 then
                        -- queue this creature for this player
                        tempTable = player:GetData("rare-queue")
                        table.insert(tempTable, creature.id)
                        player:SetData("rare-queue", tempTable)
                    end
                end
            else
                print("player level == 0 which is weird")
            end
        end
    end
end -- }}}

function Ambush.addCreatureToQueue(player, creatureId) -- {{{
    local tempTable = player:GetData("queue")
    table.insert(tempTable, creatureId)
    player:SetData("queue", tempTable)
end -- }}}

-----------------------------------------------------------------------------------------------

-- make sure this function is in the async callback function... it might take
-- a while depending on how many banned creatures there are.
function Ambush.isCreatureBanned(creatureId) -- {{{

    for _, id in ipairs(Ambush.BANNED_CREATURE_IDS) do
        if creatureId == id then
            return true
        end
    end
    return false
end -- }}}

function Ambush.isRareCreatureBanned(creatureId) -- {{{

    for _, id in ipairs(Ambush.BANNED_RARE_IDS) do
        if creatureId == id then
            return true
        end
    end
    return false
end -- }}}

-----------------------------------------------------------------------------------------------

function Ambush.randomSpawn(player) -- {{{
    local ambush_min_distance = 60
    local ambush_max_distance = 75


    local  playerID   = player:GetGUID(                         ) -- ?
    local playerQueue = player:GetData("queue"                  )
    local   randInt   = math.random   (1, #playerQueue          ) -- what the fuck
    local  creatureId = table.remove(      playerQueue, randInt )
    player:SetData(     "queue",           playerQueue          ) -- oh god it gets worse

    print("Ambush! Watch out, here comes " .. creatureId .. "!")
    player:SendBroadcastMessage("Ambush! Watch out, here comes " .. creatureId .. "!")

    if creatureId ~= 0 then
        local x, y, z, o = player:GetLocation()
              x, y       = Movement.getPlusSpawnPosition(x, y, ambush_min_distance, ambush_max_distance)
                    z    = player:GetMap():GetHeight(x, y)
                       o = math.random(0, 6.28)
        local TEMPSUMMON_CORPSE_TIMED_DESPAWN = 6
        local TEMPSUMMON_DESPAWN_TIMER = 60 * 1000 -- 60 seconds
        local creature = player:SpawnCreature(creatureId, x, y, z, o,
                                              TEMPSUMMON_CORPSE_TIMED_DESPAWN,
                                              TEMPSUMMON_DESPAWN_TIMER)
        if creature then
            -- check and make sure the creature did not spawn in the water
            -- if it did, then try 3 times to find a new spawn location.
            -- if one cannot be found, then just give up and despawn the creature
            -- is-in-water check {{{
            local tries = 0
            while creature:IsInWater() and tries < 3 do
                tries = tries + 1
                x, y = Movement.getPlusSpawnPosition(x, y, ambush_min_distance, ambush_max_distance)
                z    = player:GetMap():GetHeight(x, y)
                creature:NearTeleport(x, y, z, o)
            end
            if tries == 3 then
                creature:DespawnOrUnsummon(0)
                return
            end
            --- }}}

            creature:SetData("ambush-chase-target", playerID)
            creature:SetData("ambush-max-distance", ambush_max_distance)
            player  :SetData("num-ambushers", player:GetData("num-ambushers") + 1)
            creature:RegisterEvent(Ambush.chasePlayer, 1000, 1)
        end
    end
end -- }}}

function Ambush.randomSpawnRare(player) -- {{{
    local ambush_min_distance = 60
    local ambush_max_distance = 75

    local  playerID   = player:GetGUID(                         ) -- ?
    local playerQueue = player:GetData("rare-queue"             )
    local   randInt   = math.random   (1, #playerQueue          ) -- what the fuck
    local  creatureId = table.remove(      playerQueue, randInt )
    player:SetData(     "rare-queue",      playerQueue          ) -- oh god it gets worse

    print("Rare creature spawn: " .. creatureId .. " - Regenerating queue.")
    player:SendBroadcastMessage("A dark rustling alerts you to a dangerous presence. Keep a lookout.")

    if creatureId ~= 0 then
        local x, y, z, o = player:GetLocation()
              x, y       = Movement.getPlusSpawnPosition(x, y, ambush_min_distance, ambush_max_distance)
                    z    = player:GetMap():GetHeight(x, y)
                       o = math.random(0, 6.28)
        local TEMPSUMMON_MANUAL_DESPAWN = 8
        local creature = player:SpawnCreature(creatureId, x, y, z, o,
                                              TEMPSUMMON_CORPSE_TIMED_DESPAWN)
        if creature then
            -- check and make sure the creature did not spawn in the water
            -- if it did, then try 3 times to find a new spawn location.
            -- if one cannot be found, then just give up and despawn the creature
            -- is-in-water check {{{
            local tries = 0
            while creature:IsInWater() and tries < 3 do
                tries = tries + 1
                x, y = Movement.getPlusSpawnPosition(x, y, ambush_min_distance, ambush_max_distance)
                z    = player:GetMap():GetHeight(x, y)
                creature:NearTeleport(x, y, z, o)
            end
            if tries == 3 then
                creature:DespawnOrUnsummon(0)
                return
            end
            --- }}}

            creature:SetData("rare-chase-target", playerID)
            creature:SetData("ambush-max-distance", ambush_max_distance) -- what is this used for?
            player  :SetData("is-in-boss-fight", true)
            creature:RegisterEvent(Ambush.chasePlayer, 1000, 1)
        end
    end
end -- }}}

-----------------------------------------------------------------------------------------------

function Ambush.chasePlayer(_eventID, _delay, _repeats, creature) -- {{{
    if creature:IsDead() then
        return
    end
                                      -- DISTNACE FROM THE MIDPOINT BETWEEN THE PLAYER AND THE
                                      -- CREATURE
    local     CREATURE_MAX_DISTANCE    = creature:GetData("ambush-max-distance") or 60
    local         WANDER_RADIUS        = creature:GetData("wander-radius") or 10
    local WANDER_RADIUS_INCREASE_DELAY = 5000 ----- time between each increase in wander radius
    local            playerID          = creature:GetData("ambush-chase-target") -- required
    local             player           = GetPlayerByGUID(playerID)
    local           creatureX,
                    creatureY,
                    creatureZ,
                    creatureO          = creature:GetLocation()

    if player:IsDead() or not player:IsStandState() then
        print("wandering")
        creature:MoveClear()
        creature:SetHomePosition(creatureX, creatureY, creatureZ, creatureO)
        creature:MoveRandom(WANDER_RADIUS)
        creature:SetData("wander-radius", WANDER_RADIUS)
        creature:RegisterEvent(Ambush.chasePlayer, WANDER_RADIUS_INCREASE_DELAY, 1)
        return
    end
    local playerX, playerY = player:GetLocation()
    if Movement.isCloseEnough(creatureX, creatureY, playerX, playerY, 5) then
        creature:SetHomePosition(creatureX, creatureY, creatureZ, creatureO)
        creature:AttackStart(player)
    else
        local targetX, targetY = Movement.getMidpoint( creature:GetX(),
                                                       creature:GetY(),
                                                       playerX,
                                                       playerY
                                                     )
        if Movement.getLazyDistance(creatureX, creatureY, targetX, targetY) > CREATURE_MAX_DISTANCE then
            print(Movement.getLazyDistance(creatureX, creatureY, targetX, targetY) .." yards is too far away, despawning")
            player:SetData("num-ambushers", player:GetData("num-ambushers") - 1)
            creature:DespawnOrUnsummon(0)
        end
        local targetZ = creature:GetMap():GetHeight(targetX, targetY)

        creature:MoveTo(math.random(0, 4294967295), targetX, targetY, targetZ)
        creature:RegisterEvent(Ambush.chasePlayer, 1000, 1)
    end
end -- }}}

function Ambush.onCreatureDeath(event, killer, creature) -- {{{
    print("on creature death")
    owning_player_ID = creature:GetData("ambush-chase-target") or nil
    if owning_player_ID then
        local player = GetPlayerByGUID(owning_player_ID)
        if player then
            if player:GetData("is-in-boss-fight") then
                print("player no longer in a boss fight")
                player:SetData("is-in-boss-fight", false)
            else
                local numAmbushers = player:GetData("num-ambushers") or 1
                if    numAmbushers > 0 then
                    print("setting numAmbushers to " .. numAmbushers - 1)
                    player:SetData("num-ambushers", numAmbushers - 1)
                end
            end
        end
    end
end -- }}}

-----------------------------------------------------------------------------------------------

function Ambush.setupPlayer(event, player)
    player:SetData( "queue", {} )
    player:SetData( "rare-queue", {} )
    player:SetData( "num-ambushers", 0 )
end

PLAYER_EVENT_ON_LOGIN = 3
PLAYER_EVENT_ON_KILL_CREATURE = 7
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,  Ambush.setupPlayer)
RegisterPlayerEvent(PLAYER_EVENT_ON_KILL_CREATURE, Ambush.onCreatureDeath, 0)

-----------------------------------------------------------------------------------------------
