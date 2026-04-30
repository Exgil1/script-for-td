-- Working Auto Miner for Mobile (Delta Executor)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local MINE_RANGE = 30 -- How close you need to be to mine
local MINE_DELAY = 0.15 -- Delay between mining (lower = faster)
local minedAsteroids = {} -- Track recently mined asteroids

-- Get the mining remote (empty string name)
local Communication = ReplicatedStorage:WaitForChild("Communication")
local Functions = Communication:WaitForChild("Functions")
local miningRemote = Functions:FindFirstChild("") -- The empty string remote

if not miningRemote then
    warn("Mining remote not found!")
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

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 350)
mainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "⛏️ AUTO ASTEROID MINER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
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
toggleBtn.Position = UDim2.new(0.1, 0, 0.16, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
toggleBtn.Text = "START MINING"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: ❌ OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = mainFrame

-- Range Slider Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
rangeLabel.Position = UDim2.new(0.05, 0, 0.42, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📏 Range: " .. currentRange .. " studs"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 12
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = mainFrame

-- Range Slider Background
local rangeSliderBg = Instance.new("Frame")
rangeSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
rangeSliderBg.Position = UDim2.new(0.1, 0, 0.48, 0)
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

local rangeFillCorner = Instance.new("UICorner")
rangeFillCorner.CornerRadius = UDim.new(1, 0)
rangeFillCorner.Parent = rangeFill

-- Speed Slider Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0.58, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: " .. string.format("%.0f", 1/currentDelay) .. " mines/sec"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Speed Slider Background
local speedSliderBg = Instance.new("Frame")
speedSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
speedSliderBg.Position = UDim2.new(0.1, 0, 0.64, 0)
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

local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim.new(1, 0)
speedFillCorner.Parent = speedFill

-- Stats Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0.9, 0, 0, 50)
statsLabel.Position = UDim2.new(0.05, 0, 0.73, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📊 Mined: 0\n🪨 Nearby: 0"
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = mainFrame

-- Instructions Label
local instructionsLabel = Instance.new("TextLabel")
instructionsLabel.Size = UDim2.new(0.9, 0, 0, 30)
instructionsLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
instructionsLabel.BackgroundTransparency = 1
instructionsLabel.Text = "💡 Stand near asteroids\nto auto-mine them!"
instructionsLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
instructionsLabel.TextSize = 10
instructionsLabel.Font = Enum.Font.Gotham
instructionsLabel.TextXAlignment = Enum.TextXAlignment.Left
instructionsLabel.Parent = mainFrame

-- Dragging functionality
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

-- Slider update functions (for touch)
local function updateRange(value)
    currentRange = math.floor(10 + (value * 40))
    rangeFill.Size = UDim2.new(value, 0, 1, 0)
    rangeLabel.Text = "📏 Range: " .. currentRange .. " studs"
end

local function updateSpeed(value)
    currentDelay = 0.05 + ((1 - value) * 0.45)
    speedFill.Size = UDim2.new(value, 0, 1, 0)
    speedLabel.Text = "⚡ Speed: " .. string.format("%.0f", 1/currentDelay) .. " mines/sec"
end

-- Touch handlers for sliders
local function setupSlider(sliderBg, fill, callback)
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 20, 0, 20)
    sliderBtn.Position = UDim2.new(fill.Size.X.Scale, -10, -8, 0)
    sliderBtn.BackgroundColor3 = fill.BackgroundColor3
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBg
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = sliderBtn
    
    local function updateFromInput(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        callback(relativeX)
        sliderBtn.Position = UDim2.new(relativeX, -10, -8, 0)
    end
    
    sliderBtn.InputBegan:Connect(function(input)
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

setupSlider(rangeSliderBg, rangeFill, updateRange)
setupSlider(speedSliderBg, speedFill, updateSpeed)

-- Mining Functions
local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    -- Get Plot1 (since your script uses Plot1)
    local plot = plots:FindFirstChild("Plot1")
    if plot then return plot end
    
    -- Fallback to any plot with player's name
    for _, p in pairs(plots:GetChildren()) do
        if p.Name:lower():find(player.Name:lower()) then
            return p
        end
    end
    
    return plots:FindFirstChild("Plot1")
end

local function getAsteroidsInRange(plot, range)
    local asteroids = plot:FindFirstChild("Asteroids")
    if not asteroids then return {} end
    
    local asteroidsInRange = {}
    local playerPos = humanoidRootPart.Position
    
    for _, asteroid in pairs(asteroids:GetChildren()) do
        -- Skip if recently mined
        if minedAsteroids[asteroid.Name] and tick() - minedAsteroids[asteroid.Name] < currentDelay then
            continue
        end
        
        -- Check if asteroid still exists
        if asteroid and asteroid.Parent then
            local primaryPart = asteroid:FindFirstChild("Primary")
            if not primaryPart then
                primaryPart = asteroid:FindFirstChildWhichIsA("BasePart")
            end
            
            if primaryPart and primaryPart.Parent then
                local distance = (playerPos - primaryPart.Position).Magnitude
                if distance <= range then
                    table.insert(asteroidsInRange, {
                        id = asteroid.Name,
                        folder = asteroid,
                        distance = distance
                    })
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(asteroidsInRange, function(a, b) return a.distance < b.distance end)
    return asteroidsInRange
end

local function mineAsteroid(plot, asteroidFolder)
    if not miningRemote then return false end
    
    -- Use the exact same method as your working manual script
    local success = pcall(function()
        local args = {plot, asteroidFolder}
        miningRemote:InvokeServer(unpack(args))
    end)
    
    if success then
        minedAsteroids[asteroidFolder.Name] = tick()
        return true
    end
    
    return false
end

-- Main mining loop
local miningLoop = nil
local lastMineTime = 0

local function startMiningLoop()
    while isMining and RunService.Heartbeat:Wait() do
        if tick() - lastMineTime < currentDelay then
            continue
        end
        
        local plot = getPlayerPlot()
        if not plot then
            statusLabel.Text = "Status: ⚠️ NO PLOT FOUND"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            task.wait(1)
            continue
        end
        
        local nearbyAsteroids = getAsteroidsInRange(plot, currentRange)
        
        -- Update stats
        statsLabel.Text = string.format("📊 Mined: %d\n🪨 Nearby: %d", totalMined, #nearbyAsteroids)
        
        if #nearbyAsteroids > 0 then
            for _, asteroid in pairs(nearbyAsteroids) do
                if not isMining then break end
                
                if mineAsteroid(plot, asteroid.folder) then
                    totalMined = totalMined + 1
                    lastMineTime = tick()
                    statusLabel.Text = "Status: ✅ MINING... (" .. totalMined .. ")"
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    
                    -- Visual flash effect
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                    task.wait(0.05)
                    if isMining then
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
                    end
                end
                
                task.wait(0.02) -- Small delay between multiple asteroids
            end
        else
            statusLabel.Text = "Status: 🔍 NO ASTEROIDS IN RANGE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
        
        -- Clean old mined asteroids
        for id, time in pairs(minedAsteroids) do
            if tick() - time > 2 then
                minedAsteroids[id] = nil
            end
        end
    end
end

-- Toggle mining on/off
local function toggleMining()
    isMining = not isMining
    
    if isMining then
        toggleBtn.Text = "⏹️ STOP MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        statusLabel.Text = "Status: ✅ ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        if miningLoop then
            coroutine.close(miningLoop)
        end
        miningLoop = coroutine.create(startMiningLoop)
        coroutine.resume(miningLoop)
    else
        toggleBtn.Text = "▶️ START MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.Text = "Status: ❌ OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if miningLoop then
            coroutine.close(miningLoop)
            miningLoop = nil
        end
    end
end

-- Button connections
toggleBtn.MouseButton1Click:Connect(toggleMining)
closeBtn.MouseButton1Click:Connect(function()
    isMining = false
    screenGui:Destroy()
    if miningLoop then
        coroutine.close(miningLoop)
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    task.wait(1)
end)

-- Print startup info
print("=== AUTO MINER LOADED ===")
print("Using remote: (empty string) - " .. (miningRemote and "FOUND ✓" or "NOT FOUND ✗"))
print("Range: " .. currentRange .. " studs")
print("Speed: " .. string.format("%.0f", 1/currentDelay) .. " mines/sec")
print("Press START to begin mining")
print("=========================")

-- Success message on GUI
local successMsg = Instance.new("TextLabel")
successMsg.Size = UDim2.new(0.8, 0, 0, 20)
successMsg.Position = UDim2.new(0.1, 0, 0.1, 0)
successMsg.BackgroundTransparency = 1
successMsg.Text = "✓ Ready to mine!"
successMsg.TextColor3 = Color3.fromRGB(76, 175, 80)
successMsg.TextSize = 11
successMsg.Font = Enum.Font.Gotham
successMsg.Parent = mainFrame

task.delay(2, function()
    successMsg:Destroy()
end)
