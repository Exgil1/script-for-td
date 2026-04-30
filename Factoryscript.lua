-- Auto Ore Miner Script - Fixed for your game
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local CHECK_INTERVAL = 0.2 -- How often to check for ores
local MINE_DELAY = 0.5 -- Delay between mining attempts
local RANGE = 15 -- Max range to mine ores

-- Get the mining function from your game
local Communication = ReplicatedStorage:WaitForChild("Communication")
local Functions = Communication:WaitForChild("Functions")
local AsteroidClient = ReplicatedStorage:FindFirstChild("Framework")
    :FindFirstChild("Client")
    :FindFirstChild("Services")
    :FindFirstChild("PlotService")
    :FindFirstChild("AsteroidClient")

-- Function to get all asteroids in player's plot
local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    -- Find your plot (adjust this based on how your game stores plot ownership)
    for _, plot in pairs(plots:GetChildren()) do
        -- Check if this is your plot (you may need to adjust this condition)
        local plotOwner = plot:FindFirstChild("Owner") or plot:FindFirstChild("ClaimedBy")
        if plotOwner and plotOwner.Value == player.Name then
            return plot
        end
        
        -- Alternative: check if plot name contains your username
        if plot.Name:lower():find(player.Name:lower()) then
            return plot
        end
    end
    
    -- If no specific plot found, use Plot1 (or let user specify)
    return plots:FindFirstChild("Plot1")
end

-- Function to get all asteroid children
local function getAsteroidsInPlot(plot)
    local asteroids = plot:FindFirstChild("Asteroids")
    if not asteroids then return {} end
    
    local asteroidList = {}
    for _, asteroid in pairs(asteroids:GetChildren()) do
        -- Each asteroid is a folder with a unique ID
        if asteroid:IsA("Folder") or asteroid:IsA("Model") then
            -- Find the Primary part of the asteroid
            local primaryPart = asteroid:FindFirstChild("Primary")
            if not primaryPart then
                -- If no Primary, find any BasePart
                primaryPart = asteroid:FindFirstChildWhichIsA("BasePart")
            end
            
            if primaryPart then
                table.insert(asteroidList, {
                    id = asteroid.Name,  -- The unique ID string
                    part = primaryPart,
                    folder = asteroid
                })
            end
        end
    end
    
    return asteroidList
end

-- Function to get closest asteroid
local function getClosestAsteroid(asteroids)
    local closest = nil
    local closestDistance = math.huge
    local currentPos = humanoidRootPart.Position
    
    for _, asteroid in pairs(asteroids) do
        local distance = (currentPos - asteroid.part.Position).Magnitude
        if distance < closestDistance and distance <= RANGE then
            closestDistance = distance
            closest = asteroid
        end
    end
    
    return closest, closestDistance
end

-- Function to mine asteroid using your game's system
local function mineAsteroid(plot, asteroidId)
    -- Get the asteroid folder
    local asteroids = plot:FindFirstChild("Asteroids")
    if not asteroids then return false end
    
    local asteroidFolder = asteroids:FindFirstChild(asteroidId)
    if not asteroidFolder then return false end
    
    -- Method 1: Use the remote function (from your original code)
    local miningFunction = Functions:FindFirstChild("") -- Note: Your original had empty string!
    if miningFunction then
        local args = {plot, asteroidFolder}
        local success = miningFunction:InvokeServer(unpack(args))
        if success then
            return true
        end
    end
    
    -- Method 2: Try to find the correct mining remote
    local possibleMiningRemotes = {
        "MineAsteroid",
        "MineOre", 
        "Harvest",
        "Collect",
        "BreakAsteroid",
        "Mine",
        "Extract"
    }
    
    for _, remoteName in pairs(possibleMiningRemotes) do
        local remote = Functions:FindFirstChild(remoteName)
        if remote then
            local success = remote:InvokeServer(plot, asteroidFolder)
            if success then
                return true
            end
        end
    end
    
    -- Method 3: Use the AsteroidClient service if available
    if AsteroidClient and AsteroidClient.Harvest then
        AsteroidClient:Harvest(plot, asteroidFolder)
        return true
    end
    
    -- Method 4: Simulate clicking on the asteroid's primary part
    local primaryPart = asteroidFolder:FindFirstChild("Primary")
    if primaryPart then
        -- Check for ClickDetector
        local clickDetector = primaryPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector:Click()
            return true
        end
        
        -- Check for proximity prompt
        local proximityPrompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt:Prompt(player)
            return true
        end
    end
    
    return false
end

-- Function to walk to asteroid
local function moveToPosition(targetPos)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local distance = (targetPos - humanoidRootPart.Position).Magnitude
    
    if distance > 5 then
        humanoid:MoveTo(targetPos)
        
        -- Wait until close enough or timeout
        local timeout = 3
        local startTime = tick()
        
        while tick() - startTime < timeout do
            local newDistance = (targetPos - humanoidRootPart.Position).Magnitude
            if newDistance <= 5 then
                break
            end
            humanoid:MoveTo(targetPos)
            task.wait(0.1)
        end
    end
end

-- Main mining loop
local isMining = true
local currentTarget = nil

local function startMining()
    print("Auto Miner Started! Looking for asteroids...")
    
    while isMining and task.wait(CHECK_INTERVAL) do
        -- Get player's plot
        local plot = getPlayerPlot()
        if not plot then
            task.wait(1)
            continue
        end
        
        -- Get all asteroids in plot
        local asteroids = getAsteroidsInPlot(plot)
        if #asteroids == 0 then
            -- No asteroids found, wait and check again
            task.wait(0.5)
            continue
        end
        
        -- Find closest asteroid
        local closest, distance = getClosestAsteroid(asteroids)
        
        if closest then
            -- Check if asteroid still exists
            if not closest.folder or not closest.folder.Parent then
                task.wait(0.1)
                continue
            end
            
            -- Move to asteroid if needed
            if distance > 6 then
                moveToPosition(closest.part.Position)
            end
            
            -- Mine the asteroid
            local mined = mineAsteroid(plot, closest.id)
            
            if mined then
                print("Mining asteroid:", closest.id)
                task.wait(MINE_DELAY)
            else
                -- If mining failed, try a different approach
                task.wait(0.3)
            end
        else
            -- No asteroids in range, wait a bit
            task.wait(0.2)
        end
    end
end

-- Function to stop mining
local function stopMining()
    isMining = false
    print("Auto Miner Stopped")
end

-- Start mining
startMining()

-- Toggle mining with 'M' key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        if isMining then
            stopMining()
        else
            isMining = true
            task.spawn(startMining)
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    task.wait(1)
end)

-- Print available remotes for debugging
print("Available mining functions:")
for _, child in pairs(Functions:GetChildren()) do
    if child.Name ~= "" then
        print(" - " .. child.Name)
    end
end
