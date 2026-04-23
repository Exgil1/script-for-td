pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UIChangeDetector"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 650)
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
targetElementDisplay.Size = UDim2.new(1, -20, 0, 50)
targetElementDisplay.Position = UDim2.new(0, 10, 0, 105)
targetElementDisplay.Text = "Wave Source: Not found yet"
targetElementDisplay.TextColor3 = Color3.new(255, 255, 255)
targetElementDisplay.BackgroundColor3 = Color3.new(30, 30, 30)
targetElementDisplay.TextSize = 11
targetElementDisplay.TextWrapped = true
targetElementDisplay.Parent = mainFrame

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -20, 0, 420)
logScroll.Position = UDim2.new(0, 10, 0, 165)
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
copyBtn.Size = UDim2.new(0.44, -5, 0, 35)
copyBtn.Position = UDim2.new(0.03, 0, 0, 595)
copyBtn.Text = "COPY LOGS"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.44, -5, 0, 35)
clearBtn.Position = UDim2.new(0.52, 0, 0, 595)
clearBtn.Text = "CLEAR LOGS"
clearBtn.BackgroundColor3 = Color3.new(150, 50, 0)
clearBtn.TextColor3 = Color3.new(255, 255, 255)
clearBtn.TextSize = 12
clearBtn.Parent = mainFrame

local changes = {}
local waveSourceElement = nil
local waveSourcePath = ""
local currentWave = 0

local function addToLog(text, color)
    color = color or Color3.new(200, 200, 200)
    local time = os.date("%H:%M:%S")
    local logText = "[" .. time .. "] " .. text
    
    table.insert(changes, 1, {text = logText, color = color})
    if #changes > 200 then 
        for i = 200, #changes do table.remove(changes) end
    end
    
    -- Update UI
    for _, child in ipairs(logContent:GetChildren()) do
        child:Destroy()
    end
    
    local count = 0
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
        count = count + 1
        if count > 100 then break end
    end
    
    task.wait()
    logScroll.CanvasPosition = Vector2.new(0, 0)
    logScroll.CanvasSize = UDim2.new(0, 0, 0, math.min(#changes, 100) * 20)
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
    local lastLogTime = 0
    
    local function getFullPath(instance)
        local path = instance.Name
        local parent = instance.Parent
        while parent and parent ~= playerGui do
            path = parent.Name .. "/" .. path
            parent = parent.Parent
        end
        return path
    end
    
    local function hookTextLabel(label)
        if originalTexts[label] then return end
        originalTexts[label] = label.Text
        
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
                    
                    if #numbers > 0 and newText:len() < 30 then
                        -- This text change contains numbers
                        local info = string.format("UI Changed: [%s] '%s' -> '%s' | Numbers: %s", 
                            label.Name, 
                            oldText:sub(1, 20), 
                            newText:sub(1, 20),
                            table.concat(numbers, ", "))
                        
                        addToLog(info, Color3.new(100, 255, 100))
                        
                        -- Check if this looks like a wave display (2-3 digit number)
                        local cleanNumber = newText:match("^(%d%d?%d?)$")
                        if cleanNumber then
                            local waveNum = tonumber(cleanNumber)
                            if waveNum and waveNum > 0 and waveNum < 600 and waveNum ~= currentWave then
                                currentWave = waveNum
                                local fullPath = getFullPath(label)
                                
                                addToLog("!!! WAVE SOURCE FOUND !!!", Color3.new(255, 200, 0))
                                addToLog("Element Name: " .. label.Name, Color3.new(255, 200, 0))
                                addToLog("Element Path: " .. fullPath, Color3.new(255, 200, 0))
                                addToLog("Wave Value: " .. waveNum, Color3.new(255, 200, 0))
                                
                                waveSourceElement = label
                                waveSourcePath = fullPath
                                targetElementDisplay.Text = "Wave Source: " .. label.Name .. "\nPath: " .. fullPath
                                targetElementDisplay.TextColor3 = Color3.new(0, 255, 0)
                                currentWaveDisplay.Text = "Current Wave: " .. waveNum
                                currentWaveDisplay.TextColor3 = Color3.new(0, 255, 0)
                            end
                        end
                        
                        -- Also check for "Wave X" pattern
                        if string.find(string.lower(newText), "wave") or string.find(string.lower(newText), "round") then
                            for _, num in ipairs(numbers) do
                                if num > 0 and num < 600 and num ~= currentWave then
                                    currentWave = num
                                    local fullPath = getFullPath(label)
                                    
                                    addToLog("!!! WAVE PATTERN DETECTED", Color3.new(255, 200, 0))
                                    addToLog("Element: " .. label.Name, Color3.new(255, 200, 0))
                                    addToLog("Text: " .. newText, Color3.new(255, 200, 0))
                                    addToLog("Path: " .. fullPath, Color3.new(255, 200, 0))
                                    
                                    if not waveSourceElement then
                                        waveSourceElement = label
                                        waveSourcePath = fullPath
                                        targetElementDisplay.Text = "Wave Candidate: " .. label.Name .. "\nPath: " .. fullPath
                                    end
                                    currentWaveDisplay.Text = "Current Wave: " .. num
                                end
                            end
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

-- Manual wave detection function
local function manualDetectWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        addToLog("No PlayerGui found!", Color3.new(255, 0, 0))
        return 
    end
    
    addToLog("=== MANUAL SCAN FOR WAVE DISPLAYS ===", Color3.new(255, 255, 0))
    
    local function scanForWaves(instance, path)
        if instance:IsA("TextLabel") then
            local text = instance.Text or ""
            local lowerText = string.lower(text)
            
            if string.find(lowerText, "wave") or string.find(lowerText, "round") then
                local numbers = text:match("(%d+)")
                if numbers then
                    addToLog("Found: " .. instance.Name, Color3.new(100, 255, 100))
                    addToLog("  Text: " .. text, Color3.new(200, 200, 200))
                    addToLog("  Path: " .. path, Color3.new(200, 200, 200))
                end
            end
            
            -- Also find pure number displays
            local pureNum = text:match("^(%d%d?%d?)$")
            if pureNum and tonumber(pureNum) > 0 and tonumber(pureNum) < 600 then
                addToLog("Pure Number Display: " .. instance.Name, Color3.new(100, 255, 100))
                addToLog("  Number: " .. pureNum, Color3.new(200, 200, 200))
                addToLog("  Path: " .. path, Color3.new(200, 200, 200))
            end
        end
        
        for _, child in pairs(instance:GetChildren()) do
            scanForWaves(child, path .. "/" .. child.Name)
        end
    end
    
    scanForWaves(playerGui, "PlayerGui")
    addToLog("=== MANUAL SCAN COMPLETE ===", Color3.new(255, 255, 0))
end

-- Start monitoring
monitorAllTextChanges()

-- Button functions
copyBtn.MouseButton1Click:Connect(function()
    local data = "UI CHANGE DETECTOR LOGS\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Detected Wave Source: " .. (waveSourceElement and waveSourceElement.Name or "Not found") .. "\n"
    data = data .. "Wave Source Path: " .. waveSourcePath .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n\n"
    
    for i = #changes, 1, -1 do
        data = data .. changes[i].text .. "\n"
    end
    
    -- Try multiple copy methods for Delta Mobile
    local success = false
    
    -- Method 1: setclipboard
    success = pcall(function()
        setclipboard(data)
    end)
    
    if success then
        addToLog("Logs copied to clipboard!", Color3.new(0, 255, 0))
    else
        -- Method 2: tostring print (user can manually copy)
        print("=== COPY THIS DATA ===")
        print(data)
        print("=== END DATA ===")
        addToLog("Could not copy automatically! Check executor console for data", Color3.new(255, 255, 0))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    changes = {}
    for _, child in ipairs(logContent:GetChildren()) do
        child:Destroy()
    end
    addToLog("Logs cleared", Color3.new(255, 255, 0))
end)

-- Add manual scan button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.44, -5, 0, 30)
scanBtn.Position = UDim2.new(0.03, 0, 0, 635)
scanBtn.Text = "MANUAL SCAN"
scanBtn.BackgroundColor3 = Color3.new(100, 100, 0)
scanBtn.TextColor3 = Color3.new(255, 255, 255)
scanBtn.TextSize = 11
scanBtn.Parent = mainFrame

scanBtn.MouseButton1Click:Connect(function()
    manualDetectWave()
end)

-- Make frame taller to fit new button
mainFrame.Size = UDim2.new(0, 400, 0, 680)

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
addToLog("Press MANUAL SCAN to scan current UI for wave displays", Color3.new(255, 255, 0))

end)
