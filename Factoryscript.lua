-- Mobile Auto Aura Miner with GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local AURA_RANGE = 35
local MINE_INTERVAL = 0.05
local minedAsteroids = {}

-- Get required services
local Communication = ReplicatedStorage:WaitForChild("Communication")
local Functions = Communication:WaitForChild("Functions")

-- Find mining remote
local miningRemote = nil
local possibleRemoteNames = { "", "MineAsteroid", "MineOre", "Mine", "Harvest", "Collect", "Break", "ExtractOre", "Gather" }

for _, name in pairs(possibleRemoteNames) do
    local remote = Functions:FindFirstChild(name)
    if remote then
        miningRemote = remote
        break
    end
end

if not miningRemote and #Functions:GetChildren() > 0 then
    miningRemote = Functions:GetChildren()[1]
end

-- GUI Variables
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoMinerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local isMining = false
local currentRange = AURA_RANGE
local currentSpeed = MINE_INTERVAL

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ AUTO AURA MINER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Toggle Button (Main Control)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.1, 0, 0.18, 0)
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
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Range Slider Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
rangeLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Range: " .. currentRange .. " studs"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 12
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = mainFrame

-- Range Slider
local rangeSlider = Instance.new("Frame")
rangeSlider.Size = UDim2.new(0.8, 0, 0, 4)
rangeSlider.Position = UDim2.new(0.1, 0, 0.51, 0)
rangeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
rangeSlider.BorderSizePixel = 0
rangeSlider.Parent = mainFrame

local rangeSliderCorner = Instance.new("UICorner")
rangeSliderCorner.CornerRadius = UDim.new(1, 0)
rangeSliderCorner.Parent = rangeSlider

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(0.5, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeSlider

local rangeFillCorner = Instance.new("UICorner")
rangeFillCorner.CornerRadius = UDim.new(1, 0)
rangeFillCorner.Parent = rangeFill

local rangeKnob = Instance.new("TextButton")
rangeKnob.Size = UDim2.new(0, 20, 0, 20)
rangeKnob.Position = UDim2.new(0.5, -10, -8, 0)
rangeKnob.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
rangeKnob.Text = ""
rangeKnob.Parent = rangeSlider

local rangeKnobCorner = Instance.new("UICorner")
rangeKnobCorner.CornerRadius = UDim.new(1, 0)
rangeKnobCorner.Parent = rangeKnob

-- Speed Slider Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. string.format("%.2f", 1/currentSpeed) .. " mines/sec"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Speed Slider
local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.8, 0, 0, 4)
speedSlider.Position = UDim2.new(0.1, 0, 0.66, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = mainFrame

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(1, 0)
speedSliderCorner.Parent = speedSlider

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim.new(1, 0)
speedFillCorner.Parent = speedFill

local speedKnob = Instance.new("TextButton")
speedKnob.Size = UDim2.new(0, 20, 0, 20)
speedKnob.Position = UDim2.new(0.5, -10, -8, 0)
speedKnob.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedKnob.Text = ""
speedKnob.Parent = speedSlider

local speedKnobCorner = Instance.new("UICorner")
speedKnobCorner.CornerRadius = UDim.new(1, 0)
speedKnobCorner.Parent = speedKnob

-- Stats Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0.9, 0, 0, 40)
statsLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Mined: 0\nNearby: 0"
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = mainFrame

-- Drag functionality
local dragging = false
local dragInput
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

titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Slider functions
local function updateRangeSlider(input)
    local relativeX = math.clamp((input.Position.X - rangeSlider.AbsolutePosition.X) / rangeSlider.AbsoluteSize.X, 0, 1)
    rangeFill.Size = UDim2.new(relativeX, 0, 1, 0)
    rangeKnob.Position = UDim2.new(relativeX, -10, -8, 0)
    currentRange = math.floor(relativeX * 80 + 10)
    rangeLabel.Text = "Range: " .. currentRange .. " studs"
end

local function updateSpeedSlider(input)
    local relativeX = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
    speedFill.Size = UDim2.new(relativeX, 0, 1, 0)
    speedKnob.Position = UDim2.new(relativeX, -10, -8, 0)
    currentSpeed = math.max(0.01, (1 - relativeX) * 0.2 + 0.01)
    speedLabel.Text = "Speed: " .. string.format("%.1f", 1/currentSpeed) .. " mines/sec"
end

rangeKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConnection
        local endConnection
        
        moveConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Change then
                updateRangeSlider(input)
            end
        end)
        
        endConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                moveConnection:Disconnect()
                endConnection:Disconnect()
            end
        end)
    end
end)

speedKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConnection
        local endConnection
        
        moveConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Change then
                updateSpeedSlider(input)
            end
        end)
        
        endConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                moveConnection:Disconnect()
                endConnection:Disconnect()
            end
        end)
    end
end)

-- Mining functions
local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, plot in pairs(plots:GetChildren()) do
        local plotOwner = plot:FindFirstChild("Owner") or plot:FindFirstChild("ClaimedBy") or plot:FindFirstChild("PlotOwner")
        if plotOwner and plotOwner.Value == player.Name then
            return plot
        end
    end
    
    local playerPos = humanoidRootPart.Position
    for _, plot in pairs(plots:GetChildren()) do
        local plotPrimary = plot:FindFirstChild("Primary") or plot:FindFirstChildWhichIsA("BasePart")
        if plotPrimary and (playerPos - plotPrimary.Position).Magnitude < 50 then
            return plot
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
        if minedAsteroids[asteroid.Name] and tick() - minedAsteroids[asteroid.Name] < 0.5 then
            continue
        end
        
        local primaryPart = asteroid:FindFirstChild("Primary") or asteroid:FindFirstChildWhichIsA("BasePart")
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
    
    table.sort(asteroidsInRange, function(a, b) return a.distance < b.distance end)
    return asteroidsInRange
end

local function mineAsteroid(plot, asteroidId)
    if not miningRemote then return false end
    
    local asteroids = plot:FindFirstChild("Asteroids")
    if not asteroids then return false end
    
    local asteroidFolder = asteroids:FindFirstChild(asteroidId)
    if not asteroidFolder or not asteroidFolder.Parent then return false end
    
    pcall(function()
        if miningRemote.Name == "" then
            miningRemote:FireServer(plot, asteroidFolder)
        else
            miningRemote:FireServer(plot, asteroidFolder)
        end
    end)
    
    minedAsteroids[asteroidId] = tick()
    return true
end

-- Mining loop
local miningCoroutine = nil
local totalMined = 0
local lastMineTime = 0

local function startMining()
    while isMining and RunService.Heartbeat:Wait() do
        if tick() - lastMineTime < currentSpeed then continue end
        
        local plot = getPlayerPlot()
        if plot then
            local nearbyAsteroids = getAsteroidsInRange(plot, currentRange)
            
            -- Update stats
            statsLabel.Text = "Mined: " .. totalMined .. "\nNearby: " .. #nearbyAsteroids
            
            if #nearbyAsteroids > 0 then
                for _, asteroid in pairs(nearbyAsteroids) do
                    if not isMining then break end
                    if mineAsteroid(plot, asteroid.id) then
                        totalMined = totalMined + 1
                        lastMineTime = tick()
                        
                        -- Visual feedback
                        statusLabel.Text = "Status: MINING... (" .. totalMined .. ")"
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        
                        task.wait(0.03)
                    end
                end
            else
                statusLabel.Text = "Status: IDLE (no asteroids)"
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
        else
            statusLabel.Text = "Status: NO PLOT"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        -- Clean mined asteroids tracking
        if tick() % 3 < 0.1 then
            for id, time in pairs(minedAsteroids) do
                if tick() - time > 2 then
                    minedAsteroids[id] = nil
                end
            end
        end
    end
end

-- Toggle function
local function toggleMining()
    isMining = not isMining
    
    if isMining then
        toggleBtn.Text = "STOP MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        statusLabel.Text = "Status: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        if miningCoroutine then
            coroutine.close(miningCoroutine)
        end
        miningCoroutine = coroutine.create(startMining)
        coroutine.resume(miningCoroutine)
    else
        toggleBtn.Text = "START MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.Text = "Status: OFF"
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
    screenGui:Destroy()
    if miningCoroutine then
        coroutine.close(miningCoroutine)
    end
end)

-- Initialize sliders
local initialRange = (currentRange - 10) / 80
rangeFill.Size = UDim2.new(initialRange, 0, 1, 0)
rangeKnob.Position = UDim2.new(initialRange, -10, -8, 0)

local initialSpeed = 1 - ((currentSpeed - 0.01) / 0.2)
speedFill.Size = UDim2.new(initialSpeed, 0, 1, 0)
speedKnob.Position = UDim2.new(initialSpeed, -10, -8, 0)

-- Make GUI movable on mobile
local function onTouch(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local hitPosition = input.Position
        -- Check if hit position is within the mainFrame
        if hitPosition.X >= mainFrame.AbsolutePosition.X and hitPosition.X <= mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X and
           hitPosition.Y >= mainFrame.AbsolutePosition.Y and hitPosition.Y <= mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y then
            -- Start dragging
            local dragStart = input.Position
            local startPos = mainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Change then
                    local delta = input.Position - dragStart
                    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                elseif input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end
end

UserInputService.InputBegan:Connect(onTouch)

-- Print startup message
print("=== AUTO AURA MINER GUI LOADED ===")
print("Range: " .. currentRange .. " studs")
print("Speed: " .. string.format("%.1f", 1/currentSpeed) .. " mines/sec")
print("Press the START button to begin mining")
print("=====================================")

-- Flash animation for attention
local flash = TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {BackgroundColor3 = Color3.fromRGB(100, 200, 100)})
flash:Play()
task.wait(0.5)
flash:Cancel()
toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
