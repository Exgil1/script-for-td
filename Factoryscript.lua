-- Simple Remote Logger - Safe Version
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Create simple GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleLogger"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "📋 REMOTE LOGGER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Start Button
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.8, 0, 0, 45)
startBtn.Position = UDim2.new(0.1, 0, 0.12, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
startBtn.Text = "▶️ START LOGGING"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 14
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = mainFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startBtn

-- Copy Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.8, 0, 0, 40)
copyBtn.Position = UDim2.new(0.1, 0, 0.22, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyBtn.Text = "📋 COPY LOGS"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 14
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Not logging"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Logs Frame
local logsFrame = Instance.new("ScrollingFrame")
logsFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
logsFrame.Position = UDim2.new(0.05, 0, 0.42, 0)
logsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
logsFrame.BackgroundTransparency = 0.3
logsFrame.BorderSizePixel = 0
logsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logsFrame.ScrollBarThickness = 4
logsFrame.Parent = mainFrame

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 8)
logsCorner.Parent = logsFrame

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

-- Store logs
local logs = {}
local captured = {
    mining = nil,
    rebirth = nil,
    upgrade = nil,
    miningArgs = nil,
    rebirthArgs = nil,
    upgradeArgs = nil
}

local function addLog(text, color)
    table.insert(logs, 1, {text = text, color = color, time = os.date("%H:%M:%S")})
    
    if #logs > 50 then table.remove(logs) end
    
    -- Update display
    for _, child in pairs(logsFrame:GetChildren()) do
        child:Destroy()
    end
    
    local yOffset = 5
    for i, log in pairs(logs) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Size = UDim2.new(1, -10, 0, 30)
        logLabel.Position = UDim2.new(0, 5, 0, yOffset)
        logLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        logLabel.BackgroundTransparency = 0.3
        logLabel.Text = "[" .. log.time .. "] " .. log.text
        logLabel.TextColor3 = log.color or Color3.fromRGB(200, 200, 200)
        logLabel.TextSize = 10
        logLabel.Font = Enum.Font.Gotham
        logLabel.TextWrapped = true
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = logsFrame
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 4)
        logCorner.Parent = logLabel
        
        yOffset = yOffset + 35
    end
    
    logsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Safe hooking function
local isLogging = false
local hookedRemotes = {}

local function startLogging()
    if isLogging then
        addLog("Already logging!", Color3.fromRGB(255, 200, 100))
        return
    end
    
    addLog("Starting remote logger...", Color3.fromRGB(100, 255, 100))
    addLog("Now perform actions in-game:", Color3.fromRGB(255, 200, 100))
    addLog("  • Mine an asteroid", Color3.fromRGB(200, 200, 200))
    addLog("  • Click Rebirth", Color3.fromRGB(200, 200, 200))
    addLog("  • Click Upgrade", Color3.fromRGB(200, 200, 200))
    
    -- Get the Functions folder
    local communication = ReplicatedStorage:FindFirstChild("Communication")
    if not communication then
        addLog("Communication folder not found!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local functions = communication:FindFirstChild("Functions")
    if not functions then
        addLog("Functions folder not found!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Get all children (including empty named ones)
    local allRemotes = {}
    for _, child in pairs(functions:GetChildren()) do
        if child:IsA("RemoteFunction") then
            table.insert(allRemotes, child)
        end
    end
    
    addLog("Found " .. #allRemotes .. " remote functions", Color3.fromRGB(100, 200, 255))
    
    -- Hook each remote safely
    for index, remote in pairs(allRemotes) do
        -- Store original function
        local original = remote.InvokeServer
        
        -- Create new function
        remote.InvokeServer = function(...)
            local args = {...}
            
            -- Convert args to readable string
            local argsStr = {}
            for i, arg in pairs(args) do
                if typeof(arg) == "Instance" then
                    argsStr[i] = "[" .. arg.ClassName .. "]"
                elseif type(arg) == "string" then
                    argsStr[i] = '"' .. arg .. '"'
                else
                    argsStr[i] = tostring(arg)
                end
            end
            
            local fullArgs = table.concat(argsStr, ", ")
            local remoteName = remote.Name
            if remoteName == "" then
                remoteName = "(EMPTY)"
            end
            
            -- Detect what type of remote this is
            local remoteType = "unknown"
            local lowerArgs = string.lower(fullArgs)
            
            -- Check for mining related keywords
            if string.find(lowerArgs, "asteroid") or string.find(lowerArgs, "mine") or string.find(lowerArgs, "ore") then
                remoteType = "mining"
                if not captured.mining then
                    captured.mining = index
                    captured.miningArgs = argsStr
                    addLog("🎯 MINING REMOTE FOUND! Index #" .. index, Color3.fromRGB(100, 255, 100))
                    addLog("   Args: " .. fullArgs, Color3.fromRGB(150, 255, 150))
                end
            end
            
            -- Check for rebirth related keywords
            if string.find(lowerArgs, "rebirth") or string.find(lowerArgs, "prestige") or string.find(lowerArgs, "reset") then
                remoteType = "rebirth"
                if not captured.rebirth then
                    captured.rebirth = index
                    captured.rebirthArgs = argsStr
                    addLog("🎯 REBIRTH REMOTE FOUND! Index #" .. index, Color3.fromRGB(200, 100, 255))
                    addLog("   Args: " .. fullArgs, Color3.fromRGB(220, 150, 255))
                end
            end
            
            -- Check for upgrade related keywords
            if string.find(lowerArgs, "upgrade") or string.find(lowerArgs, "level") or string.find(lowerArgs, "improve") then
                remoteType = "upgrade"
                if not captured.upgrade then
                    captured.upgrade = index
                    captured.upgradeArgs = argsStr
                    addLog("🎯 UPGRADE REMOTE FOUND! Index #" .. index, Color3.fromRGB(255, 200, 100))
                    addLog("   Args: " .. fullArgs, Color3.fromRGB(255, 220, 150))
                end
            end
            
            -- Log the call
            if remoteType == "unknown" then
                addLog("[#" .. index .. "] " .. remoteName .. "(" .. fullArgs .. ")", Color3.fromRGB(150, 150, 150))
            end
            
            -- Update status
            local statusText = "Status: Logging...\n"
            statusText = statusText .. "⛏️ Mining: " .. (captured.mining and "#" .. captured.mining or "?") .. "\n"
            statusText = statusText .. "🔄 Rebirth: " .. (captured.rebirth and "#" .. captured.rebirth or "?") .. "\n"
            statusText = statusText .. "⬆️ Upgrade: " .. (captured.upgrade and "#" .. captured.upgrade or "?")
            statusLabel.Text = statusText
            
            -- Call original function
            return original(...)
        end
    end
    
    isLogging = true
    startBtn.Text = "⏸️ STOP LOGGING"
    startBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

local function stopLogging()
    if not isLogging then
        return
    end
    
    isLogging = false
    startBtn.Text = "▶️ START LOGGING"
    startBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    statusLabel.Text = "Status: Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    addLog("Logging stopped", Color3.fromRGB(255, 200, 100))
end

-- Toggle logging
local function toggleLogging()
    if isLogging then
        stopLogging()
    else
        startLogging()
    end
end

-- Copy logs
local function copyLogs()
    local text = "=== REMOTE LOGS ===\n"
    text = text .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
    
    text = text .. "=== CAPTURED REMOTES ===\n\n"
    
    if captured.mining then
        text = text .. "⛏️ MINING REMOTE:\n"
        text = text .. "   Index: " .. captured.mining .. "\n"
        text = text .. "   Arguments: " .. table.concat(captured.miningArgs or {}, ", ") .. "\n"
        text = text .. "   Code:\n"
        text = text .. "   local remote = Functions:GetChildren()[" .. captured.mining .. "]\n"
        text = text .. "   remote:InvokeServer(plot, asteroid)\n\n"
    else
        text = text .. "⛏️ MINING REMOTE: Not detected yet\n\n"
    end
    
    if captured.rebirth then
        text = text .. "🔄 REBIRTH REMOTE:\n"
        text = text .. "   Index: " .. captured.rebirth .. "\n"
        text = text .. "   Arguments: " .. table.concat(captured.rebirthArgs or {}, ", ") .. "\n"
        text = text .. "   Code:\n"
        text = text .. "   local remote = Functions:GetChildren()[" .. captured.rebirth .. "]\n"
        text = text .. "   remote:InvokeServer()\n\n"
    else
        text = text .. "🔄 REBIRTH REMOTE: Not detected yet\n\n"
    end
    
    if captured.upgrade then
        text = text .. "⬆️ UPGRADE REMOTE:\n"
        text = text .. "   Index: " .. captured.upgrade .. "\n"
        text = text .. "   Arguments: " .. table.concat(captured.upgradeArgs or {}, ", ") .. "\n"
        text = text .. "   Code:\n"
        text = text .. "   local remote = Functions:GetChildren()[" .. captured.upgrade .. "]\n"
        text = text .. "   remote:InvokeServer()\n\n"
    else
        text = text .. "⬆️ UPGRADE REMOTE: Not detected yet\n\n"
    end
    
    text = text .. "=== ALL LOGS ===\n"
    for i, log in pairs(logs) do
        text = text .. "[" .. log.time .. "] " .. log.text .. "\n"
    end
    
    local success = pcall(function()
        setclipboard(text)
    end)
    
    if success then
        addLog("✅ Logs copied to clipboard!", Color3.fromRGB(100, 255, 100))
        copyBtn.Text = "✓ COPIED!"
        task.wait(1.5)
        copyBtn.Text = "📋 COPY LOGS"
    else
        addLog("❌ Failed to copy!", Color3.fromRGB(255, 100, 100))
    end
end

-- Button connections
startBtn.MouseButton1Click:Connect(toggleLogging)
copyBtn.MouseButton1Click:Connect(copyLogs)
closeBtn.MouseButton1Click:Connect(function()
    if isLogging then stopLogging() end
    screenGui:Destroy()
end)

print("=== SIMPLE REMOTE LOGGER LOADED ===")
print("Press START LOGGING then perform actions in-game")
print("The script will detect mining, rebirth, and upgrade remotes")
