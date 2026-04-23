--// COMPLETE UI & EVENT MONITOR - FINDS WAVE TRIGGERS
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
mainFrame.Size = UDim2.new(0, 600, 0, 700)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -350)
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
pauseBtn.Size = UDim2.new(0.23, -5, 1, 0)
pauseBtn.Text = "⏸️ PAUSE"
pauseBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
pauseBtn.TextColor3 = Color3.new(1, 1, 1)
pauseBtn.Font = Enum.Font.GothamBold
pauseBtn.TextSize = 11
pauseBtn.Parent = btnFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.23, -5, 1, 0)
copyBtn.Position = UDim2.new(0.24, 0, 0, 0)
copyBtn.Text = "📋 COPY ALL"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.Parent = btnFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.23, -5, 1, 0)
clearBtn.Position = UDim2.new(0.48, 0, 0, 0)
clearBtn.Text = "🗑️ CLEAR"
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 50)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 11
clearBtn.Parent = btnFrame

local detectBtn = Instance.new("TextButton")
detectBtn.Size = UDim2.new(0.23, -5, 1, 0)
detectBtn.Position = UDim2.new(0.72, 0, 0, 0)
detectBtn.Text = "🎯 DETECT WAVE"
detectBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
detectBtn.TextColor3 = Color3.new(1, 1, 1)
detectBtn.Font = Enum.Font.GothamBold
detectBtn.TextSize = 11
detectBtn.Parent = btnFrame

-- Live Wave Display
local waveDisplayFrame = Instance.new("Frame")
waveDisplayFrame.Size = UDim2.new(1, -10, 0, 60)
waveDisplayFrame.Position = UDim2.new(0, 5, 0, 120)
waveDisplayFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
waveDisplayFrame.BorderSizePixel = 1
waveDisplayFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
waveDisplayFrame.Parent = mainFrame

local liveWaveLabel = Instance.new("TextLabel")
liveWaveLabel.Size = UDim2.new(1, -10, 0.5, 0)
liveWaveLabel.Position = UDim2.new(0, 5, 0, 5)
liveWaveLabel.Text = "🌊 Current Wave: Detecting..."
liveWaveLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
liveWaveLabel.BackgroundTransparency = 1
liveWaveLabel.Font = Enum.Font.GothamBold
liveWaveLabel.TextSize = 16
liveWaveLabel.TextXAlignment = Enum.TextXAlignment.Left
liveWaveLabel.Parent = waveDisplayFrame

local waveSourceLabel = Instance.new("TextLabel")
waveSourceLabel.Size = UDim2.new(1, -10, 0.5, 0)
waveSourceLabel.Position = UDim2.new(0, 5, 0, 35)
waveSourceLabel.Text = "Source: None"
waveSourceLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
waveSourceLabel.BackgroundTransparency = 1
waveSourceLabel.Font = Enum.Font.Gotham
waveSourceLabel.TextSize = 10
waveSourceLabel.TextXAlignment = Enum.TextXAlignment.Left
waveSourceLabel.Parent = waveDisplayFrame

-- Console Output
local consoleScroll = Instance.new("ScrollingFrame")
consoleScroll.Size = UDim2.new(1, -10, 0, 440)
consoleScroll.Position = UDim2.new(0, 5, 0, 185)
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

--// MONITOR ALL TEXT CHANGES IN UI
local function monitorUITextChanges()
    addLog("━━━ MONITORING UI TEXT CHANGES ━━━", Color3.new(1, 0.8, 0), true)
    
    local originalTexts = {}
    
    local function hookTextLabel(label)
        if originalTexts[label] then return end
        originalTexts[label] = label.Text
        
        local metatable = getrawmetatable(label)
        if metatable then
            local oldIndex = metatable.__index
            metatable.__index = function(self, key)
                if key == "Text" then
                    return originalTexts[self]
                end
                return oldIndex(self, key)
            end
            
            local newindex = metatable.__newindex
            metatable.__newindex = function(self, key, value)
                if key == "Text" and originalTexts[self] ~= value then
                    local oldValue = originalTexts[self]
                    originalTexts[self] = value
                    
                    -- Check if this looks like wave text
                    local waveMatch = value:match("(%d+)")
                    if waveMatch and (string.lower(value):match("wave") or string.lower(value):match("round")) then
                        addLog(string.format("📺 UI TEXT CHANGED: %s", self:GetFullName()), Color3.new(0.3, 0.8, 1), true)
                        addLog(string.format("   Old: '%s' → New: '%s'", oldValue or "nil", value), Color3.new(0.7, 0.7, 1))
                        addLog(string.format("   ⭐ Detected Wave Number: %s", waveMatch), Color3.new(0.3, 1, 0.3), true)
                        
                        -- Update live wave display
                        liveWaveLabel.Text = "🌊 Current Wave: " .. waveMatch
                        waveSourceLabel.Text = "Source: " .. self.Name .. " (" .. self:GetFullName() .. ")"
                        liveWaveLabel.TextColor3 = tonumber(waveMatch) >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
                    else
                        addLog(string.format("📺 UI TEXT: %s changed", self.Name), Color3.new(0.5, 0.5, 0.8))
                        addLog(string.format("   '%s' → '%s'", oldValue or "nil", value), Color3.new(0.6, 0.6, 0.8))
                    end
                end
                return newindex(self, key, value)
            end
        end
    end
    
    local function scanForTextLabels(instance)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            hookTextLabel(instance)
        end
        for _, child in ipairs(instance:GetChildren()) do
            scanForTextLabels(child)
        end
    end
    
    -- Scan all GUIs
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        scanForTextLabels(playerGui)
        addLog("✅ Monitoring PlayerGui text labels", Color3.new(0.3, 1, 0.3))
    end
    
    local coreGui = game:GetService("CoreGui")
    scanForTextLabels(coreGui)
    addLog("✅ Monitoring CoreGui text labels", Color3.new(0.3, 1, 0.3))
end

--// MONITOR ALL REMOTE EVENTS
local function monitorRemoteEvents()
    addLog("━━━ MONITORING REMOTE EVENTS ━━━", Color3.new(1, 0.8, 0), true)
    
    local function hookRemoteEvent(remote)
        if remote:IsA("RemoteEvent") then
            local oldFunc = remote.OnClientEvent
            remote.OnClientEvent = function(...)
                local args = {...}
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 3 then
                        argsStr = argsStr .. tostring(arg):sub(1, 50) .. (i < #args and ", ..." or "")
                        break
                    end
                    argsStr = argsStr .. tostring(arg) .. (i < #args and ", " or "")
                end
                
                local isWaveRelated = string.lower(remote.Name):match("wave") or 
                                      string.lower(remote.Name):match("round") or
                                      string.lower(remote.Name):match("next") or
                                      string.lower(remote.Name):match("update")
                
                if isWaveRelated then
                    addLog(string.format("🔔 WAVE-RELATED REMOTE: %s fired", remote.Name), Color3.new(1, 0.5, 0), true)
                    addLog(string.format("   Args: %s", argsStr), Color3.new(1, 0.8, 0.5))
                else
                    addLog(string.format("📡 RemoteEvent: %s fired", remote.Name), Color3.new(0.6, 0.6, 0.8))
                    addLog(string.format("   Args: %s", argsStr), Color3.new(0.7, 0.7, 0.7))
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
    addLog("✅ Monitoring all RemoteEvents", Color3.new(0.3, 1, 0.3))
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
                        
                        if type(newValue) == "number" then
                            liveWaveLabel.Text = "🌊 Current Wave: " .. newValue
                            waveSourceLabel.Text = "Source: ValueObject - " .. valueObj.Name
                            liveWaveLabel.TextColor3 = newValue >= 408 and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
                        end
                    else
                        addLog(string.format("📊 Value changed: %s (%s)", valueObj.Name, valueObj.ClassName), Color3.new(0.5, 0.5, 0.8))
                        addLog(string.format("   %s → %s", lastValue, newValue), Color3.new(0.6, 0.6, 0.8))
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
    addLog("✅ Monitoring all Value objects", Color3.new(0.3, 1, 0.3))
end

--// MONITOR BINDABLE EVENTS
local function monitorBindableEvents()
    addLog("━━━ MONITORING BINDABLE EVENTS ━━━", Color3.new(1, 0.8, 0), true)
    
    local function hookBindable(bindable)
        if bindable:IsA("BindableEvent") then
            local oldFunc = bindable.Event
            bindable.Event = function(...)
                local args = {...}
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 3 then
                        argsStr = argsStr .. "..."
                        break
                    end
                    argsStr = argsStr .. tostring(arg) .. (i < #args and ", " : "")
                end
                
                addLog(string.format("🔗 BindableEvent: %s fired", bindable.Name), Color3.new(0.6, 0.6, 0.8))
                addLog(string.format("   Args: %s", argsStr), Color3.new(0.7, 0.7, 0.7))
                
                if oldFunc then oldFunc(...) end
            end
        end
    end
    
    local function scanForBindables(instance)
        hookBindable(instance)
        for _, child in ipairs(instance:GetChildren()) do
            scanForBindables(child)
        end
    end
    
    scanForBindables(ReplicatedStorage)
    addLog("✅ Monitoring BindableEvents", Color3.new(0.3, 1, 0.3))
end

--// MONITOR ATTRIBUTE CHANGES
local function monitorAttributes()
    addLog("━━━ MONITORING ATTRIBUTES ━━━", Color3.new(1, 0.8, 0), true)
    
    local function monitorInstanceAttributes(instance)
        local function onAttributeChanged(attrName)
            return function()
                local newValue = instance:GetAttribute(attrName)
                addLog(string.format("🏷️ Attribute changed: %s.%s", instance.Name, attrName), Color3.new(0.5, 0.5, 0.8))
                addLog(string.format("   New value: %s", tostring(newValue)), Color3.new(0.6, 0.6, 0.8))
                
                if string.lower(attrName):match("wave") and type(newValue) == "number" then
                    liveWaveLabel.Text = "🌊 Current Wave: " .. newValue
                    waveSourceLabel.Text = "Source: Attribute - " .. instance.Name .. "." .. attrName
                end
            end
        end
        
        local attributes = instance:GetAttributes()
        for attrName, _ in pairs(attributes) do
            instance:GetAttributeChangedSignal(attrName):Connect(onAttributeChanged(attrName))
        end
    end
    
    local function scanForAttributes(instance)
        monitorInstanceAttributes(instance)
        for _, child in ipairs(instance:GetChildren()) do
            scanForAttributes(child)
        end
    end
    
    scanForAttributes(workspace)
    scanForAttributes(player)
    addLog("✅ Monitoring attribute changes", Color3.new(0.3, 1, 0.3))
end

--// MONITOR WORKSPACE SIGNALS
local function monitorWorkspace()
    addLog("━━━ MONITORING WORKSPACE ━━━", Color3.new(1, 0.8, 0), true)
    
    -- Monitor new enemies spawning
    workspace.ChildAdded:Connect(function(child)
        local nameLower = string.lower(child.Name)
        if nameLower:match("enemy") or nameLower:match("zombie") or nameLower:match("mob") or nameLower:match("creep") then
            addLog(string.format("👾 NEW ENEMY SPAWNED: %s", child.Name), Color3.new(1, 0.5, 0.5), true)
        end
    end)
    
    -- Monitor wave-related parts
    local function scanForWaveParts(instance)
        if instance:IsA("BasePart") and string.lower(instance.Name):match("wave") then
            addLog(string.format("🔧 Wave-related part found: %s", instance.Name), Color3.new(0.5, 0.8, 1))
        end
        for _, child in ipairs(instance:GetChildren()) do
            scanForWaveParts(child)
        end
    end
    
    scanForWaveParts(workspace)
    addLog("✅ Monitoring workspace for enemies and wave parts", Color3.new(0.3, 1, 0.3))
end

--// MANUAL WAVE DETECTION FUNCTION
local function manualWaveDetection()
    addLog("━━━ MANUAL WAVE DETECTION ━━━", Color3.new(1, 0.8, 0), true)
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        addLog("❌ No PlayerGui found!", Color3.new(1, 0.3, 0.3))
        return 
    end
    
    local foundWaves = {}
    
    local function searchForWaveNumbers(instance, path)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            local numbers = text:match("%d+")
            if numbers and (#text < 50) then
                local num = tonumber(numbers)
                if num and num > 0 and num < 1000 then
                    table.insert(foundWaves, {
                        text = text,
                        number = num,
                        path = path .. "/" .. instance.Name,
                        instance = instance
                    })
                end
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            searchForWaveNumbers(child, path .. "/" .. instance.Name)
        end
    end
    
    searchForWaveNumbers(playerGui, "PlayerGui")
    
    if #foundWaves > 0 then
        addLog(string.format("Found %d potential wave displays:", #foundWaves), Color3.new(0.3, 1, 0.3), true)
        for i, wave in ipairs(foundWaves) do
            addLog(string.format("  %d. Wave: %d | Text: '%s'", i, wave.number, wave.text), Color3.new(1, 0.8, 0))
            addLog(string.format("     Path: %s", wave.path), Color3.new(0.7, 0.7, 0.7))
            
            -- Highlight the found UI element
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Adornee = wave.instance
            highlight.Size = wave.instance.AbsoluteSize
            highlight.Color3 = Color3.new(1, 0, 0)
            highlight.Transparency = 0.5
            highlight.Visible = true
            highlight.ZIndex = 10
            highlight.Parent = wave.instance
            
            task.delay(3, function()
                highlight:Destroy()
            end)
        end
    else
        addLog("No wave numbers found in UI. Start a raid first!", Color3.new(1, 0.5, 0))
    end
end

--// START ALL MONITORS
addLog("═══════════════════════════════════════════", Color3.new(1, 1, 0), true)
addLog("🔍 EVENT MONITOR STARTED - LOOKING FOR WAVE TRIGGERS", Color3.new(1, 0.5, 0), true)
addLog("═══════════════════════════════════════════", Color3.new(1, 1, 0), true)

-- Start monitoring
monitorUITextChanges()
monitorRemoteEvents()
monitorValueObjects()
monitorBindableEvents()
monitorAttributes()
monitorWorkspace()

-- Button connections
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
        addLog("✅ Full console copied to clipboard!", Color3.new(0.3, 1, 0.3))
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
    manualWaveDetection()
end)

filterBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterText = string.lower(filterBox.Text)
    addLog(string.format("Filter set to: '%s'", filterText == "" and "none" or filterText), Color3.new(1, 0.8, 0))
end)

addLog("✅ All monitors active! Start a raid to see wave triggers", Color3.new(0.3, 1, 0.3))
addLog("💡 TIPS:", Color3.new(1, 0.8, 0))
addLog("   • Watch for ⭐ marked events - these are wave-related", Color3.new(0.7, 0.7, 0.7))
addLog("   • When wave changes, you'll see what UI element updates", Color3.new(0.7, 0.7, 0.7))
addLog("   • Press 'DETECT WAVE' to find and highlight wave displays", Color3.new(0.7, 0.7, 0.7))
addLog("   • Use filter to show only specific events (ex: 'wave')", Color3.new(0.7, 0.7, 0.7))

end)
