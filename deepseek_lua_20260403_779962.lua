--// ULTIMATE ORB FARMER - WITH WORKING MOBILE GUI

pcall(function()

local player = game:GetService("Players").LocalPlayer
local collectRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Remotes"):WaitForChild("CollectOrb")

-- Create GUI on StarterGui instead (more reliable on mobile)
local gui = Instance.new("ScreenGui")
gui.Name = "OrbFarmer"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")  -- Changed from CoreGui to PlayerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🔮 ORB FARMER"
title.TextColor3 = Color3.new(0.5, 0.8, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = titleBar

-- Status display
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 50)
statusFrame.Position = UDim2.new(0, 10, 0, 45)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statusFrame.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0.6, 0)
statusText.Position = UDim2.new(0, 5, 0, 5)
statusText.Text = "Status: IDLE"
statusText.TextColor3 = Color3.new(1, 1, 0)
statusText.TextSize = 14
statusText.Font = Enum.Font.GothamBold
statusText.BackgroundTransparency = 1
statusText.Parent = statusFrame

local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, -10, 0.4, 0)
statsText.Position = UDim2.new(0, 5, 0, 30)
statsText.Text = "Session: 0 | Rate: 0/min"
statsText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
statsText.TextSize = 11
statsText.BackgroundTransparency = 1
statsText.Parent = statusFrame

-- Currency displays
local currencies = {"Gems", "Coins", "Easter Eggs"}
local currencyLabels = {}
local yPos = 105

for _, currency in ipairs(currencies) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.Parent = mainFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.4, -5, 1, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.Text = currency
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.6, -5, 1, 0)
    valueLabel.Position = UDim2.new(0.4, 0, 0, 0)
    valueLabel.Text = "0"
    valueLabel.TextColor3 = Color3.new(0.5, 0.8, 1)
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = frame
    
    currencyLabels[currency] = valueLabel
    yPos = yPos + 55
end

-- Buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.45, -5, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, yPos)
startBtn.Text = "▶ START"
startBtn.TextSize = 14
startBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Parent = mainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.45, -5, 0, 40)
stopBtn.Position = UDim2.new(0.52, 0, 0, yPos)
stopBtn.Text = "⏹ STOP"
stopBtn.TextSize = 14
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Parent = mainFrame

-- Farming variables
local farming = false
local farmingThread = nil
local sessionCount = 0
local startTime = 0

-- Get currency function
local function getCurrency(currencyName)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(currencyName)
        if stat then
            return stat.Value
        end
    end
    return 0
end

-- Update display
local function updateDisplay()
    for currency, label in pairs(currencyLabels) do
        local amount = getCurrency(currency)
        if currency == "Coins" then
            if amount >= 1000000 then
                label.Text = string.format("%.1fM", amount / 1000000)
            elseif amount >= 1000 then
                label.Text = string.format("%.1fK", amount / 1000)
            else
                label.Text = tostring(amount)
            end
        else
            label.Text = tostring(amount)
        end
    end
    
    local elapsed = tick() - startTime
    local rate = elapsed > 0 and (sessionCount / elapsed * 60) or 0
    statsText.Text = string.format("Session: %d | Rate: %.1f/min", sessionCount, rate)
end

-- Main farming loop
local function startFarming()
    if farming then
        statusText.Text = "Status: ALREADY RUNNING"
        return
    end
    
    farming = true
    sessionCount = 0
    startTime = tick()
    statusText.Text = "Status: 🟢 FARMING"
    statusText.TextColor3 = Color3.new(0.3, 1, 0.3)
    
    farmingThread = task.spawn(function()
        while farming do
            -- Collect Gems
            local before = getCurrency("Gems")
            pcall(function()
                collectRemote:FireServer(2, "Gems", true)
            end)
            task.wait(0.5)
            local after = getCurrency("Gems")
            
            if after > before then
                sessionCount = sessionCount + 1
                updateDisplay()
            end
            
            -- Collect Coins
            pcall(function()
                collectRemote:FireServer(18667, "Coins", true)
            end)
            task.wait(0.5)
            
            -- Collect Easter Eggs
            pcall(function()
                collectRemote:FireServer(5, "EasterEggs", true)
            end)
            task.wait(0.5)
            
            updateDisplay()
        end
    end)
end

local function stopFarming()
    farming = false
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
    statusText.Text = "Status: ⚪ IDLE"
    statusText.TextColor3 = Color3.new(1, 1, 0)
    updateDisplay()
end

-- Button connections
startBtn.MouseButton1Click:Connect(startFarming)
stopBtn.MouseButton1Click:Connect(stopFarming)
closeBtn.MouseButton1Click:Connect(function()
    stopFarming()
    gui:Destroy()
end)

-- Initial update
updateDisplay()

print("==========================================")
print("   ORB FARMER GUI LOADED!")
print("   Look for the window on your screen")
print("   Drag the title bar to move it")
print("==========================================")

-- Try to make GUI visible on top
gui.Enabled = true
mainFrame.Visible = true

end)
