Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

function Area:update(dt)
    if self.world then
      self.world:update(dt) 
    end
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then 
          game_object:destroy()
          table.remove(self.game_objects, i) 
        end
    end
end

function Area:draw()
    for _, game_object in ipairs(self.game_objects) do game_object:draw(dt) end
end

function Area:destroy()
  for i = #self.game_objects, 1, -1 do
    local game_object = self.game_objects[i]
    game_object:destroy()
    table.remove(self.game_objects, i)
  end
  
  self.game_objects = {}
  
  if self.world then
    self.world:destroy()
    self.world = nil
  end
  
end

function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    table.insert(self.game_objects, game_object)
    return game_object 
end

function Area:addPhysicsWorld()
  self.world = wf.newWorld(0,0,true)
end

function Area:getGameObjects(predicate)
    matches = {}
    for _, game_object in ipairs(self.game_objects) do
        local res = predicate(game_object)
        if res then
            table.insert(matches, game_object) 
        end
    end
    return matches
end

function Area:queryCircleArea(x, y, radius, game_object_classes)
    local game_objects =  self:getGameObjects(function(game_object) 
        for _, game_object_class in ipairs(game_object_classes) do
            if (game_object:is(game_object_class)) then
                return true
            end
        end
        return false
    end)

    local matches = {}

    for _, game_object in ipairs(game_objects) do
        if (lineIntersection(x, y, radius, game_object)) then
            table.insert(matches, game_object)
        end
    end

    return matches
end

function Area:getClosestGameObject(x,y,radius,object_classes)
    matches = queryCircleArea(x,y,radius,object_classes)

    table.sort(matches, function(a,b)
        return self:getDistance(x,y, a) < self:getDistance(x,y,b)
    end)

    return matches[1]
end

function Area:lineIntersection(x,y,max_distance,game_object)
    return self:getDistance(x,y,game_object) <= max_distance
end

function Area:getDistance(x,y, game_object)
    return math.sqrt((x - game_object.x)^2 + (y - game_object.y)^2)
end