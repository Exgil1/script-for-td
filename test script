--// WAVE DETECTION & AUTO-END SCRIPT
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--// REMOTES
local events = ReplicatedStorage:WaitForChild("Events")
local remotesFolder = events:WaitForChild("Remotes")
local raidStop = remotesFolder:WaitForChild("RaidStop")

--// WAVE DETECTION VARIABLES
local currentWave = 0
local autoEndEnabled = false
local autoEndThread = nil
local targetWave = 408  -- Change this to whatever wave you want
local waveCheckInterval = 0.5  -- Check every 0.5 seconds

--// FIND WAVE DISPLAY
local function findWaveDisplay()
    -- Try common wave display locations
    local waveText = nil
    
    -- Check player's GUI
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        -- Search for wave text in all GUI elements
        local function searchForWave(instance)
            if waveText then return end
            if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                local text = instance.Text or ""
                -- Check if text contains wave pattern
                if text:match("Wave%s*(%d+)") or text:match("WAVE%s*(%d+)") or text:match("wave%s*(%d+)") then
                    waveText = instance
                    return
                end
            end
            for _, child in ipairs(instance:GetChildren()) do
                searchForWave(child)
                if waveText then break end
            end
        end
        searchForWave(playerGui)
    end
    
    -- Check screen GUI
    if not waveText then
        local coreGui = game:GetService("CoreGui")
        local function searchCoreGui(instance)
            if waveText then return end
            if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                local text = instance.Text or ""
                if text:match("Wave%s*(%d+)") or text:match("WAVE%s*(%d+)") or text:match("wave%s*(%d+)") then
                    waveText = instance
                    return
                end
            end
            for _, child in ipairs(instance:GetChildren()) do
                searchCoreGui(child)
                if waveText then break end
            end
        end
        searchCoreGui(coreGui)
    end
    
    return waveText
end

--// GET CURRENT WAVE FROM TEXT
local function getCurrentWave()
    local waveDisplay = findWaveDisplay()
    if waveDisplay then
        local text = waveDisplay.Text
        -- Try to extract wave number (supports various formats)
        local waveNum = text:match("Wave%s*(%d+)") or 
                       text:match("WAVE%s*(%d+)") or 
                       text:match("wave%s*(%d+)") or
                       text:match("(%d+)")
        if waveNum then
            return tonumber(waveNum)
        end
    end
    return nil
end

--// AUTO-END FUNCTION
local function autoEndRaid()
    print("[WaveDetect] Attempting to end raid at wave " .. currentWave)
    pcall(function()
        raidStop:FireServer()
        print("[WaveDetect] Raid end command sent!")
    end)
end

--// WAVE MONITOR LOOP
local function startWaveMonitor()
    if autoEndThread then 
        task.cancel(autoEndThread)
        autoEndThread = nil
    end
    
    autoEndThread = task.spawn(function()
        print("[WaveDetect] Wave monitor started - Target wave: " .. targetWave)
        local lastWave = 0
        
        while autoEndEnabled do
            local wave = getCurrentWave()
            
            if wave and wave ~= lastWave then
                lastWave = wave
                currentWave = wave
                print("[WaveDetect] Current Wave: " .. wave)
                
                -- Update status display if available
                if waveStatusLabel then
                    waveStatusLabel.Text = "🌊 Current Wave: " .. wave .. " / " .. targetWave
                    if wave >= targetWave then
                        waveStatusLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
                    else
                        waveStatusLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
                    end
                end
                
                -- Check if reached target wave
                if wave >= targetWave then
                    print("[WaveDetect] Target wave " .. targetWave .. " reached! Auto-ending raid...")
                    if waveStatusLabel then
                        waveStatusLabel.Text = "✅ TARGET REACHED! Ending raid..."
                    end
                    autoEndRaid()
                    autoEndEnabled = false  -- Stop monitoring after ending
                    if autoEndButton then
                        autoEndButton.Text = "🎯 AUTO-END: OFF"
                        autoEndButton.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
                    end
                    break
                end
            end
            
            task.wait(waveCheckInterval)
        end
        
        print("[WaveDetect] Wave monitor stopped")
        autoEndThread = nil
    end)
end

local function stopWaveMonitor()
    autoEndEnabled = false
    if autoEndThread then
        task.cancel(autoEndThread)
        autoEndThread = nil
    end
    print("[WaveDetect] Wave monitor stopped")
end

--// TOGGLE AUTO-END
local function toggleAutoEnd()
    if autoEndEnabled then
        stopWaveMonitor()
        if autoEndButton then
            autoEndButton.Text = "🎯 AUTO-END: OFF"
            autoEndButton.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        end
        if waveStatusLabel then
            waveStatusLabel.Text = "🌊 Monitor: Off"
        end
    else
        autoEndEnabled = true
        startWaveMonitor()
        if autoEndButton then
            autoEndButton.Text = "🎯 AUTO-END: ON (Wave " .. targetWave .. ")"
            autoEndButton.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        end
        if waveStatusLabel then
            local current = getCurrentWave() or 0
            waveStatusLabel.Text = "🌊 Current Wave: " .. current .. " / " .. targetWave
            waveStatusLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
        end
    end
end

--// CREATE GUI FOR WAVE DETECTION
local gui = Instance.new("ScreenGui")
gui.Name = "WaveAutoEnd"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 120)
mainFrame.Position = UDim2.new(1, -320, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(200, 100, 100)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌊 WAVE AUTO-END"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local waveStatusLabel = Instance.new("TextLabel")
waveStatusLabel.Size = UDim2.new(1, -10, 0, 30)
waveStatusLabel.Position = UDim2.new(0, 5, 0, 35)
waveStatusLabel.Text = "🌊 Wave Monitor: Off"
waveStatusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
waveStatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
waveStatusLabel.Font = Enum.Font.Gotham
waveStatusLabel.TextSize = 12
waveStatusLabel.Parent = mainFrame

local autoEndButton = Instance.new("TextButton")
autoEndButton.Size = UDim2.new(1, -10, 0, 35)
autoEndButton.Position = UDim2.new(0, 5, 0, 70)
autoEndButton.Text = "🎯 AUTO-END: OFF"
autoEndButton.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoEndButton.TextColor3 = Color3.new(1, 1, 1)
autoEndButton.Font = Enum.Font.GothamBold
autoEndButton.TextSize = 12
autoEndButton.Parent = mainFrame

autoEndButton.MouseButton1Click:Connect(toggleAutoEnd)

-- Optional: Add wave number input
local waveInputFrame = Instance.new("Frame")
waveInputFrame.Size = UDim2.new(1, -10, 0, 30)
waveInputFrame.Position = UDim2.new(0, 5, 0, 110)
waveInputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
waveInputFrame.BackgroundTransparency = 0.5
waveInputFrame.Parent = mainFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(0.4, -5, 1, 0)
waveLabel.Text = "Target Wave:"
waveLabel.TextColor3 = Color3.new(1, 1, 1)
waveLabel.BackgroundTransparency = 1
waveLabel.TextSize = 11
waveLabel.Parent = waveInputFrame

local waveInput = Instance.new("TextBox")
waveInput.Size = UDim2.new(0.3, -5, 1, -5)
waveInput.Position = UDim2.new(0.42, 0, 0, 2)
waveInput.Text = tostring(targetWave)
waveInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
waveInput.TextColor3 = Color3.new(1, 1, 1)
waveInput.TextSize = 11
waveInput.Parent = waveInputFrame

local setWaveBtn = Instance.new("TextButton")
setWaveBtn.Size = UDim2.new(0.25, -5, 1, -5)
setWaveBtn.Position = UDim2.new(0.74, 0, 0, 2)
setWaveBtn.Text = "Set"
setWaveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
setWaveBtn.TextColor3 = Color3.new(1, 1, 1)
setWaveBtn.TextSize = 11
setWaveBtn.Parent = waveInputFrame

setWaveBtn.MouseButton1Click:Connect(function()
    local newWave = tonumber(waveInput.Text)
    if newWave and newWave > 0 then
        targetWave = newWave
        waveStatusLabel.Text = "🌊 Target set to wave " .. targetWave
        task.wait(1.5)
        if autoEndEnabled then
            waveStatusLabel.Text = "🌊 Current Wave: " .. (getCurrentWave() or 0) .. " / " .. targetWave
        else
            waveStatusLabel.Text = "🌊 Wave Monitor: Off"
        end
        -- Update button text
        if autoEndEnabled then
            autoEndButton.Text = "🎯 AUTO-END: ON (Wave " .. targetWave .. ")"
        end
    else
        waveStatusLabel.Text = "❌ Invalid wave number!"
        task.wait(1.5)
        waveInput.Text = tostring(targetWave)
        if autoEndEnabled then
            waveStatusLabel.Text = "🌊 Current Wave: " .. (getCurrentWave() or 0) .. " / " .. targetWave
        else
            waveStatusLabel.Text = "🌊 Wave Monitor: Off"
        end
    end
end)

-- Manual end button
local manualEndBtn = Instance.new("TextButton")
manualEndBtn.Size = UDim2.new(0.48, -5, 0, 30)
manualEndBtn.Position = UDim2.new(0.51, 0, 0, 145)
manualEndBtn.Text = "⚡ END NOW"
manualEndBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
manualEndBtn.TextColor3 = Color3.new(1, 1, 1)
manualEndBtn.Font = Enum.Font.GothamBold
manualEndBtn.TextSize = 11
manualEndBtn.Parent = mainFrame

local refreshWaveBtn = Instance.new("TextButton")
refreshWaveBtn.Size = UDim2.new(0.48, -5, 0, 30)
refreshWaveBtn.Position = UDim2.new(0.01, 0, 0, 145)
refreshWaveBtn.Text = "🔄 REFRESH WAVE"
refreshWaveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
refreshWaveBtn.TextColor3 = Color3.new(1, 1, 1)
refreshWaveBtn.Font = Enum.Font.GothamBold
refreshWaveBtn.TextSize = 11
refreshWaveBtn.Parent = mainFrame

manualEndBtn.MouseButton1Click:Connect(function()
    print("[WaveDetect] Manual end triggered")
    pcall(function()
        raidStop:FireServer()
        waveStatusLabel.Text = "✅ Raid ended manually!"
        task.wait(2)
        if autoEndEnabled then
            waveStatusLabel.Text = "🌊 Current Wave: " .. (getCurrentWave() or 0) .. " / " .. targetWave
        else
            waveStatusLabel.Text = "🌊 Wave Monitor: Off"
        end
    end)
end)

refreshWaveBtn.MouseButton1Click:Connect(function()
    local wave = getCurrentWave()
    if wave then
        currentWave = wave
        waveStatusLabel.Text = "🌊 Current Wave: " .. wave .. " / " .. targetWave
        if autoEndEnabled then
            waveStatusLabel.TextColor3 = wave >= targetWave and Color3.new(1, 0.3, 0.3) or Color3.new(0.3, 1, 0.3)
        end
    else
        waveStatusLabel.Text = "❌ Could not detect wave!"
        task.wait(1.5)
        if autoEndEnabled then
            waveStatusLabel.Text = "🌊 Current Wave: ? / " .. targetWave
        else
            waveStatusLabel.Text = "🌊 Wave Monitor: Off"
        end
    end
end)

-- Resize main frame to fit all elements
mainFrame.Size = UDim2.new(0, 300, 0, 185)

print("=== WAVE DETECTION AUTO-END LOADED ===")
print("✅ Detects current wave number from UI")
print("✅ Auto-ends raid when wave " .. targetWave .. " is reached")
print("✅ Can change target wave anytime")
print("✅ Manual end button available")

-- Optional: Auto-start monitoring (uncomment if you want it on by default)
-- toggleAutoEnd()

end)
