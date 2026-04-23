
pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui

local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, 0, 0, 60)
waveDisplay.Position = UDim2.new(0, 0, 0, 10)
waveDisplay.Text = "WAVE: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
waveDisplay.TextSize = 36
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 80)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.new(255, 255, 255)
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

local autoEndBtn = Instance.new("TextButton")
autoEndBtn.Size = UDim2.new(0.9, 0, 0, 35)
autoEndBtn.Position = UDim2.new(0.05, 0, 0, 115)
autoEndBtn.Text = "AUTO END (408): OFF"
autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
autoEndBtn.TextColor3 = Color3.new(255, 255, 255)
autoEndBtn.TextSize = 12
autoEndBtn.Parent = mainFrame

local endNowBtn = Instance.new("TextButton")
endNowBtn.Size = UDim2.new(0.9, 0, 0, 35)
endNowBtn.Position = UDim2.new(0.05, 0, 0, 155)
endNowBtn.Text = "END RAID NOW"
endNowBtn.BackgroundColor3 = Color3.new(200, 0, 0)
endNowBtn.TextColor3 = Color3.new(255, 255, 255)
endNowBtn.TextSize = 12
endNowBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0, 195)
copyBtn.Text = "COPY LOG"
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

-- Force refresh wave detection - look for ANY wave number
local function getCurrentWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local highestWave = 0
    
    local function searchAll(instance)
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                -- Look for any 3-digit or 2-digit number that could be a wave
                local nums = {}
                for num in string.gmatch(text, "(%d+)") do
                    local n = tonumber(num)
                    if n and n > 0 and n < 500 then
                        table.insert(nums, n)
                    end
                end
                -- Get the highest number from this text
                for _, n in ipairs(nums) do
                    if n > highestWave then
                        highestWave = n
                    end
                end
            end
            searchAll(child)
        end
    end
    
    searchAll(playerGui)
    return highestWave > 0 and highestWave or nil
end

-- Continuous monitoring with force refresh
spawn(function()
    findRaidStop()
    
    while true do
        local wave = getCurrentWave()
        
        if wave and wave ~= currentWave then
            currentWave = wave
            waveDisplay.Text = "WAVE: " .. wave
            
            -- Store history
            table.insert(waveHistory, 1, {
                wave = wave,
                time = os.date("%H:%M:%S")
            })
            if #waveHistory > 20 then table.remove(waveHistory) end
            
            -- Check target
            if wave >= 408 then
                waveDisplay.TextColor3 = Color3.new(255, 0, 0)
                statusLabel.Text = "TARGET REACHED: " .. wave
                if autoEndActive then
                    endRaid()
                    autoEndActive = false
                    autoEndBtn.Text = "AUTO END (408): OFF"
                    autoEndBtn.BackgroundColor3 = Color3.new(100, 0, 0)
                end
            else
                waveDisplay.TextColor3 = Color3.new(0, 255, 0)
                statusLabel.Text = "Wave: " .. wave
            end
        elseif not wave then
            -- No wave found, reset display
            if currentWave ~= 0 then
                currentWave = 0
                waveDisplay.Text = "WAVE: ???"
                waveDisplay.TextColor3 = Color3.new(255, 255, 0)
                statusLabel.Text = "No raid detected"
            end
        end
        
        wait(0.3)
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
    local data = "WAVE HISTORY\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n"
    for i, w in ipairs(waveHistory) do
        data = data .. "[" .. w.time .. "] Wave: " .. w.wave .. "\n"
    end
    pcall(function()
        setclipboard(data)
        statusLabel.Text = "Copied!"
        task.wait(1.5)
        if currentWave > 0 then
            statusLabel.Text = "Wave: " .. currentWave
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
