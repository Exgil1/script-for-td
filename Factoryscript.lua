-- Auto Ore Miner Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local MINE_DELAY = 0.5 -- Delay between mining attempts (seconds)
local CHECK_INTERVAL = 0.3 -- How often to check for ores (seconds)
local MOVE_SPEED = 20 -- Speed to move to ore
local TOOL_EQUIP_DELAY = 0.2 -- Delay after equipping tool

-- Get the mining tool (you may need to adjust this based on your game)
local miningTool = nil
for _, tool in pairs(player.Backpack:GetChildren()) do
    if tool:IsA("Tool") and (tool.Name:lower():find("pick") or tool.Name:lower():find("drill") or tool.Name:lower():find("miner")) then
        miningTool = tool
        break
    end
end

if not miningTool then
    warn("No mining tool found in backpack!")
end

-- Function to get active plot
local function getActivePlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    -- Check all plots to see which one belongs to the player
    for _, plot in pairs(plots:GetChildren()) do
        -- Check for plot ownership (adjust based on your game's system)
        local plotOwner = plot:FindFirstChild("Owner") or plot:FindFirstChild("ClaimedBy")
        if plotOwner and plotOwner.Value == player.Name then
            return plot
        end
    end
    
    return nil
end

-- Function to find ores in a plot
local function findOresInPlot(plot)
    local ores = {}
    
    local asteroids = plot:FindFirstChild("Asteroids")
    if asteroids then
        for _, asteroid in pairs(asteroids:GetChildren()) do
            -- Check for ore (look for any part with ore-related properties)
            -- Adjust these conditions based on your game's ore structure
            if asteroid:IsA("BasePart") or asteroid:FindFirstChild("Hitbox") then
                table.insert(ores, asteroid)
            end
            
            -- Check children for ore parts
            for _, child in pairs(asteroid:GetDescendants()) do
                if child:IsA("BasePart") and (child.Name:lower():find("ore") or child.Name:lower():find("rock") or child:FindFirstChild("Health")) then
                    table.insert(ores, child)
                end
            end
        end
    end
    
    return ores
end

-- Function to get closest ore
local function getClosestOre(ores, currentPosition)
    local closest = nil
    local closestDistance = math.huge
    
    for _, ore in pairs(ores) do
        local orePosition = ore.Position
        local distance = (currentPosition - orePosition).Magnitude
        
        if distance < closestDistance then
            closestDistance = distance
            closest = ore
        end
    end
    
    return closest, closestDistance
end

-- Function to move to ore
local function moveToOre(ore)
    local orePosition = ore.Position
    local direction = (orePosition - humanoidRootPart.Position).Unit
    local distance = (orePosition - humanoidRootPart.Position).Magnitude
    
    -- Move towards ore
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:MoveTo(orePosition)
        
        -- Wait until close enough or timeout
        local timeout = 5
        local startTime = tick()
        
        while tick() - startTime < timeout and distance > 5 do
            distance = (orePosition - humanoidRootPart.Position).Magnitude
            if distance > 5 then
                humanoid:MoveTo(orePosition)
            end
            task.wait(0.1)
        end
    end
end

-- Function to equip mining tool
local function equipTool()
    if not miningTool then return false end
    
    -- Check if tool is already equipped
    if character:FindFirstChild(miningTool.Name) then
        return true
    end
    
    -- Move tool from backpack to character
    miningTool.Parent = character
    task.wait(TOOL_EQUIP_DELAY)
    
    return character:FindFirstChild(miningTool.Name) ~= nil
end

-- Function to mine ore
local function mineOre(ore, plot, oreId)
    -- Equip mining tool
    if miningTool and not equipTool() then
        warn("Failed to equip mining tool!")
        return false
    end
    
    -- Attempt to mine the ore
    local success = false
    
    -- Try different mining methods based on your game's system
    
    -- Method 1: Using the communication function (from your example)
    local communication = ReplicatedStorage:FindFirstChild("Communication")
    if communication then
        local functions = communication:FindFirstChild("Functions")
        if functions then
            local mineFunction = functions:FindFirstChild("MineOre") or functions:FindFirstChild("Mine")
            if mineFunction then
                local args = {plot, ore}
                success = mineFunction:InvokeServer(unpack(args))
                if success then
                    task.wait(MINE_DELAY)
                    return true
                end
            end
        end
    end
    
    -- Method 2: Using click detection
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        -- Activate tool
        tool:Activate()
        task.wait(0.1)
        
        -- Check if ore has health or clickable property
        local clickDetector = ore:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector:Click()
            success = true
        elseif ore:IsA("BasePart") then
            -- Simulate clicking on the ore
            local mouse = player:GetMouse()
            if mouse then
                -- For older scripts that require mouse
                -- You may need to fire a remote event
            end
        end
    end
    
    task.wait(MINE_DELAY)
    return success
end

-- Function to check if ore still exists
local function oreExists(ore)
    return ore and ore.Parent ~= nil
end

-- Main mining loop
local function startMining()
    print("Auto Miner Started!")
    
    while task.wait(CHECK_INTERVAL) do
        -- Get active plot
        local plot = getActivePlot()
        if not plot then
            task.wait(1)
            continue
        end
        
        -- Find all ores in plot
        local ores = findOresInPlot(plot)
        if #ores == 0 then
            task.wait(1)
            continue
        end
        
        -- Find closest ore
        local closestOre, distance = getClosestOre(ores, humanoidRootPart.Position)
        
        if closestOre then
            -- Move to ore if too far
            if distance > 8 then
                moveToOre(closestOre)
            end
            
            -- Mine the ore
            local mined = mineOre(closestOre, plot)
            
            if mined then
                print("Mined ore:", closestOre.Name)
            end
            
            -- Small delay before next mining attempt
            task.wait(0.2)
        end
    end
end

-- Function to stop mining
local function stopMining()
    print("Auto Miner Stopped")
    -- You can add cleanup code here if needed
end

-- Start mining
startMining()

-- Optional: Toggle mining with a key (press 'M' to stop/start)
local isMining = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        isMining = not isMining
        if isMining then
            startMining()
        else
            stopMining()
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Find mining tool again
    miningTool = nil
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("pick") or tool.Name:lower():find("drill") or tool.Name:lower():find("miner")) then
            miningTool = tool
            break
        end
    end
    
    task.wait(1)
end)
