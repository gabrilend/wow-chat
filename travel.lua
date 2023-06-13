Travel = {}

function Travel.getTravellerSpawnPosition(x, y, z, o)
    randInt = math.random(1, 4)
    if randInt == 1 then
        x = x + math.random(30,45)
        y = y + math.random(-45, 45)
    elseif randInt == 2 then
        x = x + math.random(-45, -30)
        y = y + math.random(-45, 45)
    elseif randInt == 3 then
        x = x + math.random(-45, 45)
        y = y + math.random(30, 45)
    elseif randInt == 4 then
        x = x + math.random(-45, 45)
        y = y + math.random(-45, -30)
    end

    return x, y, z, o
end

-- this function calculates a position on the exact opposite side of the player
function Travel.getTravellerMovePosition(player, x, y, z, o)
    --          player == v2
    --           spawn == v1
    -- target location == v1 + ((v2 - v1) * 2)
    local playerX, playerY, playerZ, playerO = player:GetLocation()

    x = x + ((playerX - x) * 2)
    y = y + ((playerY - y) * 2)
    z = player:GetMap():GetHeight(x, y)
    o = o

    return x, y, z, o
end

function Travel.getRandomTravellerIdOfLevel(level)

    -- rel is a bitmask of faction relations: 1 = friendly to horde
    --                                        2 = friendly to alliance
    --                                        3 = friendly to both

    local food        = { { id = 32642, minLevel = 65, maxLevel = 80, rel = 1 },

                          { id = 258,   minLevel = 1,  maxLevel = 20, rel = 2 },
                          { id = 3937,  minLevel = 6,  maxLevel = 25, rel = 2 },

                          { id = 6496,  minLevel = 1,  maxLevel = 80, rel = 3 },
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
                          { id = 19236, minLevel = 15, maxLevel = 40, rel = 3 },
                          { id = 19238, minLevel = 5,  maxLevel = 35, rel = 3 },
                          { id = 3658,  minLevel = 5,  maxlevel = 15, rel = 3 },
                          { id = 3491,  minLevel = 13, maxLevel = 19, rel = 3 },
                          { id = 3053,  minLevel = 15, maxLevel = 20, rel = 3 },
                          { id = 23571, minLevel = 30, maxLevel = 45, rel = 3 },
                          { id = 2483,  minLevel = 28, maxLevel = 32, rel = 3 },
                          { id = 2482,  minLevel = 29, maxLevel = 31, rel = 3 },
                          { id = 2843,  minLevel = 30, maxLevel = 40, rel = 3 },
                          { id = 3000,  minLevel = 29, maxLevel = 40, rel = 3 },
                          { id = 11184, minLevel = 39, maxLevel = 41, rel = 3 },
                          { id = 12024, minLevel = 39, maxLevel = 41, rel = 3 },
                          { id = 19536, minLevel = 65, maxLevel = 66, rel = 3 },
                          { id = 19236, minLevel = 15, maxLevel = 40, rel = 3 },
                          { id = 19238, minLevel = 30, maxLevel = 35, rel = 3 },
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
                          { id = 27139, minLevel = 69, maxLevel = 70, rel = 3 },
                          { id = 28994, minLevel = 71, maxLevel = 71, rel = 3 },
                          { id = 29476, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 29497, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 28989, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 28991, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 29496, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 29494, minLevel = 70, maxLevel = 70, rel = 3 },
                          { id = 30006, minLevel = 75, maxLevel = 80, rel = 3 },
                          { id = 27943, minLevel = 15, maxLevel = 40, rel = 3 },
                          { id = 28855, minLevel = 29, maxLevel = 41, rel = 3 },
                          { id = 30067, minLevel = 70, maxLevel = 70, rel = 3 },
                        }
    local ranged      = { { id = 3322,  minLevel = 4,  maxLevel = 30, rel = 1 },

                          { id = 1668,  minLevel = 11, maxLevel = 16, rel = 2 },
                          { id = 1461,  minLevel = 16, maxLevel = 21, rel = 2 },
                          { id = 1459,  minLevel = 11, maxLevel = 16, rel = 2 },
                          { id = 3951,  minLevel = 30, maxLevel = 30, rel = 2 },
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
    local trainers    = { {
                        }
    local questgivers = { {
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

    -- These are all the travellers that are available to spawn at all levels
    local potentialTravellers = {

          }

    -- add any travellers you want to spawn between player level 1 and 10
    if level >= 1 and level <= 10 then
        local level1To10 = {
                           }
        for k,v in ipairs(level1To10) do
            table.insert(potentialTravellers, level1To10[v])
        end

    else -- add other level tiers here
        local level10Plus = { }
        for k,v in ipairs(level10Plus) do
            table.insert(potentialTravellers, level10Plus[v])
        end
    end

    local traveller = potentialTravellers[math.random( #potentialTravellers )]
    return traveller

end

function Travel.spawnAndTravel(player)
    print("A traveller appears...")
    local travellerId = Travel.getRandomTravellerIdOfLevel(player:GetLevel())
    if travellerId ~= 0 then
        local x, y, z, o = Travel.getTravellerSpawnPosition(player:GetLocation())
        local TEMPSUMMON_TIMED_OR_DEAD_DESPAWN = 1
        local TEMPSUMMON_DESPAWN_TIMER = 300 * 1000 -- 5 minutes
        local traveller = player:SpawnCreature(travellerId, x, y, z, o,
                                              TEMPSUMMON_TIMED_OR_DEAD_DESPAWN,
                                              TEMPSUMMON_DESPAWN_TIMER)

        if traveller then
            traveller:SetSpeed(0, 1)
            traveller:SetWalk(true)
            x, y, z, o = Travel.getTravellerMovePosition(player, x, y, z, o)
            traveller:MoveTo(math.random(0, 4294967295), x, y, z, o)
        end
    end
end

function Travel.isPositionPathable(x, y, z, mapId)
    -- Create a temporary WorldObject at the desired position.
    local obj = CreateWorldObject(mapId, x, y, z, 0)

    -- Check if the object is in the air or in water.
    if obj:IsInAir() or obj:IsInWater() then
        return false
    end

    -- Check the ground level at the position.
    local groundZ = GetMapById(mapId):GetHeight(x, y)
    if math.abs(groundZ - z) > 10 then -- You may need to adjust this threshold.
        return false
    end

    return true
end


