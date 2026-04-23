pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 300)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "WAVE CONTROLLER"
title.TextColor3 = Color3.new(255, 255, 255)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, -20, 0, 70)
waveDisplay.Position = UDim2.new(0, 10, 0, 50)
waveDisplay.Text = "Wave: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(40, 40, 40)
waveDisplay.TextSize = 32
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.Text = "Status: Monitoring"
statusLabel.TextColor3 = Color3.new(255, 255, 255)
statusLabel.BackgroundColor3 = Color3.new(40, 40, 40)
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

local autoEndBtn = Instance.new("TextButton")
autoEndBtn.Size = UDim2.new(1, -20, 0, 45)
autoEndBtn.Position = UDim2.new(0, 10, 0, 170)
autoEndBtn.Text = "AUTO END AT WAVE 408: OFF"
autoEndBtn.BackgroundColor3 = Color3.new(100, 50, 50)
autoEndBtn.TextColor3 = Color3.new(255, 255, 255)
autoEndBtn.TextSize = 14
autoEndBtn.Parent = mainFrame

local endNowBtn = Instance.new("TextButton")
endNowBtn.Size = UDim2.new(0.48, -5, 0, 40)
endNowBtn.Position = UDim2.new(0, 10, 0, 225)
endNowBtn.Text = "END RAID NOW"
endNowBtn.BackgroundColor3 = Color3.new(200, 0, 0)
endNowBtn.TextColor3 = Color3.new(255, 255, 255)
endNowBtn.TextSize = 14
endNowBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.48, -5, 0, 40)
copyBtn.Position = UDim2.new(0.52, 0, 0, 225)
copyBtn.Text = "COPY LOG"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 200)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 14
copyBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 270)
closeBtn.Text = "CLOSE"
closeBtn.BackgroundColor3 = Color3.new(100, 100, 100)
closeBtn.TextColor3 = Color3.new(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame

local autoEndActive = false
local currentWave = 0
local lastLoggedWave = 0
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
            statusLabel.TextColor3 = Color3.new(255, 255, 0)
        end)
    else
        statusLabel.Text = "RaidStop not found!"
        statusLabel.TextColor3 = Color3.new(255, 0, 0)
    end
end

local function addToHistory(wave)
    table.insert(waveHistory, 1, {
        wave = wave,
        time = os.date("%H:%M:%S")
    })
    while #waveHistory > 30 do
        table.remove(waveHistory)
    end
end

-- Use the working method from your log - get the HIGHEST wave detected
local function getCurrentWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local highestWave = 0
    
    local function search(instance)
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                local num = text:match("Wave%s*(%d+)") or text:match("WAVE%s*(%d+)") or text:match("wave%s*(%d+)")
                if num then
                    local w = tonumber(num)
                    if w and w > highestWave and w < 500 then
                        highestWave = w
                    end
                end
            end
            search(child)
        end
    end
    
    search(playerGui)
    
    if highestWave > 0 then
        return highestWave
    end
    return nil
end

spawn(function()
    findRaidStop()
    
    while true do
        local wave = getCurrentWave()
        
        if wave and wave ~= currentWave then
            currentWave = wave
            waveDisplay.Text = "Wave: " .. wave
            addToHistory(wave)
            
            if wave >= 408 then
                waveDisplay.TextColor3 = Color3.new(255, 0, 0)
                statusLabel.Text = "TARGET WAVE REACHED: " .. wave
                statusLabel.TextColor3 = Color3.new(255, 0, 0)
                
                if autoEndActive then
                    endRaid()
                    autoEndActive = false
                    autoEndBtn.Text = "AUTO END AT WAVE 408: OFF"
                    autoEndBtn.BackgroundColor3 = Color3.new(100, 50, 50)
                    statusLabel.Text = "Auto-ended at wave " .. wave
                end
            else
                waveDisplay.TextColor3 = Color3.new(0, 255, 0)
                statusLabel.Text = "In raid - Wave " .. wave
                statusLabel.TextColor3 = Color3.new(255, 255, 255)
            end
        end
        
        wait(0.3)
    end
end)

autoEndBtn.MouseButton1Click:Connect(function()
    autoEndActive = not autoEndActive
    if autoEndActive then
        autoEndBtn.Text = "AUTO END AT WAVE 408: ON"
        autoEndBtn.BackgroundColor3 = Color3.new(50, 100, 50)
        statusLabel.Text = "Auto-end enabled - will end at wave 408"
    else
        autoEndBtn.Text = "AUTO END AT WAVE 408: OFF"
        autoEndBtn.BackgroundColor3 = Color3.new(100, 50, 50)
        statusLabel.Text = "Auto-end disabled"
    end
end)

endNowBtn.MouseButton1Click:Connect(function()
    endRaid()
end)

copyBtn.MouseButton1Click:Connect(function()
    local data = "WAVE HISTORY\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n"
    
    for i, w in ipairs(waveHistory) do
        data = data .. "[" .. w.time .. "] Wave: " .. w.wave .. "\n"
    end
    
    pcall(function()
        setclipboard(data)
        statusLabel.Text = "Copied to clipboard!"
        task.wait(2)
        if currentWave >= 408 then
            statusLabel.Text = "TARGET WAVE REACHED: " .. currentWave
        elseif currentWave > 0 then
            statusLabel.Text = "In raid - Wave " .. currentWave
        else
            statusLabel.Text = "Monitoring"
        end
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

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
