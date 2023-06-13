TEMPO = 0
TEMPO_MIN = -30
TEMPO_MAX = 30
TEMPO_DIRECTION = 1
RHYTHM = 0
RHYTHM_MAX = 1
RHYTHM_MIN = 0

local function updateTempo(diff)
    -- Increase or decrease the TEMPO value.
    if TEMPO == TEMPO_MAX then
        TEMPO_DIRECTION = -RHYTHM_MAX
    elseif TEMPO == TEMPO_MIN then
        TEMPO_DIRECTION =  RHYTHM_MAX
    end
    TEMPO = TEMPO + TEMPO_DIRECTION
end

local function tempoUpdater(eventID, diff)
    RHYTHM = RHYTHM + 1
    if RHYTHM >= RHYTHM_MAX then
        RHYTHM = RHYTHM - RHYTHM_MAX
        updateTempo()
    end
end

local function startTempo(eventID, player)
    TEMPO_MIN = TEMPO_MIN * 2
    TEMPO_MAX = TEMPO_MAX * 2
    player:RegisterEvent(tempoUpdater, 1000, 0)
end

local function stopTempo(eventID, player)
    TEMPO_MIN = TEMPO_MIN / 2
    TEMPO_MAX = TEMPO_MAX / 2
    print("[FIXME] Verify that tempoUpdater is stopped when the player logs out.")
end

PLAYER_EVENT_ON_LOGIN  = 3
PLAYER_EVENT_ON_LOGOUT = 4
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, startTempo)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, stopTempo)
