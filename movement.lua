
Movement = {}

function Movement.getBoxSpawnPosition(originX, originY, minDist, maxDist)
    randInt = math.random(1, 4)
    if randInt == 1 then
        x = originX + math.random( minDist,  maxDist)
        y = originY + math.random(-maxDist,  maxDist)
    elseif randInt == 2 then
        x = originX + math.random(-maxDist, -minDist)
        y = originY + math.random(-maxDist,  maxDist)
    elseif randInt == 3 then
        x = originX + math.random(-maxDist,  maxDist)
        y = originY + math.random( minDist,  maxDist)
    elseif randInt == 4 then
        x = originX + math.random(-maxDist,  maxDist)
        y = originY + math.random(-maxDist, -minDist)
    end

    return x, y
end

-- this should make a rough circle around the player
-- it's more like a plus shape but that's close enough
function Movement.getPlusSpawnPosition(originX, originY, minDist, maxDist)
    randInt = math.random(1, 4)
    if randInt == 1 then
        x = originX + math.random( minDist,  maxDist)
        y = originY + math.random(-minDist,  minDist)
    elseif randInt == 2 then
        x = originX + math.random(-maxDist, -minDist)
        y = originY + math.random(-minDist,  minDist)
    elseif randInt == 3 then
        x = originX + math.random(-minDist,  minDist)
        y = originY + math.random( minDist,  maxDist)
    elseif randInt == 4 then
        x = originX + math.random(-minDist,  minDist)
        y = originY + math.random(-maxDist, -minDist)
    end

    return x, y
end


-- calculates a position on the exact opposite side of the given position
-- x1 and y1 are the pivot point
-- x2 and y2 are the initial point
-- diagram:
-- (initialX, initialY) ---------> (pivotX, pivotY) ---------> (x, y)
function Movement.getPositionOppositePoint(initialX, initialY, pivotX, pivotY)
    x = initialX + ((pivotX - initialX) * 2)
    y = initialY + ((pivotY - initialY) * 2)

    return x, y
end
