-- Complete Hidden Remote Scanner & Logger
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Store all found remotes and their usage
local foundRemotes = {
    functions = {},
    events = {},
    usageLogs = {}
}

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HiddenRemoteScanner"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 550)
mainFrame.Position = UDim2.new(0.5, -175, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar (draggable)
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
title.Text = "🔍 HIDDEN REMOTE SCANNER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Tab Buttons
local tabs = {}
local currentTab = "scan"

local scanTabBtn = Instance.new("TextButton")
scanTabBtn.Size = UDim2.new(0.33, 0, 0, 35)
scanTabBtn.Position = UDim2.new(0, 0, 0, 45)
scanTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
scanTabBtn.Text = "📡 SCAN"
scanTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanTabBtn.TextSize = 12
scanTabBtn.Font = Enum.Font.GothamBold
scanTabBtn.Parent = mainFrame

local hookTabBtn = Instance.new("TextButton")
hookTabBtn.Size = UDim2.new(0.34, 0, 0, 35)
hookTabBtn.Position = UDim2.new(0.33, 0, 0, 45)
hookTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hookTabBtn.Text = "🎣 HOOK"
hookTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
hookTabBtn.TextSize = 12
hookTabBtn.Font = Enum.Font.GothamBold
hookTabBtn.Parent = mainFrame

local resultsTabBtn = Instance.new("TextButton")
resultsTabBtn.Size = UDim2.new(0.33, 0, 0, 35)
resultsTabBtn.Position = UDim2.new(0.67, 0, 0, 45)
resultsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
resultsTabBtn.Text = "📋 RESULTS"
resultsTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
resultsTabBtn.TextSize = 12
resultsTabBtn.Font = Enum.Font.GothamBold
resultsTabBtn.Parent = mainFrame

-- Content Frames
local scanFrame = Instance.new("ScrollingFrame")
scanFrame.Size = UDim2.new(1, -10, 1, -90)
scanFrame.Position = UDim2.new(0, 5, 0, 85)
scanFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scanFrame.BackgroundTransparency = 0.2
scanFrame.BorderSizePixel = 0
scanFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scanFrame.ScrollBarThickness = 4
scanFrame.Visible = true
scanFrame.Parent = mainFrame

local hookFrame = Instance.new("ScrollingFrame")
hookFrame.Size = UDim2.new(1, -10, 1, -90)
hookFrame.Position = UDim2.new(0, 5, 0, 85)
hookFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hookFrame.BackgroundTransparency = 0.2
hookFrame.BorderSizePixel = 0
hookFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
hookFrame.ScrollBarThickness = 4
hookFrame.Visible = false
hookFrame.Parent = mainFrame

local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, -10, 1, -90)
resultsFrame.Position = UDim2.new(0, 5, 0, 85)
resultsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
resultsFrame.BackgroundTransparency = 0.2
resultsFrame.BorderSizePixel = 0
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 4
resultsFrame.Visible = false
resultsFrame.Parent = mainFrame

-- Scan Tab Content
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 50)
scanBtn.Position = UDim2.new(0.05, 0, 0, 5)
scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
scanBtn.Text = "🔍 START DEEP SCAN"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 14
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = scanFrame

local scanBtnCorner = Instance.new("UICorner")
scanBtnCorner.CornerRadius = UDim.new(0, 8)
scanBtnCorner.Parent = scanBtn

local scanStatus = Instance.new("TextLabel")
scanStatus.Size = UDim2.new(0.9, 0, 0, 30)
scanStatus.Position = UDim2.new(0.05, 0, 0.12, 0)
scanStatus.BackgroundTransparency = 1
scanStatus.Text = "Ready to scan"
scanStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
scanStatus.TextSize = 11
scanStatus.Font = Enum.Font.Gotham
scanStatus.Parent = scanFrame

local scanResults = Instance.new("ScrollingFrame")
scanResults.Size = UDim2.new(1, 0, 1, -160)
scanResults.Position = UDim2.new(0, 0, 0, 160)
scanResults.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
scanResults.BackgroundTransparency = 0.2
scanResults.BorderSizePixel = 0
scanResults.CanvasSize = UDim2.new(0, 0, 0, 0)
scanResults.ScrollBarThickness = 4
scanResults.Parent = scanFrame

-- Hook Tab Content
local startHookBtn = Instance.new("TextButton")
startHookBtn.Size = UDim2.new(0.9, 0, 0, 50)
startHookBtn.Position = UDim2.new(0.05, 0, 0, 5)
startHookBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
startHookBtn.Text = "🎣 START REMOTE HOOKING"
startHookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startHookBtn.TextSize = 14
startHookBtn.Font = Enum.Font.GothamBold
startHookBtn.Parent = hookFrame

local startHookCorner = Instance.new("UICorner")
startHookCorner.CornerRadius = UDim.new(0, 8)
startHookCorner.Parent = startHookBtn

local hookStatus = Instance.new("TextLabel")
hookStatus.Size = UDim2.new(0.9, 0, 0, 40)
hookStatus.Position = UDim2.new(0.05, 0, 0.12, 0)
hookStatus.BackgroundTransparency = 1
hookStatus.Text = "Not hooked\nPerform actions in-game to detect remotes"
hookStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
hookStatus.TextSize = 11
hookStatus.Font = Enum.Font.Gotham
hookStatus.TextWrapped = true
hookStatus.Parent = hookFrame

local hookLogs = Instance.new("ScrollingFrame")
hookLogs.Size = UDim2.new(1, 0, 1, -170)
hookLogs.Position = UDim2.new(0, 0, 0, 170)
hookLogs.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
hookLogs.BackgroundTransparency = 0.2
hookLogs.BorderSizePixel = 0
hookLogs.CanvasSize = UDim2.new(0, 0, 0, 0)
hookLogs.ScrollBarThickness = 4
hookLogs.Parent = hookFrame

-- Results Tab Content
local copyAllBtn = Instance.new("TextButton")
copyAllBtn.Size = UDim2.new(0.9, 0, 0, 45)
copyAllBtn.Position = UDim2.new(0.05, 0, 0, 5)
copyAllBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyAllBtn.Text = "📋 COPY ALL LOGS"
copyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyAllBtn.TextSize = 14
copyAllBtn.Font = Enum.Font.GothamBold
copyAllBtn.Parent = resultsFrame

local copyAllCorner = Instance.new("UICorner")
copyAllCorner.CornerRadius = UDim.new(0, 8)
copyAllCorner.Parent = copyAllBtn

local copyMiningBtn = Instance.new("TextButton")
copyMiningBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyMiningBtn.Position = UDim2.new(0.05, 0, 0.11, 0)
copyMiningBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
copyMiningBtn.Text = "⛏️ COPY MINING REMOTE"
copyMiningBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyMiningBtn.TextSize = 12
copyMiningBtn.Font = Enum.Font.Gotham
copyMiningBtn.Parent = resultsFrame

local copyMiningCorner = Instance.new("UICorner")
copyMiningCorner.CornerRadius = UDim.new(0, 6)
copyMiningCorner.Parent = copyMiningBtn

local copyRebirthBtn = Instance.new("TextButton")
copyRebirthBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyRebirthBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
copyRebirthBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
copyRebirthBtn.Text = "🔄 COPY REBIRTH REMOTE"
copyRebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyRebirthBtn.TextSize = 12
copyRebirthBtn.Font = Enum.Font.Gotham
copyRebirthBtn.Parent = resultsFrame

local copyRebirthCorner = Instance.new("UICorner")
copyRebirthCorner.CornerRadius = UDim.new(0, 6)
copyRebirthCorner.Parent = copyRebirthBtn

local copyUpgradeBtn = Instance.new("TextButton")
copyUpgradeBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyUpgradeBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
copyUpgradeBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
copyUpgradeBtn.Text = "⬆️ COPY UPGRADE REMOTE"
copyUpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyUpgradeBtn.TextSize = 12
copyUpgradeBtn.Font = Enum.Font.Gotham
copyUpgradeBtn.Parent = resultsFrame

local copyUpgradeCorner = Instance.new("UICorner")
copyUpgradeCorner.CornerRadius = UDim.new(0, 6)
copyUpgradeCorner.Parent = copyUpgradeBtn

local resultsDisplay = Instance.new("ScrollingFrame")
resultsDisplay.Size = UDim2.new(1, 0, 1, -220)
resultsDisplay.Position = UDim2.new(0, 0, 0, 220)
resultsDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resultsDisplay.BackgroundTransparency = 0.2
resultsDisplay.BorderSizePixel = 0
resultsDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsDisplay.ScrollBarThickness = 4
resultsDisplay.Parent = resultsFrame

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

-- Tab switching
scanTabBtn.MouseButton1Click:Connect(function()
    currentTab = "scan"
    scanFrame.Visible = true
    hookFrame.Visible = false
    resultsFrame.Visible = false
    scanTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    hookTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    resultsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    scanTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hookTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    resultsTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

hookTabBtn.MouseButton1Click:Connect(function()
    currentTab = "hook"
    scanFrame.Visible = false
    hookFrame.Visible = true
    resultsFrame.Visible = false
    hookTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scanTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    resultsTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    hookTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    resultsTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

resultsTabBtn.MouseButton1Click:Connect(function()
    currentTab = "results"
    scanFrame.Visible = false
    hookFrame.Visible = false
    resultsFrame.Visible = true
    resultsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scanTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    hookTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    resultsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    hookTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateResultsDisplay()
end)

-- Deep Scan Function
local function deepScan(parent, depth, results)
    depth = depth or 0
    if depth > 15 then return end
    
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("RemoteFunction") then
            table.insert(results.functions, {
                name = child.Name ~= "" and child.Name : "(EMPTY)",
                path = child:GetFullName(),
                object = child,
                index = #results.functions + 1
            })
        elseif child:IsA("RemoteEvent") then
            table.insert(results.events, {
                name = child.Name ~= "" and child.Name : "(EMPTY)",
                path = child:GetFullName(),
                object = child,
                index = #results.events + 1
            })
        end
        
        pcall(function() deepScan(child, depth + 1, results) end)
    end
end

local function performDeepScan()
    scanStatus.Text = "Scanning... Please wait"
    scanStatus.TextColor3 = Color3.fromRGB(255, 152, 0)
    scanBtn.Text = "🔄 SCANNING..."
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    
    -- Clear previous results
    for _, child in pairs(scanResults:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local scanResults_data = {functions = {}, events = {}}
    
    -- Perform deep scan
    task.wait()
    deepScan(ReplicatedStorage, 0, scanResults_data)
    deepScan(game:GetService("ReplicatedStorage"), 0, scanResults_data)
    
    -- Store in global
    foundRemotes.functions = scanResults_data.functions
    foundRemotes.events = scanResults_data.events
    
    -- Display results
    local yOffset = 5
    local function addResult(text, color, isHeader)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, isHeader and 25 or 20)
        label.Position = UDim2.new(0, 5, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextSize = isHeader and 12 or 10
        label.Font = isHeader and Enum.Font.GothamBold or Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = scanResults
        yOffset = yOffset + (isHeader and 28 or 22)
        return label
    end
    
    addResult("=== REMOTE FUNCTIONS FOUND: " .. #scanResults_data.functions .. " ===", Color3.fromRGB(100, 200, 100), true)
    for i, remote in pairs(scanResults_data.functions) do
        addResult(string.format("%d. %s [%s]", i, remote.name, remote.path), Color3.fromRGB(200, 200, 200), false)
    end
    
    yOffset = yOffset + 10
    addResult("=== REMOTE EVENTS FOUND: " .. #scanResults_data.events .. " ===", Color3.fromRGB(100, 200, 255), true)
    for i, remote in pairs(scanResults_data.events) do
        addResult(string.format("%d. %s [%s]", i, remote.name, remote.path), Color3.fromRGB(200, 200, 200), false)
    end
    
    scanResults.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    
    scanStatus.Text = string.format("✅ Scan complete! Found %d functions, %d events", #scanResults_data.functions, #scanResults_data.events)
    scanStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    scanBtn.Text = "🔍 SCAN COMPLETE"
    
    task.wait(2)
    scanBtn.Text = "🔍 START DEEP SCAN"
    scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
end

scanBtn.MouseButton1Click:Connect(performDeepScan)

-- Remote Hooking System
local hooked = false
local hookLogsList = {}

local function addHookLog(text, type)
    table.insert(hookLogsList, {text = text, type = type, time = os.date("%H:%M:%S")})
    
    -- Update display
    for _, child in pairs(hookLogs:GetChildren()) do
        child:Destroy()
    end
    
    local yOffset = 5
    for i, log in pairs(hookLogsList) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Size = UDim2.new(1, -10, 0, 35)
        logLabel.Position = UDim2.new(0, 5, 0, yOffset)
        logLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        logLabel.BackgroundTransparency = 0.3
        logLabel.Text = string.format("[%s] %s", log.time, log.text)
        logLabel.TextColor3 = log.type == "mining" and Color3.fromRGB(100, 255, 100) or 
                              (log.type == "rebirth" and Color3.fromRGB(200, 100, 255) or
                              (log.type == "upgrade" and Color3.fromRGB(255, 200, 100) or
                              Color3.fromRGB(200, 200, 200)))
        logLabel.TextSize = 10
        logLabel.Font = Enum.Font.Gotham
        logLabel.TextWrapped = true
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = hookLogs
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 4)
        logCorner.Parent = logLabel
        
        yOffset = yOffset + 40
    end
    
    hookLogs.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

local function startRemoteHooking()
    if hooked then
        addHookLog("Hooking already active!", "info")
        return
    end
    
    addHookLog("Starting remote hooking...", "info")
    addHookLog("Perform actions in-game (mine, rebirth, upgrade)", "info")
    addHookLog("The script will detect which remotes are used", "info")
    
    local Communication = ReplicatedStorage:WaitForChild("Communication")
    local Functions = Communication:WaitForChild("Functions")
    local Events = Communication:WaitForChild("Events")
    
    -- Hook all empty remotes
    local emptyFunctions = {}
    local emptyEvents = {}
    
    for _, child in pairs(Functions:GetChildren()) do
        if child.Name == "" and child:IsA("RemoteFunction") then
            table.insert(emptyFunctions, child)
        end
    end
    
    for _, child in pairs(Events:GetChildren()) do
        if child.Name == "" and child:IsA("RemoteEvent") then
            table.insert(emptyEvents, child)
        end
    end
    
    addHookLog(string.format("Found %d empty functions, %d empty events to monitor", #emptyFunctions, #emptyEvents), "info")
    
    -- Hook functions
    for i, remote in pairs(emptyFunctions) do
        local originalInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local argsStr = {}
            local remoteType = "unknown"
            
            for _, arg in pairs(args) do
                if type(arg) == "string" then
                    table.insert(argsStr, arg)
                    if string.find(arg:lower(), "mine") or string.find(arg:lower(), "ore") or string.find(arg:lower(), "asteroid") then
                        remoteType = "mining"
                    elseif string.find(arg:lower(), "rebirth") or string.find(arg:lower(), "prestige") then
                        remoteType = "rebirth"
                    elseif string.find(arg:lower(), "upgrade") or string.find(arg:lower(), "level") then
                        remoteType = "upgrade"
                    end
                elseif typeof(arg) == "Instance" then
                    local className = arg.ClassName
                    table.insert(argsStr, "[" .. className .. "]")
                    if className == "Folder" and arg.Name:match("^{.*}$") then
                        remoteType = "mining" -- Asteroid folder
                    end
                else
                    table.insert(argsStr, tostring(arg))
                end
            end
            
            local logMsg = string.format("📡 RemoteFunction #%d called! Args: %s", i, table.concat(argsStr, ", "))
            addHookLog(logMsg, remoteType)
            
            -- Store the remote type for later
            if remoteType == "mining" then
                foundRemotes.miningRemote = {index = i, remote = remote, args = argsStr}
            elseif remoteType == "rebirth" then
                foundRemotes.rebirthRemote = {index = i, remote = remote, args = argsStr}
            elseif remoteType == "upgrade" then
                foundRemotes.upgradeRemote = {index = i, remote = remote, args = argsStr}
            end
            
            return originalInvoke(self, ...)
        end
    end
    
    -- Hook events
    for i, remote in pairs(emptyEvents) do
        local originalFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            local argsStr = {}
            local remoteType = "unknown"
            
            for _, arg in pairs(args) do
                if type(arg) == "string" then
                    table.insert(argsStr, arg)
                    if string.find(arg:lower(), "mine") or string.find(arg:lower(), "ore") then
                        remoteType = "mining"
                    elseif string.find(arg:lower(), "rebirth") or string.find(arg:lower(), "prestige") then
                        remoteType = "rebirth"
                    elseif string.find(arg:lower(), "upgrade") or string.find(arg:lower(), "level") then
                        remoteType = "upgrade"
                    end
                elseif typeof(arg) == "Instance" then
                    table.insert(argsStr, "[" .. arg.ClassName .. "]")
                else
                    table.insert(argsStr, tostring(arg))
                end
            end
            
            local logMsg = string.format("📡 RemoteEvent #%d fired! Args: %s", i, table.concat(argsStr, ", "))
            addHookLog(logMsg, remoteType)
            
            return originalFire(self, ...)
        end
    end
    
    hooked = true
    startHookBtn.Text = "🎣 HOOKING ACTIVE"
    startHookBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    hookStatus.Text = "✅ Hooking active!\nPerform actions in-game to detect remotes"
    hookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
end

startHookBtn.MouseButton1Click:Connect(startRemoteHooking)

-- Update results display
local function updateResultsDisplay()
    for _, child in pairs(resultsDisplay:GetChildren()) do
        child:Destroy()
    end
    
    local yOffset = 5
    local function addResult(text, color, size)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, size or 25)
        label.Position = UDim2.new(0, 5, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextSize = size or 12
        label.Font = Enum.Font.Gotham
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = resultsDisplay
        yOffset = yOffset + (size or 25) + 5
        return label
    end
    
    addResult("=== DETECTED REMOTES ===", Color3.fromRGB(255, 200, 100), 14)
    
    if foundRemotes.miningRemote then
        addResult("⛏️ MINING REMOTE:", Color3.fromRGB(100, 255, 100), 12)
        addResult(string.format("   Index: %d", foundRemotes.miningRemote.index), Color3.fromRGB(200, 200, 200), 10)
        addResult(string.format("   Args: %s", table.concat(foundRemotes.miningRemote.args, ", ")), Color3.fromRGB(150, 150, 150), 10)
        addResult("", Color3.fromRGB(255, 255, 255), 5)
    else
        addResult("⛏️ MINING REMOTE: Not yet detected", Color3.fromRGB(255, 100, 100), 11)
        addResult("   Perform a mining action while hooked!", Color3.fromRGB(150, 150, 150), 10)
        addResult("", Color3.fromRGB(255, 255, 255), 5)
    end
    
    if foundRemotes.rebirthRemote then
        addResult("🔄 REBIRTH REMOTE:", Color3.fromRGB(200, 100, 255), 12)
        addResult(string.format("   Index: %d", foundRemotes.rebirthRemote.index), Color3.fromRGB(200, 200, 200), 10)
        addResult(string.format("   Args: %s", table.concat(foundRemotes.rebirthRemote.args, ", ")), Color3.fromRGB(150, 150, 150), 10)
        addResult("", Color3.fromRGB(255, 255, 255), 5)
    else
        addResult("🔄 REBIRTH REMOTE: Not yet detected", Color3.fromRGB(255, 100, 100), 11)
        addResult("   Perform a rebirth action while hooked!", Color3.fromRGB(150, 150, 150), 10)
        addResult("", Color3.fromRGB(255, 255, 255), 5)
    end
    
    if foundRemotes.upgradeRemote then
        addResult("⬆️ UPGRADE REMOTE:", Color3.fromRGB(255, 200, 100), 12)
        addResult(string.format("   Index: %d", foundRemotes.upgradeRemote.index), Color3.fromRGB(200, 200, 200), 10)
        addResult(string.format("   Args: %s", table.concat(foundRemotes.upgradeRemote.args, ", ")), Color3.fromRGB(150, 150, 150), 10)
    else
        addResult("⬆️ UPGRADE REMOTE: Not yet detected", Color3.fromRGB(255, 100, 100), 11)
        addResult("   Perform an upgrade action while hooked!", Color3.fromRGB(150, 150, 150), 10)
    end
    
    resultsDisplay.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
end

-- Copy functions
local function copyToClipboard(text, successMsg)
    local success = pcall(function()
        setclipboard(text)
    end)
    
    if success then
        hookStatus.Text = "✅ " .. successMsg
        hookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(2)
        if hooked then
            hookStatus.Text = "✅ Hooking active!\nPerform actions in-game to detect remotes"
        else
            hookStatus.Text = "Not hooked\nPerform actions in-game to detect remotes"
        end
    else
        hookStatus.Text = "❌ Failed to copy!"
        hookStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

copyAllBtn.MouseButton1Click:Connect(function()
    local logText = "=== HIDDEN REMOTE SCAN RESULTS ===\n"
    logText = logText .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
    
    logText = logText .. "=== MINING REMOTE ===\n"
    if foundRemotes.miningRemote then
        logText = logText .. "Index: " .. foundRemotes.miningRemote.index .. "\n"
        logText = logText .. "Args: " .. table.concat(foundRemotes.miningRemote.args, ", ") .. "\n"
        logText = logText .. "Code: local miningRemote = Functions:GetChildren()[" .. foundRemotes.miningRemote.index .. "]\n"
    else
        logText = logText .. "Not detected yet\n"
    end
    
    logText = logText .. "\n=== REBIRTH REMOTE ===\n"
    if foundRemotes.rebirthRemote then
        logText = logText .. "Index: " .. foundRemotes.rebirthRemote.index .. "\n"
        logText = logText .. "Args: " .. table.concat(foundRemotes.rebirthRemote.args, ", ") .. "\n"
        logText = logText .. "Code: local rebirthRemote = Functions:GetChildren()[" .. foundRemotes.rebirthRemote.index .. "]\n"
    else
        logText = logText .. "Not detected yet\n"
    end
    
    logText = logText .. "\n=== UPGRADE REMOTE ===\n"
    if foundRemotes.upgradeRemote then
        logText = logText .. "Index: " .. foundRemotes.upgradeRemote.index .. "\n"
        logText = logText .. "Args: " .. table.concat(foundRemotes.upgradeRemote.args, ", ") .. "\n"
        logText = logText .. "Code: local upgradeRemote = Functions:GetChildren()[" .. foundRemotes.upgradeRemote.index .. "]\n"
    else        logText = logText .. "Not detected yet\n"
    end
    
    logText = logText .. "\n=== HOOK LOGS ===\n"
    for i, log in pairs(hookLogsList) do
        logText = logText .. "[" .. log.time .. "] " .. log.text .. "\n"
    end
    
    copyToClipboard(logText, "All logs copied!")
end)

copyMiningBtn.MouseButton1Click:Connect(function()
    if foundRemotes.miningRemote then
        local code = string.format([[
-- Mining Remote
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local miningRemote = Functions:GetChildren()[%d]

-- Usage:
-- miningRemote:InvokeServer(plot, asteroid)
]], foundRemotes.miningRemote.index)
        copyToClipboard(code, "Mining remote code copied!")
    else
        copyToClipboard("", "No mining remote detected yet!")
    end
end)

copyRebirthBtn.MouseButton1Click:Connect(function()
    if foundRemotes.rebirthRemote then
        local code = string.format([[
-- Rebirth Remote
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local rebirthRemote = Functions:GetChildren()[%d]

-- Usage:
-- rebirthRemote:InvokeServer(args)
]], foundRemotes.rebirthRemote.index)
        copyToClipboard(code, "Rebirth remote code copied!")
    else
        copyToClipboard("", "No rebirth remote detected yet!")
    end
end)

copyUpgradeBtn.MouseButton1Click:Connect(function()
    if foundRemotes.upgradeRemote then
        local code = string.format([[
-- Upgrade Remote
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local upgradeRemote = Functions:GetChildren()[%d]

-- Usage:
-- upgradeRemote:InvokeServer(args)
]], foundRemotes.upgradeRemote.index)
        copyToClipboard(code, "Upgrade remote code copied!")
    else
        copyToClipboard("", "No upgrade remote detected yet!")
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Auto scan on startup
task.wait(0.5)
performDeepScan()

print("=== HIDDEN REMOTE SCANNER LOADED ===")
print("Features:")
print("📡 SCAN tab - Find all hidden remotes")
print("🎣 HOOK tab - Detect which remotes are used for actions")
print("📋 RESULTS tab - Copy remote codes for mining/rebirth/upgrade")
print("")
print("To find rebirth/upgrade remotes:")
print("1. Go to HOOK tab")
print("2. Press START REMOTE HOOKING")
print("3. Perform rebirth/upgrade in-game")
print("4. Check RESULTS tab for detected remotes")
