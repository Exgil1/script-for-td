--// COMPLETE TOWER DEFENSE AUTO FARM - WITH PRECISE CHALLENGE COOLDOWN
--// Features: Auto Build, Auto Buy, Auto Challenge (with NextAvailableTime), Schedule, Auto-Save Config

pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

--// GLOBAL VARIABLES
local isFirstRun = true
local autoRaidTriggered = false
local challengeLoopThread = nil
local currentChallengeName = nil

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

--// PLAYER DATA FOR CHALLENGE COOLDOWN
local challengesFolder = player:FindFirstChild("Challenges")
local playerFlags = player:FindFirstChild("Flags")
local raidingFlag = playerFlags and playerFlags:FindFirstChild("Raiding")
local challengeActiveFlag = playerFlags and playerFlags:FindFirstChild("ChallengeActive")

--// CHALLENGE DURATIONS (seconds) - for countdown display during active challenge
local challengeDurations = {
    ["Insane Challenge"] = 22 * 60,
    ["Pro Challenge"] = 20 * 60,
    ["Godly Challenge"] = 20 * 60,
    ["Easter Challenge #1"] = 15 * 60,
    ["Easter Challenge #2"] = 15 * 60,
    ["Novice Challenge"] = 10 * 60,
    ["Advanced Challenge"] = 15 * 60,
}

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

--// ============== CHALLENGE COOLDOWN FUNCTIONS ==============

local function getChallengeCooldown(challengeName)
    if not challengesFolder then return 0 end
    
    local challengeNode = challengesFolder:FindFirstChild(challengeName)
    if not challengeNode then
        challengeNode = challengesFolder:FindFirstChild(challengeName:gsub(" ", ""))
    end
    
    if challengeNode then
        local nextAvailable = challengeNode:FindFirstChild("NextAvailableTime")
        if nextAvailable then
            local remaining = nextAvailable.Value - os.time()
            return math.max(0, remaining)
        end
    end
    return 0
end

local function getChallengeTimeRemaining(challengeName)
    local challengeStartTime = player:FindFirstChild("ChallengeStartTime")
    if not challengeStartTime or challengeStartTime.Value == 0 then
        return nil
    end
    
    local duration = challengeDurations[challengeName]
    if not duration then
        return nil
    end
    
    local elapsed = os.time() - challengeStartTime.Value
    local remaining = duration - elapsed
    return math.max(0, remaining)
end

local function isChallengeAvailable(challengeName)
    return getChallengeCooldown(challengeName) == 0
end

local function isInChallenge()
    return challengeActiveFlag and challengeActiveFlag.Value == true
end

local function isInRaid()
    return raidingFlag and raidingFlag.Value == true
end

--// ============== GUI ==============
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 750)
mainFrame.Position = UDim2.new(0, 10, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

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

--// TABS
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
statusCard.Size = UDim2.new(1, -20, 0, 140)
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
countdownDisplay.Size = UDim2.new(0.95, 0, 0, 45)
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
orderDisplay.Position = UDim2.new(0.025, 0, 0, 90)
orderDisplay.Text = "Current: None → Next: None"
orderDisplay.TextColor3 = Color3.new(0.6, 0.6, 0.8)
orderDisplay.TextSize = 11
orderDisplay.BackgroundTransparency = 1
orderDisplay.Parent = statusCard

-- Queue Display
local queueTitle = Instance.new("TextLabel")
queueTitle.Size = UDim2.new(0.9, 0, 0, 25)
queueTitle.Text = "📋 CHALLENGE QUEUE (with cooldowns)"
queueTitle.TextColor3 = Color3.new(1, 1, 0.5)
queueTitle.TextSize = 14
queueTitle.BackgroundTransparency = 1
queueTitle.Parent = challengePanel

local queueDisplay = Instance.new("TextLabel")
queueDisplay.Size = UDim2.new(0.9, 0, 0, 100)
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

local function updateQueueWithCooldowns()
    local enabledList = {}
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            local cooldown = getChallengeCooldown(ch.name)
            if cooldown == 0 then
                table.insert(enabledList, string.format("%s ✅ READY", ch.name))
            else
                local hours = math.floor(cooldown / 3600)
                local minutes = math.floor((cooldown % 3600) / 60)
                local seconds = cooldown % 60
                if hours > 0 then
                    table.insert(enabledList, string.format("%s ⏰ %02dh %02dm", ch.name, hours, minutes))
                else
                    table.insert(enabledList, string.format("%s ⏰ %02d:%02d", ch.name, minutes, seconds))
                end
            end
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
            updateQueueWithCooldowns()
            autoSaveConfig()
        end)
        
        intervalBox:GetPropertyChangedSignal("Text"):Connect(function()
            local val = tonumber(intervalBox.Text)
            if val and val > 0 then
                challengeOrder[index].interval = val
                updateQueueWithCooldowns()
                autoSaveConfig()
            end
        end)
        
        upBtn.MouseButton1Click:Connect(function()
            if index > 1 then
                challengeOrder[index], challengeOrder[index-1] = challengeOrder[index-1], challengeOrder[index]
                refreshChallengeUI()
                updateQueueWithCooldowns()
                autoSaveConfig()
            end
