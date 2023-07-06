require "movement" -- for spawning the chests at specific positions

Treasure = { chests = {} }

local chests = { { id = 2843,   minLevel = 1,  maxLevel = 5  },
                 { id = 106318, minLevel = 3,  maxLevel = 7  },
                 { id = 106319, minLevel = 6,  maxLevel = 10 },
                 -- { id = 152608, minLevel = 11, maxLevel = 15 }, -- kolkar's booty, req key
                 { id = 75293,  minLevel = 11, maxLevel = 15 },
                 { id = 75298,  minLevel = 16, maxLevel = 21 },
                 { id = 74448,  minLevel = 21, maxLevel = 27 },
                 { id = 75299,  minLevel = 27, maxLevel = 31 },
                 { id = 75300,  minLevel = 30, maxLevel = 35 },
                 { id = 142184, minLevel = 36, maxLevel = 41 }, -- captain's chest
                 { id = 141979, minLevel = 36, maxLevel = 40 }, -- uldaman chest
                 { id = 179697, minLevel = 41, maxLevel = 49 }, -- arena chest (blue bracers)
                 { id = 190552, minLevel = 40, maxLevel = 80 }, -- chest with vendor trash, sells for gold
                 { id = 153464, minLevel = 50, maxLevel = 60 },
                 { id = 179564, minLevel = 54, maxLevel = 59 }, -- dire maul chest
                 { id = 179528, minLevel = 55, maxLevel = 80 },
                 { id = 181804, minLevel = 57, maxLevel = 62 },
                 { id = 185168, minLevel = 60, maxLevel = 60 }, -- ramparts chest
                 { id = 184930, minLevel = 60, maxLevel = 64 },
                 { id = 184933, minLevel = 64, maxLevel = 66 },
                 { id = 184937, minLevel = 66, maxLevel = 68 },
                 { id = 184941, minLevel = 68, maxLevel = 74 },
                 { id = 186744, minLevel = 69, maxLevel = 72 }, -- random lvl 70 greens
                 { id = 184465, minLevel = 69, maxLevel = 71 }, -- mechanar normal mode
                 { id = 186672, minLevel = 72, maxLevel = 79 }, -- zul'aman rings (level 70)
                 { id = 187892, minLevel = 72, maxLevel = 79 }, -- tbc cloaks
                 { id = 188191, minLevel = 72, maxLevel = 79 }, -- tbc amulets
                 { id = 190586, minLevel = 76, maxLevel = 79 }, -- halls of stone normal mode
                 { id = 193996, minLevel = 80, maxLevel = 80 }, -- halls of stone heroic mode
                 { id = 190663, minLevel = 78, maxLevel = 80 }, -- culling of stratholme - Mal'Ganis
                 { id = 193402, minLevel = 80, maxLevel = 80 }, -- rusted prisoner's footlocker
                 { id = 193603, minLevel = 80, maxLevel = 80 }, -- oculus dungeon gear
                 { id = 193905, minLevel = 80, maxLevel = 80 }, -- eye of eternity raid gear
                 { id = 194331, minLevel = 80, maxLevel = 80 }, -- ulduar raid gear
                 { id = 194308, minLevel = 80, maxLevel = 80 }, --      cache of winter - Ulduar
                 { id = 194201, minLevel = 80, maxLevel = 80 }, -- rare cache of winter - Ulduar
                 { id = 181366, minLevel = 80, maxLevel = 80 }, -- four horseman chest (lvl 80)

                 { id = 2849,   minLevel = 1,  maxLevel = 80 }, -- dinosaur bone
               }
Treasure.chests = chests

-- public functions
-- used to add a treasure to a player's queue.
function Treasure.addTreasure(playerID, chestID)
    local player = GetPlayerByGUID(playerID)
    local playerQueue = player:GetData("treasureChests")
    table.insert(playerQueue, chestID)
    player:SetData("treasureChests", playerQueue)
end

-- makes treasure for the player!
function Treasure.spawnTreasure(player)
    local treasureMinDist = 20
    local treasureMaxDist = 35
    local playerQueue = player:GetData("treasureChests")
    local next = next
    if playerQueue == nil or next(playerQueue) == nil then
        Treasure.regenerateQueue(player)
        Treasure.spawnTreasure(player)
        return
    else
        local chestID = Treasure.getRandomChestFromQueue(player:GetGUID())
        local x, y, z, o = player:GetLocation()
              x, y       = Movement.getPlusSpawnPosition(x, y, treasureMinDist, treasureMaxDist)
                    z    = player:GetMap():GetHeight(x, y)
                       o = math.random(0, 6.28)
        player:SendBroadcastMessage("Treasure!")
        print("Treasure!")
        if x or y or z or o == nil then
            if not x then print("Treasure: Error getting x for spawn position") end
            if not y then print("Treasure: Error getting y for spawn position") end
            if not z then print("Treasure: Error getting z for spawn position") end
            if not o then print("Treasure: Error getting o for spawn position") end
        end
        local chest = player:SummonGameObject(chestID, x, y, z, o, 0)
    end
end

-- private functions
-- used only when logging in to set up the initial tables
function Treasure.setupTreasure(_event, player)
    local playerQueue = {}
    local playerLevel = player:GetLevel()

    for i, chest in pairs(Treasure.chests) do
        if playerLevel >= chest.minLevel and playerLevel <= chest.maxLevel then
            table.insert(playerQueue, chest.id)
        end
    end
    player:SetData("treasureChests", playerQueue)

end

-- can be used to either create a new queue from scratch
-- or to insert objects into a currently existing queue - quest items?
function Treasure.regenerateQueue(player)
    local playerQueue = player:GetData("treasureChests")
    local playerLevel = player:GetLevel()

    for i, chest in pairs(Treasure.chests) do
        if playerLevel >= chest.minLevel and playerLevel <= chest.maxLevel then
            table.insert(playerQueue, chest.id)
        end
    end
    player:SetData("treasureChests", playerQueue)
end

function Treasure.getRandomChestFromQueue(playerID)
    local player      = GetPlayerByGUID(playerID)
    local playerQueue = player:GetData("treasureChests")
    local chestID     = table.remove(playerQueue, math.random(#playerQueue))
    player:SetData("treasureChests", playerQueue)
    return chestID
end


PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, Treasure.setupTreasure)


