-- Advanced Remote Scanner & Auto Miner for Mobile
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ========== REMOTE SCANNER ==========
local scannedRemotes = {}
local miningRemote = nil
local allFunctions = {}

-- Deep scan function to find all remotes (including hidden ones)
local function deepScanRemotes(parent, depth)
    depth = depth or 0
    if depth > 10 then return end
    
    for _, child in pairs(parent:GetChildren()) do
        -- Check if it's a RemoteFunction or RemoteEvent
        if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
            local remoteInfo = {
                Name = child.Name ~= "" and child.Name or "(EMPTY STRING)",
                ClassName = child.ClassName,
                Parent = child.Parent.Name,
                FullPath = child:GetFullName()
            }
            table.insert(scannedRemotes, remoteInfo)
            table.insert(allFunctions, child)
            
            -- Try to find mining-related remotes
            local lowerName = string.lower(child.Name)
            if child.Name == "" or 
               string.find(lowerName, "mine") or 
               string.find(lowerName, "ore") or 
               string.find(lowerName, "asteroid") or
               string.find(lowerName, "harvest") or
               string.find(lowerName, "collect") then
                miningRemote = child
            end
        end
        
        -- Recursively scan children (including hidden ones)
        pcall(function()
            deepScanRemotes(child, depth + 1)
        end)
    end
    
    -- Also scan services that might contain hidden remotes
    pcall(function()
        for _, service in pairs(game:GetChildren()) do
            if service:IsA("Service") then
                for _, child in pairs(service:GetChildren()) do
                    if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                        local remoteInfo = {
                            Name = child.Name ~= "" and child.Name : "(EMPTY STRING)",
                            ClassName = child.ClassName,
                            Parent = child.Parent.Name,
                            FullPath = child:GetFullName()
                        }
                        table.insert(scannedRemotes, remoteInfo)
                        table.insert(allFunctions, child)
                    end
                end
            end
        end
    end)
end

-- ========== GUI SETUP ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteScannerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local isMining = false
local currentRange = 35
local currentDelay = 0.1
local totalMined = 0
local minedAsteroids = {}
local selectedRemote = nil

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 500)
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BackgroundTransparency = 0.05
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 REMOTE SCANNER & MINER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Tab Buttons
local scanTabBtn = Instance.new("TextButton")
scanTabBtn.Size = UDim2.new(0.5, -1, 0, 35)
scanTabBtn.Position = UDim2.new(0, 0, 0, 45)
scanTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
scanTabBtn.Text = "📡 SCAN"
scanTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanTabBtn.TextSize = 14
scanTabBtn.Font = Enum.Font.GothamBold
scanTabBtn.Parent = mainFrame

local scanTabCorner = Instance.new("UICorner")
scanTabCorner.CornerRadius = UDim.new(0, 0)
scanTabCorner.Parent = scanTabBtn

local minerTabBtn = Instance.new("TextButton")
minerTabBtn.Size = UDim2.new(0.5, -1, 0, 35)
minerTabBtn.Position = UDim2.new(0.5, 1, 0, 45)
minerTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
minerTabBtn.Text = "⛏️ MINER"
minerTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minerTabBtn.TextSize = 14
minerTabBtn.Font = Enum.Font.GothamBold
minerTabBtn.Parent = mainFrame

local minerTabCorner = Instance.new("UICorner")
minerTabCorner.CornerRadius = UDim.new(0, 0)
minerTabCorner.Parent = minerTabBtn

-- Content Frames
local scanFrame = Instance.new("ScrollingFrame")
scanFrame.Size = UDim2.new(1, -10, 1, -90)
scanFrame.Position = UDim2.new(0, 5, 0, 85)
scanFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scanFrame.BackgroundTransparency = 0.3
scanFrame.BorderSizePixel = 0
scanFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scanFrame.ScrollBarThickness = 4
scanFrame.Visible = true
scanFrame.Parent = mainFrame

local minerFrame = Instance.new("Frame")
minerFrame.Size = UDim2.new(1, -10, 1, -90)
minerFrame.Position = UDim2.new(0, 5, 0, 85)
minerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
minerFrame.BackgroundTransparency = 0.3
minerFrame.BorderSizePixel = 0
minerFrame.Visible = false
minerFrame.Parent = mainFrame

-- Scan Button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 45)
scanBtn.Position = UDim2.new(0.05, 0, 0, 5)
scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
scanBtn.Text = "🔍 START SCAN"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 16
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = scanFrame

local scanBtnCorner = Instance.new("UICorner")
scanBtnCorner.CornerRadius = UDim.new(0, 8)
scanBtnCorner.Parent = scanBtn

-- Copy Logs Button
local copyLogsBtn = Instance.new("TextButton")
copyLogsBtn.Size = UDim2.new(0.9, 0, 0, 40)
copyLogsBtn.Position = UDim2.new(0.05, 0, 0, 55)
copyLogsBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyLogsBtn.Text = "📋 COPY LOGS"
copyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyLogsBtn.TextSize = 14
copyLogsBtn.Font = Enum.Font.GothamBold
copyLogsBtn.Parent = scanFrame

local copyLogsCorner = Instance.new("UICorner")
copyLogsCorner.CornerRadius = UDim.new(0, 8)
copyLogsCorner.Parent = copyLogsBtn

-- Results List
local resultsList = Instance.new("ScrollingFrame")
resultsList.Size = UDim2.new(1, 0, 1, -105)
resultsList.Position = UDim2.new(0, 0, 0, 100)
resultsList.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resultsList.BackgroundTransparency = 0.2
resultsList.BorderSizePixel = 0
resultsList.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsList.ScrollBarThickness = 4
resultsList.Parent = scanFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 6)
resultsCorner.Parent = resultsList

-- Miner Frame UI Elements
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.1, 0, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
toggleBtn.Text = "▶️ START MINING"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = minerFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Remote Selector
local remoteLabel = Instance.new("TextLabel")
remoteLabel.Size = UDim2.new(0.9, 0, 0, 25)
remoteLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
remoteLabel.BackgroundTransparency = 1
remoteLabel.Text = "🎯 Selected Remote: None"
remoteLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
remoteLabel.TextSize = 11
remoteLabel.Font = Enum.Font.Gotham
remoteLabel.Parent = minerFrame

local remoteSelectBtn = Instance.new("TextButton")
remoteSelectBtn.Size = UDim2.new(0.8, 0, 0, 35)
remoteSelectBtn.Position = UDim2.new(0.1, 0, 0.24, 0)
remoteSelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
remoteSelectBtn.Text = "⚙️ SELECT REMOTE"
remoteSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
remoteSelectBtn.TextSize = 12
remoteSelectBtn.Font = Enum.Font.Gotham
remoteSelectBtn.Parent = minerFrame

local remoteSelectCorner = Instance.new("UICorner")
remoteSelectCorner.CornerRadius = UDim.new(0, 6)
remoteSelectCorner.Parent = remoteSelectBtn

-- Range Slider
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
rangeLabel.Position = UDim2.new(0.05, 0, 0.33, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📏 Range: 35 studs"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 11
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.Parent = minerFrame

local rangeSliderBg = Instance.new("Frame")
rangeSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
rangeSliderBg.Position = UDim2.new(0.1, 0, 0.37, 0)
rangeSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
rangeSliderBg.BorderSizePixel = 0
rangeSliderBg.Parent = minerFrame

local rangeSliderCorner = Instance.new("UICorner")
rangeSliderCorner.CornerRadius = UDim.new(1, 0)
rangeSliderCorner.Parent = rangeSliderBg

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(0.625, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeSliderBg

-- Speed Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0.44, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: 10/sec"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = minerFrame

local speedSliderBg = Instance.new("Frame")
speedSliderBg.Size = UDim2.new(0.8, 0, 0, 4)
speedSliderBg.Position = UDim2.new(0.1, 0, 0.48, 0)
speedSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedSliderBg.BorderSizePixel = 0
speedSliderBg.Parent = minerFrame

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(1, 0)
speedSliderCorner.Parent = speedSliderBg

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSliderBg

-- Stats
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0.9, 0, 0, 70)
statsFrame.Position = UDim2.new(0.05, 0, 0.55, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = minerFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsFrame

local minedLabel = Instance.new("TextLabel")
minedLabel.Size = UDim2.new(1, 0, 0.5, 0)
minedLabel.Position = UDim2.new(0, 0, 0, 0)
minedLabel.BackgroundTransparency = 1
minedLabel.Text = "📊 Mined: 0"
minedLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
minedLabel.TextSize = 12
minedLabel.Font = Enum.Font.GothamBold
minedLabel.Parent = statsFrame

local nearbyLabel = Instance.new("TextLabel")
nearbyLabel.Size = UDim2.new(1, 0, 0.5, 0)
nearbyLabel.Position = UDim2.new(0, 0, 0.5, 0)
nearbyLabel.BackgroundTransparency = 1
nearbyLabel.Text = "🪨 Nearby: 0"
nearbyLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
nearbyLabel.TextSize = 11
nearbyLabel.Font = Enum.Font.Gotham
nearbyLabel.Parent = statsFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = minerFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
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

-- Tab Switching
scanTabBtn.MouseButton1Click:Connect(function()
    scanFrame.Visible = true
    minerFrame.Visible = false
    scanTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    minerTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    scanTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minerTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

minerTabBtn.MouseButton1Click:Connect(function()
    scanFrame.Visible = false
    minerFrame.Visible = true
    minerTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scanTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    minerTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Slider Setup
local function setupSlider(sliderBg, fill, callback)
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(fill.Size.X.Scale, -10, -8, 0)
    knob.BackgroundColor3 = fill.BackgroundColor3
    knob.Text = ""
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local function update(input)
                local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                knob.Position = UDim2.new(relativeX, -10, -8, 0)
                callback(relativeX)
            end
            
            update(input)
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Change then
                    update(input)
                elseif input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

setupSlider(rangeSliderBg, rangeFill, function(val)
    currentRange = math.floor(10 + (val * 40))
    rangeLabel.Text = "📏 Range: " .. currentRange .. " studs"
end)

setupSlider(speedSliderBg, speedFill, function(val)
    currentDelay = 0.05 + ((1 - val) * 0.45)
    speedLabel.Text = "⚡ Speed: " .. string.format("%.0f", 1/currentDelay) .. "/sec"
end)

-- ========== SCAN FUNCTION ==========
local function performScan()
    scannedRemotes = {}
    allFunctions = {}
    miningRemote = nil
    
    statusLabel.Text = "Status: Scanning..."
    scanBtn.Text = "🔄 SCANNING..."
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    
    -- Clear previous results
    for _, child in pairs(resultsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Perform deep scan
    task.wait(0.1)
    deepScanRemotes(ReplicatedStorage)
    deepScanRemotes(game:GetService("ReplicatedStorage"))
    
    -- Display results
    local yOffset = 5
    local resultTexts = {}
    
    if #scannedRemotes == 0 then
        local noResult = Instance.new("TextLabel")
        noResult.Size = UDim2.new(1, -10, 0, 30)
        noResult.Position = UDim2.new(0, 5, 0, yOffset)
        noResult.BackgroundTransparency = 1
        noResult.Text = "❌ No remotes found!"
        noResult.TextColor3 = Color3.fromRGB(255, 100, 100)
        noResult.TextSize = 12
        noResult.Font = Enum.Font.Gotham
        noResult.Parent = resultsList
        yOffset = yOffset + 35
    else
        for i, remote in pairs(scannedRemotes) do
            local remoteBtn = Instance.new("TextButton")
            remoteBtn.Size = UDim2.new(1, -10, 0, 40)
            remoteBtn.Position = UDim2.new(0, 5, 0, yOffset)
            remoteBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            remoteBtn.BackgroundTransparency = 0.2
            remoteBtn.Text = string.format("[%s] %s\n%s", remote.ClassName, remote.Name, remote.FullPath)
            remoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            remoteBtn.TextSize = 10
            remoteBtn.Font = Enum.Font.Gotham
            remoteBtn.TextWrapped = true
            remoteBtn.TextXAlignment = Enum.TextXAlignment.Left
            remoteBtn.Parent = resultsList
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = remoteBtn
            
            -- Store remote info for copy
            table.insert(resultTexts, string.format("Name: %s | Type: %s | Path: %s", remote.Name, remote.ClassName, remote.FullPath))
            
            -- Select remote button
            remoteBtn.MouseButton1Click:Connect(function()
                selectedRemote = allFunctions[i]
                remoteLabel.Text = "🎯 Selected: " .. (remote.Name ~= "" and remote.Name : "(empty)")
                remoteLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                statusLabel.Text = "Status: Remote selected!"
                
                -- Highlight selected
                for _, btn in pairs(resultsList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    end
                end
                remoteBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                
                -- Auto-switch to miner tab
                task.wait(0.5)
                minerTabBtn.MouseButton1Click:Click()
            end)
            
            yOffset = yOffset + 45
        end
    end
    
    resultsList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    -- Store logs for copying
    local logText = "=== REMOTE SCAN RESULTS ===\n"
    logText = logText .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    logText = logText .. "Total Remotes Found: " .. #scannedRemotes .. "\n\n"
    
    for i, remote in pairs(scannedRemotes) do
        logText = logText .. string.format("%d. Name: %s\n   Type: %s\n   Path: %s\n\n", i, remote.Name, remote.ClassName, remote.FullPath)
    end
    
    -- Copy button function
    copyLogsBtn.MouseButton1Click:Connect(function()
        local clipboardSuccess = pcall(function()
            setclipboard(logText)
        end)
        
        if clipboardSuccess then
            copyLogsBtn.Text = "✓ COPIED!"
            copyLogsBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            task.wait(1.5)
            copyLogsBtn.Text = "📋 COPY LOGS"
            copyLogsBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        else
            copyLogsBtn.Text = "❌ FAILED"
            task.wait(1)
            copyLogsBtn.Text = "📋 COPY LOGS"
        end
    end)
    
    scanBtn.Text = "✅ SCAN COMPLETE!"
    scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    statusLabel.Text = string.format("Status: Found %d remotes", #scannedRemotes)
    
    task.wait(2)
    scanBtn.Text = "🔍 START SCAN"
end

-- Remote selection from miner tab
remoteSelectBtn.MouseButton1Click:Connect(function()
    scanTabBtn.MouseButton1Click:Click()
    statusLabel.Text = "Status: Select a remote from the list"
end)

scanBtn.MouseButton1Click:Connect(performScan)

-- ========== MINING FUNCTIONS ==========
local function getAsteroidsInRange()
    local asteroids = {}
    local plots = workspace:FindFirstChild("Plots")
    
    if not plots then return asteroids end
    
    local targetPlot = plots:FindFirstChild("Plot1")
    if not targetPlot then return asteroids end
    
    local asteroidsFolder = targetPlot:FindFirstChild("Asteroids")
    if not asteroidsFolder then return asteroids end
    
    local playerPos = humanoidRootPart.Position
    
    for _, asteroid in pairs(asteroidsFolder:GetChildren()) do
        if minedAsteroids[asteroid.Name] and tick() - minedAsteroids[asteroid.Name] < 0.5 then
            continue
        end
        
        local primaryPart = asteroid:FindFirstChild("Primary") or asteroid:FindFirstChildWhichIsA("BasePart")
        if primaryPart and primaryPart.Parent then
            local distance = (playerPos - primaryPart.Position).Magnitude
            if distance <= currentRange then
                table.insert(asteroids, {
                    id = asteroid.Name,
                    folder = asteroid,
                    plot = targetPlot,
                    distance = distance
                })
            end
        end
    end
    
    table.sort(asteroids, function(a, b) return a.distance < b.distance end)
    return asteroids
end

local function mineAsteroid(plot, asteroidFolder)
    if not selectedRemote then
        -- Try auto-detect if no remote selected
        for _, remote in pairs(allFunctions) do
            local success = pcall(function()
                remote:InvokeServer(plot, asteroidFolder)
            end)
            if success then return true end
        end
        return false
    end
    
    -- Try different methods with selected remote
    local methods = {
        function() return selectedRemote:InvokeServer(plot, asteroidFolder) end,
        function() return selectedRemote:FireServer(plot, asteroidFolder) end,
        function() 
            local args = {plot, asteroidFolder}
            return selectedRemote:InvokeServer(unpack(args)) 
        end,
        function()
            local args = {plot, asteroidFolder}
            return selectedRemote:FireServer(unpack(args))
        end
    }
    
    for _, method in pairs(methods) do
        local success = pcall(method)
        if success then return true end
    end
    
    return false
end

-- Mining loop
local miningCoroutine = nil
local lastMineTime = 0

local function startMiningLoop()
    while isMining and RunService.Heartbeat:Wait() do
        if tick() - lastMineTime < currentDelay then
            continue
        end
        
        local nearbyAsteroids = getAsteroidsInRange()
        
        nearbyLabel.Text = "🪨 Nearby: " .. #nearbyAsteroids
        minedLabel.Text = "📊 Mined: " .. totalMined
        
        if #nearbyAsteroids > 0 then
            local target = nearbyAsteroids[1]
            statusLabel.Text = "Status: ⛏️ Mining..."
            
            local mined = mineAsteroid(target.plot, target.folder)
            
            if mined then
                totalMined = totalMined + 1
                lastMineTime = tick()
                minedAsteroids[target.id] = tick()
                minedLabel.Text = "📊 Mined: " .. totalMined
                
                -- Visual feedback
                toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.05)
                if isMining then
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
                end
            end
        else
            statusLabel.Text = "Status: No asteroids in range"
        end
        
        -- Cleanup
        for id, time in pairs(minedAsteroids) do
            if tick() - time > 2 then
                minedAsteroids[id] = nil
            end
        end
    end
end

local function toggleMining()
    if not selectedRemote and #allFunctions == 0 then
        statusLabel.Text = "Status: Scan for remotes first!"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
        task.wait(1)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        return
    end
    
    isMining = not isMining
    
    if isMining then
        toggleBtn.Text = "⏹️ STOP MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        statusLabel.Text = "Status: Mining active"
        
        if miningCoroutine then
            coroutine.close(miningCoroutine)
        end
        miningCoroutine = coroutine.create(startMiningLoop)
        coroutine.resume(miningCoroutine)
    else
        toggleBtn.Text = "▶️ START MINING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.Text = "Status: Stopped"
        
        if miningCoroutine then
            coroutine.close(miningCoroutine)
            miningCoroutine = nil
        end
    end
end

toggleBtn.MouseButton1Click:Connect(toggleMining)
closeBtn.MouseButton1Click:Connect(function()
    isMining = false
    screenGui:Destroy()
    if miningCoroutine then
        coroutine.close(miningCoroutine)
    end
end)

-- Auto-scan on startup
task.wait(0.5)
performScan()

print("=== REMOTE SCANNER & MINER LOADED ===")
print("Scanning for hidden remotes...")
