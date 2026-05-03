-- ULTIMATE REMOTE CAPTURE SYSTEM - Catches ALL hidden remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteCaptureSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.5, -190, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
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
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 REMOTE CAPTURE SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Control Buttons
local captureBtn = Instance.new("TextButton")
captureBtn.Size = UDim2.new(0.44, 0, 0, 45)
captureBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
captureBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
captureBtn.Text = "▶️ START CAPTURE"
captureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
captureBtn.TextSize = 12
captureBtn.Font = Enum.Font.GothamBold
captureBtn.Parent = mainFrame

local captureCorner = Instance.new("UICorner")
captureCorner.CornerRadius = UDim.new(0, 6)
captureCorner.Parent = captureBtn

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.44, 0, 0, 45)
clearBtn.Position = UDim2.new(0.53, 0, 0.1, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
clearBtn.Text = "🗑️ CLEAR LOGS"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 12
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn

-- Copy All Button
local copyAllBtn = Instance.new("TextButton")
copyAllBtn.Size = UDim2.new(0.94, 0, 0, 40)
copyAllBtn.Position = UDim2.new(0.03, 0, 0.19, 0)
copyAllBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyAllBtn.Text = "📋 COPY ALL CAPTURED REMOTES"
copyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyAllBtn.TextSize = 12
copyAllBtn.Font = Enum.Font.GothamBold
copyAllBtn.Parent = mainFrame

local copyAllCorner = Instance.new("UICorner")
copyAllCorner.CornerRadius = UDim.new(0, 6)
copyAllCorner.Parent = copyAllBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.94, 0, 0, 35)
statusLabel.Position = UDim2.new(0.03, 0, 0.27, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusLabel.BackgroundTransparency = 0.5
statusLabel.Text = "Status: ⚪ IDLE"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = statusLabel

-- Capture Logs Frame
local logsFrame = Instance.new("Frame")
logsFrame.Size = UDim2.new(0.94, 0, 0.55, 0)
logsFrame.Position = UDim2.new(0.03, 0, 0.33, 0)
logsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
logsFrame.BackgroundTransparency = 0.3
logsFrame.BorderSizePixel = 0
logsFrame.Parent = mainFrame

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 6)
logsCorner.Parent = logsFrame

local logsList = Instance.new("ScrollingFrame")
logsList.Size = UDim2.new(1, -10, 1, -10)
logsList.Position = UDim2.new(0, 5, 0, 5)
logsList.BackgroundTransparency = 1
logsList.CanvasSize = UDim2.new(0, 0, 0, 0)
logsList.ScrollBarThickness = 4
logsList.Parent = logsFrame

-- Detected Remotes Display
local remotesFrame = Instance.new("Frame")
remotesFrame.Size = UDim2.new(0.94, 0, 0.2, 0)
remotesFrame.Position = UDim2.new(0.03, 0, 0.9, 0)
remotesFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
remotesFrame.BackgroundTransparency = 0.3
remotesFrame.BorderSizePixel = 0
remotesFrame.Parent = mainFrame

local remotesCorner = Instance.new("UICorner")
remotesCorner.CornerRadius = UDim.new(0, 6)
remotesCorner.Parent = remotesFrame

local miningRemoteLabel = Instance.new("TextLabel")
miningRemoteLabel.Size = UDim2.new(1, 0, 0.33, 0)
miningRemoteLabel.Position = UDim2.new(0, 0, 0, 0)
miningRemoteLabel.BackgroundTransparency = 1
miningRemoteLabel.Text = "⛏️ Mining: Not captured"
miningRemoteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
miningRemoteLabel.TextSize = 10
miningRemoteLabel.Font = Enum.Font.Gotham
miningRemoteLabel.Parent = remotesFrame

local rebirthRemoteLabel = Instance.new("TextLabel")
rebirthRemoteLabel.Size = UDim2.new(1, 0, 0.33, 0)
rebirthRemoteLabel.Position = UDim2.new(0, 0, 0.33, 0)
rebirthRemoteLabel.BackgroundTransparency = 1
rebirthRemoteLabel.Text = "🔄 Rebirth: Not captured"
rebirthRemoteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthRemoteLabel.TextSize = 10
rebirthRemoteLabel.Font = Enum.Font.Gotham
rebirthRemoteLabel.Parent = remotesFrame

local upgradeRemoteLabel = Instance.new("TextLabel")
upgradeRemoteLabel.Size = UDim2.new(1, 0, 0.34, 0)
upgradeRemoteLabel.Position = UDim2.new(0, 0, 0.66, 0)
upgradeRemoteLabel.BackgroundTransparency = 1
upgradeRemoteLabel.Text = "⬆️ Upgrade: Not captured"
upgradeRemoteLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
upgradeRemoteLabel.TextSize = 10
upgradeRemoteLabel.Font = Enum.Font.Gotham
upgradeRemoteLabel.Parent = remotesFrame

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

-- Data storage
local capturedRemotes = {
    functions = {},
    events = {},
    calls = {}
}

local logs = {}
local isCapturing = false
local remoteIndexMap = {}

-- Add log entry
local function addLog(text, color, type)
    table.insert(logs, 1, {text = text, color = color, type = type, time = os.date("%H:%M:%S")})
    
    -- Keep only last 100 logs
    if #logs > 100 then
        table.remove(logs)
    end
    
    -- Update display
    for _, child in pairs(logsList:GetChildren()) do
        child:Destroy()
    end
    
    local yOffset = 5
    for i, log in pairs(logs) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Size = UDim2.new(1, -10, 0, 35)
        logLabel.Position = UDim2.new(0, 5, 0, yOffset)
        logLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        logLabel.BackgroundTransparency = 0.3
        logLabel.Text = "[" .. log.time .. "] " .. log.text
        logLabel.TextColor3 = log.color or Color3.fromRGB(200, 200, 200)
        logLabel.TextSize = 10
        logLabel.Font = Enum.Font.Gotham
        logLabel.TextWrapped = true
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = logsList
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 4)
        logCorner.Parent = logLabel
        
        yOffset = yOffset + 40
    end
    
    logsList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Method 1: Hook into metatable of all remote objects
local function hookRemoteMetatable()
    local success, result = pcall(function()
        local oldIndex = debug.getmetatable(game).__index
        debug.getmetatable(game).__index = function(self, key)
            local value = oldIndex(self, key)
            if value and (value:IsA("RemoteFunction") or value:IsA("RemoteEvent")) then
                -- Remote found
                if not remoteIndexMap[value] then
                    remoteIndexMap[value] = #capturedRemotes.functions + #capturedRemotes.events + 1
                    if value:IsA("RemoteFunction") then
                        table.insert(capturedRemotes.functions, value)
                    else
                        table.insert(capturedRemotes.events, value)
                    end
                end
            end
            return value
        end
    end)
end

-- Method 2: Hook all existing remotes in ReplicatedStorage
local function hookAllRemotes()
    local function scanAndHook(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                if not remoteIndexMap[child] then
                    remoteIndexMap[child] = #capturedRemotes.functions + #capturedRemotes.events + 1
                    if child:IsA("RemoteFunction") then
                        table.insert(capturedRemotes.functions, child)
                        hookRemoteFunction(child)
                    else
                        table.insert(capturedRemotes.events, child)
                        hookRemoteEvent(child)
                    end
                end
            end
            scanAndHook(child)
        end
    end
    
    local function hookRemoteFunction(remote)
        local originalInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local argsStr = {}
            
            for _, arg in pairs(args) do
                if typeof(arg) == "Instance" then
                    argsStr[#argsStr + 1] = "[" .. arg.ClassName .. ":" .. (arg.Name or "?") .. "]"
                elseif type(arg) == "string" then
                    argsStr[#argsStr + 1] = '"' .. arg .. '"'
                else
                    argsStr[#argsStr + 1] = tostring(arg)
                end
            end
            
            local remoteName = remote.Name ~= "" and remote.Name or "(EMPTY)"
            local remotePath = remote:GetFullName()
            local index = remoteIndexMap[remote]
            
            -- Detect remote type
            local remoteType = "unknown"
            local fullArgsText = table.concat(argsStr, ", ")
            local lowerArgs = string.lower(fullArgsText)
            
            if string.find(remotePath, "Asteroid") or string.find(lowerArgs, "asteroid") or string.find(lowerArgs, "mine") then
                remoteType = "mining"
            elseif string.find(lowerArgs, "rebirth") or string.find(lowerArgs, "prestige") then
                remoteType = "rebirth"
            elseif string.find(lowerArgs, "upgrade") or string.find(lowerArgs, "level") then
                remoteType = "upgrade"
            end
            
            -- Log the call
            local logMsg = string.format("[#%d] %s:%s(%s) [%s]", 
                index, 
                remote:IsA("RemoteFunction") and "Func" or "Event",
                remoteName,
                fullArgsText ~= "" and fullArgsText or "no args",
                remotePath
            )
            
            local color = remoteType == "mining" and Color3.fromRGB(100, 255, 100) or
                          (remoteType == "rebirth" and Color3.fromRGB(200, 100, 255) or
                          (remoteType == "upgrade" and Color3.fromRGB(255, 200, 100) or
                          Color3.fromRGB(150, 150, 150)))
            
            addLog(logMsg, color, remoteType)
            
            -- Update captured remote info
            if remoteType == "mining" then
                capturedRemotes.miningIndex = index
                capturedRemotes.miningArgs = argsStr
                miningRemoteLabel.Text = "⛏️ Mining: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                miningRemoteLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif remoteType == "rebirth" then
                capturedRemotes.rebirthIndex = index
                capturedRemotes.rebirthArgs = argsStr
                rebirthRemoteLabel.Text = "🔄 Rebirth: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                rebirthRemoteLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
            elseif remoteType == "upgrade" then
                capturedRemotes.upgradeIndex = index
                capturedRemotes.upgradeArgs = argsStr
                upgradeRemoteLabel.Text = "⬆️ Upgrade: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                upgradeRemoteLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            
            -- Store call
            table.insert(capturedRemotes.calls, {
                time = os.time(),
                index = index,
                name = remoteName,
                path = remotePath,
                args = argsStr,
                type = remoteType
            })
            
            return originalInvoke(self, ...)
        end
    end
    
    local function hookRemoteEvent(remote)
        local originalFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            local argsStr = {}
            
            for _, arg in pairs(args) do
                if typeof(arg) == "Instance" then
                    argsStr[#argsStr + 1] = "[" .. arg.ClassName .. ":" .. (arg.Name or "?") .. "]"
                elseif type(arg) == "string" then
                    argsStr[#argsStr + 1] = '"' .. arg .. '"'
                else
                    argsStr[#argsStr + 1] = tostring(arg)
                end
            end
            
            local remoteName = remote.Name ~= "" and remote.Name or "(EMPTY)"
            local remotePath = remote:GetFullName()
            local index = remoteIndexMap[remote]
            
            local remoteType = "unknown"
            local fullArgsText = table.concat(argsStr, ", ")
            local lowerArgs = string.lower(fullArgsText)
            
            if string.find(remotePath, "Asteroid") or string.find(lowerArgs, "asteroid") or string.find(lowerArgs, "mine") then
                remoteType = "mining"
            elseif string.find(lowerArgs, "rebirth") or string.find(lowerArgs, "prestige") then
                remoteType = "rebirth"
            elseif string.find(lowerArgs, "upgrade") or string.find(lowerArgs, "level") then
                remoteType = "upgrade"
            end
            
            local logMsg = string.format("[#%d] %s:%s(%s) [%s]", 
                index, 
                remote:IsA("RemoteFunction") and "Func" or "Event",
                remoteName,
                fullArgsText ~= "" and fullArgsText or "no args",
                remotePath
            )
            
            local color = remoteType == "mining" and Color3.fromRGB(100, 255, 100) or
                          (remoteType == "rebirth" and Color3.fromRGB(200, 100, 255) or
                          (remoteType == "upgrade" and Color3.fromRGB(255, 200, 100) or
                          Color3.fromRGB(150, 150, 150)))
            
            addLog(logMsg, color, remoteType)
            
            if remoteType == "mining" then
                capturedRemotes.miningIndex = index
                capturedRemotes.miningArgs = argsStr
                miningRemoteLabel.Text = "⛏️ Mining: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                miningRemoteLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif remoteType == "rebirth" then
                capturedRemotes.rebirthIndex = index
                capturedRemotes.rebirthArgs = argsStr
                rebirthRemoteLabel.Text = "🔄 Rebirth: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                rebirthRemoteLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
            elseif remoteType == "upgrade" then
                capturedRemotes.upgradeIndex = index
                capturedRemotes.upgradeArgs = argsStr
                upgradeRemoteLabel.Text = "⬆️ Upgrade: #" .. index .. " - Args: " .. table.concat(argsStr, ", ")
                upgradeRemoteLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            
            table.insert(capturedRemotes.calls, {
                time = os.time(),
                index = index,
                name = remoteName,
                path = remotePath,
                args = argsStr,
                type = remoteType
            })
            
            return originalFire(self, ...)
        end
    end
    
    scanAndHook(ReplicatedStorage)
    scanAndHook(game:GetService("ReplicatedStorage"))
    scanAndHook(game:GetService("Players").LocalPlayer.PlayerGui)
end

-- Start capturing
local function startCapture()
    if isCapturing then
        addLog("Already capturing!", Color3.fromRGB(255, 200, 100))
        return
    end
    
    addLog("🚀 Starting remote capture system...", Color3.fromRGB(100, 255, 100))
    addLog("📡 Hooking all remotes in ReplicatedStorage...", Color3.fromRGB(100, 200, 255))
    
    capturedRemotes = {functions = {}, events = {}, calls = {}}
    remoteIndexMap = {}
    logs = {}
    
    addLog("✅ Now PERFORM ACTIONS in-game:", Color3.fromRGB(255, 200, 100))
    addLog("   • Mine an asteroid", Color3.fromRGB(200, 200, 200))
    addLog("   • Click Rebirth button", Color3.fromRGB(200, 200, 200))
    addLog("   • Upgrade your field", Color3.fromRGB(200, 200, 200))
    
    hookAllRemotes()
    hookRemoteMetatable()
    
    isCapturing = true
    captureBtn.Text = "⏸️ CAPTURING..."
    captureBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    statusLabel.Text = "Status: 🟢 CAPTURING - Perform actions!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- Stop capturing
local function stopCapture()
    if not isCapturing then
        addLog("Not capturing!", Color3.fromRGB(255, 200, 100))
        return
    end
    
    isCapturing = false
    captureBtn.Text = "▶️ START CAPTURE"
    captureBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    statusLabel.Text = "Status: ⚪ IDLE"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    addLog("⏹️ Capture stopped", Color3.fromRGB(255, 200, 100))
end

-- Clear logs
local function clearLogs()
    logs = {}
    capturedRemotes.calls = {}
    for _, child in pairs(logsList:GetChildren()) do
        child:Destroy()
    end
    addLog("🗑️ Logs cleared", Color3.fromRGB(255, 200, 100))
end

-- Copy all captured remotes
local function copyAllRemotes()
    local text = "=== CAPTURED REMOTES ===\n"
    text = text .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
    
    text = text .. "=== MINING REMOTE ===\n"
    if capturedRemotes.miningIndex then
        text = text .. "Index: " .. capturedRemotes.miningIndex .. "\n"
        text = text .. "Arguments: " .. table.concat(capturedRemotes.miningArgs or {}, ", ") .. "\n"
        text = text .. "Code:\n"
        text = text .. string.format([[
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local miningRemote = Functions:GetChildren()[%d]
-- Usage:
local plot = workspace.Plots.Plot1
local asteroid = plot.Asteroids:GetChildren()[1]
miningRemote:InvokeServer(plot, asteroid)
]], capturedRemotes.miningIndex)
    else
        text = text .. "Not captured yet\n"
    end
    
    text = text .. "\n=== REBIRTH REMOTE ===\n"
    if capturedRemotes.rebirthIndex then
        text = text .. "Index: " .. capturedRemotes.rebirthIndex .. "\n"
        text = text .. "Arguments: " .. table.concat(capturedRemotes.rebirthArgs or {}, ", ") .. "\n"
        text = text .. "Code:\n"
        text = text .. string.format([[
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local rebirthRemote = Functions:GetChildren()[%d]
-- Try different usages:
rebirthRemote:InvokeServer()  -- No args
-- rebirthRemote:InvokeServer(true)
-- rebirthRemote:InvokeServer("Rebirth")
]], capturedRemotes.rebirthIndex)
    else
        text = text .. "Not captured yet\n"
    end
    
    text = text .. "\n=== UPGRADE REMOTE ===\n"
    if capturedRemotes.upgradeIndex then
        text = text .. "Index: " .. capturedRemotes.upgradeIndex .. "\n"
        text = text .. "Arguments: " .. table.concat(capturedRemotes.upgradeArgs or {}, ", ") .. "\n"
        text = text .. "Code:\n"
        text = text .. string.format([[
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local upgradeRemote = Functions:GetChildren()[%d]
-- Try different usages:
upgradeRemote:InvokeServer()
-- upgradeRemote:InvokeServer(1)
-- upgradeRemote:InvokeServer("upgrade")
]], capturedRemotes.upgradeIndex)
    else
        text = text .. "Not captured yet\n"
    end
    
    text = text .. "\n=== ALL CAPTURED CALLS ===\n"
    for i, call in pairs(capturedRemotes.calls) do
        text = text .. string.format("[%d] #%d: %s(%s)\n", i, call.index, call.name, table.concat(call.args, ", "))
    end
    
    local success = pcall(function()
        setclipboard(text)
    end)
    
    if success then
        addLog("✅ All captured remotes copied to clipboard!", Color3.fromRGB(100, 255, 100))
        copyAllBtn.Text = "✓ COPIED!"
        task.wait(2)
        copyAllBtn.Text = "📋 COPY ALL CAPTURED REMOTES"
    else
        addLog("❌ Failed to copy!", Color3.fromRGB(255, 100, 100))
    end
end

-- Button connections
captureBtn.MouseButton1Click:Connect(function()
    if isCapturing then
        stopCapture()
    else
        startCapture()
    end
end)

clearBtn.MouseButton1Click:Connect(clearLogs)
copyAllBtn.MouseButton1Click:Connect(copyAllRemotes)
closeBtn.MouseButton1Click:Connect(function()
    stopCapture()
    screenGui:Destroy()
end)

-- Auto-start capture
task.wait(1)
startCapture()

print("=== ULTIMATE REMOTE CAPTURE SYSTEM ===")
print("✅ Started! The script will capture ALL remote calls")
print("📋 Now perform these actions in-game:")
print("   • Mine an asteroid")
print("   • Click Rebirth button")  
print("   • Upgrade your field/equipment")
print("📋 The GUI will show which remotes are captured")
print("🎯 Press COPY ALL to get ready-to-use code")
