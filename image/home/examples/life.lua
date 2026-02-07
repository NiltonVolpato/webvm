#!/usr/bin/env lua5.5
-- Conway's Game of Life

local W, H = 40, 20
local grid = {}

-- Initialize with random cells
math.randomseed(os.time())
for y = 1, H do
    grid[y] = {}
    for x = 1, W do
        grid[y][x] = math.random() < 0.3
    end
end

local function count_neighbors(x, y)
    local count = 0
    for dy = -1, 1 do
        for dx = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nx, ny = ((x + dx - 1) % W) + 1, ((y + dy - 1) % H) + 1
                if grid[ny][nx] then count = count + 1 end
            end
        end
    end
    return count
end

local function step()
    local new = {}
    for y = 1, H do
        new[y] = {}
        for x = 1, W do
            local n = count_neighbors(x, y)
            new[y][x] = (grid[y][x] and (n == 2 or n == 3)) or (not grid[y][x] and n == 3)
        end
    end
    grid = new
end

local function draw()
    io.write("\27[H\27[2J")  -- clear screen
    for y = 1, H do
        for x = 1, W do
            io.write(grid[y][x] and "X" or " ")
        end
        io.write("\n")
    end
    print("Press Ctrl+C to exit")
end

while true do
    draw()
    step()
    os.execute("sleep 0.1")
end
