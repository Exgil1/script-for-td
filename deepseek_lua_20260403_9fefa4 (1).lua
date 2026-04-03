--// COMPLETE TOWER DEFENSE AUTO FARM - WITH AUTO RAID TOGGLE
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

--// CONFIGURATION SAVE SYSTEM
local configName = "TD_Auto_Farm_Config"
local savedConfig = nil

local function loadConfig()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(configName .. ".json"))
    end)
    if success and data then
        savedConfig = data
        print("[Config] Loaded saved configuration")
        return true
    end
    print("[Config] No saved configuration found, using defaults")
    return false
end

local function saveConfig()
    local config = {
        version = 3,
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
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    
    if success then
        pcall(function()
            writefile(configName .. ".json", encoded)
            print("[Config] Saved successfully")
            if saveStatus then
                saveStatus.Text = "✅ Config saved at " .. os.date("%H:%M:%S")
                task.wait(2)
                saveStatus.Text = "Ready"
            end
        end)
    end
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
        updateQueueDisplay()
    end
    
    if savedConfig.selectedItems then
        for _, itemName in ipairs(savedConfig.selectedItems) do
            selectedItems[itemName] = true
            local btn = itemButtons[itemName]
            if btn then
                btn.Text = btn.Text:gsub("%[ %]","[X]")
            end
        end
    end
    
    autoRaidAfterChallenge = savedConfig.autoRaidAfterChallenge ~= nil and savedConfig.autoRaidAfterChallenge or true
    if autoRaidAfterToggle then
        autoRaidAfterToggle.Text = autoRaidAfterChallenge and "🏠 Auto Raid AFTER each challenge: ✅ ON" or "🏠 Auto Raid AFTER each challenge: ❌ OFF"
        autoRaidAfterToggle.BackgroundColor3 = autoRaidAfterChallenge and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    end
    
    autoRaidActive = savedConfig.autoRaidEnabled or false
    autoRaidWaitTime = savedConfig.autoRaidWaitTime or 300
    if autoRaidToggle then
        autoRaidToggle.Text = autoRaidActive and "🏠 Auto Raid AFTER LAST: ✅ ON (Wait " .. math.floor(autoRaidWaitTime/60) .. " min)" or "🏠 Auto Raid AFTER LAST: ❌ OFF"
        autoRaidToggle.BackgroundColor3 = autoRaidActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    end
    
    if savedConfig.autoBuyEnabled and not autoBuyActive then
        autoBuyActive = true
        autoBuyToggle.Text = "🔴 AUTO BUY (1s): ON"
        autoBuyToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        autoBuyLoop()
    end
    
    if savedConfig.autoChallengeEnabled and not autoChallengeActive then
        autoChallengeActive = true
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: ON"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        runAutoChallenge()
    end
    
    return true
end

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

--// ITEMS
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

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 780)
mainFrame.Position = UDim2.new(0, 10, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "TD Auto Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 3)
minBtn.Text = "-"
minBtn.Parent = mainFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 10, 0, 100)
iconBtn.Text = "TD"
iconBtn.Visible = false
iconBtn.Parent = gui

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    iconBtn.Visible = true
end)

iconBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    iconBtn.Visible = false
end)

--// TABS
local tabY = 40
local tabs = {}
local currentTab = "build"

local function createTab(name, text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 0, 30)
    btn.Position = UDim2.new(0, 5 + (xPos * 98), 0, tabY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = mainFrame
    tabs[name] = btn
    return btn
end

createTab("build", "🏗️ Build", 0)
createTab("buy", "🛒 Buy", 1)
createTab("challenge", "🎯 Challenge", 2)
createTab("schedule", "⏰ Schedule", 3)
createTab("config", "💾 Config", 4)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -80)
contentFrame.Position = UDim2.new(0, 10, 0, 75)
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
    panel.Parent = contentFrame
    local layout = Instance.new("UIListLayout")
    layout.Parent = panel
    layout.Padding = UDim.new(0, 5)
end

--// ============== BUILD TAB ==============
local buildPanel = panels.build

local easterBuildBtn = Instance.new("TextButton")
easterBuildBtn.Size = UDim2.new(1, -20, 0, 50)
easterBuildBtn.Text = "🐰 BUILD ALL EASTER (4 Towers)"
easterBuildBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
easterBuildBtn.TextColor3 = Color3.new(1, 1, 1)
easterBuildBtn.Font = Enum.Font.GothamBold
easterBuildBtn.Parent = buildPanel

local megaBuildBtn = Instance.new("TextButton")
megaBuildBtn.Size = UDim2.new(1, -20, 0, 50)
megaBuildBtn.Text = "⚔️ BUILD ALL MEGA RAID (5 Towers)"
megaBuildBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
megaBuildBtn.TextColor3 = Color3.new(1, 1, 1)
megaBuildBtn.Font = Enum.Font.GothamBold
megaBuildBtn.Parent = buildPanel

local buildStatus = Instance.new("TextLabel")
buildStatus.Size = UDim2.new(1, -20, 0, 40)
buildStatus.Text = "Status: Ready"
buildStatus.TextColor3 = Color3.new(1, 1, 1)
buildStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
buildStatus.Parent = buildPanel

--// ============== BUY TAB ==============
local buyPanel = panels.buy

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.PlaceholderText = "🔍 Search item..."
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Parent = buyPanel

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -20, 0, 250)
itemsScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
itemsScroll.Parent = buyPanel

local itemsLayout = Instance.new("UIListLayout", itemsScroll)

local selectedItems = {}
local itemButtons = {}

for name, typ in pairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Text = (typ=="E" and "🎯 [EVENT] " or "⚔️ [NORMAL] ").."[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = itemsScroll
    itemButtons[name] = btn
    
    local sel = false
    btn.MouseButton1Click:Connect(function()
        sel = not sel
        if sel then
            btn.Text = btn.Text:gsub("%[ %]","[X]")
            selectedItems[name] = true
        else
            btn.Text = btn.Text:gsub("%[X%]","[ ]")
            selectedItems[name] = nil
        end
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
autoBuyToggle.Size = UDim2.new(1, -20, 0, 45)
autoBuyToggle.Text = "🟢 AUTO BUY (1s): OFF"
autoBuyToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoBuyToggle.TextColor3 = Color3.new(1, 1, 1)
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
    autoBuyToggle.Text = autoBuyActive and "🔴 AUTO BUY (1s): ON" or "🟢 AUTO BUY (1s): OFF"
    autoBuyToggle.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoBuyActive then autoBuyLoop() end
end)

--// ============== CHALLENGE TAB ==============
local challengePanel = panels.challenge

-- Current Queue Display
local queueTitle = Instance.new("TextLabel")
queueTitle.Size = UDim2.new(1, -20, 0, 25)
queueTitle.Text = "📋 CURRENT CHALLENGE QUEUE"
queueTitle.TextColor3 = Color3.new(1, 1, 0)
queueTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
queueTitle.Parent = challengePanel

local queueDisplay = Instance.new("TextLabel")
queueDisplay.Size = UDim2.new(1, -20, 0, 60)
queueDisplay.Text = "No challenges enabled"
queueDisplay.TextColor3 = Color3.new(0.7, 0.7, 0.7)
queueDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
queueDisplay.TextWrapped = true
queueDisplay.TextXAlignment = Enum.TextXAlignment.Left
queueDisplay.Parent = challengePanel

local challengeStatus = Instance.new("TextLabel")
challengeStatus.Size = UDim2.new(1, -20, 0, 40)
challengeStatus.Text = "Status: Idle"
challengeStatus.TextColor3 = Color3.new(1, 1, 1)
challengeStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
challengeStatus.Parent = challengePanel

local countdownDisplay = Instance.new("TextLabel")
countdownDisplay.Size = UDim2.new(1, -20, 0, 40)
countdownDisplay.Text = "Next: --:--"
countdownDisplay.TextColor3 = Color3.new(1, 0.8, 0)
countdownDisplay.TextSize = 18
countdownDisplay.Font = Enum.Font.GothamBold
countdownDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
countdownDisplay.Parent = challengePanel

local orderDisplay = Instance.new("TextLabel")
orderDisplay.Size = UDim2.new(1, -20, 0, 35)
orderDisplay.Text = "Current: None | Next: None"
orderDisplay.TextColor3 = Color3.new(0.5, 0.8, 1)
orderDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
orderDisplay.Parent = challengePanel

-- Auto Raid Toggles Section
local raidTitle = Instance.new("TextLabel")
raidTitle.Size = UDim2.new(1, -20, 0, 25)
raidTitle.Text = "🤖 AUTO RAID SETTINGS"
raidTitle.TextColor3 = Color3.new(1, 1, 0)
raidTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
raidTitle.Parent = challengePanel

-- Toggle 1: Auto Raid AFTER EACH challenge
local autoRaidAfterChallenge = true
local autoRaidAfterToggle = Instance.new("TextButton")
autoRaidAfterToggle.Size = UDim2.new(1, -20, 0, 40)
autoRaidAfterToggle.Text = "🏠 Auto Raid AFTER each challenge: ✅ ON"
autoRaidAfterToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
autoRaidAfterToggle.TextColor3 = Color3.new(1, 1, 1)
autoRaidAfterToggle.Parent = challengePanel

-- Toggle 2: Auto Raid AFTER LAST challenge (with wait time)
local autoRaidActive = false
local autoRaidWaitTime = 300 -- 5 minutes default
local autoRaidToggle = Instance.new("TextButton")
autoRaidToggle.Size = UDim2.new(0.7, -5, 0, 40)
autoRaidToggle.Text = "🏠 Auto Raid AFTER LAST: ❌ OFF"
autoRaidToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoRaidToggle.TextColor3 = Color3.new(1, 1, 1)
autoRaidToggle.Parent = challengePanel

-- Wait time input for auto raid
local raidWaitBox = Instance.new("TextBox")
raidWaitBox.Size = UDim2.new(0.27, -5, 0, 40)
raidWaitBox.Position = UDim2.new(0.71, 0, 0, 0)
raidWaitBox.Text = "300"
raidWaitBox.PlaceholderText = "Wait (sec)"
raidWaitBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
raidWaitBox.TextColor3 = Color3.new(1, 1, 1)
raidWaitBox.Parent = challengePanel

raidWaitBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(raidWaitBox.Text)
    if val and val > 0 then
        autoRaidWaitTime = val
        autoRaidToggle.Text = autoRaidActive and "🏠 Auto Raid AFTER LAST: ✅ ON (Wait " .. math.floor(autoRaidWaitTime/60) .. " min)" or "🏠 Auto Raid AFTER LAST: ❌ OFF"
    end
end)

-- Challenge order list title
local orderTitle = Instance.new("TextLabel")
orderTitle.Size = UDim2.new(1, -20, 0, 25)
orderTitle.Text = "⚙️ CHALLENGE CONFIGURATION"
orderTitle.TextColor3 = Color3.new(1, 1, 0)
orderTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
orderTitle.Parent = challengePanel

local challengeScroll = Instance.new("ScrollingFrame")
challengeScroll.Size = UDim2.new(1, -20, 0, 160)
challengeScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
challengeScroll.Parent = challengePanel

local challengeLayout = Instance.new("UIListLayout")
challengeLayout.Parent = challengeScroll

-- Store challenge order data
local challengeOrder = {}

-- Initialize with default order
for i, ch in ipairs(allChallenges) do
    challengeOrder[i] = {
        name = ch.name,
        id = ch.id,
        interval = 300,
        enabled = false
    }
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
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        frame.Parent = challengeScroll
        
        local enableBtn = Instance.new("TextButton")
        enableBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
        enableBtn.Position = UDim2.new(0, 5, 0.1, 0)
        enableBtn.Text = ch.enabled and "✅ " .. ch.name or "❌ " .. ch.name
        enableBtn.BackgroundColor3 = ch.enabled and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
        enableBtn.TextColor3 = Color3.new(1, 1, 1)
        enableBtn.TextXAlignment = Enum.TextXAlignment.Left
        enableBtn.Parent = frame
        
        local intervalBox = Instance.new("TextBox")
        intervalBox.Size = UDim2.new(0.25, -5, 0.7, 0)
        intervalBox.Position = UDim2.new(0.33, 0, 0.15, 0)
        intervalBox.Text = tostring(ch.interval)
        intervalBox.PlaceholderText = "Interval (sec)"
        intervalBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        intervalBox.TextColor3 = Color3.new(1, 1, 1)
        intervalBox.Parent = frame
        
        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
        upBtn.Position = UDim2.new(0.61, 0, 0.15, 0)
        upBtn.Text = "⬆️"
        upBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        upBtn.TextColor3 = Color3.new(1, 1, 1)
        upBtn.Parent = frame
        
        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
        downBtn.Position = UDim2.new(0.73, 0, 0.15, 0)
        downBtn.Text = "⬇️"
        downBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        downBtn.TextColor3 = Color3.new(1, 1, 1)
        downBtn.Parent = frame
        
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0.12, -5, 0.7, 0)
        removeBtn.Position = UDim2.new(0.86, 0, 0.15, 0)
        removeBtn.Text = "🗑️"
        removeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        removeBtn.TextColor3 = Color3.new(1, 1, 1)
        removeBtn.Parent = frame
        
        challengeFrames[i] = {frame = frame, enableBtn = enableBtn, intervalBox = intervalBox}
        
        local index = i
        enableBtn.MouseButton1Click:Connect(function()
            challengeOrder[index].enabled = not challengeOrder[index].enabled
            enableBtn.Text = challengeOrder[index].enabled and "✅ " .. challengeOrder[index].name or "❌ " .. challengeOrder[index].name
            enableBtn.BackgroundColor3 = challengeOrder[index].enabled and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
            updateQueueDisplay()
        end)
        
        intervalBox:GetPropertyChangedSignal("Text"):Connect(function()
            local val = tonumber(intervalBox.Text)
            if val and val > 0 then
                challengeOrder[index].interval = val
                updateQueueDisplay()
            end
        end)
        
        upBtn.MouseButton1Click:Connect(function()
            if index > 1 then
                challengeOrder[index], challengeOrder[index-1] = challengeOrder[index-1], challengeOrder[index]
                refreshChallengeUI()
                updateQueueDisplay()
            end
        end)
        
        downBtn.MouseButton1Click:Connect(function()
            if index < #challengeOrder then
                challengeOrder[index], challengeOrder[index+1] = challengeOrder[index+1], challengeOrder[index]
                refreshChallengeUI()
                updateQueueDisplay()
            end
        end)
        
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(challengeOrder, index)
            refreshChallengeUI()
            updateQueueDisplay()
        end)
    end
    updateQueueDisplay()
end

-- Add new challenge
local addFrame = Instance.new("Frame")
addFrame.Size = UDim2.new(1, -20, 0, 80)
addFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
addFrame.Parent = challengePanel

local challengeDropdown = Instance.new("TextBox")
challengeDropdown.Size = UDim2.new(0.6, -5, 0, 35)
challengeDropdown.PlaceholderText = "Type challenge name..."
challengeDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
challengeDropdown.TextColor3 = Color3.new(1, 1, 1)
challengeDropdown.Parent = addFrame

local addInterval = Instance.new("TextBox")
addInterval.Size = UDim2.new(0.35, -5, 0, 35)
addInterval.Position = UDim2.new(0.62, 0, 0, 0)
addInterval.PlaceholderText = "Interval (sec)"
addInterval.Text = "300"
addInterval.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
addInterval.TextColor3 = Color3.new(1, 1, 1)
addInterval.Parent = addFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, 0, 0, 35)
addBtn.Position = UDim2.new(0, 0, 0, 40)
addBtn.Text = "➕ ADD CHALLENGE"
addBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.Parent = addFrame

addBtn.MouseButton1Click:Connect(function()
    local name = challengeDropdown.Text
    local interval = tonumber(addInterval.Text) or 300
    if name ~= "" then
        table.insert(challengeOrder, {name = name, id = name, interval = interval, enabled = true})
        refreshChallengeUI()
        challengeDropdown.Text = ""
    end
end)

-- Preset buttons
local presetFrame = Instance.new("Frame")
presetFrame.Size = UDim2.new(1, -20, 0, 35)
presetFrame.BackgroundTransparency = 1
presetFrame.Parent = challengePanel

local preset1 = Instance.new("TextButton")
preset1.Size = UDim2.new(0.32, -2, 1, 0)
preset1.Text = "📋 Default"
preset1.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
preset1.TextColor3 = Color3.new(1, 1, 1)
preset1.Parent = presetFrame

local preset2 = Instance.new("TextButton")
preset2.Size = UDim2.new(0.32, -2, 1, 0)
preset2.Position = UDim2.new(0.34, 0, 0, 0)
preset2.Text = "⚡ Godly Only"
preset2.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
preset2.TextColor3 = Color3.new(1, 1, 1)
preset2.Parent = presetFrame

local preset3 = Instance.new("TextButton")
preset3.Size = UDim2.new(0.32, -2, 1, 0)
preset3.Position = UDim2.new(0.68, 0, 0, 0)
preset3.Text = "🗑️ Clear All"
preset3.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
preset3.TextColor3 = Color3.new(1, 1, 1)
preset3.Parent = presetFrame

preset1.MouseButton1Click:Connect(function()
    challengeOrder = {}
    table.insert(challengeOrder, {name = "Insane Challenge", id = "Insane Challenge", interval = 300, enabled = true})
    table.insert(challengeOrder, {name = "Pro Challenge", id = "Pro Challenge", interval = 240, enabled = true})
    table.insert(challengeOrder, {name = "Easter Challenge #2", id = "Easter Challenge #2", interval = 180, enabled = true})
    table.insert(challengeOrder, {name = "Godly Challenge", id = "Godly Challenge", interval = 300, enabled = true})
    refreshChallengeUI()
end)

preset2.MouseButton1Click:Connect(function()
    challengeOrder = {}
    table.insert(challengeOrder, {name = "Godly Challenge", id = "Godly Challenge", interval = 600, enabled = true})
    refreshChallengeUI()
end)

preset3.MouseButton1Click:Connect(function()
    challengeOrder = {}
    refreshChallengeUI()
end)

-- Auto Challenge Toggle
local autoChallengeActive = false
local autoChallengeToggle = Instance.new("TextButton")
autoChallengeToggle.Size = UDim2.new(1, -20, 0, 50)
autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoChallengeToggle.TextColor3 = Color3.new(1, 1, 1)
autoChallengeToggle.Font = Enum.Font.GothamBold
autoChallengeToggle.Parent = challengePanel

-- Toggle connections
autoRaidAfterToggle.MouseButton1Click:Connect(function()
    autoRaidAfterChallenge = not autoRaidAfterChallenge
    autoRaidAfterToggle.Text = autoRaidAfterChallenge and "🏠 Auto Raid AFTER each challenge: ✅ ON" or "🏠 Auto Raid AFTER each challenge: ❌ OFF"
    autoRaidAfterToggle.BackgroundColor3 = autoRaidAfterChallenge and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
end)

autoRaidToggle.MouseButton1Click:Connect(function()
    autoRaidActive = not autoRaidActive
    autoRaidToggle.Text = autoRaidActive and "🏠 Auto Raid AFTER LAST: ✅ ON (Wait " .. math.floor(autoRaidWaitTime/60) .. " min)" or "🏠 Auto Raid AFTER LAST: ❌ OFF"
    autoRaidToggle.BackgroundColor3 = autoRaidActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
end)

-- UI Detection Functions
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

local function clickStartButton()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, btn in ipairs(pg:GetDescendants()) do
        if btn:IsA("TextButton") and btn.Text == "Start Challenge" and btn.Visible and btn.Active then
            btn:Click()
            return true
        end
    end
    return false
end

local function startSpecificChallenge(challengeId)
    pcall(function()
        raidStop:FireServer()
        task.wait(1)
        startChallenge:InvokeServer(challengeId)
        task.wait(1)
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

local function turnOffAutoRaid()
    pcall(function()
        changeSetting:InvokeServer("AutoRaid", "Off")
    end)
end

local function startAutoRaid()
    pcall(function()
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

-- Main Auto Challenge Loop
local function runAutoChallenge()
    task.spawn(function()
        local isFirstRun = true
        
        while autoChallengeActive do
            -- Get enabled challenges in order
            local enabledList = {}
            for _, ch in ipairs(challengeOrder) do
                if ch.enabled then
                    table.insert(enabledList, ch)
                end
            end
            
            if #enabledList == 0 then
                challengeStatus.Text = "Status: No challenges enabled!"
                countdownDisplay.Text = "Next: ---"
                task.wait(5)
            else
                for currentIndex, challenge in ipairs(enabledList) do
                    if not autoChallengeActive then break end
                    
                    -- Update display
                    local nextName = "None"
                    if currentIndex < #enabledList then
                        nextName = enabledList[currentIndex + 1].name
                    elseif #enabledList > 0 then
                        nextName = enabledList[1].name
                    end
                    orderDisplay.Text = string.format("📍 Current: %s | ➡️ Next: %s", challenge.name, nextName)
                    
                    -- ONLY wait for cooldown on the FIRST challenge
                    if isFirstRun then
                        challengeStatus.Text = "⏳ Waiting for cooldown (first challenge only) - " .. challenge.name
                        local cooldownEnded = false
                        while autoChallengeActive and not cooldownEnded do
                            local timer = findCooldownTimer()
                            if timer then
                                local timeText = timer.Text
                                countdownDisplay.Text = "⏰ Cooldown: " .. timeText
                                if timeText == "00:00" or timeText == "0:00" then
                                    cooldownEnded = true
                                end
                            else
                                countdownDisplay.Text = "⚠️ Open Challenge Menu"
                            end
                            task.wait(1)
                        end
                        isFirstRun = false
                    end
                    
                    if autoChallengeActive then
                        -- Start the challenge
                        challengeStatus.Text = "🚀 Starting " .. challenge.name
                        countdownDisplay.Text = "🏃 Running: " .. challenge.name
                        startSpecificChallenge(challenge.id)
                        
                        -- Wait for the interval (time between challenges)
                        local waitTime = challenge.interval
                        for i = waitTime, 1, -1 do
                            if not autoChallengeActive then break end
                            local mins = math.floor(i / 60)
                            local secs = i % 60
                            countdownDisplay.Text = string.format("⏱️ Next challenge in: %02d:%02d", mins, secs)
                            if i % 30 == 0 or i <= 10 then
                                challengeStatus.Text = string.format("✅ %s - Next in %d:%02d", challenge.name, mins, secs)
                            end
                            task.wait(1)
                        end
                        
                        -- OPTION 1: Auto Raid AFTER EACH challenge (if enabled)
                        if autoRaidAfterChallenge then
                            challengeStatus.Text = "🛑 Turning off Auto Raid..."
                            turnOffAutoRaid()
                        end
                    end
                end
                
                -- OPTION 2: Auto Raid AFTER ALL challenges complete (if enabled)
                if autoRaidActive then
                    challengeStatus.Text = "🤖 All challenges complete! Starting Auto Raid in " .. math.floor(autoRaidWaitTime/60) .. " minutes..."
                    for i = autoRaidWaitTime, 1, -1 do
                        if not autoChallengeActive then break end
                        local mins = math.floor(i / 60)
                        local secs = i % 60
                        countdownDisplay.Text = string.format("🚀 Auto Raid in: %02d:%02d", mins, secs)
                        if i % 30 == 0 or i <= 10 then
                            challengeStatus.Text = string.format("🤖 Auto Raid starting in %d:%02d", mins, secs)
                        end
                        task.wait(1)
                    end
                    if autoChallengeActive then
                        challengeStatus.Text = "🚀 Starting Auto Raid!"
                        startAutoRaid()
                        countdownDisplay.Text = "🏠 Auto Raid Active!"
                        -- Let raid run for a bit before next cycle
                        task.wait(60)
                    end
                end
                
                -- After completing all challenges, reset isFirstRun for next cycle
                isFirstRun = true
            end
        end
    end)
end

autoChallengeToggle.MouseButton1Click:Connect(function()
    autoChallengeActive = not autoChallengeActive
    autoChallengeToggle.Text = autoChallengeActive and "🎯 AUTO CHALLENGE: ON" or "🎯 AUTO CHALLENGE: OFF"
    autoChallengeToggle.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoChallengeActive then
        runAutoChallenge()
    else
        challengeStatus.Text = "Challenge Status: Idle"
        countdownDisplay.Text = "Next: --:--"
        orderDisplay.Text = "Current: None | Next: None"
    end
end)

refreshChallengeUI()

--// ============== SCHEDULE TAB ==============
local schedulePanel = panels.schedule

local scheduleStatus = Instance.new("TextLabel")
scheduleStatus.Size = UDim2.new(1, -20, 0, 60)
scheduleStatus.Text = "Schedule Status: IDLE\n🐰 Easter (:15 & :45): OFF\n⚔️ Mega Raid (:00): OFF"
scheduleStatus.TextColor3 = Color3.new(1, 1, 1)
scheduleStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
scheduleStatus.TextWrapped = true
scheduleStatus.Parent = schedulePanel

local easterScheduleToggle = Instance.new("TextButton")
easterScheduleToggle.Size = UDim2.new(1, -20, 0, 45)
easterScheduleToggle.Text = "🐰 EASTER SCHEDULE (:15 & :45): OFF"
easterScheduleToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
easterScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
easterScheduleToggle.Parent = schedulePanel

local megaScheduleToggle = Instance.new("TextButton")
megaScheduleToggle.Size = UDim2.new(1, -20, 0, 45)
megaScheduleToggle.Text = "⚔️ MEGA RAID SCHEDULE (:00): OFF"
megaScheduleToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
megaScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
megaScheduleToggle.Parent = schedulePanel

--// BUILD FUNCTIONS
local function executeEasterBuild()
    buildStatus.Text = "Building Easter..."
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(easterBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            eBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    buildStatus.Text = "Easter complete!"
    task.wait(2)
    buildStatus.Text = "Status: Ready"
end

local function executeMegaBuild()
    buildStatus.Text = "Building Mega Raid..."
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(megaRaidBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            cBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    buildStatus.Text = "Mega complete!"
    task.wait(2)
    buildStatus.Text = "Status: Ready"
end

easterBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeEasterBuild)
end)

megaBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeMegaBuild)
end)

-- Schedule checker
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
                    task.spawn(executeEasterBuild)
                end
                
                if megaSched and min == 0 then
                    scheduleStatus.Text = "Schedule: Running Mega Raid..."
                    task.spawn(executeMegaBuild)
                end
                
                local nextInfo = ""
                if easterSched then
                    if min < 15 then nextInfo = "Next Easter: :15"
                    elseif min < 45 then nextInfo = "Next Easter: :45"
                    else nextInfo = "Next Easter: :15 (next hour)" end
                end
                scheduleStatus.Text = "Schedule Status: ACTIVE\n🐰 " .. (easterSched and nextInfo or "Easter: OFF") .. "\n⚔️ " .. (megaSched and "Next Mega: :00" or "Mega: OFF")
            end
            task.wait(1)
        end
    end)
end

easterScheduleToggle.MouseButton1Click:Connect(function()
    easterSched = not easterSched
    easterScheduleToggle.Text = easterSched and "🐰 EASTER SCHEDULE (:15 & :45): ✅ ON" or "🐰 EASTER SCHEDULE (:15 & :45): ❌ OFF"
    easterScheduleToggle.BackgroundColor3 = easterSched and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
end)

megaScheduleToggle.MouseButton1Click:Connect(function()
    megaSched = not megaSched
    megaScheduleToggle.Text = megaSched and "⚔️ MEGA RAID SCHEDULE (:00): ✅ ON" or "⚔️ MEGA RAID SCHEDULE (:00): ❌ OFF"
    megaScheduleToggle.BackgroundColor3 = megaSched and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
end)

runScheduler()

--// ============== CONFIG TAB ==============
local configPanel = panels.config

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(1, -20, 0, 40)
configTitle.Text = "💾 SAVE / LOAD CONFIGURATION"
configTitle.TextColor3 = Color3.new(1, 1, 0)
configTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
configTitle.Font = Enum.Font.GothamBold
configTitle.Parent = configPanel

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 60)
saveBtn.Text = "💾 SAVE CURRENT CONFIGURATION\n(Saves challenges, selected items, and settings)"
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.TextSize = 14
saveBtn.Parent = configPanel

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(1, -20, 0, 60)
loadBtn.Text = "📂 LOAD SAVED CONFIGURATION\n(Restores last saved settings)"
loadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
loadBtn.TextColor3 = Color3.new(1, 1, 1)
loadBtn.TextSize = 14
loadBtn.Parent = configPanel

local saveStatus = Instance.new("TextLabel")
saveStatus.Size = UDim2.new(1, -20, 0, 40)
saveStatus.Text = "Ready"
saveStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
saveStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
saveStatus.Parent = configPanel

local configInfo = Instance.new("TextLabel")
configInfo.Size = UDim2.new(1, -20, 0, 100)
configInfo.Text = "📌 Info:\n- Config saves to: " .. configName .. ".json\n- Auto-loads when script starts\n- Saves: Challenge order, intervals, enabled state, selected items, auto-buy state, auto-raid settings"
configInfo.TextColor3 = Color3.new(0.6, 0.6, 0.6)
configInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
configInfo.TextWrapped = true
configInfo.TextSize = 12
configInfo.Parent = configPanel

saveBtn.MouseButton1Click:Connect(function()
    saveConfig()
end)

loadBtn.MouseButton1Click:Connect(function()
    if loadConfig() then
        applyConfig()
        saveStatus.Text = "✅ Config loaded at " .. os.date("%H:%M:%S")
        task.wait(2)
        saveStatus.Text = "Ready"
    else
        saveStatus.Text = "❌ No saved config found"
        task.wait(2)
        saveStatus.Text = "Ready"
    end
end)

--// TAB SWITCHING
for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for tabName, panel in pairs(panels) do
            panel.Visible = (tabName == name)
            if tabs[tabName] then
                tabs[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(50, 50, 60)
            end
        end
        currentTab = name
    end)
end

-- Show build tab by default
panels.build.Visible = true
tabs.build.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

-- Load saved config on startup
loadConfig()
applyConfig()

print("=== TD Auto Farm Loaded ===")
print("Auto Raid Options:")
print("  ✅ AFTER EACH challenge - Turns OFF Auto Raid")
print("  ✅ AFTER LAST challenge - Waits interval, then turns ON Auto Raid")
print("  ✅ Both can be toggled independently!")

end)
