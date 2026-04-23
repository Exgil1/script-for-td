pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui

local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, 0, 0, 70)
waveDisplay.Position = UDim2.new(0, 0, 0, 10)
waveDisplay.Text = "WAVE: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
waveDisplay.TextSize = 40
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 90)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.new(255, 255, 255)
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

local autoEndBtn = Instance.new("TextButton")
autoEndBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoEndBtn.Position = UDim2.new(0.05, 0, 0, 130)
autoEndBtn.Text = "AUTO END (408): OFF"
autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
autoEndBtn.TextColor3 = Color3.new(255, 255, 255)
autoEndBtn.TextSize = 13
autoEndBtn.Parent = mainFrame

local endNowBtn = Instance.new("TextButton")
endNowBtn.Size = UDim2.new(0.9, 0, 0, 40)
endNowBtn.Position = UDim2.new(0.05, 0, 0, 175)
endNowBtn.Text = "END RAID NOW"
endNowBtn.BackgroundColor3 = Color3.new(200, 0, 0)
endNowBtn.TextColor3 = Color3.new(255, 255, 255)
endNowBtn.TextSize = 13
endNowBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 40)
copyBtn.Position = UDim2.new(0.05, 0, 0, 220)
copyBtn.Text = "COPY LOG"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 13
copyBtn.Parent = mainFrame

local autoEndActive = false
local currentWave = 0
local waveHistory = {}
local raidStopRemote = nil
local waveHistoryLog = {}

local function findRaidStop()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local remotes = events:FindFirstChild("Remotes")
        if remotes then
            raidStopRemote = remotes:FindFirstChild("RaidStop")
        end
    end
end

local function endRaid()
    if raidStopRemote then
        pcall(function()
            raidStopRemote:FireServer()
            statusLabel.Text = "Raid Ended at wave " .. currentWave
        end)
    end
end

-- Track all wave numbers and their last seen time
local waveSeen = {}
local function getCurrentWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local currentTime = tick()
    local foundWave = nil
    
    local function searchForWave(instance)
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                -- Find any number that could be a wave (2-3 digits)
                local waveNum = text:match("(%d+)")
                if waveNum then
                    local num = tonumber(waveNum)
                    if num and num > 0 and num < 500 then
                        -- Update when this wave was last seen
                        waveSeen[num] = currentTime
                        -- If this is the most recently updated wave, use it
                        if not foundWave or waveSeen[foundWave] < currentTime then
                            foundWave = num
                        end
                    end
                end
            end
            searchForWave(child)
        end
    end
    
    searchForWave(playerGui)
    
    -- Clean up old entries (older than 2 seconds)
    for wave, time in pairs(waveSeen) do
        if currentTime - time > 2 then
            waveSeen[wave] = nil
        end
    end
    
    -- Find the wave that was updated most recently
    local mostRecent = nil
    local mostRecentTime = 0
    
    for wave, time in pairs(waveSeen) do
        if time > mostRecentTime then
            mostRecentTime = time
            mostRecent = wave
        end
    end
    
    return mostRecent
end

-- Continuous monitoring
spawn(function()
    findRaidStop()
    local lastSeenWave = 0
    
    while true do
        local wave = getCurrentWave()
        
        if wave and wave > 0 then
            -- Only update if wave changed
            if wave ~= currentWave then
                currentWave = wave
                waveDisplay.Text = "WAVE: " .. wave
                
                -- Store history
                table.insert(waveHistory, 1, {
                    wave = wave,
                    time = os.date("%H:%M:%S")
                })
                if #waveHistory > 30 then table.remove(waveHistory) end
                
                -- Log to history
                table.insert(waveHistoryLog, 1, "[" .. os.date("%H:%M:%S") .. "] Wave: " .. wave)
                if #waveHistoryLog > 50 then table.remove(waveHistoryLog) end
                
                -- Check target
                if wave >= 408 then
                    waveDisplay.TextColor3 = Color3.new(255, 0, 0)
                    statusLabel.Text = "TARGET REACHED: Wave " .. wave
                    if autoEndActive then
                        endRaid()
                        autoEndActive = false
                        autoEndBtn.Text = "AUTO END (408): OFF"
                        autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
                        statusLabel.Text = "Auto-ended at wave " .. wave
                    end
                else
                    waveDisplay.TextColor3 = Color3.new(0, 255, 0)
                    statusLabel.Text = "Current Wave: " .. wave
                end
            end
        end
        
        wait(0.2)
    end
end)

autoEndBtn.MouseButton1Click:Connect(function()
    autoEndActive = not autoEndActive
    if autoEndActive then
        autoEndBtn.Text = "AUTO END (408): ON"
        autoEndBtn.BackgroundColor3 = Color3.new(0, 100, 0)
        statusLabel.Text = "Auto-end ON - will end at wave 408"
    else
        autoEndBtn.Text = "AUTO END (408): OFF"
        autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
        statusLabel.Text = "Auto-end OFF"
    end
end)

endNowBtn.MouseButton1Click:Connect(function()
    endRaid()
end)

copyBtn.MouseButton1Click:Connect(function()
    local data = "WAVE HISTORY (Most recent first)\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n"
    for i, entry in ipairs(waveHistoryLog) do
        data = data .. entry .. "\n"
    end
    pcall(function()
        setclipboard(data)
        statusLabel.Text = "Copied!"
        task.wait(1.5)
        if currentWave > 0 then
            statusLabel.Text = "Current Wave: " .. currentWave
        else
            statusLabel.Text = "Ready"
        end
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

end)
