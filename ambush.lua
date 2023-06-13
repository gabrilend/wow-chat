
Ambush = {} -- table to hold the functions.
AMBUSH_QUEUED_TABLE = {} -- table to hold monsters that are queued to attack.

function Ambush.spawnAndAttackPlayer(player)
    local LEVEL = player:GetLevel()

    -- if there are no monsters queued for this player, then query the database
    local playerID = player:GetGUIDLow()
    if AMBUSH_QUEUED_TABLE[playerID] == nil then
        AMBUSH_QUEUED_TABLE[playerID] = { queue = {}, level = 0 }
    end

    local next = next
    if next(AMBUSH_QUEUED_TABLE[playerID].queue) == nil then
        AMBUSH_QUEUED_TABLE[playerID] = {level = LEVEL} -- store player level
        QUEUE_SIZE = 25 -- how many creatures to pull from the db at once
        WorldDBQueryAsync("SELECT entry, minlevel, maxlevel FROM creature_template WHERE minlevel <= " .. LEVEL .. " AND maxlevel >= " .. LEVEL .. " AND rank = 0 AND npcflag = 0 AND lootid != 0 AND (type = 2 OR type = 3 OR type = 4 OR type = 5 OR type = 6 OR type = 9) LIMIT " .. QUEUE_SIZE .. ";", Ambush.pushToAmbushQueue)
    else
        Ambush.randomSpawn(player)
    end
end

-- important: the player's level must be stored in the table before this is called
--            specifically at AMBUSH_QUEUED_TABLE[playerGUID].level
function Ambush.pushToAmbushQueue(query)

    local creatures = {}
    if query then
        repeat
            local creature = {
                id       = query:GetUInt32(0),
                minLevel = query:GetUInt32(1),
                maxLevel = query:GetUInt32(2)
            }
            if Ambush.isCreatureBanned(creature.id) then
                print("Banned creature " .. creature.id .. " found, skipping")
            else
                table.insert(creatures, creature)
            end
        until not query:NextRow()
    else
        print("no query found wtf")
        return
    end

    -- for each player currently logged in
    for playerGUID, data in pairs(AMBUSH_QUEUED_TABLE) do
        if data.level ~= 0 then
            local playerLevel = data.level
            AMBUSH_QUEUED_TABLE[playerGUID].queue = {} -- initialize queue
            -- for each creaturethat we just queried
            for _, creature in ipairs(creatures) do
                -- if this creature is appropriate for this player
                if playerLevel >= creature.minLevel and
                   playerLevel <= creature.maxLevel then
                    -- queue this creature for this player
                    table.insert(AMBUSH_QUEUED_TABLE[playerGUID].queue,
                                 creature.id)
                else
                    print("Creature not appropriate for player")
                end
            end
        else
            print("player level == 0 which is weird")
        end
    end
end

-- make sure this function is in the async callback function... it might take
-- a while depending on how many banned creatures there are.
function Ambush.isCreatureBanned(creatureId)

    -- add more when you find them
    -- 7074 and 7073 are maybes, try fighting them and see if they're too hard
    -- 11141 on thin ice
    local BANNED_CREATURE_IDS = { 17887, 19416, 2673,  3569,  16422, 16423,
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
                                }

    for _, id in ipairs(BANNED_CREATURE_IDS) do
        if creatureId == id then
            return true
        end
    end
    return false
end

function Ambush.randomSpawn(player)

    local playerID = player:GetGUIDLow()
    local randInt = math.random(1, #AMBUSH_QUEUED_TABLE[playerID].queue)
    local creatureId = table.remove(AMBUSH_QUEUED_TABLE[playerID].queue, randInt)

    print("Ambush! Watch out, here comes " .. creatureId .. "!")


    if creatureId ~= 0 then
        local x, y, z, o = Ambush.getAmbushSpawnPosition(player)
        local TEMPSUMMON_CORPSE_TIMED_DESPAWN = 6
        local TEMPSUMMON_DESPAWN_TIMER = 60 * 1000 -- 60 seconds
        local creature = player:SpawnCreature(creatureId, x, y, z, o,
                                              TEMPSUMMON_CORPSE_TIMED_DESPAWN,
                                              TEMPSUMMON_DESPAWN_TIMER)
        if creature then
            x, y, z, o = Ambush.getAmbushAttackMovePosition(player)
            creature:MoveTo(math.random(0, 4294967295), x, y, z, o)
            creature:AttackStart(player)
        end
    end
end

-- this should make a rough circle around the player
-- it's more like a plus shape but that's close enough
function Ambush.getAmbushSpawnPosition(player)
    local x, y, z, o = player:GetLocation()
    randInt = math.random(1, 4)
    if randInt == 1 then
        x = x + math.random(45,60)
        y = y + math.random(-45, 45)
    elseif randInt == 2 then
        x = x + math.random(-60, -45)
        y = y + math.random(-45, 45)
    elseif randInt == 3 then
        x = x + math.random(-45, 45)
        y = y + math.random(45, 60)
    elseif randInt == 4 then
        x = x + math.random(-45, 45)
        y = y + math.random(-60, -45)
    end

    return x, y, z, o
end

-- not sure how necessary this is
-- generates a random position that's pretty close to the player
function Ambush.getAmbushAttackMovePosition(player)
    local x, y, z, o = player:GetLocation()
    return x + math.random(), y + math.random(), z, o
end

