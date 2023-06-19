
-- the real question is why tho

RHYTHM_MAX = 1
RHYTHM_MIN = 0
RHYTHM_INTERVAL = 0.5 * 1000

Tempo = { value = 0,
          min = -30,
          max = 30,
          direction = 1 }

Rhythm = { players = {} }

function Rhythm.tempoUpdater(_eventID, delay, _repeats)
    -- Increase or decrease the TEMPO value.
    if Tempo.value >= Tempo.max then
        Tempo.direction = -1
    elseif Tempo.value <= Tempo.min then
        Tempo.direction =  1
    end

    for _, player in pairs(Rhythm.players) do
        if player.differential >= 1 then
            Tempo.value = Tempo.value + (delay * Tempo.direction)
            player.differential = player.differential - delay
        end
    end
end

function Rhythm.rhythmUpdater(_eventId, delay, _repeats)
    delay = delay / 1000 -- convert to seconds instead of miliseconds

    for _, player in pairs(Rhythm.players) do
        Rhythm.players[player].current_rhythm =
                              Rhythm.players[player] + (Tempo.direction * delay)

        if Rhythm.players[i].current_rhythm >= RHYTHM_MAX then
            Rhythm.players[i].differential =
                Rhythm.players[i].differential + RHYTHM_MAX
            Rhythm.players[i].current_rhythm =
                Rhythm.players[i].current_rhythm - RHYTHM_MAX
        end
    end
end

function Rhythm.addPlayer(_eventID, player)
    Tempo.min = Tempo.min * 2
    Tempo.max = Tempo.max * 2
    local playerGUID = player:GetGUID()
    if Rhythm.players[playerGUID] == nil then
        Rhythm.players[playerGUID] = { id = playerGUID,
                                       current_rhythm = 0,
                                       differential = 0 }
    else
        print("WARNING: playerGUID already present in Rhythm.players[]")
    end
end

function Rhythm.removePlayer(_eventID, player)
    Tempo.min = Tempo.min / 2
    Tempo.max = Tempo.max / 2
    local playerGUID = player:GetGUID()
    if Rhythm.players[playerGUID] ~= nil then
        Rhythm.players[playerGUID] = nil
    else
        print("WARNING: playerGUID not present in Rhythm.players[]")
    end
end

function Rhythm.startTempo()
    CreateLuaEvent(Rhythm.tempoUpdater, RHYTHM_INTERVAL, 0)
end

PLAYER_EVENT_ON_LOGIN  = 3
PLAYER_EVENT_ON_LOGOUT = 4
ELUNA_EVENT_ON_LUA_STATE_OPEN = 33
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, Rhythm.addPlayer)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, Rhythm.removePlayer)
RegisterServerEvent(ELUNA_EVENT_ON_LUA_STATE_OPEN, Rhythm.startTempo)
