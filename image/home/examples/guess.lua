#!/usr/bin/env lua5.5
-- Number guessing game

math.randomseed(os.time())
local secret = math.random(1, 100)
local attempts = 0

print("I'm thinking of a number between 1 and 100...")

while true do
    io.write("Your guess: ")
    local guess = tonumber(io.read())
    attempts = attempts + 1

    if not guess then
        print("Please enter a number!")
    elseif guess < secret then
        print("Too low!")
    elseif guess > secret then
        print("Too high!")
    else
        print(string.format("Correct! You got it in %d attempts!", attempts))
        break
    end
end
