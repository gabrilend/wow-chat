
Movement = {}

-- call this function periodically and it'll return a new target position
function Movement.orbitPosition(originX, originY, radius, speed, dt)
    x = originX + math.cos(speed * dt) * radius
    y = originY + math.sin(speed * dt) * radius

    return x, y
end

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

function Movement.getMidpoint(x1, y1, x2, y2)
    x = (x1 + x2) / 2
    y = (y1 + y2) / 2

    return x, y
end

-- function to calculate the squared distance between two points
function Movement.squaredDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

-- function to normalize a vector
function Movement.normalize(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    return dx / length, dy / length
end

-- function to find the closest point on the circle to the given point
function Movement.nearestPointOnCircle(circleX, circleY, circleRadius, pointX, pointY)
    -- calculate the direction vector from the circle center to the point
    local dx, dy = pointX - circleX, pointY - circleY

    -- normalize the direction vector
    dx, dy = normalize(dx, dy)

    -- scale the direction vector by the radius of the circle
    dx, dy = dx * circleRadius, dy * circleRadius

    -- calculate the coordinates of the nearest point on the circle
    local nearestX, nearestY = circleX + dx, circleY + dy

    return nearestX, nearestY
end

function Movement.isCloseEnough(x1, y1, x2, y2, dist)
    return Movement.squaredDistance(x1, y1, x2, y2) <= dist * dist
end

