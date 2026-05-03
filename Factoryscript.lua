-- DIRECT REMOTE CATCHER - Simpler but Effective
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteCatcher"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🎯 REMOTE CATCHER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

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

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: READY"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = mainFrame

-- Instructions
local instLabel = Instance.new("TextLabel")
instLabel.Size = UDim2.new(0.9, 0, 0, 60)
instLabel.Position = UDim2.new(0.05, 0, 0.16, 0)
instLabel.BackgroundTransparency = 1
instLabel.Text = "📋 Instructions:\n1. Tap START\n2. Perform actions in-game\n3. Remotes will be captured"
instLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
instLabel.TextSize = 11
instLabel.Font = Enum.Font.Gotham
instLabel.TextWrapped = true
instLabel.Parent = mainFrame

-- Start Button
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.8, 0, 0, 45)
startBtn.Position = UDim2.new(0.1, 0, 0.28, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
startBtn.Text = "▶️ START CATCHING"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 14
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = mainFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startBtn

-- Copy All Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.8, 0, 0, 40)
copyBtn.Position = UDim2.new(0.1, 0, 0.37, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyBtn.Text = "📋 COPY ALL REMOTES"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

-- Results Frame
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(0.94, 0, 0.45, 0)
resultsFrame.Position = UDim2.new(0.03, 0, 0.45, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
resultsFrame.BackgroundTransparency = 0.3
resultsFrame.BorderSizePixel = 0
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 4
resultsFrame.Parent = mainFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 8)
resultsCorner.Parent = resultsFrame

-- Detected Remotes Display
local miningDisplay = Instance.new("TextLabel")
miningDisplay.Size = UDim2.new(0.94, 0, 0, 30)
miningDisplay.Position = UDim2.new(0.03, 0, 0.92, 0)
miningDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
miningDisplay.BackgroundTransparency = 0.5
miningDisplay.Text = "⛏️ Mining: ⏳ Waiting..."
miningDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
miningDisplay.TextSize = 10
miningDisplay.Font = Enum.Font.Gotham
miningDisplay.Parent = mainFrame

local miningCorner = Instance.new("UICorner")
miningCorner.CornerRadius = UDim.new(0, 4)
miningCorner.Parent = miningDisplay

local rebirthDisplay = Instance.new("TextLabel")
rebirthDisplay.Size = UDim2.new(0.94, 0, 0, 30)
rebirthDisplay.Position = UDim2.new(0.03, 0, 0.96, 0)
rebirthDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
rebirthDisplay.BackgroundTransparency = 0.5
rebirthDisplay.Text = "🔄 Rebirth: ⏳ Waiting..."
rebirthDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthDisplay.TextSize = 10
rebirthDisplay.Font = Enum.Font.Gotham
rebirthDisplay.Parent = mainFrame

local rebirthCorner = Instance.new("UICorner")
rebirthCorner.CornerRadius = UDim.new(0, 4)
rebirthCorner.Parent = rebirthDisplay

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

-- Store captured remotes
local captured = {
    mining = nil,
    miningArgs = nil,
    rebirth = nil,
    rebirthArgs = nil,
    upgrade = nil,
    upgradeArgs = nil,
    allCalls = {}
}

local logs = {}

local function addLog(text, color)
    table.insert(logs, 1, {text = text, color = color, time = os.date("%H:%M:%S")})
    
    if #logs > 50 then table.remove(logs) end
    
    for _, child in pairs(resultsFrame:GetChildren()) do
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
        logLabel.Parent = resultsFrame
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 4)
        logCorner.Parent = logLabel
        
        yOffset = yOffset + 35
    end
    
    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Direct hooking of the Functions folder
local function hookDirectly()
    addLog("🔍 Accessing Communication.Functions...", Color3.fromRGB(100, 200, 255))
    
    local Communication = ReplicatedStorage:FindFirstChild("Communication")
    if not Communication then
        addLog("❌ Communication not found!", Color3.fromRGB(255, 100, 100))
        return false
    end
    
    local Functions = Communication:FindFirstChild("Functions")
    if not Functions then
        addLog("❌ Functions not found!", Color3.fromRGB(255, 100, 100))
        return false
    end
    
    local children = Functions:GetChildren()
    addLog(string.format("📡 Found %d children in Functions", #children), Color3.fromRGB(100, 200, 255))
    
    local hookedCount = 0
    
    for index, child in pairs(children) do
        if child:IsA("RemoteFunction") then
            local originalInvoke = child.InvokeServer
            
            child.InvokeServer = function(self, ...)
                local args = {...}
                local argsStr = {}
                
                for _, arg in pairs(args) do
                    if typeof(arg) == "Instance" then
                        argsStr[#argsStr + 1] = "[" .. arg.ClassName .. "]"
                        if arg.Name and arg.Name:match("^{.*}$") then
                            argsStr[#argsStr - 1] = "[ASTEROID:" .. string.sub(arg.Name, 1, 20) .. "...]"
                        end
                    elseif type(arg) == "string" then
                        argsStr[#argsStr + 1] = '"' .. arg .. '"'
                    else
                        argsStr[#argsStr + 1] = tostring(arg)
                    end
                end
                
                local fullArgs = table.concat(argsStr, ", ")
                local childName = child.Name ~= "" and child.Name or "(EMPTY)"
                
                -- Detect type
                local detectedType = nil
                local lowerArgs = string.lower(fullArgs)
                
                if string.find(lowerArgs, "mine") or string.find(lowerArgs, "ore") or string.find(lowerArgs, "asteroid") then
                    detectedType = "mining"
                elseif string.find(lowerArgs, "rebirth") or string.find(lowerArgs, "prestige") then
                    detectedType = "rebirth"
                elseif string.find(lowerArgs, "upgrade") or string.find(lowerArgs, "level") then
                    detectedType = "upgrade"
                end
                
                -- Also check for asteroid folder pattern
                for _, arg in pairs(args) do
                    if typeof(arg) == "Instance" and arg.ClassName == "Folder" and arg.Name and arg.Name:match("^{.*}$") then
                        detectedType = "mining"
                    end
                end
                
                local logMsg = string.format("#%d [%s] %s(%s)", index, childName, detectedType or "REMOTE", fullArgs)
                
                if detectedType == "mining" then
                    addLog("⛏️ " .. logMsg, Color3.fromRGB(100, 255, 100))
                    captured.mining = index
                    captured.miningArgs = argsStr
                    miningDisplay.Text = "⛏️ Mining: #" .. index .. " - Args: " .. fullArgs
                    miningDisplay.TextColor3 = Color3.fromRGB(100, 255, 100)
                elseif detectedType == "rebirth" then
                    addLog("🔄 " .. logMsg, Color3.fromRGB(200, 100, 255))
                    captured.rebirth = index
                    captured.rebirthArgs = argsStr
                    rebirthDisplay.Text = "🔄 Rebirth: #" .. index .. " - Args: " .. fullArgs
                    rebirthDisplay.TextColor3 = Color3.fromRGB(200, 100, 255)
                else
                    addLog(logMsg, Color3.fromRGB(150, 150, 150))
                end
                
                table.insert(captured.allCalls, {
                    index = index,
                    args = fullArgs,
                    type = detectedType,
                    time = os.time()
                })
                
                return originalInvoke(self, ...)
            end
            
            hookedCount = hookedCount + 1
        end
    end
    
    addLog(string.format("✅ Hooked %d remote functions", hookedCount), Color3.fromRGB(100, 255, 100))
    return true
end

-- Alternative: Hook by scanning all remotes in ReplicatedStorage
local function hookAllRemotes()
    addLog("🔍 Scanning entire ReplicatedStorage...", Color3.fromRGB(100, 200, 255))
    
    local remotes = {}
    
    local function scan(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("RemoteFunction") then
                table.insert(remotes, child)
            end
            scan(child)
        end
    end
    
    scan(ReplicatedStorage)
    scan(game:GetService("ReplicatedStorage"))
    
    addLog(string.format("📡 Found %d total remotes", #remotes), Color3.fromRGB(100, 200, 255))
    
    for _, remote in pairs(remotes) do
        local originalInvoke = remote.InvokeServer
        
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local argsStr = {}
            
            for _, arg in pairs(args) do
                if typeof(arg) == "Instance" then
                    argsStr[#argsStr + 1] = "[" .. arg.ClassName .. "]"
                elseif type(arg) == "string" then
                    argsStr[#argsStr + 1] = '"' .. arg .. '"'
                else
                    argsStr[#argsStr + 1] = tostring(arg)
                end
            end
            
            local fullArgs = table.concat(argsStr, ", ")
            local remoteName = remote.Name ~= "" and remote.Name : "(EMPTY)"
            local remotePath = remote:GetFullName()
            
            local detectedType = nil
            local lowerArgs = string.lower(fullArgs)
            local lowerPath = string.lower(remotePath)
            
            if string.find(lowerArgs, "mine") or string.find(lowerArgs, "ore") or string.find(lowerArgs, "asteroid") or string.find(lowerPath, "asteroid") then
                detectedType = "mining"
            elseif string.find(lowerArgs, "rebirth") or string.find(lowerArgs, "prestige") or string.find(lowerPath, "rebirth") then
                detectedType = "rebirth"
            elseif string.find(lowerArgs, "upgrade") or string.find(lowerArgs, "level") or string.find(lowerPath, "upgrade") then
                detectedType = "upgrade"
            end
            
            local logMsg = string.format("[%s] %s(%s)", remoteName, detectedType or "REMOTE", fullArgs)
            
            if detectedType == "mining" then
                addLog("⛏️ " .. logMsg, Color3.fromRGB(100, 255, 100))
                captured.mining = remote
                captured.miningArgs = argsStr
                miningDisplay.Text = "⛏️ Mining: " .. remoteName .. " - Args: " .. fullArgs
                miningDisplay.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif detectedType == "rebirth" then
                addLog("🔄 " .. logMsg, Color3.fromRGB(200, 100, 255))
                captured.rebirth = remote
                captured.rebirthArgs = argsStr
                rebirthDisplay.Text = "🔄 Rebirth: " .. remoteName .. " - Args: " .. fullArgs
                rebirthDisplay.TextColor3 = Color3.fromRGB(200, 100, 255)
            else
                addLog(logMsg, Color3.fromRGB(150, 150, 150))
            end
            
            return originalInvoke(self, ...)
        end
    end
    
    addLog("✅ Hooked all remotes!", Color3.fromRGB(100, 255, 100))
end

-- Start catching
local isCatching = false

local function startCatching()
    if isCatching then
        addLog("Already catching!", Color3.fromRGB(255, 200, 100))
        return
    end
    
    addLog("🚀 Starting remote catcher...", Color3.fromRGB(100, 255, 100))
    
    -- Try direct hook first
    local success = hookDirectly()
    
    if not success then
        addLog("⚠️ Direct hook failed, trying full scan...", Color3.fromRGB(255, 200, 100))
        hookAllRemotes()
    end
    
    isCatching = true
    startBtn.Text = "⏸️ CATCHING..."
    startBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    statusLabel.Text = "Status: CATCHING - Perform actions!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    addLog("✅ NOW PERFORM ACTIONS IN-GAME:", Color3.fromRGB(255, 200, 100))
    addLog("   • Mine an asteroid", Color3.fromRGB(200, 200, 200))
    addLog("   • Click Rebirth", Color3.fromRGB(200, 200, 200))
    addLog("   • Upgrade something", Color3.fromRGB(200, 200, 200))
end

-- Stop catching
local function stopCatching()
    if not isCatching then
        return
    end
    
    isCatching = false
    startBtn.Text = "▶️ START CATCHING"
    startBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    statusLabel.Text = "Status: STOPPED"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    addLog("⏹️ Stopped catching", Color3.fromRGB(255, 200, 100))
end

-- Copy all captured remotes
local function copyAll()
    local text = "=== CAPTURED REMOTES ===\n"
    text = text .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
    
    text = text .. "=== MINING REMOTE ===\n"
    if captured.mining then
        text = text .. "Index/Name: " .. tostring(captured.mining) .. "\n"
        text = text .. "Arguments: " .. table.concat(captured.miningArgs or {}, ", ") .. "\n"
        text = text .. [[
-- USE THIS CODE FOR MINING:
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local miningRemote = Functions:GetChildren()[INDEX_HERE]  -- Replace INDEX_HERE with the number shown
local plot = workspace.Plots.Plot1
local asteroid = plot.Asteroids:GetChildren()[1]
miningRemote:InvokeServer(plot, asteroid)
]]
    else
        text = text .. "Not captured yet. Mine an asteroid to capture it.\n"
    end
    
    text = text .. "\n=== REBIRTH REMOTE ===\n"
    if captured.rebirth then
        text = text .. "Index/Name: " .. tostring(captured.rebirth) .. "\n"
        text = text .. "Arguments: " .. table.concat(captured.rebirthArgs or {}, ", ") .. "\n"
        text = text .. [[
-- USE THIS CODE FOR REBIRTH:
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local rebirthRemote = Functions:GetChildren()[INDEX_HERE]  -- Replace INDEX_HERE with the number shown
rebirthRemote:InvokeServer()  -- Try with or without args
]]
    else
        text = text .. "Not captured yet. Click Rebirth to capture it.\n"
    end
    
    text = text .. "\n=== ALL CAPTURED CALLS ===\n"
    for i, call in pairs(captured.allCalls) do
        text = text .. string.format("[%d] %s\n", i, call.args)
    end
    
    local success = pcall(function()
        setclipboard(text)
    end)
    
    if success then
        addLog("✅ Copied to clipboard!", Color3.fromRGB(100, 255, 100))
        copyBtn.Text = "✓ COPIED!"
        task.wait(1.5)
        copyBtn.Text = "📋 COPY ALL REMOTES"
    else
        addLog("❌ Failed to copy!", Color3.fromRGB(255, 100, 100))
    end
end

-- Button connections
startBtn.MouseButton1Click:Connect(function()
    if isCatching then
        stopCatching()
    else
        startCatching()
    end
end)

copyBtn.MouseButton1Click:Connect(copyAll)
closeBtn.MouseButton1Click:Connect(function()
    stopCatching()
    screenGui:Destroy()
end)

-- Auto-start
task.wait(1)
startCatching()

print("=== REMOTE CATCHER LOADED ===")
print("The script is now CATCHING remotes")
print("Perform these actions:")
print("  1. Mine an asteroid")
print("  2. Click Rebirth button")
print("  3. Upgrade something")
print("The remotes will appear in the GUI when you perform the actions!")
