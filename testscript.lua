pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "WAVE CONTROLLER"
title.TextColor3 = Color3.new(255, 255, 255)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, -20, 0, 70)
waveDisplay.Position = UDim2.new(0, 10, 0, 45)
waveDisplay.Text = "WAVE: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(30, 30, 30)
waveDisplay.TextSize = 36
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 125)
statusLabel.Text = "Status: Monitoring"
statusLabel.TextColor3 = Color3.new(255, 255, 255)
statusLabel.BackgroundColor3 = Color3.new(30, 30, 30)
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

local autoEndBtn = Instance.new("TextButton")
autoEndBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoEndBtn.Position = UDim2.new(0.05, 0, 0, 165)
autoEndBtn.Text = "AUTO END (408): OFF"
autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
autoEndBtn.TextColor3 = Color3.new(255, 255, 255)
autoEndBtn.TextSize = 13
autoEndBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0, 210)
copyBtn.Text = "COPY WAVE HISTORY"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local autoEndActive = false
local currentWave = 0
local waveHistory = {}
local raidStopRemote = nil

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

-- Directly target the Wave element we found
local function getCurrentWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- Navigate to the Wave element
    local framework = playerGui:FindFirstChild("Framework")
    if framework then
        local raid = framework:FindFirstChild("Raid")
        if raid then
            local top = raid:FindFirstChild("Top")
            if top then
                local waveElement = top:FindFirstChild("Wave")
                if waveElement and waveElement:IsA("TextLabel") then
                    local text = waveElement.Text or ""
                    local waveNum = text:match("Wave%s*(%d+)") or text:match("(%d+)")
                    if waveNum then
                        return tonumber(waveNum)
                    end
                end
            end
        end
    end
    
    return nil
end

-- Continuous monitoring
spawn(function()
    findRaidStop()
    
    while true do
        local wave = getCurrentWave()
        
        if wave and wave > 0 and wave ~= currentWave then
            currentWave = wave
            waveDisplay.Text = "WAVE: " .. wave
            
            table.insert(waveHistory, 1, {
                wave = wave,
                time = os.date("%H:%M:%S")
            })
            if #waveHistory > 50 then table.remove(waveHistory) end
            
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
        elseif wave and wave == currentWave then
            -- Just update timestamp in history
            if #waveHistory > 0 then
                waveHistory[1].time = os.date("%H:%M:%S")
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

copyBtn.MouseButton1Click:Connect(function()
    local data = "=== WAVE HISTORY ===\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "Auto-End Status: " .. (autoEndActive and "ON" or "OFF") .. "\n"
    data = data .. "--------------------\n"
    data = data .. "Wave Progress (Most Recent First):\n"
    
    for i, w in ipairs(waveHistory) do
        data = data .. "[" .. w.time .. "] Wave " .. w.wave .. "\n"
    end
    
    pcall(function()
        setclipboard(data)
        statusLabel.Text = "Copied to clipboard!"
        task.wait(2)
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
