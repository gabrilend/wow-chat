
DK = {}

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
    player:SetFreeTalentPoints(45)
    player:EquipItem(13505, 15)
end

PLAYER_EVENT_ON_FIRST_LOGIN = 30
RegisterPlayerEvent(PLAYER_EVENT_ON_FIRST_LOGIN, DK.onFirstLogin)
