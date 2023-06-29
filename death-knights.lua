local quests = { 12593, 12619, 12842, 12848, 12636, 12641, 12657, 12678, 12679, 12680, 12687,
                 12698, 12701, 12706, 12716, 12719, 12720, 12722, 12724, 12725, 12727, 12733, -1,
                 12751, 12754, 12755, 12756, 12757, 12779, 12801, 13165, 13166
               }
local racequests = { 12742, 12748, 12744, 12743, 12750, 12739, 12745, 12749, -1, 12747, 12746 }

DK = { quests     = quests,
       racequests = racequests
     }

function DK.printPosition(_eventID, player, msg)
    if msg == "pos" then
        x, y, z, o = player:GetLocation()
        player:SendBroadcastMessage("X: " .. x .. " Y: " .. y .. " Z: " .. z .. " O: " .. o)
        player:SendBroadcastMessage("MapID: " .. player:GetMapId())
        player:SendBroadcastMessage("ZoneID: " .. player:GetZoneId())
    end
end

PLAYER_EVENT_ON_CHAT = 18
RegisterPlayerEvent(PLAYER_EVENT_ON_CHAT, DK.printPosition)

function DK.onFirstLogin(_eventID, player)
    if player:GetClass() ~= 6 then
        return
    end
    targetRace = player:GetRace()
    targetTeam = player:GetTeam()
    if targetTeam == 0 then
    -- alliance end quest
        DK.quests[33] = 13188
    else
    -- horde
        DK.quests[33] = 13189
    end
    DK.quests[23] = DK.racequests[targetRace]
    for _, i in ipairs(DK.quests) do
        player:AddQuest(i)
        player:CompleteQuest(i)
        player:RewardQuest(i)
    end
    player:AddItem(38664)
    player:AddItem(39322)
    player:AddItem(38632)

    if player:GetLevel() < 58 then player:SetLevel(58)
    end
    player:SaveToDB()
    player:EquipItem(13505, 15)
end

function DK.onLogin(_eventID, player)
    if player:GetClass() ~= 6 and player:GetMapID() == 609 then
        return
    end
    player:RegisterEvent(DK.teleportCheck, 2000, 1)
end

-- teleport box -- dock
             -- 1309.7868652344, -6126.091796875,  14.213508605957
             -- 1292.6856689453, -6125.2758789062, 13.98921585083
             -- 1289.4045410156, -6165.6259765625, 13.988998413086
             -- 1307.6597900391, -6166.923828125,  13.988998413086
-- teleport box -- road
             -- 1781.8649902344, -4867.0151367188, 88.716270446777
             -- 1801.3431396484, -4867.015625,     89.938385009766
             -- 1799.4702148438, -4875.36328125,   89.868949890137
             -- 1781.3470458984, -4868.1845703125, 88.448524475098
-- teleport box -- beach
             -- 2292.9423828125, -6162.6479492188, 1.1365040540695
             -- 2064.091796875,  -6150.6176757812, 0.34862634539604
             -- 2043.25,         -6207.7368164062, -1.4076384305954
             -- 2303.6145019531, -6224.1137695312, -1.4076384305954
function DK.teleportCheck(eventID, delay, repeats, player)
    if player:GetMapId()  == 609  and
       player:GetZoneId() == 4298 -- [FIXME?] make sure this zoneID is not preventing the teleport
    then
        x, y, z, o = player:GetLocation()
        -- dock
        if x > 1289.4045410156 and x < 1309.7868652344  and
           y > -6166.923828125 and y < -6125.2758789062 and
           z > 13.988998413086 and z < 14.213508605957  then player:Teleport( 571,
                                                                              2473.486328125,
                                                                              -426.0638427734,
                                                                              2.9070627689362,
                                                                              0.066335506737232 )
        -- road
        elseif x > 1781.3470458984 and x < 1801.3431396484  and
               y > -4875.36328125  and y < -4867.0151367188 and
               z > 88.448524475098 and z < 89.938385009766  then player:Teleport( 0,
                                                                                  1786.7312011719,
                                                                                  -4878.4706742188,
                                                                                  87.49080657959,
                                                                                  1.3365938663483 )
        -- beach
        elseif x > 2043.25          and x < 2303.6145019531  and
               y > -6224.1137695312 and y < -6150.6176757812 and
               z > -1.4076384305954 and z < 1.1365040540695  then player:Teleport( 571,
                                                                                  2473.486328125,
                                                                                  -426.0638427734,
                                                                                  2.9070627689362,
                                                                                  0.066335506737232 )
            return
        end
    else return
    end
    player:RegisterEvent(DK.teleportCheck, 2000, 1)
end

PLAYER_EVENT_ON_FIRST_LOGIN = 30
PLAYER_EVENT_ON_LOGIN = 3
RegisterPlayerEvent(PLAYER_EVENT_ON_FIRST_LOGIN, DK.onFirstLogin)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, DK.onLogin)
