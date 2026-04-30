-- Working Auto Miner with Proper Asteroid Detection
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local MINE_RANGE = 40
local MINE_DELAY = 0.1
local minedAsteroids = {}

-- Get the mining remote
local Communication = ReplicatedStorage:WaitForChild("Communication")
local Functions = Communication:WaitForChild("Functions")
local miningRemote = Functions:FindFirstChild("")

if not miningRemote then
    warn("Mining remote not found! Looking for alternatives...")
    -- Try to find any remote that might work
    for _, child in pairs(Functions:GetChildren()) do
        print("Found remote:", child.Name ~= "" and child.Name or "(empty)")
        if child.Name == "" then
            miningRemote = child
            break
        end
    end
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoMinerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local isMining = false
local currentRange = MINE_RANGE
local currentDelay = MINE_DELAY
local totalMined = 0
local debugMode = true

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.Position = UDim2.new(0.5, -125, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BackgroundTransparency = 0.05
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "⛏️ AUTO ASTEROID MINER v2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.1, 0, 0.14, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
toggleBtn.Text = "START MINING"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: ❌ OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = mainFrame

-- Range Slider
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
rangeLabel.Position = UDim2.new(0.05, 0, 0.37, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📏 Range: " .. currentRange .. " studs"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 11
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = mainFrame

local rangeSliderBg = Instance.new("Frame")
rangeSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
rangeSliderBg.Position = UDim2.new(0.1, 0, 0.42, 0)
rangeSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
rangeSliderBg.BorderSizePixel = 0
rangeSliderBg.Parent = mainFrame

local rangeSliderCorner = Instance.new("UICorner")
rangeSliderCorner.CornerRadius = UDim.new(1, 0)
rangeSliderCorner.Parent = rangeSliderBg

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new((currentRange - 10) / 40, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeSliderBg

-- Speed Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: " .. string.format("%.0f", 1/currentDelay) .. "/sec"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedSliderBg = Instance.new("Frame")
speedSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
speedSliderBg.Position = UDim2.new(0.1, 0, 0.55, 0)
speedSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedSliderBg.BorderSizePixel = 0
speedSliderBg.Parent = mainFrame

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(1, 0)
speedSliderCorner.Parent = speedSliderBg

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(1 - ((currentDelay - 0.05) / 0.45), 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSliderBg

-- Stats Display
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0.9, 0, 0, 70)
statsFrame.Position = UDim2.new(0.05, 0, 0.62, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0.6, 0)
statsLabel.Position = UDim2.new(0, 0, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📊 Mined: 0"
statsLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
statsLabel.TextSize = 12
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.Parent = statsFrame

local nearbyLabel = Instance.new("TextLabel")
nearbyLabel.Size = UDim2.new(1, 0, 0.4, 0)
nearbyLabel.Position = UDim2.new(0, 0, 0.6, 0)
nearbyLabel.BackgroundTransparency = 1
nearbyLabel.Text = "🪨 Nearby: 0"
nearbyLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
nearbyLabel.TextSize = 11
nearbyLabel.Font = Enum.Font.Gotham
nearbyLabel.TextXAlignment = Enum.TextXAlignment.Center
nearbyLabel.Parent = statsFrame

-- Debug Label
local debugLabel = Instance.new("TextLabel")
debugLabel.Size = UDim2.new(0.9, 0, 0, 40)
debugLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
debugLabel.BackgroundTransparency = 1
debugLabel.Text = "🔍 Ready"
debugLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
debugLabel.TextSize = 9
debugLabel.Font = Enum.Font.Gotham
debugLabel.TextXAlignment = Enum.TextXAlignment.Left
debugLabel.Parent = mainFrame

-- Dragging
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Slider functions
local function setupTouchSlider(sliderBg, fill, callback, minVal, maxVal)
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(fill.Size.X.Scale, -10, -8, 0)
    knob.BackgroundColor3 = fill.BackgroundColor3
    knob.Text = ""
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local function updateFromInput(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        knob.Position = UDim2.new(relativeX, -10, -8, 0)
        callback(relativeX, minVal, maxVal)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateFromInput(input)
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Change then
                    updateFromInput(input)
                elseif input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

setupTouchSlider(rangeSliderBg, rangeFill, function(val)
    currentRange = math.floor(10 + (val * 40))
    rangeLabel.Text = "📏 Range: " .. currentRange .. " studs"
end)

setupTouchSlider(speedSliderBg, speedFill, function(val)
    currentDelay = 0.05 + ((1 - val) * 0.45)
    speedLabel.Text = "⚡ Speed: " .. string.format("%.0f", 1/currentDelay) .. "/sec"
end)

-- Core Mining Functions
local function getAllAsteroids()
    local allAsteroids = {}
    local plots = workspace:FindFirstChild("Plots")
    
    if not plots then
        debugLabel.Text = "❌ No Plots folder found!"
        return allAsteroids
    end
    
    -- Get Plot1 (from your script)
    local targetPlot = plots:FindFirstChild("Plot1")
    if not targetPlot then
        debugLabel.Text = "❌ Plot1 not found!"
        return allAsteroids
    end
    
    local asteroidsFolder = targetPlot:FindFirstChild("Asteroids")
    if not asteroidsFolder then
        debugLabel.Text = "⚠️ No Asteroids folder in Plot1"
        return allAsteroids
    end
    
    -- Get all asteroid folders (they have unique IDs like {8e4bd65d-68be-4a7f-8371-a47380a7f198})
    for _, asteroid in pairs(asteroidsFolder:GetChildren()) do
        -- Asteroids are folders with unique IDs
        if asteroid:IsA("Folder") or asteroid:IsA("Model") then
            -- Find the primary part (for distance checking)
            local primaryPart = asteroid:FindFirstChild("Primary")
            if not primaryPart then
                primaryPart = asteroid:FindFirstChildWhichIsA("BasePart")
            end
            
            if primaryPart then
                table.insert(allAsteroids, {
                    id = asteroid.Name, -- The unique ID
                    folder = asteroid,
                    part = primaryPart,
                    plot = targetPlot
                })
            end
        end
    end
    
    return allAsteroids
end

local function getAsteroidsInRange(asteroids, range)
    local inRange = {}
    local playerPos = humanoidRootPart.Position
    
    for _, asteroid in pairs(asteroids) do
        -- Skip if recently mined
        if minedAsteroids[asteroid.id] and tick() - minedAsteroids[asteroid.id] < 0.5 then
            continue
        end
        
        -- Check if asteroid still exists
        if not asteroid.folder or not asteroid.folder.Parent then
            continue
        end
        
        local distance = (playerPos - asteroid.part.Position).Magnitude
        if distance <= range then
            table.insert(inRange, {
                asteroid = asteroid,
                distance = distance
            })
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(inRange, function(a, b) return a.distance < b.distance end)
    return inRange
end

-- Multiple mining methods to ensure it works
local function mineAsteroid_Method1(plot, asteroidFolder)
    -- Method 1: Direct InvokeServer with plot and asteroid folder (your working method)
    if miningRemote then
        local success = pcall(function()
            local args = {plot, asteroidFolder}
            return miningRemote:InvokeServer(unpack(args))
        end)
        if success then return true end
    end
    return false
end

local function mineAsteroid_Method2(plot, asteroidFolder)
    -- Method 2: FireServer instead of InvokeServer
    if miningRemote then
        local success = pcall(function()
            local args = {plot, asteroidFolder}
            miningRemote:FireServer(unpack(args))
        end)
        if success then return true end
    end
    return false
end

local function mineAsteroid_Method3(asteroidFolder)
    -- Method 3: Click the primary part
    local primaryPart = asteroidFolder:FindFirstChild("Primary")
    if primaryPart then
        local clickDetector = primaryPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            local success = pcall(function()
                clickDetector:Click()
            end)
            if success then return true end
        end
    end
    return false
end

local function mineAsteroid_Method4(asteroidFolder)
    -- Method 4: Use ProximityPrompt
    local primaryPart = asteroidFolder:FindFirstChild("Primary")
    if primaryPart then
        local prompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            local success = pcall(function()
                prompt:Prompt(player)
            end)
            if success then return true end
        end
    end
    return false
end

local function mineAsteroid(plot, asteroidFolder, asteroidId)
    -- Try all methods in order
    local methods = {
        {func = mineAsteroid_Method1, name = "InvokeServer"},
        {func = mineAsteroid_Method2, name = "FireServer"},
        {func = mineAsteroid_Method3, name = "ClickDetector"},
        {func = mineAsteroid_Method4, name = "ProximityPrompt"}
    }
    
    for _, method in pairs(methods) do
        local success = method.func(plot, asteroidFolder)
        if success then
            if debugMode then
                debugLabel.Text = "✅ Mined using: " .. method.name
                task.wait(0.5)
            end
            return true
        end
    end
    
    return false
end

-- Main mining loop
local miningCoroutine = nil
local lastMineTime = 0

local function startMining()
    debugLabel.Text = "🔍 Scanning for asteroids..."
    
    while isMining and RunService.Heartbeat:Wait() do
        if tick() - lastMineTime < currentDelay then
            continue
        end
        
        -- Get all asteroids
        local allAsteroids = getAllAsteroids()
        
        if #allAsteroids == 0 then
            statusLabel.Text = "Status: ⚠️ NO ASTEROIDS FOUND"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            nearbyLabel.Text = "🪨 Nearby: 0"
            debugLabel.Text = "❌ No asteroids in Plot1/Asteroids"
            task.wait(0.5)
            continue
        end
        
        -- Debug: Show first asteroid ID found
        if debugMode and #allAsteroids > 0 then
            debugLabel.Text = "🔍 Found asteroid: " .. string.sub(allAsteroids[1].id, 1, 30) .. "..."
        end
        
        -- Get asteroids in range
        local nearbyAsteroids = getAsteroidsInRange(allAsteroids, currentRange)
        
        -- Update UI
        nearbyLabel.Text = "🪨 Nearby: " .. #nearbyAsteroids
        statsLabel.Text = "📊 Mined: " .. totalMined
        
        if #nearbyAsteroids > 0 then
            -- Mine the closest asteroid first
            local target = nearbyAsteroids[1]
            
            statusLabel.Text = "Status: ⛏️ MINING..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- Attempt to mine
            local mined = mineAsteroid(target.asteroid.plot, target.asteroid.folder, target.asteroid.id)
            
            if mined then
                totalMined = totalMined + 1
                lastMineTime = tick()
                minedAsteroids[target.asteroid.id] = tick()
                statsLabel.Text = "📊 Mined: " .. totalMined
                
                -- Visual feedback
                debugLabel.Text = "✅ Mined: " .. string.sub(target.asteroid.id, 1, 20) .. "..."
                
                -- Flash effect
                toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.05)
                if isMining then
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
                end
            else
                debugLabel.Text = "⚠️ Failed to mine: " .. string.sub(target.asteroid.id, 1, 20) .. "..."
            end
        else
            statusLabel.Text = "Status: 🚶 MOVE CLOSER"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            debugLabel.Text = "🔍 No asteroids within " .. currentRange .. " studs"
        end
        
        -- Clean up tracked asteroids
        for id, time in pairs(minedAsteroids) do
            if tick() - time > 2 then
                minedAsteroids[id] = nil
            end
        end
    end
end

-- Toggle function
local function toggleMining()
    isMining = not isMining
    
    if isMining then
        toggleBtn.Text = "⏹️ STOP MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        statusLabel.Text = "Status: ✅ ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        if miningCoroutine then
            coroutine.close(miningCoroutine)
        end
        miningCoroutine = coroutine.create(startMining)
        coroutine.resume(miningCoroutine)
    else
        toggleBtn.Text = "▶️ START MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.Text = "Status: ❌ OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if miningCoroutine then
            coroutine.close(miningCoroutine)
            miningCoroutine = nil
        end
    end
end

-- Button connections
toggleBtn.MouseButton1Click:Connect(toggleMining)
closeBtn.MouseButton1Click:Connect(function()
    isMining = false
    screenGui:Destroy()
    if miningCoroutine then
        coroutine.close(miningCoroutine)
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    task.wait(1)
    debugLabel.Text = "🔄 Character respawned, ready!"
end)

-- Test function to verify remote works
local function testRemote()
    if miningRemote then
        debugLabel.Text = "✅ Remote found: (empty string)"
        print("Remote found successfully!")
    else
        debugLabel.Text = "❌ Remote NOT found!"
        print("Could not find empty string remote!")
    end
end

testRemote()

-- Print startup info
print("=== AUTO MINER v2 LOADED ===")
print("Remote found:", miningRemote ~= nil)
print("Default range: " .. currentRange)
print("Default speed: " 
