--// COMPLETE UI & EVENT MONITOR - FINDS WAVE TRIGGERS (NO METATABLE VERSION)
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

--// CREATE MAIN GUI WITH DETAILED OUTPUT
local gui = Instance.new("ScreenGui")
gui.Name = "EventMonitor"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 750)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -375)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(200, 100, 100)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔍 EVENT & UI MONITOR - FIND WAVE TRIGGERS"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Filter Input
local filterBox = Instance.new("TextBox")
filterBox.Size = UDim2.new(1, -10, 0, 30)
filterBox.Position = UDim2.new(0, 5, 0, 45)
filterBox.PlaceholderText = "🔍 Filter events (type 'wave', 'round', 'raid', etc.)"
filterBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
filterBox.TextColor3 = Color3.new(1, 1, 1)
filterBox.Text = ""
filterBox.Parent = mainFrame

-- Control Buttons
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -10, 0, 35)
btnFrame.Position = UDim2.new(0, 5, 0, 80)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = mainFrame

local pauseBtn = Instance.new("TextButton")
pauseBtn.Size = UDim2.new(0.18, -5, 1, 0)
pauseBtn.Text = "⏸️ PAUSE"
pauseBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
pauseBtn.TextColor3 = Color3.new(1, 1, 1)
pauseBtn.Font = Enum.Font.GothamBold
pauseBtn.TextSize = 11
pauseBtn.Parent = btnFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.18, -5, 1, 0)
copyBtn.Position = UDim2.new(0.19, 0, 0, 0)
copyBtn.Text = "📋 COPY"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.Parent = btnFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.18, -5, 1, 0)
clearBtn.Position = UDim2.new(0.38, 0, 0, 0)
clearBtn.Text = "🗑️ CLEAR"
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 50)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 11
clearBtn.Parent = btnFrame

local detectBtn = Instance.new("TextButton")
detectBtn.Size = UDim2.new(0.18, -5, 1, 0)
detectBtn.Position = UDim2.new(0.57, 0, 0, 0)
detectBtn.Text = "🎯 SCAN UI"
detectBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
detectBtn.TextColor3 = Color3.new(1, 1, 1)
detectBtn.Font = Enum.Font.GothamBold
detectBtn.TextSize = 11
detectBtn.Parent = btnFrame

local scanRemotesBtn = Instance.new("TextButton")
scanRemotesBtn.Size = UDim2.new(0.22, -5, 1, 0)
scanRemotesBtn.Position = UDim2.new(0.76, 0, 0, 0)
scanRemotesBtn.Text = "🔍 SCAN REMOTES"
scanRemotesBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 100)
scanRemotesBtn.TextColor3 = Color3.new(1, 1, 1)
scanRemotesBtn.Font = Enum.Font.GothamBold
scanRemotesBtn.TextSize = 10
scanRemotesBtn.Parent = btnFrame

-- Live Wave Display
local waveDisplayFrame = Instance.new("Frame")
waveDisplayFrame.Size = UDim2.new(1, -10, 0, 70)
waveDisplayFrame.Position = UDim2.new(0, 5, 0, 120)
waveDisplayFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
waveDisplayFrame.BorderSizePixel = 1
waveDisplayFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
waveDisplayFrame.Parent = mainFrame

local liveWaveLabel = Instance.new("TextLabel")
liveWaveLabel.Size = UDim2.new(1, -10, 0.6, 0)
liveWaveLabel.Position = UDim2.new(0, 5, 0, 5)
liveWaveLabel.Text = "🌊 Current Wave: Detecting..."
liveWaveLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
liveWaveLabel.BackgroundTransparency = 1
liveWaveLabel.Font = Enum.Font.GothamBold
liveWaveLabel.TextSize = 16
liveWaveLabel.TextXAlignment = Enum.TextXAlignment.Left
liveWaveLabel.Parent = waveDisplayFrame

local waveSourceLabel = Instance.new("TextLabel")
waveSourceLabel.Size = UDim2.new(1, -10, 0.4, 0)
waveSourceLabel.Position = UDim2.new(0, 5, 0, 45)
waveSourceLabel.Text = "Source: None"
waveSourceLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
waveSourceLabel.BackgroundTransparency = 1
waveSourceLabel.Font = Enum.Font.Gotham
waveSourceLabel.TextSize = 10
waveSourceLabel.TextXAlignment = Enum.TextXAlignment.Left
waveSourceLabel.Parent = waveDisplayFrame

-- Console Output
local consoleScroll = Instance.new("ScrollingFrame")
consoleScroll.Size = UDim2.new(1, -10, 0, 460)
consoleScroll.Position = UDim2.new(0, 5, 0, 195)
consoleScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
consoleScroll.BorderSizePixel = 1
consoleScroll.BorderColor3 = Color3.fromRGB(60, 60, 90)
consoleScroll.Parent = mainFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.Parent = consoleScroll
consoleLayout.Padding = UDim.new(0, 1)

local consoleContent = Instance.new("Frame")
consoleContent.Size = UDim2.new(1, 0, 0, 0)
consoleContent.BackgroundTransparency = 1
consoleContent.Parent = consoleScroll

--// DATA STORAGE
local eventLogs = {}
local paused = false
local filterText = ""
local lastUIWave = 0
local lastUIData = {}

--// ADD LOG FUNCTION
local function addLog(text, color, importance)
    if paused then return end
    if filterText ~= "" and not string.lower(text):match(filterText) then return end
    
    color = color or Color3.new(0.8, 0.8, 0.8)
    local timestamp = os.date("%H:%M:%S")
    local prefix = importance and "⭐ " or "   "
    local formattedText = prefix .. "[" .. timestamp .. "] " .. text
    
    table.insert(eventLogs, 1, {text = formattedText, color = color})
    
    -- Keep only last 200 logs
    while #eventLogs > 200 do
        table.remove(eventLogs)
    end
    
    -- Update UI
    for _, child in ipairs(consoleContent:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for i = #eventLogs, 1, -1 do
        local log = eventLogs[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Text = log.text
        label.TextColor3 = log.color
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.Parent = consoleContent
    end
    
    task.wait()
    consoleScroll.CanvasPosition = Vector2.new(0, 0)
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, #eventLogs * 19)
end

--// SCAN UI FOR WAVE DISPLAYS (EVERY SECOND)
local function scanUIForWaves()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local highestWave = 0
    local waveSource = nil
    local waveTextFound = nil
    
    local function searchForWave(instance)
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
                    local num = tonumber(waveNum)
                    if num and num > highestWave and num < 1000 then
                        highestWave = num
                        waveSource = instance.Name
                        waveTextFound = text
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
    
    if highestWave > 0 and highestWave ~= lastUIWave then
        lastUIWave = highestWave
        addLog(string.format("🌊 WAVE DETECTED: %d", highestWave), Color3.new(0.3, 1, 0.3), true)
        addLog(string.format("   Source: %s", waveSource or "Unknown"), Color3.new(0.7, 0.7, 0.7))
        addLog(string.format("   Full Text: '%s'", waveTextFound or "N/A"), Color3.new(0.7, 0.7, 0.7))
        
        -- Update live display
        liveWaveLabel.Text = "🌊 Current Wave: " .. highestWave
        waveSourceLabel.Text = "Source: " .. (waveSource or "Unknown") .. " (UI Text)"
        liveWaveLabel.TextColor3 = highestWave >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
    end
end

--// MONITOR ALL REMOTE EVENTS
local function monitorRemoteEvents()
    addLog("━━━ MONITORING REMOTE EVENTS ━━━", Color3.new(1, 0.8, 0), true)
    
    local remoteCount = 0
    
    local function hookRemoteEvent(remote)
        if remote:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
            local oldFunc = remote.OnClientEvent
            remote.OnClientEvent = function(...)
                local args = {...}
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 3 then
                        argsStr = argsStr .. "..."
                        break
                    end
                    if type(arg) == "table" then
                        argsStr = argsStr .. "{table}"
                    else
                        argsStr = argsStr .. tostring(arg)
                    end
                    argsStr = argsStr .. (i < #args and ", " : "")
                end
                
                local isWaveRelated = string.lower(remote.Name):match("wave") or 
                                      string.lower(remote.Name):match("round") or
                                      string.lower(remote.Name):match("next") or
                                      string.lower(remote.Name):match("update") or
                                      string.lower(remote.Name):match("spawn")
                
                if isWaveRelated then
                    addLog(string.format("🔔 WAVE-RELATED REMOTE: %s fired", remote.Name), Color3.new(1, 0.5, 0), true)
                    addLog(string.format("   Args: %s", argsStr), Color3.new(1, 0.8, 0.5))
                else
                    -- Only log non-wave remotes if they contain numbers (potential data)
                    if argsStr:match("%d+") then
                        addLog(string.format("📡 Remote: %s fired (has numbers)", remote.Name), Color3.new(0.6, 0.6, 0.8))
                        addLog(string.format("   Args: %s", argsStr), Color3.new(0.7, 0.7, 0.7))
                    end
                end
                
                if oldFunc then oldFunc(...) end
            end
        end
    end
    
    local function scanForRemotes(instance)
        hookRemoteEvent(instance)
        for _, child in ipairs(instance:GetChildren()) do
            scanForRemotes(child)
        end
    end
    
    scanForRemotes(ReplicatedStorage)
    addLog(string.format("✅ Monitoring %d RemoteEvents", remoteCount), Color3.new(0.3, 1, 0.3))
end

--// MONITOR VALUE OBJECTS
local function monitorValueObjects()
    addLog("━━━ MONITORING VALUE OBJECTS ━━━", Color3.new(1, 0.8, 0), true)
    
    local function monitorValue(valueObj)
        if valueObj:IsA("IntValue") or valueObj:IsA("NumberValue") or valueObj:IsA("StringValue") then
            local lastValue = valueObj.Value
            valueObj.Changed:Connect(function(newValue)
                if lastValue ~= newValue then
                    local isWaveRelated = string.lower(valueObj.Name):match("wave") or 
                                          string.lower(valueObj.Name):match("round")
                    
                    if isWaveRelated then
                        addLog(string.format("⭐ WAVE VALUE: %s changed", valueObj.Name), Color3.new(1, 0.5, 0), true)
                        addLog(string.format("   %s → %s", lastValue, newValue), Color3.new(1, 0.8, 0.5))
                        
                        if type(newValue) == "number" and newValue > 0 then
                            lastUIWave = newValue
                            liveWaveLabel.Text = "🌊 Current Wave: " .. newValue
                            waveSourceLabel.Text = "Source: ValueObject - " .. valueObj.Name
                            liveWaveLabel.TextColor3 = newValue >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
                        end
                    else
                        -- Log value changes that contain numbers (potential wave data)
                        if tostring(newValue):match("%d+") and not isWaveRelated then
                            addLog(string.format("📊 Value: %s = %s", valueObj.Name, newValue), Color3.new(0.5, 0.5, 0.8))
                        end
                    end
                    lastValue = newValue
                end
            end)
        end
    end
    
    local function scanForValues(instance)
        monitorValue(instance)
        for _, child in ipairs(instance:GetChildren()) do
            scanForValues(child)
        end
    end
    
    scanForValues(player)
    scanForValues(ReplicatedStorage)
    addLog("✅ Monitoring Value objects", Color3.new(0.3, 1, 0.3))
end

--// LIST ALL REMOTES (FOR REFERENCE)
local function listAllRemotes()
    addLog("━━━ LISTING ALL REMOTES ━━━", Color3.new(1, 0.8, 0), true)
    
    local remoteNames = {}
    
    local function collectRemotes(instance)
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            table.insert(remoteNames, instance.Name .. " (" .. instance.ClassName .. ")")
        end
        for _, child in ipairs(instance:GetChildren()) do
            collectRemotes(child)
        end
    end
    
    collectRemotes(ReplicatedStorage)
    
    -- Sort and display
    table.sort(remoteNames)
    addLog(string.format("Found %d remotes:", #remoteNames), Color3.new(0.3, 1, 0.3))
    for i, name in ipairs(remoteNames) do
        if string.lower(name):match("wave") or string.lower(name):match("round") then
            addLog(string.format("  ⭐ %s", name), Color3.new(1, 0.8, 0))
        else
            addLog(string.format("  📡 %s", name), Color3.new(0.6, 0.6, 0.8))
        end
    end
end

--// SCAN FOR WAVE UI ELEMENTS (WITH HIGHLIGHT)
local function scanAndHighlightWaveUI()
    addLog("━━━ SCANNING FOR WAVE UI ELEMENTS ━━━", Color3.new(1, 0.8, 0), true)
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        addLog("❌ No PlayerGui found!", Color3.new(1, 0.3, 0.3))
        return 
    end
    
    local foundElements = {}
    
    local function searchForWaveElements(instance, path)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            if text:match("Wave") or text:match("WAVE") or text:match("wave") or 
               text:match("Round") or text:match("ROUND") then
                local numbers = text:match("%d+")
                table.insert(foundElements, {
                    instance = instance,
                    text = text,
                    numbers = numbers,
                    path = path .. "/" .. instance.Name
                })
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            searchForWaveElements(child, path .. "/" .. instance.Name)
        end
    end
    
    searchForWaveElements(playerGui, "PlayerGui")
    
    if #foundElements > 0 then
        addLog(string.format("Found %d wave-related UI elements:", #foundElements), Color3.new(0.3, 1, 0.3), true)
        for i, elem in ipairs(foundElements) do
            addLog(string.format("  %d. Text: '%s'", i, elem.text), Color3.new(1, 0.8, 0))
            addLog(string.format("     Path: %s", elem.path), Color3.new(0.7, 0.7, 0.7))
            addLog(string.format("     Numbers: %s", elem.numbers or "none"), Color3.new(0.7, 0.7, 0.7))
            
            -- Highlight the element
            local originalColor = elem.instance.BackgroundColor3
            for _ = 1, 3 do
                elem.instance.BackgroundColor3 = Color3.new(1, 0, 0)
                task.wait(0.3)
                elem.instance.BackgroundColor3 = Color3.new(0, 1, 0)
                task.wait(0.3)
            end
            elem.instance.BackgroundColor3 = originalColor
        end
    else
        addLog("No wave-related UI elements found. Start a raid first!", Color3.new(1, 0.5, 0))
    end
end

--// START MONITORING LOOP
local function startMonitorLoop()
    task.spawn(function()
        while true do
            if not paused then
                scanUIForWaves()
            end
            task.wait(0.5)
        end
    end)
end

--// BUTTON CONNECTIONS
pauseBtn.MouseButton1Click:Connect(function()
    paused = not paused
    pauseBtn.Text = paused and "▶️ START" or "⏸️ PAUSE"
    pauseBtn.BackgroundColor3 = paused and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(100, 50, 50)
    addLog(paused and "⏸️ Monitoring paused" or "▶️ Monitoring resumed", Color3.new(1, 0.8, 0))
end)

copyBtn.MouseButton1Click:Connect(function()
    local allText = ""
    for i = #eventLogs, 1, -1 do
        allText = allText .. eventLogs[i].text .. "\n"
    end
    if allText ~= "" then
        setclipboard(allText)
        addLog("✅ Console copied to clipboard!", Color3.new(0.3, 1, 0.3))
    else
        addLog("❌ No data to copy!", Color3.new(1, 0.3, 0.3))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    eventLogs = {}
    for _, child in ipairs(consoleContent:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    addLog("Console cleared", Color3.new(1, 0.8, 0))
end)

detectBtn.MouseButton1Click:Connect(function()
    scanAndHighlightWaveUI()
end)

scanRemotesBtn.MouseButton1Click:Connect(function()
    listAllRemotes()
end)

filterBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterText = string.lower(filterBox.Text)
    addLog(string.format("Filter set to: '%s'", filterText == "" and "none" or filterText), Color3.new(1, 0.8, 0))
end)

--// INITIALIZE
addLog("═══════════════════════════════════════════", Color3.new(1, 1, 0), true)
addLog("🔍 EVENT MONITOR STARTED (NO METATABLE VERSION)", Color3.new(1, 0.5, 0), true)
addLog("═══════════════════════════════════════════", Color3.new(1, 1, 0), true)

-- Start all monitors
monitorRemoteEvents()
monitorValueObjects()
startMonitorLoop()

-- List all remotes automatically
task.wait(2)
listAllRemotes()

addLog("✅ All monitors active!", Color3.new(0.3, 1, 0.3))
addLog("💡 TIPS:", Color3.new(1, 0.8, 0))
addLog("   • Watch for ⭐ marked events - these are wave-related", Color3.new(0.7, 0.7, 0.7))
addLog("   • When wave changes, you'll see it in the console", Color3.new(0.7, 0.7, 0.7))
addLog("   • Press 'SCAN UI' to find and flash wave displays", Color3.new(0.7, 0.7, 0.7))
addLog("   • Press 'SCAN REMOTES' to see all available remotes", Color3.new(0.7, 0.7, 0.7))
addLog("   • Use filter to show only specific events (ex: 'wave')", Color3.new(0.7, 0.7, 0.7))
addLog("   • Start a raid to see wave triggers in action!", Color3.new(1, 0.8, 0))

end)
