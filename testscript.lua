--// DELTA MOBILE - WAVE DETECTION & MONITOR
--// Works on mobile executors like Delta

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--// CREATE SIMPLE GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WaveMonitor"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🌊 WAVE MONITOR (Delta Mobile)"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Current Wave Display
local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, -20, 0, 60)
waveDisplay.Position = UDim2.new(0, 10, 0, 45)
waveDisplay.Text = "🌊 Current Wave: ???"
waveDisplay.TextColor3 = Color3.new(0.3, 1, 0.3)
waveDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
waveDisplay.Font = Enum.Font.GothamBold
waveDisplay.TextSize = 18
waveDisplay.Parent = mainFrame

-- Raid Type Display
local raidDisplay = Instance.new("TextLabel")
raidDisplay.Size = UDim2.new(1, -20, 0, 30)
raidDisplay.Position = UDim2.new(0, 10, 0, 110)
raidDisplay.Text = "🏟️ Raid: None"
raidDisplay.TextColor3 = Color3.new(1, 1, 0.5)
raidDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
raidDisplay.Font = Enum.Font.Gotham
raidDisplay.TextSize = 12
raidDisplay.Parent = mainFrame

-- Console Output Frame
local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(1, -20, 0, 300)
consoleFrame.Position = UDim2.new(0, 10, 0, 150)
consoleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
consoleFrame.BorderSizePixel = 1
consoleFrame.BorderColor3 = Color3.fromRGB(60, 60, 90)
consoleFrame.Parent = mainFrame

local consoleList = Instance.new("UIListLayout")
consoleList.Parent = consoleFrame
consoleList.Padding = UDim.new(0, 2)

local consoleContent = Instance.new("Frame")
consoleContent.Size = UDim2.new(1, 0, 0, 0)
consoleContent.BackgroundTransparency = 1
consoleContent.Parent = consoleFrame

-- Buttons
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.48, -5, 0, 35)
copyBtn.Position = UDim2.new(0, 10, 0, 460)
copyBtn.Text = "📋 COPY LOGS"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, -5, 0, 35)
clearBtn.Position = UDim2.new(0.52, 0, 0, 460)
clearBtn.Text = "🗑️ CLEAR"
clearBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 12
clearBtn.Parent = mainFrame

--// DATA
local logs = {}
local currentWave = 0
local lastWave = 0

--// ADD LOG FUNCTION
local function addLog(text, color)
    color = color or Color3.new(0.8, 0.8, 0.8)
    local timestamp = os.date("%H:%M:%S")
    local formatted = "[" .. timestamp .. "] " .. text
    
    table.insert(logs, 1, {text = formatted, color = color})
    
    -- Keep last 100 logs
    while #logs > 100 do table.remove(logs) end
    
    -- Update UI
    for _, child in ipairs(consoleContent:GetChildren()) do
        child:Destroy()
    end
    
    for i = #logs, 1, -1 do
        local log = logs[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Text = log.text
        label.TextColor3 = log.color
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = consoleContent
    end
    
    task.wait()
    consoleFrame.CanvasPosition = Vector2.new(0, 0)
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, #logs * 20)
end

--// SCAN UI FOR WAVE NUMBER
local function scanForWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local function searchForWaveText(instance)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            
            -- Look for wave patterns
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
                    return tonumber(waveNum)
                end
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            local result = searchForWaveText(child)
            if result then return result end
        end
        return nil
    end
    
    return searchForWaveText(playerGui)
end

--// SCAN FOR RAID TYPE
local function scanForRaidType()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local function searchForRaid(instance)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            local lower = string.lower(text)
            
            if lower:match("mega raid") then
                return "Mega Raid"
            elseif lower:match("raft raid") then
                return "Raft Raid"
            elseif lower:match("community raid") then
                return "Community Raid"
            elseif lower:match("insane challenge") then
                return "Insane Challenge"
            elseif lower:match("pro challenge") then
                return "Pro Challenge"
            elseif lower:match("godly challenge") then
                return "Godly Challenge"
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            local result = searchForRaid(child)
            if result then return result end
        end
        return nil
    end
    
    return searchForRaid(playerGui)
end

--// HOOK REMOTE EVENTS (SIMPLE VERSION)
local function hookRemotes()
    local success, result = pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events then
            local remotes = events:FindFirstChild("Remotes")
            if remotes then
                for _, remote in ipairs(remotes:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        local oldFunc = remote.OnClientEvent
                        remote.OnClientEvent = function(...)
                            local args = {...}
                            local name = remote.Name
                            
                            if string.find(string.lower(name), "wave") or 
                               string.find(string.lower(name), "round") then
                                addLog("🔔 " .. name .. " fired!", Color3.new(1, 0.8, 0))
                                for i, arg in ipairs(args) do
                                    addLog("   Arg" .. i .. ": " .. tostring(arg), Color3.new(0.8, 0.8, 0.8))
                                end
                            end
                            
                            if oldFunc then oldFunc(...) end
                        end
                    end
                end
            end
        end
    end)
    
    if success then
        addLog("✅ Remote event monitoring active", Color3.new(0.3, 1, 0.3))
    else
        addLog("⚠️ Remote hooking failed (normal for Delta)", Color3.new(1, 0.8, 0))
    end
end

--// MONITOR VALUE CHANGES
local function monitorValues()
    local success, result = pcall(function()
        local playerFlags = player:FindFirstChild("Flags")
        if playerFlags then
            for _, flag in ipairs(playerFlags:GetChildren()) do
                if flag:IsA("IntValue") or flag:IsA("NumberValue") then
                    flag.Changed:Connect(function(newValue)
                        if string.find(string.lower(flag.Name), "wave") or 
                           string.find(string.lower(flag.Name), "round") then
                            addLog("⭐ " .. flag.Name .. " = " .. newValue, Color3.new(0.3, 1, 0.3))
                            currentWave = newValue
                            waveDisplay.Text = "🌊 Current Wave: " .. currentWave
                            waveDisplay.TextColor3 = currentWave >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
                        end
                    end)
                end
            end
        end
    end)
end

--// MAIN MONITOR LOOP
local function startMonitoring()
    addLog("=== WAVE MONITOR STARTED (Delta Mobile) ===", Color3.new(1, 1, 0))
    addLog("Start a raid to detect waves!", Color3.new(0.3, 1, 0.3))
    
    local lastRaidType = ""
    
    task.spawn(function()
        while true do
            -- Scan for wave
            local wave = scanForWave()
            if wave and wave ~= lastWave then
                lastWave = wave
                currentWave = wave
                waveDisplay.Text = "🌊 Current Wave: " .. wave
                
                if wave >= 408 then
                    waveDisplay.TextColor3 = Color3.new(1, 0.3, 0.3)
                    addLog("🎯 TARGET WAVE " .. wave .. " REACHED!", Color3.new(1, 0.3, 0.3), true)
                else
                    waveDisplay.TextColor3 = Color3.new(0.3, 1, 0.3)
                    addLog("🌊 Wave: " .. wave, Color3.new(0.3, 1, 0.3))
                end
            end
            
            -- Scan for raid type
            local raidType = scanForRaidType()
            if raidType and raidType ~= lastRaidType then
                lastRaidType = raidType
                raidDisplay.Text = "🏟️ Raid: " .. raidType
                addLog("🏟️ Raid detected: " .. raidType, Color3.new(1, 0.8, 0))
            elseif not raidType and lastRaidType ~= "" then
                if lastRaidType ~= "" then
                    addLog("🏁 Raid ended. Final wave: " .. lastWave, Color3.new(1, 0.5, 0))
                    lastRaidType = ""
                    raidDisplay.Text = "🏟️ Raid: None"
                end
            end
            
            task.wait(0.5)
        end
    end)
end

--// BUTTON FUNCTIONS
copyBtn.MouseButton1Click:Connect(function()
    local text = ""
    for i = #logs, 1, -1 do
        text = text .. logs[i].text .. "\n"
    end
    if text ~= "" then
        setclipboard(text)
        addLog("✅ Logs copied to clipboard!", Color3.new(0.3, 1, 0.3))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    logs = {}
    for _, child in ipairs(consoleContent:GetChildren()) do
        child:Destroy()
    end
    addLog("Console cleared", Color3.new(1, 1, 0))
end)

--// START EVERYTHING
pcall(function()
    hookRemotes()
    monitorValues()
    startMonitoring()
end)

addLog("💡 TIPS:", Color3.new(1, 0.8, 0))
addLog("   • Start a raid to see wave detection", Color3.new(0.7, 0.7, 0.7))
addLog("   • Waves will appear automatically", Color3.new(0.7, 0.7, 0.7))
addLog("   • Press COPY to save all logs", Color3.new(0.7, 0.7, 0.7))
