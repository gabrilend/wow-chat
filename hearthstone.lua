
require "movement" -- for the spawning randomization

-- this script will teleport all group members to the player using their hearthstone

-- target is the player using their hearthstone
-- player is the group member who is following
-- needs to play visual effects to notify them and then teleport them to
-- a random location near the hearthing player and face them toward the hearther
local function teleport(event, delay, repeats, player)
    print("teleport!")
    local   target   = GetPlayerByGUID(player:GetData("group-hearthstone-target-player"))
    local playerX, playerY, playerZ, playerO
    local targetX, targetY, targetZ = target:GetLocation()
    local count = 0
    player:SetData("teleport-count", 0)
    repeat
        count = count + 1
        playerX, playerY, playerZ, playerO = target:GetLocation()
        playerX, playerY                   = Movement.getCircleSpawnPosition(targetX, targetY, 5, 10)
                                playerZ          = target:GetMap():GetHeight(playerX, playerY)
                                         playerO = math.tan(playerX/playerY)
        print("playerO = "..playerO)
        -- orient the player toward the hearther
        if     targetX < playerX and targetY < playerY then playerO = playerO + 3.14
        elseif targetX > playerX and targetY < playerY then playerO =    6.28 - playerO
        elseif targetX > playerX and targetY > playerY then playerO = playerO
        elseif targetX < playerX and targetY > playerY then playerO =    3.14 - playerO
        end
        print("new playerO = "..playerO)
    until (playerZ < targetZ + 5 and playerZ > targetZ - 5) or count > 5
    print("teleporting to "..playerX..", "..playerY..", "..playerZ..", "..playerO)
    player:Teleport(target:GetMapId(), playerX, playerY, playerZ, playerO)
end

local function teleportInProgress(event, delay, repeats, player)
    print("teleportInProgress")
    local HEARTHSTONE_CAST_TIME = 10
    local DELAY = 3 -- delay between visual effects
    player:CastSpell(player, VISUAL_EFFECT_ID, true) -- cast level up effect
    local teleport_count = player:GetData("teleport-count") or 0
          teleport_count = teleport_count + DELAY
    player:SetData("teleport-count", teleport_count)
    if teleport_count < HEARTHSTONE_CAST_TIME then
        player:RegisterEvent(teleportInProgress, DELAY * 1000, 1)
    else
        if player:IsStandState() then -- to decline a hearth just sit down
            player:RegisterEvent(teleport, 1000, 1)
        end
    end
end

local function HearthstoneUse( event, player, item, target)
    print("using hearthstone")
    if player:IsInGroup() then
        print("player is in group")
        local group_members = player:GetGroup():GetMembers()
        for k, v in pairs(group_members) do
            if v == player then
                print("v == player")
                return
            end
            print("v ~= player")
            v:SendBroadcastMessage("You are being teleported to "..player:GetName().."'s hearthstone.")
            v:SendBroadcastMessage("You may sit down to cancel the teleport.")
            v:SetData("group-hearthstone-target-player", player:GetGUID())
            v:RegisterEvent(teleportInProgress, 500, 1)
        end
    end
end

ITEM_EVENT_ON_USE = 2
HEARTHSTONE_ITEM_ID = 6948
VISUAL_EFFECT_ID = 47292
RegisterItemEvent( HEARTHSTONE_ITEM_ID, ITEM_EVENT_ON_USE, HearthstoneUse, 0)

