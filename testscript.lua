--// DELTA MOBILE - GUI WAVE MONITOR WITH COPY BUTTON
--// NO COMPLEX FUNCTIONS - SHOULD WORK 100%

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create GUI (using only basic properties)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveMonitorGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🌊 WAVE MONITOR"
title.TextColor3 = Color3.new(255, 255, 255)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Big Wave Display
local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, -20, 0, 80)
waveDisplay.Position = UDim2.new(0, 10, 0, 50)
waveDisplay.Text = "Wave: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(30, 30, 30)
waveDisplay.TextSize = 32
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

-- Status
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 30)
statusText.Position = UDim2.new(0, 10, 0, 140)
statusText.Text = "Status: Monitoring"
statusText.TextColor3 = Color3.new(255, 255, 255)
statusText.BackgroundColor3 = Color3.new(30, 30, 30)
statusText.TextSize = 12
statusText.Parent = mainFrame

-- Log Scroll Frame
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 0, 150)
logFrame.Position = UDim2.new(0, 10, 0, 180)
logFrame.BackgroundColor3 = Color3.new(20, 20, 20)
logFrame.BorderSizePixel = 1
logFrame.BorderColor3 = Color3.new(100, 100, 100)
logFrame.Parent = mainFrame

local logList = Instance.new("UIListLayout")
logList.Parent = logFrame
logList.Padding = UDim.new(0, 2)

local logContent = Instance.new("Frame")
logContent.Size = UDim2.new(1, 0, 0, 0)
logContent.BackgroundTransparency = 1
logContent.Parent = logFrame

-- Buttons
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.45, -5, 0, 40)
copyButton.Position = UDim2.new(0, 10, 0, 340)
copyButton.Text = "📋 COPY LOGS"
copyButton.BackgroundColor3 = Color3.new(0, 100, 200)
copyButton.TextColor3 = Color3.new(255, 255, 255)
copyButton.TextSize = 14
copyButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.45, -5, 0, 40)
closeButton.Position = UDim2.new(0.52, 0, 0, 340)
closeButton.Text = "❌ CLOSE"
closeButton.BackgroundColor3 = Color3.new(200, 50, 50)
closeButton.TextColor3 = Color3.new(255, 255, 255)
closeButton.TextSize = 14
closeButton.Parent = mainFrame

-- Variables
local waveHistory = {}  -- Store {wave, time}
local currentWave = 0
local lastWave = 0
local isInRaid = false

-- Add log to GUI
local function addLog(text, color)
    color = color or Color3.new(200, 200, 200)
    local time = os.date("%H:%M:%S")
    local logText = "[" .. time .. "] " .. text
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Text = logText
    label.TextColor3 = color
    label.BackgroundTransparency = 1
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = logContent
    
    -- Store in history (for copy)
    table.insert(waveHistory, 1, {text = logText, color = color})
    
    -- Keep only last 100 logs
    while #waveHistory > 100 do
        table.remove(waveHistory)
    end
    
    -- Keep only last 20 visible logs
    local children = logContent:GetChildren()
    if #children > 20 then
        children[#children]:Destroy()
    end
    
    -- Auto scroll to top
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, 0)
    logFrame.CanvasSize = UDim2.new(0, 0, 0, #children * 20)
end

-- Simple wave detection
local function detectWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local highest = 0
    
    local function search(instance)
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                -- Try different wave patterns
                local num = text:match("Wave%s*(%d+)")
                if not num then num = text:match("WAVE%s*(%d+)") end
                if not num then num = text:match("wave%s*(%d+)") end
                if not num then num = text:match("Round%s*(%d+)") end
                if not num then num = text:match("W(%d+)") end
                
                if num then
                    local waveNum = tonumber(num)
                    if waveNum and waveNum > highest and waveNum < 500 then
                        highest = waveNum
                    end
                end
            end
            search(child)
        end
    end
    
    search(playerGui)
    return highest > 0 and highest or nil
end

-- Main monitoring loop
spawn(function()
    addLog("=== WAVE MONITOR STARTED ===", Color3.new(0, 255, 0))
    addLog("Start a raid to detect waves", Color3.new(255, 255, 0))
    
    while true do
        local wave = detectWave()
        
        if wave then
            if not isInRaid then
                isInRaid = true
                addLog("🏟️ Raid detected!", Color3.new(0, 255, 0))
            end
            
            if wave ~= lastWave then
                lastWave = wave
                currentWave = wave
                
                -- Update display
                if wave >= 408 then
                    waveDisplay.Text = "⚠️ WAVE " .. wave .. " ⚠️"
                    waveDisplay.TextColor3 = Color3.new(255, 0, 0)
                    statusText.Text = "TARGET REACHED! Wave " .. wave
                    addLog("🎯 TARGET WAVE " .. wave .. " REACHED!", Color3.new(255, 0, 0))
                else
                    waveDisplay.Text = "🌊 WAVE " .. wave
                    waveDisplay.TextColor3 = Color3.new(0, 255, 0)
                    statusText.Text = "In Raid - Wave " .. wave
                    addLog("Wave: " .. wave, Color3.new(0, 255, 0))
                end
            end
        else
            if isInRaid then
                isInRaid = false
                lastWave = 0
                waveDisplay.Text = "Wave: ???"
                waveDisplay.TextColor3 = Color3.new(255, 255, 0)
                statusText.Text = "No raid detected"
                addLog("🏁 Raid ended", Color3.new(255, 255, 0))
            end
        end
        
        wait(0.5)
    end
end)

-- COPY BUTTON - This is what you need!
copyButton.MouseButton1Click:Connect(function()
    local allLogs = "=== WAVE MONITOR LOGS ===\n"
    allLogs = allLogs .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    allLogs = allLogs .. "Last Wave: " .. currentWave .. "\n"
    allLogs = allLogs .. "Total Logs: " .. #waveHistory .. "\n"
    allLogs = allLogs .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    
    -- Add all logs in order
    for i = #waveHistory, 1, -1 do
        allLogs = allLogs .. waveHistory[i].text .. "\n"
    end
    
    -- Copy to clipboard
    pcall(function()
        setclipboard(allLogs)
        addLog("✅ Logs copied to clipboard!", Color3.new(0, 255, 0))
        statusText.Text = "Copied to clipboard!"
        wait(2)
        if isInRaid then
            statusText.Text = "In Raid - Wave " .. currentWave
        else
            statusText.Text = "No raid detected"
        end
    end)
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Make draggable for mobile
local dragStart = nil
local dragPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        dragPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function()
    dragStart = nil
end)

game:GetService("UserInputService").TouchMoved:Connect(function(input)
    if dragStart then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X,
                                        dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

print("Wave Monitor Loaded - GUI with COPY button ready")
