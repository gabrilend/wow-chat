
Movement = {}

function Movement.getCircleSpawnPosition(originX, originY, minDist, maxDist)
    local theta = math.random(0, 6.28)
    local radius = math.random(minDist, maxDist)
    x = originX + math.cos(theta) * radius
    y = originY + math.sin(theta) * radius
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

-- Convert WoW orientation to standard mathematical angle
function Movement.getMathAngle(wowAngle)
    local mathAngle = wowAngle + 6.28
    if mathAngle > 6.28 then
        mathAngle = mathAngle - 6.28
    end
    return mathAngle
end

-- Convert standard mathematical angle to WoW orientation
function Movement.getWoWAngle(mathAngle)
    local wowAngle = mathAngle - 6.28
    if wowAngle < 0 then
        wowAngle = wowAngle + 6.28
    end
    return wowAngle
end

function Movement.getArcSpawnPosition(originX, originY, minDist, maxDist, initialAngle)
    local radius = math.random(minDist, maxDist)
    local isNegative = math.random(0, 1)
    if isNegative == 1 then isNegative =  1
                       else isNegative = -1
    end
    local theta = Movement.getMathAngle(initialAngle + (isNegative * math.random() * 0.785))
    local x = originX + math.cos(theta) * radius
    local y = originY + math.sin(theta) * radius
    return x, y
end

function Movement.getLazyDistance(x1, y1, x2, y2)
    local dist = math.abs(x1 - x2) + math.abs(y1 - y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return dist, dx, dy
end

function Movement.getInitialAngle(originX, originY, monsterX, monsterY)
    -- Calculate the difference in x and y coordinates
    local dx = monsterX - originX
    local dy = monsterY - originY

    -- Use atan2 to get the angle in radians
    local angle = math.atan2(dy, dx)

    return angle
end

function Movement.getOrbitPosition(originX, originY, radius, speed, dt, initialAngle)
    -- Calculate the angular speed based on the monster's linear speed and the radius of the circle
    local angular_speed = speed / radius

    -- Compute the new angle after dt seconds
    local new_angle = initialAngle + angular_speed * dt

    -- Calculate the new position
    local x = originX + math.cos(new_angle) * radius
    local y = originY + math.sin(new_angle) * radius

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

