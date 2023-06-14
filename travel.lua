require("movement") -- movement.lua

Travel = { players    = {},
           travellers = {}
         }

function Travel.addPlayer(_event, player)
    local playerID = player:GetGUIDLow()
    print("Travel.addPlayer() called")
    print(_event)
    print(player)
    print(Travel.players[playerID])
    if Travel.players[playerID] == nil then
        Travel.players[playerID] = { travellers = {},
                                     typeMask = 0,
                                     playerFaction = 0,
                                     playerLevel = player:GetLevel()
                                   }
    else
        print("You're calling Travel.addPlayer() wrong.")
    end
    if player.IsHorde == true then
        Travel.players[playerID].playerFaction = 1
    else
        Travel.players[playerID].playerFaction = 2
    end
    local playerClass = player:GetClass()
    Travel.players[playerID].typeMask = Travel.getTravelerTypeMask(playerClass)
    Travel.updatePlayerTravellers(playerID)
end

-- this function returns a bitmask of all the traveller types that a player can spawn
function Travel.getTravelerTypeMask(class)
    if class == 1 then -- 1 = warriort
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 128 + 256 + 512
    end
    if class == 2 then -- 2 = paladin
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
    if class == 3 then -- 3 = hunter
        return 1 + 2 + 4 + 8 + 0  + 32 + 64 + 128 + 256 + 512
    end
    if class == 4 then -- 4 = rogue
        return 0 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256 + 512
    end
    if class == 5 then -- 5 = priest
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
    if class == 6 then -- 6 = death knight
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
    if class == 7 then -- 7 = shaman
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
    if class == 8 then -- 8 = mage
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 0
    end
    if class == 9 then -- 9 = warlock
        return 0 + 2 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
    if class == 11 then -- 11 = druid
        return 0 + 0 + 4 + 8 + 0  + 32 + 64 + 0   + 256 + 512
    end
end

-- runs when a player logs in or levels up or runs out of travellers to spawn
function Travel.updatePlayerTravellers(playerID)
    local playerTypeMask = Travel.players[playerID].typeMask
    local playerLevel    = Travel.players[playerID].playerLevel
    local playerFaction  = Travel.players[playerID].playerFaction

    for _, traveller_category in pairs(Travel.travellers) do
        if bit32.band(traveller_category.typeMask, playerTypeMask) ~= 0 then
            for _, specific_traveller in pairs(traveller_category.list) do
                if Travel.isValidFaction(specific_traveller.faction, playerFaction) and
                   specific_traveller.minLevel <= playerLevel and
                   specific_Traveller.maxLevel >= playerLevel
                   then
                       table.insert(Travel.players[playerID].travellers, specific_traveller.id)
                end
            end
        end
    end
end

function Travel.isValidFaction(f1, f2)
    if ( f1 == f2           ) or
       ( f1 == 1 and f2 == 3) or
       ( f1 == 2 and f2 == 3) or
       ( f1 == 3 and f2 == 1) or
       ( f1 == 3 and f2 == 2) then
        return true
    else
        return false
    end
end

function Travel.getRandomTravellerId(playerID)
    if Travel.players[playerID].travellers ~= nil and
      #Travel.players[playerID].travellers >  0   then
        print("Travel.getRandomTravellerId() called")
        print(#Travel.players[playerID].travellers)
        local randInt = math.random(1, #Travel.players[playerID].travellers)
        return table.remove(Travel.players[playerID].travellers, randInt)
    else
        Travel.updatePlayerTravellers(playerID)
        if Travel.getRandomTravellerId(playerID) == 0 then
            print("you failed")
            return 6496
        end
        return Travel.getRandomTravellerId(playerID)
    end
end

function Travel.spawnAndTravel(player)
    print("A traveller appears...")
    local travellerId = Travel.getRandomTravellerId(player:GetGUIDLow())
    print(travellerId)
    if travellerId ~= 0 then
        local x, y, z, o = player:GetLocation()
              x, y       = Movement.getBoxSpawnPosition(x, y, 30, 45)
                    z    = player:GetMap():GetHeight(x, y)
                       o = math.random(0, 6.28)
        local TEMPSUMMON_TIMED_OR_DEAD_DESPAWN = 1
        local TEMPSUMMON_DESPAWN_TIMER = 300 * 1000 -- 5 minutes
        local traveller = player:SpawnCreature(travellerId, x, y, z, o,
                                               TEMPSUMMON_TIMED_OR_DEAD_DESPAWN,
                                               TEMPSUMMON_DESPAWN_TIMER)

        if traveller then
            traveller:SetSpeed(0, 1)
            traveller:SetWalk(true)
            playerX, playerY = player:GetLocation()
            x, y = Movement.getPositionOppositePoint(x, y, playerX, playerY)
            z    = player:GetMap():GetHeight(x, y)
            traveller:MoveTo(math.random(0, 4294967295), x, y, z, o)
        end
    end
end

-- probably not every vendor, but I tried to get as many as I could

-- rel is a bitmask of faction relations: 1 = friendly to horde
--                                        2 = friendly to alliance
--                                        3 = friendly to both

local food        = { { id = 32642, minLevel = 65, maxLevel = 80, rel = 1 },

                      { id = 258,   minLevel = 1,  maxLevel = 20, rel = 2 },
                      { id = 3937,  minLevel = 6,  maxLevel = 25, rel = 2 },

                      { id = 6496,  minLevel = 1,  maxLevel = 80, rel = 3 }, -- duplicated three times because I'm sadistic
                      { id = 6496,  minLevel = 1,  maxLevel = 80, rel = 3 }, -- duplicate
                      { id = 6496,  minLevel = 1,  maxLevel = 80, rel = 3 }, -- duplicate
                      { id = 2842,  minLevel = 1,  maxLevel = 45, rel = 3 },
                      { id = 23699, minLevel = 65, maxLevel = 70, rel = 3 },
                      { id = 32478, minLevel = 65, maxLevel = 80, rel = 3 },
                      { id = 32631, minLevel = 65, maxLevel = 80, rel = 3 },
                    }
local melee       = { { id = 3539,  minLevel = 17, maxLevel = 27, rel = 1 },
                      { id = 3479,  minLevel = 8,  maxLevel = 12, rel = 1 },
                      { id = 1407,  minLevel = 39, maxLevel = 41, rel = 1 }, -- duplicated in armor
                      { id = 10361, minLevel = 39, maxLevel = 41, rel = 1 },
                      { id = 10379, minLevel = 29, maxLevel = 32, rel = 1 }, -- duplicated here
                      { id = 10379, minLevel = 39, maxLevel = 41, rel = 1 }, -- duplicate
                      { id = 21474, minLevel = 29, maxLevel = 31, rel = 1 }, -- duplicated here
                      { id = 21474, minLevel = 66, maxLevel = 66, rel = 1 }, -- duplicate

                      { id = 2265,  minLevel = 1,  maxLevel = 6,  rel = 2 },
                      { id = 1441,  minLevel = 17, maxLevel = 21, rel = 2 },
                      { id = 225,   minLevel = 14, maxLevel = 21, rel = 2 }, -- duplicated here
                      { id = 225,   minLevel = 26, maxLevel = 27, rel = 2 }, -- duplicate
                      { id = 1471,  minLevel = 29, maxLevel = 31, rel = 2 }, -- duplicated here
                      { id = 1471,  minLevel = 40, maxLevel = 41, rel = 2 }, -- duplicate
                      { id = 1296,  minLevel = 39, maxLevel = 41, rel = 2 },
                      { id = 15315, minLevel = 29, maxLevel = 31, rel = 2 }, -- duplicated here
                      { id = 15315, minLevel = 39, maxLevel = 41, rel = 2 }, -- duplicate

                      { id = 2840,  minLevel = 8,  maxLevel = 15, rel = 3 },
                      { id = 4086,  minLevel = 15, maxLevel = 25, rel = 3 },
                      { id = 3534,  minLevel = 10, maxLevel = 20, rel = 3 },
                      { id = 19238, minLevel = 5,  maxLevel = 20, rel = 3 }, -- duplicated here
                      { id = 19238, minLevel = 31, maxLevel = 40, rel = 3 }, -- duplicate
                      { id = 3658,  minLevel = 8,  maxlevel = 15, rel = 3 },
                      { id = 3491,  minLevel = 13, maxLevel = 17, rel = 3 },
                      { id = 23571, minLevel = 30, maxLevel = 41, rel = 3 }, -- duplicated in armor
                      { id = 2483,  minLevel = 29, maxLevel = 30, rel = 3 }, -- duplicated here
                      { id = 2483,  minLevel = 39, maxLevel = 41, rel = 3 }, -- duplicate
                      { id = 2482,  minLevel = 29, maxLevel = 31, rel = 3 },
                      { id = 2843,  minLevel = 29, maxLevel = 31, rel = 3 }, -- duplicated here
                      { id = 2843,  minLevel = 39, maxLevel = 41, rel = 3 }, -- duplicate
                      { id = 3000,  minLevel = 29, maxLevel = 40, rel = 3 },
                      { id = 11184, minLevel = 39, maxLevel = 41, rel = 3 },
                      { id = 12024, minLevel = 39, maxLevel = 41, rel = 3 },
                      { id = 19536, minLevel = 65, maxLevel = 66, rel = 3 },
                      { id = 19047, minLevel = 10, maxLevel = 30, rel = 3 },
                      { id = 19240, minLevel = 29, maxLevel = 41, rel = 3 },
                      { id = 27185, minLevel = 69, maxLevel = 69, rel = 3 },
                      { id = 27151, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 27188, minLevel = 71, maxLevel = 71, rel = 3 },
                      { id = 20112, minLevel = 59, maxLevel = 59, rel = 3 },
                      { id = 20917, minLevel = 60, maxLevel = 60, rel = 3 },
                      { id = 19526, minLevel = 61, maxLevel = 61, rel = 3 },
                      { id = 31027, minLevel = 20, maxLevel = 30, rel = 3 },
                      { id = 19043, minLevel = 31, maxLevel = 32, rel = 3 },
                      { id = 25314, minLevel = 39, maxLevel = 41, rel = 3 },
                      { id = 29497, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 28991, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 29496, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 29494, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 30006, minLevel = 75, maxLevel = 80, rel = 3 },
                      { id = 28855, minLevel = 29, maxLevel = 41, rel = 3 },
                      { id = 30067, minLevel = 70, maxLevel = 70, rel = 3 },
                    }
local ranged      = { { id = 3322,  minLevel = 4,  maxLevel = 30, rel = 1 },

                      { id = 1668,  minLevel = 11, maxLevel = 16, rel = 2 },
                      { id = 1461,  minLevel = 16, maxLevel = 21, rel = 2 },
                      { id = 1459,  minLevel = 11, maxLevel = 16, rel = 2 },
                      { id = 3951,  minLevel = 30, maxLevel = 30, rel = 2 },

                      { id = 19236, minLevel = 15, maxLevel = 21, rel = 3 }, -- duplicated here
                      { id = 19236, minLevel = 29, maxLevel = 30, rel = 3 }, -- duplicate
                      { id = 19236, minLevel = 40, maxLevel = 41, rel = 3 }, -- duplicate
                      { id = 3053,  minLevel = 15, maxLevel = 20, rel = 3 },
                      { id = 27139, minLevel = 69, maxLevel = 70, rel = 3 },
                      { id = 28994, minLevel = 71, maxLevel = 71, rel = 3 },
                      { id = 29476, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 28989, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 27943, minLevel = 15, maxLevel = 20, rel = 3 }, -- duplicated here
                      { id = 27943, minLevel = 29, maxLevel = 30, rel = 3 }, -- duplicate
                      { id = 27943, minLevel = 40, maxLevel = 41, rel = 3 }, -- duplicate
                    }
local armor       = { { id = 1407,  minLevel = 32, maxLevel = 32, rel = 1 }, -- duplicated in melee

                      { id = 3528,  minLevel = 12, maxLevel = 15, rel = 2 },
                      { id = 3532,  minLevel = 5,  maxLevel = 10, rel = 2 },
                      { id = 3530,  minLevel = 5,  maxLevel = 10, rel = 2 },
                      { id = 3529,  minLevel = 12, maxLevel = 15, rel = 2 }, -- verify if hostile or not
                      { id = 2264,  minLevel = 5,  maxLevel = 10, rel = 2 },
                      { id = 4188,  minLevel = 17, maxLevel = 17, rel = 2 }, -- duplicated here
                      { id = 4188,  minLevel = 22, maxLevel = 22, rel = 2 }, -- duplicate
                      { id = 3543,  minLevel = 17, maxLevel = 20, rel = 2 }, -- duplicated here
                      { id = 3543,  minLevel = 23, maxLevel = 25, rel = 2 }, -- duplicate
                      { id = 1695,  minLevel = 17, maxLevel = 22, rel = 2 },
                      { id = 11703, minLevel = 12, maxLevel = 14, rel = 2 },

                      { id = 3536,  minLevel = 15, maxLevel = 25, rel = 3 },
                      { id = 3134,  minLevel = 20, maxLevel = 25, rel = 3 },
                      { id = 3492,  minLevel = 15, maxLevel = 20, rel = 3 },
                      { id = 3493,  minLevel = 15, maxLevel = 20, rel = 3 },
                      { id = 4085,  minLevel = 20, maxLevel = 25, rel = 3 },
                      { id = 1669,  minLevel = 10, maxLevel = 15, rel = 3 },
                      { id = 3537,  minLevel = 20, maxLevel = 25, rel = 3 },
                      { id = 3683,  minLevel = 10, maxLevel = 15, rel = 3 },
                      { id = 8129,  minLevel = 32, maxLevel = 50, rel = 3 },
                      { id = 2845,  minLevel = 30, maxLevel = 35, rel = 3 },
                      { id = 11874, minLevel = 35, maxLevel = 40, rel = 3 },
                      { id = 2849,  minLevel = 17, maxLevel = 44, rel = 3 },
                      { id = 11183, minLevel = 44, maxLevel = 46, rel = 3 },
                      { id = 11182, minLevel = 44, maxLevel = 46, rel = 3 },
                      { id = 12023, minLevel = 39, maxLevel = 45, rel = 3 },
                      { id = 19517, minLevel = 70, maxLevel = 70, rel = 3 },
                      { id = 23571, minLevel = 32, maxLevel = 45, rel = 3 }, -- duplicated in weapons
                    }
local ammo        = { { id = 734,   minLevel = 20, maxLevel = 40, rel = 2 },
                      { id = 32638, minLevel = 65, maxLevel = 79, rel = 2 },

                      { id = 12246, minLevel = 10, maxLevel = 60, rel = 3 },
                      { id = 2839,  minLevel = 5,  maxLevel = 30, rel = 3 },
                      { id = 3498,  minLevel = 1,  maxLevel = 12, rel = 3 },
                      { id = 8131,  minLevel = 16, maxLevel = 30, rel = 3 },
                      { id = 12029, minLevel = 44, maxLevel = 44, rel = 3 },
                      { id = 14624, minLevel = 10, maxLevel = 60, rel = 3 },
                      { id = 20080, minLevel = 40, maxLevel = 70, rel = 3 },
                      { id = 22491, minLevel = 55, maxLevel = 65, rel = 3 },
                      { id = 28040, minLevel = 60, maxLevel = 80, rel = 3 },
                      { id = 30572, minLevel = 60, maxLevel = 80, rel = 3 },
                    }
local innkeepers  = { { id = 11118, minLevel = 5,  maxLevel = 25, rel = 3 },
                      { id = 16256, minLevel = 26, maxLevel = 45, rel = 3 },
                      { id = 23995, minLevel = 46, maxLevel = 65, rel = 3 },
                      { id = 29963, minLevel = 66, maxLevel = 80, rel = 3 },
                    }
local trainers    = { { }
                    }
local consumables = { { id = 4581,  minLevel = 1,  maxLevel = 25, rel = 1 },

                      { id = 20989, minLevel = 45, maxLevel = 60, rel = 3 },
                      { id = 12245, minLevel = 22, maxLevel = 27, rel = 3 },
                      { id = 23363, minLevel = 50, maxLevel = 65, rel = 3 },
                      { id = 28715, minLevel = 40, maxLevel = 80, rel = 3 },
                    }
local poisons     = { { id = 32641, minLevel = 20, maxLevel = 80, rel = 1 },

                      { id = 5169,  minLevel = 20, maxLevel = 80, rel = 2 },
                      { id = 32639, minLevel = 80, maxLevel = 80, rel = 2 },

                      { id = 2622,  minLevel = 20, maxLevel = 50, rel = 3 },
                      { id = 20986, minLevel = 50, maxLevel = 70, rel = 3 },
                      { id = 30069, minLevel = 60, maxLevel = 80, rel = 3 },
                    }
local others      = { { id = 20980, minLevel = 30, maxLevel = 60, rel = 3 },
                      { id = 6368,  minLevel = 1,  maxLevel = 80, rel = 3 },
                      { id = 7385,  minLevel = 1,  maxLevel = 80, rel = 3 },
                      { id = 29478, minLevel = 70, maxLevel = 80, rel = 3 },
                      { id = 29716, minLevel = 56, maxLevel = 56, rel = 3 },
                      { id = 28993, minLevel = 1,  maxLevel = 30, rel = 3 },
                    }

--[[ nonfunctional for now
local questgivers = { { id = 15297, minLevel = 4,  maxLevel = 6,  rel = 1 },
                      { id = 361,   minLevel = 8,  maxLevel = 12, rel = 1 },
                      { id = 15398, minLevel = 8,  maxLevel = 11, rel = 1 },
                      { id = 16252, minLevel = 15, maxLevel = 16, rel = 1 },
                      { id = 17355, minLevel = 29, maxLevel = 30, rel = 1 },

                      { id = 2080,  minLevel = 13, maxLevel = 15, rel = 2 },
                      { id = 17303, minLevel = 29, maxLevel = 30, rel = 2 },

                      { id = 9270,  minLevel = 48, maxLevel = 52, rel = 3 },
                    }
--]]

Travel.travellers["Ammo"]        = { name = "Ammo",        list = ammo,        typeMask = 1   }
Travel.travellers["Innkeepers"]  = { name = "Innkeepers",  list = innkeepers,  typeMask = 2   }
Travel.travellers["Trainers"]    = { name = "Trainers",    list = trainers,    typeMask = 4   }
Travel.travellers["Consumables"] = { name = "Consumables", list = consumables, typeMask = 8   }
Travel.travellers["Poisons"]     = { name = "Poisons",     list = poisons,     typeMask = 16  }
Travel.travellers["Others"]      = { name = "Others",      list = others,      typeMask = 32  }
Travel.travellers["Melee"]       = { name = "Melee",       list = melee,       typeMask = 64  }
Travel.travellers["Ranged"]      = { name = "Ranged",      list = ranged,      typeMask = 128 }
Travel.travellers["Armor"]       = { name = "Armor",       list = armor,       typeMask = 256 }
Travel.travellers["Food"]        = { name = "Food",        list = food,        typeMask = 512 }

local PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, Travel.addPlayer)