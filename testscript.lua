pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UIChangeDetector"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(255, 100, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "UI CHANGE DETECTOR - FIND WAVE ELEMENT"
title.TextColor3 = Color3.new(255, 255, 0)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 12
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local currentWaveDisplay = Instance.new("TextLabel")
currentWaveDisplay.Size = UDim2.new(1, -20, 0, 50)
currentWaveDisplay.Position = UDim2.new(0, 10, 0, 50)
currentWaveDisplay.Text = "Current Detected Wave: ???"
currentWaveDisplay.TextColor3 = Color3.new(0, 255, 0)
currentWaveDisplay.BackgroundColor3 = Color3.new(30, 30, 30)
currentWaveDisplay.TextSize = 18
currentWaveDisplay.Font = Enum.Font.SourceSansBold
currentWaveDisplay.Parent = mainFrame

local targetElementDisplay = Instance.new("TextLabel")
targetElementDisplay.Size = UDim2.new(1, -20, 0, 40)
targetElementDisplay.Position = UDim2.new(0, 10, 0, 105)
targetElementDisplay.Text = "Wave Source: Not found yet"
targetElementDisplay.TextColor3 = Color3.new(255, 255, 255)
targetElementDisplay.BackgroundColor3 = Color3.new(30, 30, 30)
targetElementDisplay.TextSize = 11
targetElementDisplay.Parent = mainFrame

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -20, 0, 400)
logScroll.Position = UDim2.new(0, 10, 0, 155)
logScroll.BackgroundColor3 = Color3.new(20, 20, 20)
logScroll.Parent = mainFrame

local logList = Instance.new("UIListLayout")
logList.Parent = logScroll
logList.Padding = UDim.new(0, 1)

local logContent = Instance.new("Frame")
logContent.Size = UDim2.new(1, 0, 0, 0)
logContent.BackgroundTransparency = 1
logContent.Parent = logScroll

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0, 565)
copyBtn.Text = "COPY ALL CHANGES"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local changes = {}
local waveSourceElement = nil
local currentWave = 0

local function addToLog(text, color)
    color = color or Color3.new(200, 200, 200)
    local time = os.date("%H:%M:%S")
    local logText = "[" .. time .. "] " .. text
    
    table.insert(changes, 1, {text = logText, color = color})
    if #changes > 100 then table.remove(changes) end
    
    -- Update UI
    for _, child in ipairs(logContent:GetChildren()) do
        child:Destroy()
    end
    
    for i = #changes, 1, -1 do
        local log = changes[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Text = log.text
        label.TextColor3 = log.color
        label.BackgroundTransparency = 1
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = logContent
    end
    
    task.wait()
    logScroll.CanvasPosition = Vector2.new(0, 0)
    logScroll.CanvasSize = UDim2.new(0, 0, 0, #changes * 20)
end

-- MONITOR ALL TEXT CHANGES IN REAL TIME
local function monitorAllTextChanges()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        addToLog("PlayerGui not found!", Color3.new(255, 0, 0))
        return 
    end
    
    addToLog("=== MONITORING ALL UI TEXT CHANGES ===", Color3.new(255, 255, 0))
    addToLog("Start a raid and watch for wave number changes!", Color3.new(0, 255, 0))
    
    local originalTexts = {}
    
    local function hookTextLabel(label)
        if originalTexts[label] then return end
        originalTexts[label] = label.Text
        
        -- Store old index
        local oldIndex = label.Changed
        label.Changed:Connect(function(property)
            if property == "Text" then
                local oldText = originalTexts[label]
                local newText = label.Text
                
                if oldText ~= newText then
                    originalTexts[label] = newText
                    
                    -- Check if this change contains a wave-like number
                    local numbers = {}
                    for num in string.gmatch(newText, "(%d+)") do
                        local n = tonumber(num)
                        if n and n > 0 and n < 600 then
                            table.insert(numbers, n)
                        end
                    end
                    
                    if #numbers > 0 then
                        -- This text change contains numbers
                        local info = string.format("UI Changed: [%s] '%s' -> '%s' | Numbers: %s", 
                            label.Name, 
                            oldText:sub(1, 30), 
                            newText:sub(1, 30),
                            table.concat(numbers, ", "))
                        
                        addToLog(info, Color3.new(100, 255, 100))
                        
                        -- Check if this looks like a wave display (2-3 digit number, no extra text)
                        local cleanNumber = newText:match("^(%d%d?%d?)$")
                        if cleanNumber then
                            local waveNum = tonumber(cleanNumber)
                            if waveNum and waveNum > 0 and waveNum < 600 then
                                addToLog("!!! POTENTIAL WAVE DISPLAY FOUND !!!", Color3.new(255, 200, 0))
                                addToLog("Element Name: " .. label.Name, Color3.new(255, 200, 0))
                                addToLog("Element Path: " .. label:GetFullName(), Color3.new(255, 200, 0))
                                addToLog("Wave Value: " .. waveNum, Color3.new(255, 200, 0))
                                
                                waveSourceElement = label
                                targetElementDisplay.Text = "Wave Source: " .. label.Name .. " (" .. label:GetFullName() .. ")"
                                targetElementDisplay.TextColor3 = Color3.new(0, 255, 0)
                                currentWave = waveNum
                                currentWaveDisplay.Text = "Current Detected Wave: " .. waveNum
                            end
                        end
                        
                        -- Also check for "Wave X" pattern
                        if string.find(string.lower(newText), "wave") or string.find(string.lower(newText), "round") then
                            for _, num in ipairs(numbers) do
                                if num > 0 and num < 600 then
                                    addToLog("!!! WAVE PATTERN DETECTED: " .. label.Name .. " = " .. newText, Color3.new(255, 200, 0))
                                    if not waveSourceElement then
                                        waveSourceElement = label
                                        targetElementDisplay.Text = "Wave Source (candidate): " .. label.Name
                                    end
                                    currentWave = num
                                    currentWaveDisplay.Text = "Current Detected Wave: " .. num
                                end
                            end
                        end
                    else
                        -- Log other changes for debugging
                        if string.len(newText) < 50 then
                            addToLog(string.format("UI Changed: [%s] '%s' -> '%s'", 
                                label.Name, oldText:sub(1, 20), newText:sub(1, 20)), Color3.new(150, 150, 150))
                        end
                    end
                end
            end
        end)
    end
    
    local function scanForTextLabels(instance)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            hookTextLabel(instance)
        end
        for _, child in pairs(instance:GetChildren()) do
            scanForTextLabels(child)
        end
    end
    
    scanForTextLabels(playerGui)
    addToLog("Monitoring " .. #originalTexts .. " UI elements", Color3.new(0, 255, 0))
end

-- Also monitor RemoteEvents for wave-related signals
local function monitorRemoteEvents()
    local function hookRemote(remote)
        if remote:IsA("RemoteEvent") then
            local oldFunc = remote.OnClientEvent
            remote.OnClientEvent = function(...)
                local args = {...}
                local argsStr = ""
                local hasWaveNumber = false
                
                for i, arg in ipairs(args) do
                    if type(arg) == "number" and arg > 0 and arg < 600 then
                        hasWaveNumber = true
                        argsStr = argsStr .. tostring(arg) .. " "
                    elseif type(arg) == "string" and (string.find(string.lower(arg), "wave") or string.find(string.lower(arg), "round")) then
                        hasWaveNumber = true
                        argsStr = argsStr .. "'" .. arg .. "' "
                    end
                end
                
                if hasWaveNumber then
                    addToLog(string.format("REMOTE EVENT: %s fired with wave data: %s", remote.Name, argsStr), Color3.new(255, 150, 0))
                end
                
                if oldFunc then oldFunc(...) end
            end
        end
    end
    
    local function scanForRemotes(instance)
        hookRemote(instance)
        for _, child in pairs(instance:GetChildren()) do
            scanForRemotes(child)
        end
    end
    
    scanForRemotes(ReplicatedStorage)
    addToLog("Monitoring RemoteEvents for wave signals", Color3.new(0, 255, 0))
end

-- Start monitoring
monitorAllTextChanges()
monitorRemoteEvents()

copyBtn.MouseButton1Click:Connect(function()
    local data = "UI CHANGE DETECTOR LOGS\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Detected Wave Source: " .. (waveSourceElement and waveSourceElement.Name or "Not found") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n\n"
    
    for i = #changes, 1, -1 do
        data = data .. changes[i].text .. "\n"
    end
    
    pcall(function()
        setclipboard(data)
        addToLog("Copied to clipboard!", Color3.new(0, 255, 0))
    end)
end)

-- Make draggable
local dragStart, dragPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        dragPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").TouchMoved:Connect(function(input)
    if dragStart then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X,
                                        dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

addToLog("UI CHANGE DETECTOR ACTIVE", Color3.new(0, 255, 0))
addToLog("Start a raid - the script will track EVERY UI change", Color3.new(255, 255, 0))
addToLog("When wave changes, it will show which UI element updated", Color3.new(255, 255, 0))

end)
