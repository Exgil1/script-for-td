--// WORKING WAVE MONITOR - FOR DELTA MOBILE
--// Based on your logs showing "StatValue" source

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveMonitor"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🌊 WAVE MONITOR"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- Current Wave (LARGE)
local currentWaveLabel = Instance.new("TextLabel")
currentWaveLabel.Size = UDim2.new(1, -20, 0, 70)
currentWaveLabel.Position = UDim2.new(0, 10, 0, 45)
currentWaveLabel.Text = "🌊 WAVE: ???"
currentWaveLabel.TextColor3 = Color3.new(0, 255, 0)
currentWaveLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
currentWaveLabel.Font = Enum.Font.GothamBold
currentWaveLabel.TextSize = 28
currentWaveLabel.Parent = mainFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 120)
statusLabel.Text = "Status: Monitoring"
statusLabel.TextColor3 = Color3.new(0, 255, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Buttons
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.45, -5, 0, 35)
copyBtn.Position = UDim2.new(0, 10, 0, 155)
copyBtn.Text = "📋 COPY LOG"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.45, -5, 0, 35)
closeBtn.Position = UDim2.new(0.52, 0, 0, 155)
closeBtn.Text = "❌ CLOSE"
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame

-- Auto-End Toggle
local autoEndBtn = Instance.new("TextButton")
autoEndBtn.Size = UDim2.new(1, -20, 0, 40)
autoEndBtn.Position = UDim2.new(0, 10, 0, 200)
autoEndBtn.Text = "🎯 AUTO-END AT WAVE 408: OFF"
autoEndBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
autoEndBtn.TextColor3 = Color3.new(1, 1, 1)
autoEndBtn.Font = Enum.Font.GothamBold
autoEndBtn.TextSize = 14
autoEndBtn.Parent = mainFrame

-- Variables
local currentWave = 0
local waveHistory = {}
local autoEndActive = false
local raidActive = false

-- Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local raidStop = nil

-- Find raid stop remote
pcall(function()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local remotes = events:FindFirstChild("Remotes")
        if remotes then
            raidStop = remotes:FindFirstChild("RaidStop")
        end
    end
end)

-- Function to end raid
local function endRaid()
    if raidStop then
        pcall(function()
            raidStop:FireServer()
            addToLog("✅ Raid ended automatically at wave " .. currentWave, Color3.new(0, 255, 0))
            statusLabel.Text = "Status: Raid Ended"
            raidActive = false
        end)
    else
        addToLog("❌ Cannot end raid - RaidStop remote not found", Color3.new(255, 0, 0))
    end
end

-- Add to log
local function addToLog(msg, color)
    print(msg)
    -- Update status if it's important
    if string.find(msg, "Wave:") then
        -- Don't spam status
    end
end

-- Track highest wave (to avoid detecting lower waves)
local highestWaveSeen = 0
local stableWave = 0
local stableCount = 0

-- Main monitoring loop
spawn(function()
    addToLog("=== WAVE MONITOR STARTED ===", Color3.new(0, 255, 0))
    addToLog("Looking for StatValue wave displays...", Color3.new(255, 255, 0))
    
    while true do
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            local foundWaves = {}
            
            -- Find all wave numbers from StatValue or similar
            local function findWaveNumbers(instance)
                if instance:IsA("TextLabel") then
                    local text = instance.Text or ""
                    -- Look for numbers
                    local numbers = text:match("(%d+)")
                    if numbers and #numbers >= 1 and #numbers <= 3 then
                        local num = tonumber(numbers)
                        if num and num > 0 and num < 500 then
                            -- Check if this looks like a wave display
                            local lowerText = string.lower(text)
                            if lowerText:match("wave") or lowerText:match("round") or instance.Name == "StatValue" then
                                table.insert(foundWaves, {wave = num, source = instance.Name, text = text})
                            end
                        end
                    end
                end
                
                for _, child in pairs(instance:GetChildren()) do
                    findWaveNumbers(child)
                end
            end
            
            findWaveNumbers(playerGui)
            
            -- Find the highest wave (current wave is usually highest)
            local highest = 0
            local bestSource = nil
            
            for _, w in pairs(foundWaves) do
                if w.wave > highest then
                    highest = w.wave
                    bestSource = w.source
                end
            end
            
            -- Update wave if found
            if highest > 0 and highest ~= currentWave then
                -- Only update if it's not a huge jump down
                if highest > currentWave or (currentWave - highest) < 50 then
                    currentWave = highest
                    raidActive = true
                    
                    -- Update display
                    if currentWave >= 408 then
                        currentWaveLabel.Text = "⚠️ WAVE " .. currentWave .. " ⚠️"
                        currentWaveLabel.TextColor3 = Color3.new(255, 0, 0)
                        statusLabel.Text = "Status: TARGET REACHED!"
                        statusLabel.TextColor3 = Color3.new(255, 0, 0)
                        
                        -- Auto end if enabled
                        if autoEndActive then
                            addToLog("🎯 Target wave reached! Ending raid...", Color3.new(255, 255, 0))
                            endRaid()
                            autoEndActive = false
                            autoEndBtn.Text = "🎯 AUTO-END AT WAVE 408: OFF"
                            autoEndBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
                        end
                    else
                        currentWaveLabel.Text = "🌊 WAVE " .. currentWave
                        currentWaveLabel.TextColor3 = Color3.new(0, 255, 0)
                        statusLabel.Text = "Status: In Raid - Wave " .. currentWave
                        statusLabel.TextColor3 = Color3.new(0, 255, 0)
                    end
                    
                    -- Log wave change
                    addToLog("Wave: " .. currentWave, Color3.new(0, 255, 0))
                    
                    -- Store in history
                    table.insert(waveHistory, 1, {
                        wave = currentWave,
                        time = os.date("%H:%M:%S"),
                        source = bestSource or "unknown"
                    })
                    
                    -- Keep last 50
                    while #waveHistory > 50 do
                        table.remove(waveHistory)
                    end
                end
            end
            
            -- Check if raid ended (no waves found for a bit)
            if highest == 0 and raidActive then
                raidActive = false
                currentWave = 0
                currentWaveLabel.Text = "🌊 WAVE: ???"
                currentWaveLabel.TextColor3 = Color3.new(255, 255, 0)
                statusLabel.Text = "Status: No Raid Detected"
                statusLabel.TextColor3 = Color3.new(255, 255, 0)
                addToLog("Raid ended", Color3.new(255, 255, 0))
            end
        end
        
        wait(0.3)
    end
end)

-- Copy log function
copyBtn.MouseButton1Click:Connect(function()
    local logData = "=== WAVE HISTORY ===\n"
    logData = logData .. "Total waves recorded: " .. #waveHistory .. "\n"
    logData = logData .. "Current wave: " .. currentWave .. "\n"
    logData = logData .. "Auto-end: " .. (autoEndActive and "ON" or "OFF") .. "\n"
    logData = logData .. "\nWave Log (most recent first):\n"
    logData = logData .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    for i, w in ipairs(waveHistory) do
        logData = logData .. string.format("[%s] Wave %d\n", w.time, w.wave)
    end
    
    pcall(function()
        setclipboard(logData)
        statusLabel.Text = "✅ Copied to clipboard!"
        statusLabel.TextColor3 = Color3.new(0, 255, 0)
        wait(2)
        if raidActive then
            statusLabel.Text = "Status: In Raid - Wave " .. currentWave
        else
            statusLabel.Text = "Status: Monitoring"
        end
    end)
end)

-- Auto-end toggle
autoEndBtn.MouseButton1Click:Connect(function()
    autoEndActive = not autoEndActive
    if autoEndActive then
        autoEndBtn.Text = "🎯 AUTO-END AT WAVE 408: ON"
        autoEndBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        addToLog("Auto-end ENABLED - Will end raid at wave 408", Color3.new(0, 255, 0))
        statusLabel.Text = "Status: Auto-End ON - Wave " .. currentWave
    else
        autoEndBtn.Text = "🎯 AUTO-END AT WAVE 408: OFF"
        autoEndBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        addToLog("Auto-end DISABLED", Color3.new(255, 255, 0))
    end
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    addToLog("Wave Monitor Closed", Color3.new(255, 255, 0))
end)

-- Make draggable for mobile
local dragStart = nil
local dragStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function()
    dragStart = nil
end)

game:GetService("UserInputService").TouchMoved:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
                                        dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

addToLog("✅ Ready! Start a raid to detect waves", Color3.new(0, 255, 0))
addToLog("💡 Toggle AUTO-END to automatically end at wave 408", Color3.new(255, 255, 0))
