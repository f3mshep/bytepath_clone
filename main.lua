Object = require 'libraries/classic'
Input = require 'libraries/boipushy/Input'
Timer = require 'libraries/hump/timer'
Util = require 'libraries/util'
M = require 'libraries/Moses/moses'
Camera = require 'libraries/hump/camera'
wf = require 'libraries/windfield/windfield'

Globals = require 'globals'

function love.load()
    --load those libraries
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    recursiveEnumerate('rooms', object_files)
    requireFiles(object_files)
    current_room = nil
    
    --crispy graphics
    love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
    love.graphics.setLineStyle("rough")
    
    -- global utilities
    timer = Timer()
    input = Input()
    camera = Camera()
    
    -- input bindy stuff
    input:bind('left', 'left')
    input:bind('right', 'right')

    resize(3)
    
    gotoRoom('Stage')
    
    input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)
  
    input:bind('f2', function()
      gotoRoom("Stage")
    end)
    
    input:bind('f3', function()
      if current_room and current_room.destroy then 
        current_room:destroy() 
        current_room = nil
      end
    end)
    
    -- debug mode activate!
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.isFile(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function love.update(dt)
    timer:update(dt)
    camera:update(dt)
    if current_room then current_room:update(dt) end
end

function love.draw()
    if current_room then current_room:draw() end
end

function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then 
      current_room:destroy() 
    end
    current_room = _G[room_type](...)
end

function resize(s)
    love.window.setMode(s*gw, s*gh)
    sx, sy = s, s
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end