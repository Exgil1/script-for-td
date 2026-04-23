--// ADVANCED RAID & WAVE MONITOR WITH COPYABLE CONSOLE
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--// CREATE MAIN GUI WITH CONSOLE OUTPUT
local gui = Instance.new("ScreenGui")
gui.Name = "RaidWaveMonitor"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 500)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🌊 RAID & WAVE MONITOR"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 60, 0, 25)
copyBtn.Position = UDim2.new(1, -65, 0, 5)
copyBtn.Text = "📋 COPY"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.Parent = titleBar

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 50, 0, 25)
clearBtn.Position = UDim2.new(1, -120, 0, 5)
clearBtn.Text = "🗑️ CLEAR"
clearBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 11
clearBtn.Parent = titleBar

-- Current Status Display
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 100)
statusFrame.Position = UDim2.new(0, 10, 0, 45)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
statusFrame.BorderSizePixel = 1
statusFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
statusFrame.Parent = mainFrame

local raidTypeLabel = Instance.new("TextLabel")
raidTypeLabel.Size = UDim2.new(1, -10, 0, 30)
raidTypeLabel.Position = UDim2.new(0, 5, 0, 5)
raidTypeLabel.Text = "🏟️ Raid Type: Unknown"
raidTypeLabel.TextColor3 = Color3.new(1, 1, 0.5)
raidTypeLabel.BackgroundTransparency = 1
raidTypeLabel.Font = Enum.Font.GothamBold
raidTypeLabel.TextSize = 13
raidTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
raidTypeLabel.Parent = statusFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(1, -10, 0, 40)
waveLabel.Position = UDim2.new(0, 5, 0, 35)
waveLabel.Text = "🌊 Current Wave: ???"
waveLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
waveLabel.BackgroundTransparency = 1
waveLabel.Font = Enum.Font.GothamBold
waveLabel.TextSize = 18
waveLabel.TextXAlignment = Enum.TextXAlignment.Left
waveLabel.Parent = statusFrame

local waveProgress = Instance.new("Frame")
waveProgress.Size = UDim2.new(0.8, 0, 0, 8)
waveProgress.Position = UDim2.new(0, 5, 0, 80)
waveProgress.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
waveProgress.BorderSizePixel = 0
waveProgress.Parent = statusFrame

local waveFill = Instance.new("Frame")
waveFill.Size = UDim2.new(0, 0, 1, 0)
waveFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
waveFill.BorderSizePixel = 0
waveFill.Parent = waveProgress

-- Console Output
local consoleLabel = Instance.new("TextLabel")
consoleLabel.Size = UDim2.new(1, -20, 0, 25)
consoleLabel.Position = UDim2.new(0, 10, 0, 155)
consoleLabel.Text = "📋 CONSOLE OUTPUT:"
consoleLabel.TextColor3 = Color3.new(1, 1, 0.5)
consoleLabel.BackgroundTransparency = 1
consoleLabel.Font = Enum.Font.GothamBold
consoleLabel.TextSize = 12
consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
consoleLabel.Parent = mainFrame

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(1, -20, 0, 300)
consoleFrame.Position = UDim2.new(0, 10, 0, 180)
consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
consoleFrame.BorderSizePixel = 1
consoleFrame.BorderColor3 = Color3.fromRGB(60, 60, 90)
consoleFrame.Parent = mainFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.Parent = consoleFrame
consoleLayout.Padding = UDim.new(0, 2)

local consoleContent = Instance.new("Frame")
consoleContent.Size = UDim2.new(1, 0, 0, 0)
consoleContent.BackgroundTransparency = 1
consoleContent.Parent = consoleFrame

--// CONSOLE LOGGING SYSTEM
local consoleLines = {}
local maxLines = 100

local function addLog(text, color)
    color = color or Color3.new(0.8, 0.8, 0.8)
    local timestamp = os.date("%H:%M:%S")
    local formattedText = "[" .. timestamp .. "] " .. text
    
    table.insert(consoleLines, 1, {text = formattedText, color = color})
    if #consoleLines > maxLines then
        table.remove(consoleLines)
    end
    
    -- Update UI
    for _, child in ipairs(consoleContent:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for i = #consoleLines, 1, -1 do
        local line = consoleLines[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Text = line.text
        label.TextColor3 = line.color
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = consoleContent
    end
    
    -- Auto-scroll to bottom
    task.wait()
    consoleFrame.CanvasPosition = Vector2.new(0, 0)
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, #consoleLines * 22)
end

-- Helper function to copy console
copyBtn.MouseButton1Click:Connect(function()
    local allText = ""
    for i = #consoleLines, 1, -1 do
        allText = allText .. consoleLines[i].text .. "\n"
    end
    
    if allText ~= "" then
        setclipboard(allText)
        addLog("✅ Console copied to clipboard!", Color3.new(0.3, 1, 0.3))
    else
        addLog("❌ No console data to copy!", Color3.new(1, 0.3, 0.3))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    consoleLines = {}
    for _, child in ipairs(consoleContent:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    addLog("Console cleared", Color3.new(1, 1, 0.5))
end)

addLog("=== RAID & WAVE MONITOR STARTED ===", Color3.new(0.3, 1, 0.3))
addLog("Monitoring for raid type and wave changes...", Color3.new(0.7, 0.7, 0.7))

--// DETECT RAID TYPE
local function detectRaidType()
    -- Check player flags for raid type
    local playerFlags = player:FindFirstChild("Flags")
    if playerFlags then
        -- Look for raid type indicators
        for _, flag in ipairs(playerFlags:GetChildren()) do
            local nameLower = string.lower(flag.Name)
            if nameLower:match("raid") or nameLower:match("challenge") then
                if flag:IsA("StringValue") and flag.Value ~= "" then
                    addLog("Found raid type in Flags: " .. flag.Name .. " = " .. flag.Value, Color3.new(0.5, 0.8, 1))
                    return flag.Value
                elseif flag:IsA("BoolValue") and flag.Value == true then
                    addLog("Found raid active flag: " .. flag.Name, Color3.new(0.5, 0.8, 1))
                end
            end
        end
    end
    
    -- Check current GUI for raid title
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local function searchForRaidTitle(instance)
            if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                local text = instance.Text or ""
                local lowerText = string.lower(text)
                if lowerText:match("mega raid") then
                    return "Mega Raid"
                elseif lowerText:match("raft raid") then
                    return "Raft Raid"
                elseif lowerText:match("community raid") then
                    return "Community Raid"
                elseif lowerText:match("challenge") then
                    if lowerText:match("insane") then return "Insane Challenge" end
                    if lowerText:match("pro") then return "Pro Challenge" end
                    if lowerText:match("godly") then return "Godly Challenge" end
                    return "Challenge"
                end
            end
            for _, child in ipairs(instance:GetChildren()) do
                local result = searchForRaidTitle(child)
                if result then return result end
            end
            return nil
        end
        local raidType = searchForRaidTitle(playerGui)
        if raidType then
            return raidType
        end
    end
    
    return nil
end

--// DETECT CURRENT WAVE (ACCURATE METHOD)
local function detectCurrentWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local highestWave = 0
        local waveSource = nil
        
        local function searchForWave(instance)
            if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                local text = instance.Text or ""
                
                -- Try different wave formats
                local patterns = {
                        "Wave%s*(%d+)",
                        "WAVE%s*(%d+)",
                        "wave%s*(%d+)",
                        "Round%s*(%d+)",
                        "ROUND%s*(%d+)",
                        "W(%d+)",
                        "w(%d+)"
                }
                
                for _, pattern in ipairs(patterns) do
                    local waveNum = text:match(pattern)
                    if waveNum then
                        local num = tonumber(waveNum)
                        if num and num > highestWave and num < 1000 then
                            highestWave = num
                            waveSource = instance.Name
                        end
                        break
                    end
                end
            end
            
            for _, child in ipairs(instance:GetChildren()) do
                searchForWave(child)
            end
        end
        
        searchForWave(playerGui)
        
        if highestWave > 0 then
            return highestWave, waveSource
        end
    end
    
    return nil, nil
end

--// REMOTE EVENT HOOKING
local function hookRemoteEvents()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if not events then return end
    
    local remotes = events:FindFirstChild("Remotes")
    if remotes then
        for _, remote in ipairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                local oldFunc = remote.OnClientEvent
                remote.OnClientEvent = function(...)
                    local args = {...}
                    local argsStr = ""
                    for i, arg in ipairs(args) do
                        if i > 5 then 
                            argsStr = argsStr .. "..."
                            break 
                        end
                        argsStr = argsStr .. tostring(arg) .. (i < #args and ", " or "")
                    end
                    
                    -- Check if this remote might be wave-related
                    local nameLower = string.lower(remote.Name)
                    if nameLower:match("wave") or nameLower:match("round") or nameLower:match("next") or 
                       nameLower:match("update") or nameLower:match("status") then
                        addLog("🔔 Wave-related remote fired: " .. remote.Name, Color3.new(1, 0.8, 0.3))
                        addLog("   Args: " .. argsStr, Color3.new(0.7, 0.7, 0.7))
                    end
                    
                    if oldFunc then oldFunc(...) end
                end
            end
        end
    end
end

--// VALUE OBJECT MONITORING
local function monitorValues()
    -- Monitor player flags for changes
    local playerFlags = player:FindFirstChild("Flags")
    if playerFlags then
        local function onFlagChanged(flag)
            if string.lower(flag.Name):match("wave") or string.lower(flag.Name):match("raid") then
                addLog("📊 Flag changed: " .. flag.Name .. " = " .. tostring(flag.Value), Color3.new(0.5, 0.8, 1))
            end
        end
        
        for _, flag in ipairs(playerFlags:GetChildren()) do
            if flag:IsA("IntValue") or flag:IsA("NumberValue") or flag:IsA("StringValue") then
                flag.Changed:Connect(function()
                    onFlagChanged(flag)
                end)
            end
        end
    end
    
    -- Monitor leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                stat.Changed:Connect(function()
                    if string.lower(stat.Name):match("wave") or string.lower(stat.Name):match("round") then
                        addLog("📊 Leaderstat changed: " .. stat.Name .. " = " .. tostring(stat.Value), Color3.new(0.5, 0.8, 1))
                    end
                end)
            end
        end
    end
end

--// MAIN MONITORING LOOP
local lastWave = 0
local lastRaidType = ""
local waveHistory = {}

addLog("Starting monitoring loop...", Color3.new(0.3, 1, 0.3))
hookRemoteEvents()
monitorValues()

-- Check for wave-related signals in workspace
local waveSignals = {}

task.spawn(function()
    while true do
        -- Detect raid type
        local currentRaidType = detectRaidType()
        if currentRaidType and currentRaidType ~= lastRaidType then
            lastRaidType = currentRaidType
            raidTypeLabel.Text = "🏟️ Raid Type: " .. currentRaidType
            addLog("🏟️ Raid detected: " .. currentRaidType, Color3.new(0.3, 1, 0.5))
            
            -- Change color based on raid type
            if string.find(currentRaidType, "Mega") then
                raidTypeLabel.TextColor3 = Color3.new(1, 0.5, 0)
            elseif string.find(currentRaidType, "Raft") then
                raidTypeLabel.TextColor3 = Color3.new(0.5, 0.8, 1)
            elseif string.find(currentRaidType, "Challenge") then
                raidTypeLabel.TextColor3 = Color3.new(1, 0.8, 0)
            end
        elseif not currentRaidType and lastRaidType ~= "" then
            lastRaidType = ""
            raidTypeLabel.Text = "🏟️ Raid Type: None (Lobby)"
            raidTypeLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        end
        
        -- Detect current wave
        local wave, source = detectCurrentWave()
        if wave and wave ~= lastWave then
            lastWave = wave
            waveLabel.Text = "🌊 Current Wave: " .. wave
            waveLabel.TextColor3 = wave >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
            
            -- Update progress bar (assuming max wave 500 or similar)
            local progress = math.min(1, wave / 500)
            waveFill.Size = UDim2.new(progress, 0, 1, 0)
            
            -- Log wave change
            addLog(string.format("🌊 Wave changed: %d (Source: %s)", wave, source or "unknown"), 
                   wave >= 408 and Color3.new(1, 0.5, 0.5) or Color3.new(0.5, 1, 0.5))
            
            -- Record wave history
            table.insert(waveHistory, {wave = wave, time = os.time()})
            if #waveHistory > 20 then table.remove(waveHistory, 1) end
            
            -- Special notification for target wave
            if wave == 408 then
                addLog("🎯 TARGET WAVE 408 REACHED!", Color3.new(1, 0.3, 0.3))
                waveLabel.Text = "🌊 TARGET REACHED! Wave: " .. wave
                waveLabel.TextColor3 = Color3.new(1, 0, 0)
            end
        end
        
        -- Log raid end detection
        if not currentRaidType and lastWave ~= 0 then
            addLog("🏁 Raid ended. Final wave: " .. lastWave, Color3.new(1, 0.8, 0))
            lastWave = 0
        end
        
        task.wait(0.3)
    end
end)

--// SEARCH FOR HIDDEN WAVE TRIGGERS
addLog("Searching for hidden wave triggers...", Color3.new(0.7, 0.7, 1))

-- Check all remote events in the game
local function findAllWaveTriggers()
    local triggersFound = 0
    
    local function search(instance)
        if instance:IsA("RemoteEvent") or instance:IsA("BindableEvent") then
            local nameLower = string.lower(instance.Name)
            if nameLower:match("wave") or nameLower:match("round") or nameLower:match("nextwave") or
               nameLower:match("spawn") or nameLower:match("enemy") or nameLower:match("complete") then
                addLog("🔍 Found potential trigger: " .. instance:GetFullName(), Color3.new(0.7, 0.7, 1))
                triggersFound = triggersFound + 1
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            search(child)
        end
    end
    
    search(ReplicatedStorage)
    addLog(string.format("Found %d potential wave-related triggers", triggersFound), Color3.new(0.7, 0.7, 1))
end

task.wait(2)
findAllWaveTriggers()

-- Make GUI resizable/draggable
local dragging = false
local dragStart
local dragStartPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
                                        dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

addLog("✅ Monitor ready! Waiting for raid to start...", Color3.new(0.3, 1, 0.3))
addLog("💡 When raid starts, wave numbers will appear here", Color3.new(0.7, 0.7, 0.7))
addLog("📋 Use COPY button to copy all console output", Color3.new(0.7, 0.7, 0.7))

print("=== RAID & WAVE MONITOR LOADED ===")
print("✅ GUI created with copyable console")
print("✅ Monitoring raid type (Mega/Raft/Challenge)")
print("✅ Detecting wave numbers from UI")
print("✅ Hooking into wave-related remote events")
print("✅ Press COPY button to copy console output")

end)
