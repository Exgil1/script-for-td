--// SIMPLE WAVE MONITOR - FOR DELTA MOBILE
--// NO COMPLEX HOOKS, JUST BASIC UI SCANNING

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create simple GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveMonitor"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.Parent = screenGui

local waveText = Instance.new("TextLabel")
waveText.Size = UDim2.new(1, 0, 0, 50)
waveText.Position = UDim2.new(0, 0, 0, 20)
waveText.Text = "Wave: ?"
waveText.TextColor3 = Color3.fromRGB(255, 255, 255)
waveText.TextSize = 24
waveText.Font = Enum.Font.GothamBold
waveText.BackgroundTransparency = 1
waveText.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 30)
statusText.Position = UDim2.new(0, 0, 0, 80)
statusText.Text = "Status: Monitoring"
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.TextSize = 12
statusText.BackgroundTransparency = 1
statusText.Parent = mainFrame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.8, 0, 0, 30)
copyButton.Position = UDim2.new(0.1, 0, 0, 120)
copyButton.Text = "COPY WAVE DATA"
copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.8, 0, 0, 30)
closeButton.Position = UDim2.new(0.1, 0, 0, 160)
closeButton.Text = "CLOSE"
closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = mainFrame

-- Variables
local currentWave = 0
local waveHistory = {}
local isMonitoring = true

-- Function to find wave from UI
local function findWaveNumber()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local function searchForWave(instance)
        if instance:IsA("TextLabel") then
            local text = instance.Text or ""
            -- Look for numbers after "Wave" or "wave"
            local waveNum = string.match(text, "Wave%s*(%d+)")
            if not waveNum then
                waveNum = string.match(text, "WAVE%s*(%d+)")
            end
            if not waveNum then
                waveNum = string.match(text, "wave%s*(%d+)")
            end
            if not waveNum then
                waveNum = string.match(text, "Round%s*(%d+)")
            end
            if waveNum then
                return tonumber(waveNum), instance.Name
            end
        end
        
        for _, child in pairs(instance:GetChildren()) do
            local result, source = searchForWave(child)
            if result then
                return result, source
            end
        end
        return nil, nil
    end
    
    return searchForWave(playerGui)
end

-- Main monitoring loop
local lastWave = 0
local lastLogTime = 0

spawn(function()
    while isMonitoring do
        local wave, source = findWaveNumber()
        
        if wave and wave ~= lastWave then
            lastWave = wave
            currentWave = wave
            
            -- Change color based on wave
            if wave >= 408 then
                waveText.Text = "⚠️ WAVE " .. wave .. " ⚠️"
                waveText.TextColor3 = Color3.fromRGB(255, 0, 0)
                statusText.Text = "TARGET REACHED!"
                statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                waveText.Text = "🌊 WAVE " .. wave
                waveText.TextColor3 = Color3.fromRGB(0, 255, 0)
                statusText.Text = "Status: In Raid"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
            
            -- Add to history
            table.insert(waveHistory, {
                wave = wave,
                time = os.date("%H:%M:%S"),
                source = source or "unknown"
            })
            
            -- Keep last 50 waves
            if #waveHistory > 50 then
                table.remove(waveHistory, 1)
            end
            
            -- Print to console (if your executor shows it)
            print("[Wave] " .. wave .. " - Source: " .. (source or "unknown"))
        end
        
        -- Check if raid ended (no wave found for 5 seconds)
        if not wave and lastWave ~= 0 then
            local timeSinceLast = tick() - lastLogTime
            if timeSinceLast > 5 then
                lastWave = 0
                waveText.Text = "Wave: ?"
                waveText.TextColor3 = Color3.fromRGB(255, 255, 255)
                statusText.Text = "Status: No Raid Detected"
                statusText.TextColor3 = Color3.fromRGB(255, 255, 0)
                print("[Raid] Ended at wave " .. currentWave)
                lastLogTime = tick()
            end
        end
        
        wait(0.5)
    end
end)

-- Copy button function
copyButton.MouseButton1Click:Connect(function()
    local data = "=== WAVE HISTORY ===\n"
    data = data .. "Total waves recorded: " .. #waveHistory .. "\n"
    data = data .. "Last wave: " .. currentWave .. "\n"
    data = data .. "\nWave Log:\n"
    
    for i = #waveHistory, 1, -1 do
        local w = waveHistory[i]
        data = data .. string.format("[%s] Wave %d (Source: %s)\n", w.time, w.wave, w.source)
    end
    
    -- Try to copy
    pcall(function()
        setclipboard(data)
        statusText.Text = "✅ Copied to clipboard!"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(2)
        statusText.Text = "Status: Monitoring"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    isMonitoring = false
    screenGui:Destroy()
    print("[Wave Monitor] Closed")
end)

-- Make it draggable
local dragging = false
local dragStart
local dragStartPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").TouchMoved:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
                                        dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

print("=== WAVE MONITOR LOADED ===")
print("Start a raid to see wave detection")
print("Press COPY button to save wave data")
