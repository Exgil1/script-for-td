--// COMPLETE TOWER DEFENSE AUTO FARM - IMPROVED GUI
--// Features: Auto Build, Auto Buy, Auto Challenge, Schedule, Auto-Save Config, Manual Controls

pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

--// GLOBAL VARIABLES
local isFirstRun = true
local autoRaidTriggered = false
local challengeLoopThread = nil

--// REMOTES
local events = ReplicatedStorage:WaitForChild("Events")
local functionsFolder = events:WaitForChild("Functions")
local remotesFolder = events:WaitForChild("Remotes")

local buyDefense = functionsFolder:WaitForChild("BuyDefense")
local eBuyDefense = functionsFolder:WaitForChild("EBuyDefense")
local eBuildDefense = functionsFolder:WaitForChild("EBuildDefense")
local cBuildDefense = functionsFolder:WaitForChild("CBuildDefense")
local startChallenge = functionsFolder:WaitForChild("StartChallenge")
local changeSetting = functionsFolder:WaitForChild("ChangeSetting")
local joinEventRaid = remotesFolder:WaitForChild("JoinEventRaid")
local joinCommunityRaid = remotesFolder:WaitForChild("JoinCommunityRaid")
local raidStop = remotesFolder:WaitForChild("RaidStop")

--// BUILD STRUCTURES
local easterBuildStructures = {
    {id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}", pos = Vector3.new(529.6004638671875, 227.50601196289062, 1187.6143798828125), rot = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", pos = Vector3.new(533.6004638671875, 227.50601196289062, 1197.6143798828125), rot = 90},
    {id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}", pos = Vector3.new(525.6004638671875, 227.50601196289062, 1197.6143798828125), rot = 90},
    {id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}", pos = Vector3.new(531.6004638671875, 227.50601196289062, 1209.6143798828125), rot = 90}
}

local megaRaidBuildStructures = {
    {id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}", pos = Vector3.new(1539.6004638671875, 8.505999565124512, 1183.6143798828125), rot = 90},
    {id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}", pos = Vector3.new(1541.6004638671875, 8.505999565124512, 1199.6143798828125), rot = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", pos = Vector3.new(1545.6004638671875, 8.505999565124512, 1191.6143798828125), rot = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", pos = Vector3.new(1545.6004638671875, 8.505999565124512, 1189.6143798828125), rot = 90},
    {id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}", pos = Vector3.new(1537.6004638671875, 8.505999565124512, 1189.6143798828125), rot = 90}
}

--// ITEMS FOR AUTO BUY
local items = {
    ["Bunny Cannon"]="E",["Bunny Bow"]="E",["Egg Launcher"]="E",
    ["Bunny Bomb Tower"]="E",["Egg Beam"]="E",
    ["Railgun"]="N",["Mega Cannon"]="N",["Triple Mortar"]="N",
    ["Flamespitter"]="N",["Rocket Artillery"]="N",["Bomb Tower"]="N",
    ["The Shocker"]="N",["The Crusher"]="N",["Volcanic Artillery"]="N",
    ["Inferno Beam"]="N",["Mystic Artillery"]="N",["Mega Tesla"]="N",
    ["Mega Mortar"]="N",["Flamethrower"]="N",["Mega Crossbow"]="N",
    ["Double Magma Cannon"]="N",["Tesla"]="N",["Magma Cannon"]="N",
    ["Catapult"]="N",["Crossbow"]="N",["Mortar"]="N",
    ["Double Cannon"]="N",["Wizard Tower"]="N",["Archer Tower"]="N",
    ["Cannon"]="N",["Wall"]="N"
}

--// AVAILABLE CHALLENGES
local allChallenges = {
    {name = "Insane Challenge", id = "Insane Challenge"},
    {name = "Pro Challenge", id = "Pro Challenge"},
    {name = "Easter Challenge #1", id = "Easter Challenge #1"},
    {name = "Easter Challenge #2", id = "Easter Challenge #2"},
    {name = "Godly Challenge", id = "Godly Challenge"}
}

--// ============== IMPROVED GUI ==============
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

-- Main Frame with gradient background
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 700)
mainFrame.Position = UDim2.new(0, 10, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "⚔️ TD AUTO FARM ⚔️"
title.TextColor3 = Color3.new(1, 0.8, 0.3)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.Text = "−"
minBtn.TextSize = 24
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0, 10, 0, 100)
iconBtn.Text = "⚔️"
iconBtn.TextSize = 30
iconBtn.Visible = false
iconBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
iconBtn.TextColor3 = Color3.new(1, 0.8, 0.3)
iconBtn.BorderSizePixel = 2
iconBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
iconBtn.Parent = gui

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    iconBtn.Visible = true
end)

iconBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    iconBtn.Visible = false
end)

-- Status Bar (bottom)
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 30)
statusBar.Position = UDim2.new(0, 0, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
statusBar.BorderSizePixel = 0
statusBar.Parent = mainFrame

local globalStatus = Instance.new("TextLabel")
globalStatus.Size = UDim2.new(1, -10, 1, 0)
globalStatus.Position = UDim2.new(0, 5, 0, 0)
globalStatus.Text = "✅ Ready"
globalStatus.TextColor3 = Color3.new(0.5, 0.8, 0.5)
globalStatus.TextSize = 12
globalStatus.BackgroundTransparency = 1
globalStatus.TextXAlignment = Enum.TextXAlignment.Left
globalStatus.Parent = statusBar

--// TABS (Improved)
local tabY = 50
local tabs = {}
local currentTab = "build"

local function createTab(name, text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 35)
    btn.Position = UDim2.new(0, 5 + (xPos * 103), 0, tabY)
    btn.Text = text
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    tabs[name] = btn
    return btn
end

createTab("build", "🏗️ BUILD", 0)
createTab("buy", "🛒 AUTO BUY", 1)
createTab("challenge", "🎯 CHALLENGE", 2)
createTab("schedule", "⏰ SCHEDULE", 3)
createTab("config", "💾 CONFIG", 4)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local panels = {
    build = Instance.new("ScrollingFrame"),
    buy = Instance.new("ScrollingFrame"),
    challenge = Instance.new("ScrollingFrame"),
    schedule = Instance.new("ScrollingFrame"),
    config = Instance.new("ScrollingFrame")
}

for name, panel in pairs(panels) do
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Visible = false
    panel.ScrollBarThickness = 3
    panel.Parent = contentFrame
    local layout = Instance.new("UIListLayout")
    layout.Parent = panel
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

--// ============== BUILD TAB ==============
local buildPanel = panels.build

local buildCard = Instance.new("Frame")
buildCard.Size = UDim2.new(1, -20, 0, 120)
buildCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
buildCard.BorderSizePixel = 0
buildCard.Parent = buildPanel

local easterBuildBtn = Instance.new("TextButton")
easterBuildBtn.Size = UDim2.new(0.9, 0, 0, 50)
easterBuildBtn.Position = UDim2.new(0.05, 0, 0, 10)
easterBuildBtn.Text = "🐰 BUILD EASTER (4 Towers)"
easterBuildBtn.TextSize = 16
easterBuildBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 120)
easterBuildBtn.TextColor3 = Color3.new(1, 1, 1)
easterBuildBtn.BorderSizePixel = 0
easterBuildBtn.Parent = buildCard

local megaBuildBtn = Instance.new("TextButton")
megaBuildBtn.Size = UDim2.new(0.9, 0, 0, 50)
megaBuildBtn.Position = UDim2.new(0.05, 0, 0, 65)
megaBuildBtn.Text = "⚔️ BUILD MEGA RAID (5 Towers)"
megaBuildBtn.TextSize = 16
megaBuildBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 120)
megaBuildBtn.TextColor3 = Color3.new(1, 1, 1)
megaBuildBtn.BorderSizePixel = 0
megaBuildBtn.Parent = buildCard

local buildStatus = Instance.new("TextLabel")
buildStatus.Size = UDim2.new(0.9, 0, 0, 30)
buildStatus.Position = UDim2.new(0.05, 0, 0, 85)
buildStatus.Text = "Status: Ready"
buildStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
buildStatus.TextSize = 12
buildStatus.BackgroundTransparency = 1
buildStatus.Parent = buildCard

--// ============== BUY TAB ==============
local buyPanel = panels.buy

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.9, 0, 0, 35)
searchBox.PlaceholderText = "🔍 Search towers..."
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BorderSizePixel = 0
searchBox.Parent = buyPanel

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(0.9, 0, 0, 350)
itemsScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
itemsScroll.BorderSizePixel = 0
itemsScroll.Parent = buyPanel

local itemsLayout = Instance.new("UIListLayout", itemsScroll)
itemsLayout.Padding = UDim.new(0, 4)

local selectedItems = {}
local itemButtons = {}

for name, typ in pairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Text = (typ=="E" and "🎯 " or "⚔️ ").."[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = itemsScroll
    itemButtons[name] = btn
    
    local sel = false
    btn.MouseButton1Click:Connect(function()
        sel = not sel
        if sel then
            btn.Text = btn.Text:gsub("%[ %]","[✓]")
            btn.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
            selectedItems[name] = true
        else
            btn.Text = btn.Text:gsub("%[✓%]","[ ]")
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            selectedItems[name] = nil
        end
        autoSaveConfig()
    end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = string.lower(searchBox.Text)
    for name, btn in pairs(itemButtons) do
        btn.Visible = string.find(string.lower(name), txt) ~= nil
    end
end)

local autoBuyActive = false
local autoBuyToggle = Instance.new("TextButton")
autoBuyToggle.Size = UDim2.new(0.9, 0, 0, 45)
autoBuyToggle.Text = "🔴 AUTO BUY: OFF"
autoBuyToggle.TextSize = 14
autoBuyToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
autoBuyToggle.TextColor3 = Color3.new(1, 1, 1)
autoBuyToggle.BorderSizePixel = 0
autoBuyToggle.Parent = buyPanel

local function autoBuyLoop()
    task.spawn(function()
        while autoBuyActive do
            for item,_ in pairs(selectedItems) do
                if not autoBuyActive then break end
                pcall(function()
                    if items[item]=="E" then
                        eBuyDefense:InvokeServer(item,1)
                    else
                        buyDefense:InvokeServer(item,1)
                    end
                end)
                task.wait(1)
            end
            task.wait(1)
        end
    end)
end

autoBuyToggle.MouseButton1Click:Connect(function()
    autoBuyActive = not autoBuyActive
    autoBuyToggle.Text = autoBuyActive and "🟢 AUTO BUY: ON (1s)" or "🔴 AUTO BUY: OFF"
    autoBuyToggle.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
    if autoBuyActive then autoBuyLoop() end
    autoSaveConfig()
end)

--// ============== CHALLENGE TAB ==============
local challengePanel = panels.challenge

-- Status Card
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -20, 0, 120)
statusCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statusCard.BorderSizePixel = 0
statusCard.Parent = challengePanel

local challengeStatus = Instance.new("TextLabel")
challengeStatus.Size = UDim2.new(0.95, 0, 0, 35)
challengeStatus.Position = UDim2.new(0.025, 0, 0, 5)
challengeStatus.Text = "Status: Idle"
challengeStatus.TextColor3 = Color3.new(1, 0.8, 0.3)
challengeStatus.TextSize = 14
challengeStatus.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
challengeStatus.BorderSizePixel = 0
challengeStatus.Parent = statusCard

local countdownDisplay = Instance.new("TextLabel")
countdownDisplay.Size = UDim2.new(0.95, 0, 0, 40)
countdownDisplay.Position = UDim2.new(0.025, 0, 0, 42)
countdownDisplay.Text = "Next: --:--"
countdownDisplay.TextColor3 = Color3.new(0.5, 0.8, 1)
countdownDisplay.TextSize = 28
countdownDisplay.Font = Enum.Font.GothamBold
countdownDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
countdownDisplay.BorderSizePixel = 0
countdownDisplay.Parent = statusCard

local orderDisplay = Instance.new("TextLabel")
orderDisplay.Size = UDim2.new(0.95, 0, 0, 25)
orderDisplay.Position = UDim2.new(0.025, 0, 0, 85)
orderDisplay.Text = "Current: None → Next: None"
orderDisplay.TextColor3 = Color3.new(0.6, 0.6, 0.8)
orderDisplay.TextSize = 11
orderDisplay.BackgroundTransparency = 1
orderDisplay.Parent = statusCard

-- Queue Display
local queueTitle = Instance.new("TextLabel")
queueTitle.Size = UDim2.new(0.9, 0, 0, 25)
queueTitle.Text = "📋 CHALLENGE QUEUE"
queueTitle.TextColor3 = Color3.new(1, 1, 0.5)
queueTitle.TextSize = 14
queueTitle.BackgroundTransparency = 1
queueTitle.Parent = challengePanel

local queueDisplay = Instance.new("TextLabel")
queueDisplay.Size = UDim2.new(0.9, 0, 0, 80)
queueDisplay.Text = "No challenges enabled"
queueDisplay.TextColor3 = Color3.new(0.7, 0.7, 0.7)
queueDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
queueDisplay.TextWrapped = true
queueDisplay.TextXAlignment = Enum.TextXAlignment.Left
queueDisplay.TextSize = 11
queueDisplay.BorderSizePixel = 0
queueDisplay.Parent = challengePanel

-- Auto Raid Settings Card
local raidCard = Instance.new("Frame")
raidCard.Size = UDim2.new(1, -20, 0, 95)
raidCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
raidCard.BorderSizePixel = 0
raidCard.Parent = challengePanel

local raidTitle = Instance.new("TextLabel")
raidTitle.Size = UDim2.new(0.95, 0, 0, 20)
raidTitle.Position = UDim2.new(0.025, 0, 0, 5)
raidTitle.Text = "🤖 AUTO RAID SETTINGS"
raidTitle.TextColor3 = Color3.new(1, 0.7, 0.3)
raidTitle.TextSize = 12
raidTitle.BackgroundTransparency = 1
raidTitle.Parent = raidCard

local autoRaidAfterChallenge = true
local autoRaidAfterToggle = Instance.new("TextButton")
autoRaidAfterToggle.Size = UDim2.new(0.95, 0, 0, 30)
autoRaidAfterToggle.Position = UDim2.new(0.025, 0, 0, 28)
autoRaidAfterToggle.Text = "🏠 After each challenge: ON"
autoRaidAfterToggle.TextSize = 12
autoRaidAfterToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
autoRaidAfterToggle.TextColor3 = Color3.new(1, 1, 1)
autoRaidAfterToggle.BorderSizePixel = 0
autoRaidAfterToggle.Parent = raidCard

local autoRaidActive = false
local autoRaidWaitTime = 300
local autoRaidToggle = Instance.new("TextButton")
autoRaidToggle.Size = UDim2.new(0.6, -5, 0, 30)
autoRaidToggle.Position = UDim2.new(0.025, 0, 0, 62)
autoRaidToggle.Text = "After last: OFF"
autoRaidToggle.TextSize = 11
autoRaidToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
autoRaidToggle.TextColor3 = Color3.new(1, 1, 1)
autoRaidToggle.BorderSizePixel = 0
autoRaidToggle.Parent = raidCard

local raidWaitBox = Instance.new("TextBox")
raidWaitBox.Size = UDim2.new(0.3, -5, 0, 30)
raidWaitBox.Position = UDim2.new(0.65, 0, 0, 62)
raidWaitBox.Text = "300"
raidWaitBox.PlaceholderText = "Wait (sec)"
raidWaitBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
raidWaitBox.TextColor3 = Color3.new(1, 1, 1)
raidWaitBox.TextSize = 11
raidWaitBox.BorderSizePixel = 0
raidWaitBox.Parent = raidCard

raidWaitBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(raidWaitBox.Text)
    if val and val > 0 then
        autoRaidWaitTime = val
        autoRaidToggle.Text = autoRaidActive and "After last: ON (" .. math.floor(autoRaidWaitTime/60) .. "m)" or "After last: OFF"
        autoSaveConfig()
    end
end)

autoRaidAfterToggle.MouseButton1Click:Connect(function()
    autoRaidAfterChallenge = not autoRaidAfterChallenge
    autoRaidAfterToggle.Text = autoRaidAfterChallenge and "🏠 After each challenge: ON" or "🏠 After each challenge: OFF"
    autoRaidAfterToggle.BackgroundColor3 = autoRaidAfterChallenge and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
    autoSaveConfig()
end)

autoRaidToggle.MouseButton1Click:Connect(function()
    autoRaidActive = not autoRaidActive
    autoRaidToggle.Text = autoRaidActive and "After last: ON (" .. math.floor(autoRaidWaitTime/60) .. "m)" or "After last: OFF"
    autoRaidToggle.BackgroundColor3 = autoRaidActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
    autoSaveConfig()
end)

-- Challenge Configuration
local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(0.9, 0, 0, 25)
configTitle.Text = "⚙️ CHALLENGE ORDER"
configTitle.TextColor3 = Color3.new(1, 1, 0.5)
configTitle.TextSize = 14
configTitle.BackgroundTransparency = 1
configTitle.Parent = challengePanel

local challengeScroll = Instance.new("ScrollingFrame")
challengeScroll.Size = UDim2.new(0.9, 0, 0, 140)
challengeScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
challengeScroll.BorderSizePixel = 0
challengeScroll.Parent = challengePanel

local challengeLayout = Instance.new("UIListLayout", challengeScroll)
challengeLayout.Padding = UDim.new(0, 4)

-- Challenge Order Data
local challengeOrder = {}
for i, ch in ipairs(allChallenges) do
    challengeOrder[i] = {name = ch.name, id = ch.id, interval = 300, enabled = false}
end

local challengeFrames = {}

local function updateQueueDisplay()
    local enabledList = {}
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            local mins = math.floor(ch.interval / 60)
            local secs = ch.interval % 60
            table.insert(enabledList, string.format("%s (%d:%02d)", ch.name, mins, secs))
        end
    end
    
    if #enabledList == 0 then
        queueDisplay.Text = "❌ No challenges enabled"
    else
        local text = ""
        for i, ch in ipairs(enabledList) do
            text = text .. i .. ". " .. ch .. "\n"
        end
        queueDisplay.Text = text
    end
end

local function refreshChallengeUI()
    for _, frame in pairs(challengeFrames) do
        frame:Destroy()
    end
    challengeFrames = {}
    
    for i, ch in ipairs(challengeOrder) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        frame.BorderSizePixel = 0
        frame.Parent = challengeScroll
        
        local enableBtn = Instance.new("TextButton")
        enableBtn.Size = UDim2.new(0.35, -5, 0.8, 0)
        enableBtn.Position = UDim2.new(0, 5, 0.1, 0)
        enableBtn.Text = ch.enabled and "✅ " .. ch.name or "❌ " .. ch.name
        enableBtn.BackgroundColor3 = ch.enabled and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
        enableBtn.TextColor3 = Color3.new(1, 1, 1)
        enableBtn.TextXAlignment = Enum.TextXAlignment.Left
        enableBtn.TextSize = 11
        enableBtn.BorderSizePixel = 0
        enableBtn.Parent = frame
        
        local intervalBox = Instance.new("TextBox")
        intervalBox.Size = UDim2.new(0.25, -5, 0.7, 0)
        intervalBox.Position = UDim2.new(0.38, 0, 0.15, 0)
        intervalBox.Text = tostring(ch.interval)
        intervalBox.PlaceholderText = "Sec"
        intervalBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        intervalBox.TextColor3 = Color3.new(1, 1, 1)
        intervalBox.TextSize = 11
        intervalBox.BorderSizePixel = 0
        intervalBox.Parent = frame
        
        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
        upBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
        upBtn.Text = "⬆️"
        upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        upBtn.TextColor3 = Color3.new(1, 1, 1)
        upBtn.TextSize = 11
        upBtn.BorderSizePixel = 0
        upBtn.Parent = frame
        
        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
        downBtn.Position = UDim2.new(0.78, 0, 0.15, 0)
        downBtn.Text = "⬇️"
        downBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        downBtn.TextColor3 = Color3.new(1, 1, 1)
        downBtn.TextSize = 11
        downBtn.BorderSizePixel = 0
        downBtn.Parent = frame
        
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
        removeBtn.Position = UDim2.new(0.89, 0, 0.15, 0)
        removeBtn.Text = "🗑️"
        removeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        removeBtn.TextColor3 = Color3.new(1, 1, 1)
        removeBtn.TextSize = 11
        removeBtn.BorderSizePixel = 0
        removeBtn.Parent = frame
        
        challengeFrames[i] = {frame = frame, enableBtn = enableBtn}
        
        local index = i
        enableBtn.MouseButton1Click:Connect(function()
            challengeOrder[index].enabled = not challengeOrder[index].enabled
            enableBtn.Text = challengeOrder[index].enabled and "✅ " .. challengeOrder[index].name or "❌ " .. challengeOrder[index].name
            enableBtn.BackgroundColor3 = challengeOrder[index].enabled and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
            updateQueueDisplay()
            autoSaveConfig()
        end)
        
        intervalBox:GetPropertyChangedSignal("Text"):Connect(function()
            local val = tonumber(intervalBox.Text)
            if val and val > 0 then
                challengeOrder[index].interval = val
                updateQueueDisplay()
                autoSaveConfig()
            end
        end)
        
        upBtn.MouseButton1Click:Connect(function()
            if index > 1 then
                challengeOrder[index], challengeOrder[index-1] = challengeOrder[index-1], challengeOrder[index]
                refreshChallengeUI()
                updateQueueDisplay()
                autoSaveConfig()
            end
        end)
        
        downBtn.MouseButton1Click:Connect(function()
            if index < #challengeOrder then
                challengeOrder[index], challengeOrder[index+1] = challengeOrder[index+1], challengeOrder[index]
                refreshChallengeUI()
                updateQueueDisplay()
                autoSaveConfig()
            end
        end)
        
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(challengeOrder, index)
            refreshChallengeUI()
            updateQueueDisplay()
            autoSaveConfig()
        end)
    end
    updateQueueDisplay()
end

-- Add Challenge
local addFrame = Instance.new("Frame")
addFrame.Size = UDim2.new(0.9, 0, 0, 70)
addFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
addFrame.BorderSizePixel = 0
addFrame.Parent = challengePanel

local challengeDropdown = Instance.new("TextBox")
challengeDropdown.Size = UDim2.new(0.6, -5, 0, 30)
challengeDropdown.PlaceholderText = "Challenge name..."
challengeDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
challengeDropdown.TextColor3 = Color3.new(1, 1, 1)
challengeDropdown.TextSize = 11
challengeDropdown.BorderSizePixel = 0
challengeDropdown.Parent = addFrame

local addInterval = Instance.new("TextBox")
addInterval.Size = UDim2.new(0.35, -5, 0, 30)
addInterval.Position = UDim2.new(0.62, 0, 0, 0)
addInterval.Text = "300"
addInterval.PlaceholderText = "Interval"
addInterval.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
addInterval.TextColor3 = Color3.new(1, 1, 1)
addInterval.TextSize = 11
addInterval.BorderSizePixel = 0
addInterval.Parent = addFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, 0, 0, 30)
addBtn.Position = UDim2.new(0, 0, 0, 35)
addBtn.Text = "➕ ADD CHALLENGE"
addBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.TextSize = 12
addBtn.BorderSizePixel = 0
addBtn.Parent = addFrame

addBtn.MouseButton1Click:Connect(function()
    local name = challengeDropdown.Text
    local interval = tonumber(addInterval.Text) or 300
    if name ~= "" then
        table.insert(challengeOrder, {name = name, id = name, interval = interval, enabled = true})
        refreshChallengeUI()
        challengeDropdown.Text = ""
        autoSaveConfig()
    end
end)

-- Preset Buttons
local presetFrame = Instance.new("Frame")
presetFrame.Size = UDim2.new(0.9, 0, 0, 35)
presetFrame.BackgroundTransparency = 1
presetFrame.Parent = challengePanel

local preset1 = Instance.new("TextButton")
preset1.Size = UDim2.new(0.32, -2, 1, 0)
preset1.Text = "Default"
preset1.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
preset1.TextColor3 = Color3.new(1, 1, 1)
preset1.TextSize = 11
preset1.BorderSizePixel = 0
preset1.Parent = presetFrame

local preset2 = Instance.new("TextButton")
preset2.Size = UDim2.new(0.32, -2, 1, 0)
preset2.Position = UDim2.new(0.34, 0, 0, 0)
preset2.Text = "Godly Only"
preset2.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
preset2.TextColor3 = Color3.new(1, 1, 1)
preset2.TextSize = 11
preset2.BorderSizePixel = 0
preset2.Parent = presetFrame

local preset3 = Instance.new("TextButton")
preset3.Size = UDim2.new(0.32, -2, 1, 0)
preset3.Position = UDim2.new(0.68, 0, 0, 0)
preset3.Text = "Clear"
preset3.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
preset3.TextColor3 = Color3.new(1, 1, 1)
preset3.TextSize = 11
preset3.BorderSizePixel = 0
preset3.Parent = presetFrame

preset1.MouseButton1Click:Connect(function()
    challengeOrder = {}
    table.insert(challengeOrder, {name = "Insane Challenge", id = "Insane Challenge", interval = 300, enabled = true})
    table.insert(challengeOrder, {name = "Pro Challenge", id = "Pro Challenge", interval = 240, enabled = true})
    table.insert(challengeOrder, {name = "Easter Challenge #2", id = "Easter Challenge #2", interval = 180, enabled = true})
    table.insert(challengeOrder, {name = "Godly Challenge", id = "Godly Challenge", interval = 300, enabled = true})
    refreshChallengeUI()
    autoSaveConfig()
end)

preset2.MouseButton1Click:Connect(function()
    challengeOrder = {}
    table.insert(challengeOrder, {name = "Godly Challenge", id = "Godly Challenge", interval = 600, enabled = true})
    refreshChallengeUI()
    autoSaveConfig()
end)

preset3.MouseButton1Click:Connect(function()
    challengeOrder = {}
    refreshChallengeUI()
    autoSaveConfig()
end)

-- Auto Challenge Toggle & Manual Controls
local autoChallengeActive = false
local autoChallengeToggle = Instance.new("TextButton")
autoChallengeToggle.Size = UDim2.new(0.9, 0, 0, 45)
autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
autoChallengeToggle.TextSize = 14
autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
autoChallengeToggle.TextColor3 = Color3.new(1, 1, 1)
autoChallengeToggle.BorderSizePixel = 0
autoChallengeToggle.Parent = challengePanel

local manualTitle = Instance.new("TextLabel")
manualTitle.Size = UDim2.new(0.9, 0, 0, 20)
manualTitle.Text = "🎮 MANUAL CONTROLS"
manualTitle.TextColor3 = Color3.new(0.5, 0.8, 1)
manualTitle.TextSize = 12
manualTitle.BackgroundTransparency = 1
manualTitle.Parent = challengePanel

local manualFrame = Instance.new("Frame")
manualFrame.Size = UDim2.new(0.9, 0, 0, 80)
manualFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
manualFrame.BorderSizePixel = 0
manualFrame.Parent = challengePanel

local startFromFirstBtn = Instance.new("TextButton")
startFromFirstBtn.Size = UDim2.new(0.48, -5, 0.4, 0)
startFromFirstBtn.Position = UDim2.new(0, 5, 0.05, 0)
startFromFirstBtn.Text = "🎯 START FROM\nORDER 1"
startFromFirstBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
startFromFirstBtn.TextColor3 = Color3.new(1, 1, 1)
startFromFirstBtn.TextSize = 12
startFromFirstBtn.BorderSizePixel = 0
startFromFirstBtn.Parent = manualFrame

local executeNextBtn = Instance.new("TextButton")
executeNextBtn.Size = UDim2.new(0.48, -5, 0.4, 0)
executeNextBtn.Position = UDim2.new(0.52, 0, 0.05, 0)
executeNextBtn.Text = "⚡ EXECUTE\nNEXT CHALLENGE"
executeNextBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 50)
executeNextBtn.TextColor3 = Color3.new(1, 1, 1)
executeNextBtn.TextSize = 12
executeNextBtn.BorderSizePixel = 0
executeNextBtn.Parent = manualFrame

local manualWarning = Instance.new("TextLabel")
manualWarning.Size = UDim2.new(1, -10, 0, 25)
manualWarning.Position = UDim2.new(0, 5, 0.55, 0)
manualWarning.Text = "⚠️ Manual controls interrupt auto mode"
manualWarning.TextColor3 = Color3.new(1, 0.5, 0)
manualWarning.TextSize = 10
manualWarning.BackgroundTransparency = 1
manualWarning.Parent = manualFrame

--// ============== UI DETECTION & CHALLENGE FUNCTIONS ==============
local function findCooldownTimer()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text or ""
            if txt:match("%d%d:%d%d") or txt:match("%d:%d%d") then
                local parent = obj.Parent
                for _, sib in ipairs(parent:GetChildren()) do
                    if sib:IsA("TextLabel") and (sib.Text:find("Reward") or sib.Text:find("Cooldown")) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function startSpecificChallenge(challengeId)
    pcall(function()
        raidStop:FireServer()
        task.wait(0.5)
        startChallenge:InvokeServer(challengeId)
        task.wait(0.5)
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

local function turnOffAutoRaid()
    pcall(function() changeSetting:InvokeServer("AutoRaid", "Off") end)
end

local function startAutoRaid()
    pcall(function() changeSetting:InvokeServer("AutoRaid", "On") end)
end

-- Stop challenge loop
local function stopChallengeLoop()
    autoChallengeActive = false
    if challengeLoopThread then
        challengeLoopThread = nil
    end
end

-- Start challenge loop
local function startChallengeLoop()
    stopChallengeLoop()
    autoChallengeActive = true
    
    challengeLoopThread = task.spawn(function()
        local isFirstRunLocal = true
        local autoRaidTriggeredLocal = false
        
        while autoChallengeActive do
            local enabledList = {}
            for _, ch in ipairs(challengeOrder) do
                if ch.enabled then
                    table.insert(enabledList, ch)
                end
            end
            
            if #enabledList == 0 then
                challengeStatus.Text = "Status: No challenges enabled!"
                countdownDisplay.Text = "---"
                task.wait(5)
            else
                for currentIndex, challenge in ipairs(enabledList) do
                    if not autoChallengeActive then break end
                    
                    local nextName = "None"
                    if currentIndex < #enabledList then
                        nextName = enabledList[currentIndex + 1].name
                    elseif #enabledList > 0 then
                        nextName = enabledList[1].name
                    end
                    orderDisplay.Text = string.format("📍 %s → %s", challenge.name, nextName)
                    
                    if isFirstRunLocal then
                        challengeStatus.Text = "⏳ Waiting for cooldown - " .. challenge.name
                        local cooldownEnded = false
                        while autoChallengeActive and not cooldownEnded do
                            local timer = findCooldownTimer()
                            if timer then
                                local timeText = timer.Text
                                countdownDisplay.Text = timeText
                                if timeText == "00:00" or timeText == "0:00" then
                                    cooldownEnded = true
                                end
                            else
                                countdownDisplay.Text = "Open Menu"
                            end
                            task.wait(1)
                        end
                        isFirstRunLocal = false
                        
                        for i = 5, 1, -1 do
                            if not autoChallengeActive then break end
                            challengeStatus.Text = "🚀 Starting in " .. i
                            countdownDisplay.Text = i
                            task.wait(1)
                        end
                    end
                    
                    if autoChallengeActive then
                        challengeStatus.Text = "🏃 " .. challenge.name
                        countdownDisplay.Text = "RUNNING"
                        startSpecificChallenge(challenge.id)
                        
                        local waitTime = challenge.interval
                        for i = waitTime, 1, -1 do
                            if not autoChallengeActive then break end
                            local mins = math.floor(i / 60)
                            local secs = i % 60
                            countdownDisplay.Text = string.format("%02d:%02d", mins, secs)
                            if i % 30 == 0 or i <= 10 then
                                challengeStatus.Text = string.format("✅ %s - %d:%02d", challenge.name, mins, secs)
                            end
                            task.wait(1)
                        end
                        
                        if currentIndex < #enabledList then
                            for i = 5, 1, -1 do
                                if not autoChallengeActive then break end
                                challengeStatus.Text = "⏳ Next in " .. i
                                countdownDisplay.Text = i
                                task.wait(1)
                            end
                        end
                        
                        if autoRaidAfterChallenge then
                            turnOffAutoRaid()
                        end
                    end
                end
                
                if autoRaidActive and not autoRaidTriggeredLocal then
                    autoRaidTriggeredLocal = true
                    for i = autoRaidWaitTime, 1, -1 do
                        if not autoChallengeActive then break end
                        local mins = math.floor(i / 60)
                        local secs = i % 60
                        challengeStatus.Text = "🤖 Auto Raid"
                        countdownDisplay.Text = string.format("%02d:%02d", mins, secs)
                        task.wait(1)
                    end
                    if autoChallengeActive then
                        challengeStatus.Text = "🚀 Auto Raid!"
                        startAutoRaid()
                        countdownDisplay.Text = "ACTIVE"
                        task.wait(30)
                    end
                end
                
                isFirstRunLocal = true
                autoRaidTriggeredLocal = false
            end
        end
    end)
end

-- Confirmation Dialog
local function showConfirmation(title, message, onConfirm)
    local confirmGui = Instance.new("ScreenGui")
    confirmGui.Parent = game:GetService("CoreGui")
    confirmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0, 320, 0, 170)
    confirmFrame.Position = UDim2.new(0.5, -160, 0.5, -85)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    confirmFrame.BorderSizePixel = 2
    confirmFrame.BorderColor3 = Color3.fromRGB(255, 100, 100)
    confirmFrame.Parent = confirmGui
    
    local confirmTitle = Instance.new("TextLabel")
    confirmTitle.Size = UDim2.new(1, 0, 0, 45)
    confirmTitle.Text = title
    confirmTitle.TextColor3 = Color3.new(1, 0.5, 0)
    confirmTitle.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 16
    confirmTitle.Parent = confirmFrame
    
    local confirmMsg = Instance.new("TextLabel")
    confirmMsg.Size = UDim2.new(1, -20, 0, 60)
    confirmMsg.Position = UDim2.new(0, 10, 0, 50)
    confirmMsg.Text = message
    confirmMsg.TextColor3 = Color3.new(1, 1, 1)
    confirmMsg.TextWrapped = true
    confirmMsg.TextSize = 13
    confirmMsg.BackgroundTransparency = 1
    confirmMsg.Parent = confirmFrame
    
    local confirmYes = Instance.new("TextButton")
    confirmYes.Size = UDim2.new(0.4, -5, 0, 40)
    confirmYes.Position = UDim2.new(0.05, 0, 0, 115)
    confirmYes.Text = "✅ CONFIRM"
    confirmYes.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    confirmYes.TextColor3 = Color3.new(1, 1, 1)
    confirmYes.BorderSizePixel = 0
    confirmYes.Parent = confirmFrame
    
    local confirmNo = Instance.new("TextButton")
    confirmNo.Size = UDim2.new(0.4, -5, 0, 40)
    confirmNo.Position = UDim2.new(0.55, 0, 0, 115)
    confirmNo.Text = "❌ CANCEL"
    confirmNo.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    confirmNo.TextColor3 = Color3.new(1, 1, 1)
    confirmNo.BorderSizePixel = 0
    confirmNo.Parent = confirmFrame
    
    confirmYes.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
        onConfirm()
    end)
    
    confirmNo.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
    end)
end

-- Manual Control Functions
local function startFromOrderOne()
    local wasRunning = autoChallengeActive
    stopChallengeLoop()
    task.wait(0.5)
    
    isFirstRun = true
    autoRaidTriggered = false
    
    challengeStatus.Text = "🔄 Manual: Starting from Order 1..."
    countdownDisplay.Text = "START"
    
    local enabledList = {}
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            table.insert(enabledList, ch)
        end
    end
    
    if #enabledList > 0 then
        pcall(function() raidStop:FireServer() end)
        task.wait(0.5)
        challengeStatus.Text = "🚀 " .. enabledList[1].name
        startSpecificChallenge(enabledList[1].id)
        
        if wasRunning then
            task.wait(2)
            startChallengeLoop()
        end
    else
        challengeStatus.Text = "❌ No challenges enabled!"
        if wasRunning then
            startChallengeLoop()
        end
    end
end

local function executeNextChallenge()
    local wasRunning = autoChallengeActive
    stopChallengeLoop()
    task.wait(0.5)
    
    local enabledList = {}
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            table.insert(enabledList, ch)
        end
    end
    
    if #enabledList == 0 then
        challengeStatus.Text = "❌ No challenges enabled!"
        if wasRunning then
            startChallengeLoop()
        end
        return
    end
    
    local nextChallenge = nil
    local currentName = nil
    local currentText = orderDisplay.Text
    local match = string.match(currentText, "📍 (.-) →")
    if match and match ~= "None" then
        currentName = match
    end
    
    local foundCurrent = false
    for i, ch in ipairs(enabledList) do
        if foundCurrent then
            nextChallenge = ch
            break
        end
        if ch.name == currentName then
            foundCurrent = true
        end
    end
    
    if not nextChallenge then
        nextChallenge = enabledList[1]
    end
    
    challengeStatus.Text = "⚡ " .. nextChallenge.name
    pcall(function() raidStop:FireServer() end)
    task.wait(0.5)
    startSpecificChallenge(nextChallenge.id)
    
    if wasRunning then
        task.wait(2)
        startChallengeLoop()
    end
end

-- Button Connections
autoChallengeToggle.MouseButton1Click:Connect(function()
    if autoChallengeActive then
        stopChallengeLoop()
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        challengeStatus.Text = "Status: Stopped"
        countdownDisplay.Text = "---"
        orderDisplay.Text = "Current: None → Next: None"
    else
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: ON"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        startChallengeLoop()
    end
    autoSaveConfig()
end)

startFromFirstBtn.MouseButton1Click:Connect(function()
    showConfirmation("⚠️ RESTART FROM ORDER 1", "This will stop current challenge and restart from the first enabled challenge.\n\nProceed?", startFromOrderOne)
end)

executeNextBtn.MouseButton1Click:Connect(function()
    showConfirmation("⚡ EXECUTE NEXT CHALLENGE", "This will skip cooldown and immediately start the next challenge.\n\nProceed?", executeNextChallenge)
end)

-- Build Functions
local function executeEasterBuild()
    buildStatus.Text = "Building Easter..."
    globalStatus.Text = "🏗️ Building Easter..."
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(easterBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            eBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    buildStatus.Text = "✅ Easter complete!"
    globalStatus.Text = "✅ Easter built"
    task.wait(2)
    buildStatus.Text = "Status: Ready"
    globalStatus.Text = "✅ Ready"
end

local function executeMegaBuild()
    buildStatus.Text = "Building Mega Raid..."
    globalStatus.Text = "🏗️ Building Mega Raid..."
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(megaRaidBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            cBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    buildStatus.Text = "✅ Mega complete!"
    globalStatus.Text = "✅ Mega Raid built"
    task.wait(2)
    buildStatus.Text = "Status: Ready"
    globalStatus.Text = "✅ Ready"
end

easterBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeEasterBuild)
end)

megaBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeMegaBuild)
end)

--// ============== SCHEDULE TAB ==============
local schedulePanel = panels.schedule

local scheduleCard = Instance.new("Frame")
scheduleCard.Size = UDim2.new(1, -20, 0, 150)
scheduleCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
scheduleCard.BorderSizePixel = 0
scheduleCard.Parent = schedulePanel

local scheduleStatus = Instance.new("TextLabel")
scheduleStatus.Size = UDim2.new(0.95, 0, 0, 40)
scheduleStatus.Position = UDim2.new(0.025, 0, 0, 5)
scheduleStatus.Text = "Schedule Status: IDLE"
scheduleStatus.TextColor3 = Color3.new(1, 1, 1)
scheduleStatus.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
scheduleStatus.BorderSizePixel = 0
scheduleStatus.Parent = scheduleCard

local easterScheduleToggle = Instance.new("TextButton")
easterScheduleToggle.Size = UDim2.new(0.95, 0, 0, 45)
easterScheduleToggle.Position = UDim2.new(0.025, 0, 0, 50)
easterScheduleToggle.Text = "🐰 EASTER (:15 & :45): OFF"
easterScheduleToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
easterScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
easterScheduleToggle.BorderSizePixel = 0
easterScheduleToggle.Parent = scheduleCard

local megaScheduleToggle = Instance.new("TextButton")
megaScheduleToggle.Size = UDim2.new(0.95, 0, 0, 45)
megaScheduleToggle.Position = UDim2.new(0.025, 0, 0, 100)
megaScheduleToggle.Text = "⚔️ MEGA RAID (:00): OFF"
megaScheduleToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
megaScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
megaScheduleToggle.BorderSizePixel = 0
megaScheduleToggle.Parent = scheduleCard

local easterSched = false
local megaSched = false
local lastCheck = -1

local function runScheduler()
    task.spawn(function()
        while true do
            local now = os.date("*t")
            local min = now.min
            
            if min ~= lastCheck then
                lastCheck = min
                
                if easterSched and (min == 15 or min == 45) then
                    scheduleStatus.Text = "Schedule: Running Easter..."
                    globalStatus.Text = "⏰ Running Easter build"
                    task.spawn(executeEasterBuild)
                end
                
                if megaSched and min == 0 then
                    scheduleStatus.Text = "Schedule: Running Mega Raid..."
                    globalStatus.Text = "⏰ Running Mega Raid build"
                    task.spawn(executeMegaBuild)
                end
                
                local nextInfo = ""
                if easterSched then
                    if min < 15 then nextInfo = "Next Easter: :15"
                    elseif min < 45 then nextInfo = "Next Easter: :45"
                    else nextInfo = "Next Easter: :15 (next hour)" end
                end
                scheduleStatus.Text = "Schedule: Active\n🐰 " .. (easterSched and nextInfo or "Easter OFF") .. "\n⚔️ " .. (megaSched and "Next Mega: :00" or "Mega OFF")
                globalStatus.Text = "✅ Ready"
            end
            task.wait(1)
        end
    end)
end

easterScheduleToggle.MouseButton1Click:Connect(function()
    easterSched = not easterSched
    easterScheduleToggle.Text = easterSched and "🐰 EASTER (:15 & :45): ✅ ON" or "🐰 EASTER (:15 & :45): ❌ OFF"
    easterScheduleToggle.BackgroundColor3 = easterSched and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
end)

megaScheduleToggle.MouseButton1Click:Connect(function()
    megaSched = not megaSched
    megaScheduleToggle.Text = megaSched and "⚔️ MEGA RAID (:00): ✅ ON" or "⚔️ MEGA RAID (:00): ❌ OFF"
    megaScheduleToggle.BackgroundColor3 = megaSched and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
end)

runScheduler()

--// ============== CONFIG TAB ==============
local configPanel = panels.config

local configCard = Instance.new("Frame")
configCard.Size = UDim2.new(1, -20, 0, 400)
configCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
configCard.BorderSizePixel = 0
configCard.Parent = configPanel

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(0.95, 0, 0, 40)
configTitle.Position = UDim2.new(0.025, 0, 0, 5)
configTitle.Text = "💾 CONFIGURATION (Auto-Saves)"
configTitle.TextColor3 = Color3.new(1, 1, 0.5)
configTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
configTitle.Font = Enum.Font.GothamBold
configTitle.BorderSizePixel = 0
configTitle.Parent = configCard

local configStatusIndicator = Instance.new("TextLabel")
configStatusIndicator.Size = UDim2.new(0.95, 0, 0, 30)
configStatusIndicator.Position = UDim2.new(0.025, 0, 0, 50)
configStatusIndicator.Text = "📌 Status: Auto-Save Active"
configStatusIndicator.TextColor3 = Color3.new(0, 1, 0)
configStatusIndicator.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
configStatusIndicator.BorderSizePixel = 0
configStatusIndicator.Parent = configCard

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.95, 0, 0, 45)
saveBtn.Position = UDim2.new(0.025, 0, 0, 90)
saveBtn.Text = "💾 MANUAL SAVE"
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.TextSize = 14
saveBtn.BorderSizePixel = 0
saveBtn.Parent = configCard

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.95, 0, 0, 45)
resetBtn.Position = UDim2.new(0.025, 0, 0, 145)
resetBtn.Text = "⚠️ RESET TO DEFAULT"
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.TextSize = 14
resetBtn.BorderSizePixel = 0
resetBtn.Parent = configCard

local exportBtn = Instance.new("TextButton")
exportBtn.Size = UDim2.new(0.46, -5, 0, 45)
exportBtn.Position = UDim2.new(0.025, 0, 0, 200)
exportBtn.Text = "📤 EXPORT"
exportBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
exportBtn.TextColor3 = Color3.new(1, 1, 1)
exportBtn.TextSize = 14
exportBtn.BorderSizePixel = 0
exportBtn.Parent = configCard

local importBtn = Instance.new("TextButton")
importBtn.Size = UDim2.new(0.46, -5, 0, 45)
importBtn.Position = UDim2.new(0.515, 0, 0, 200)
importBtn.Text = "📋 IMPORT"
importBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 50)
importBtn.TextColor3 = Color3.new(1, 1, 1)
importBtn.TextSize = 14
importBtn.BorderSizePixel = 0
importBtn.Parent = configCard

local saveStatus = Instance.new("TextLabel")
saveStatus.Size = UDim2.new(0.95, 0, 0, 30)
saveStatus.Position = UDim2.new(0.025, 0, 0, 255)
saveStatus.Text = "Ready"
saveStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
saveStatus.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
saveStatus.BorderSizePixel = 0
saveStatus.Parent = configCard

local configInfo = Instance.new("TextLabel")
configInfo.Size = UDim2.new(0.95, 0, 0, 100)
configInfo.Position = UDim2.new(0.025, 0, 0, 295)
configInfo.Text = "📌 Auto-Save Info:\n\n✅ Changes save automatically!\n✅ Config loads when script starts\n✅ Export to save backup\n✅ Import to restore backup"
configInfo.TextColor3 = Color3.new(0.6, 0.6, 0.6)
configInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
configInfo.TextWrapped = true
configInfo.TextSize = 11
configInfo.BorderSizePixel = 0
configInfo.Parent = configCard

--// ============== CONFIG SYSTEM ==============
local configName = "TD_Auto_Farm_Config"
local savedConfig = nil

local function autoSaveConfig()
    local config = {
        version = 5,
        savedAt = os.date("%Y-%m-%d %H:%M:%S"),
        challengeOrder = {},
        selectedItems = {},
        autoBuyEnabled = autoBuyActive,
        autoRaidAfterChallenge = autoRaidAfterChallenge,
        autoRaidEnabled = autoRaidActive,
        autoRaidWaitTime = autoRaidWaitTime,
        autoChallengeEnabled = autoChallengeActive
    }
    
    for _, ch in ipairs(challengeOrder) do
        table.insert(config.challengeOrder, {
            name = ch.name,
            id = ch.id,
            interval = ch.interval,
            enabled = ch.enabled
        })
    end
    
    for item, _ in pairs(selectedItems) do
        table.insert(config.selectedItems, item)
    end
    
    local success, encoded = pcall(function() return HttpService:JSONEncode(config) end)
    if success then
        pcall(function() writefile(configName .. ".json", encoded) end)
        pcall(function() shared[configName] = encoded end)
    end
end

local function autoLoadConfig()
    local configData = nil
    local readSuccess, data = pcall(function() return readfile(configName .. ".json") end)
    if readSuccess and data and data ~= "" then
        configData = data
    end
    if not configData then
        pcall(function()
            if shared[configName] and shared[configName] ~= "" then
                configData = shared[configName]
            end
        end)
    end
    if configData then
        local success, data = pcall(function() return HttpService:JSONDecode(configData) end)
        if success and data then
            savedConfig = data
            return true
        end
    end
    return false
end

local function applyConfig()
    if not savedConfig then return false end
    
    if savedConfig.challengeOrder and #savedConfig.challengeOrder > 0 then
        challengeOrder = {}
        for _, ch in ipairs(savedConfig.challengeOrder) do
            table.insert(challengeOrder, {
                name = ch.name,
                id = ch.id,
                interval = ch.interval,
                enabled = ch.enabled
            })
        end
        refreshChallengeUI()
    end
    
    if savedConfig.selectedItems then
        for _, itemName in ipairs(savedConfig.selectedItems) do
            selectedItems[itemName] = true
            local btn = itemButtons[itemName]
            if btn then
                btn.Text = btn.Text:gsub("%[ %]","[✓]")
                btn.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
            end
        end
    end
    
    if savedConfig.autoRaidAfterChallenge ~= nil then
        autoRaidAfterChallenge = savedConfig.autoRaidAfterChallenge
        autoRaidAfterToggle.Text = autoRaidAfterChallenge and "🏠 After each challenge: ON" or "🏠 After each challenge: OFF"
        autoRaidAfterToggle.BackgroundColor3 = autoRaidAfterChallenge and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
    end
    
    if savedConfig.autoRaidEnabled ~= nil then
        autoRaidActive = savedConfig.autoRaidEnabled
        autoRaidWaitTime = savedConfig.autoRaidWaitTime or 300
        autoRaidToggle.Text = autoRaidActive and "After last: ON (" .. math.floor(autoRaidWaitTime/60) .. "m)" or "After last: OFF"
        autoRaidToggle.BackgroundColor3 = autoRaidActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
        raidWaitBox.Text = tostring(autoRaidWaitTime)
    end
    
    if savedConfig.autoBuyEnabled then
        autoBuyActive = savedConfig.autoBuyEnabled
        autoBuyToggle.Text = autoBuyActive and "🟢 AUTO BUY: ON (1s)" or "🔴 AUTO BUY: OFF"
        autoBuyToggle.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
        if autoBuyActive then autoBuyLoop() end
    end
    
    if savedConfig.autoChallengeEnabled then
        autoChallengeActive = savedConfig.autoChallengeEnabled
        autoChallengeToggle.Text = autoChallengeActive and "🎯 AUTO CHALLENGE: ON" or "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
        if autoChallengeActive then startChallengeLoop() end
    end
    
    return true
end

local function resetToDefault()
    showConfirmation("⚠️ RESET TO DEFAULT", "This will reset ALL settings to default.\nThis cannot be undone!\n\nProceed?", function()
        challengeOrder = {}
        for i, ch in ipairs(allChallenges) do
            challengeOrder[i] = {name = ch.name, id = ch.id, interval = 300, enabled = false}
        end
        refreshChallengeUI()
        
        for name, btn in pairs(itemButtons) do
            btn.Text = btn.Text:gsub("%[✓%]","[ ]")
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        end
        selectedItems = {}
        
        autoBuyActive = false
        autoBuyToggle.Text = "🔴 AUTO BUY: OFF"
        autoBuyToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        
        autoRaidAfterChallenge = true
        autoRaidAfterToggle.Text = "🏠 After each challenge: ON"
        autoRaidAfterToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        
        autoRaidActive = false
        autoRaidWaitTime = 300
        autoRaidToggle.Text = "After last: OFF"
        autoRaidToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        raidWaitBox.Text = "300"
        
        autoChallengeActive = false
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        
        autoSaveConfig()
        saveStatus.Text = "✅ Reset to default!"
        task.wait(2)
        saveStatus.Text = "Ready"
    end)
end

saveBtn.MouseButton1Click:Connect(function()
    autoSaveConfig()
    saveStatus.Text = "✅ Config saved!"
    task.wait(2)
    saveStatus.Text = "Ready"
end)

resetBtn.MouseButton1Click:Connect(function()
    resetToDefault()
end)

exportBtn.MouseButton1Click:Connect(function()
    local config = {
        version = 5,
        savedAt = os.date("%Y-%m-%d %H:%M:%S"),
        challengeOrder = {},
        selectedItems = {},
        autoBuyEnabled = autoBuyActive,
        autoRaidAfterChallenge = autoRaidAfterChallenge,
        autoRaidEnabled = autoRaidActive,
        autoRaidWaitTime = autoRaidWaitTime,
        autoChallengeEnabled = autoChallengeActive
    }
    
    for _, ch in ipairs(challengeOrder) do
        table.insert(config.challengeOrder, {
            name = ch.name,
            id = ch.id,
            interval = ch.interval,
            enabled = ch.enabled
        })
    end
    
    for item, _ in pairs(selectedItems) do
        table.insert(config.selectedItems, item)
    end
    
    local success, json = pcall(function() return HttpService:JSONEncode(config) end)
    if success then
        pcall(function() setclipboard("[TD CONFIG] " .. json) end)
        saveStatus.Text = "✅ Exported to clipboard!"
    else
        saveStatus.Text = "❌ Export failed"
    end
    task.wait(2)
    saveStatus.Text = "Ready"
end)

importBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local clip = getclipboard()
        if clip and clip ~= "" then
            local cleanClip = clip:gsub("%[TD CONFIG%] ", "")
            local success, data = pcall(function() return HttpService:JSONDecode(cleanClip) end)
            if success and data then
                savedConfig = data
                applyConfig()
                autoSaveConfig()
                saveStatus.Text = "✅ Config imported!"
            else
                saveStatus.Text = "❌ Invalid config"
            end
        else
            saveStatus.Text = "❌ Clipboard empty"
        end
        task.wait(2)
        saveStatus.Text = "Ready"
    end)
end)

--// TAB SWITCHING
for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for tabName, panel in pairs(panels) do
            panel.Visible = (tabName == name)
            if tabs[tabName] then
                tabs[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(45, 45, 60)
                tabs[tabName].TextColor3 = (tabName == name) and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
            end
        end
    end)
end

-- Show build tab by default
panels.build.Visible = true
tabs.build.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
tabs.build.TextColor3 = Color3.new(1, 1, 1)

-- Load config on startup
if autoLoadConfig() then
    applyConfig()
end

refreshChallengeUI()

print("=== TD Auto Farm Loaded! ===")
print("Improved GUI with better layout and colors!")

end)
