--// COMPLETE TOWER DEFENSE AUTO FARM - FIXED
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local function randomDelay(minSec, maxSec)
    return (minSec + math.random() * (maxSec - minSec))
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

--// VECTOR
local vector = vector or { create = function(x, y, z) return Vector3.new(x, y, z) end }

--// BUILD STRUCTURES
local easterBuildStructures = {
    {id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}", position = Vector3.new(529.6004638671875, 227.50601196289062, 1187.6143798828125), rotation = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", position = Vector3.new(533.6004638671875, 227.50601196289062, 1197.6143798828125), rotation = 90},
    {id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}", position = Vector3.new(525.6004638671875, 227.50601196289062, 1197.6143798828125), rotation = 90},
    {id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}", position = Vector3.new(531.6004638671875, 227.50601196289062, 1209.6143798828125), rotation = 90}
}

local megaRaidBuildStructures = {
    {id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}", position = Vector3.new(1539.6004638671875, 8.505999565124512, 1183.6143798828125), rotation = 90},
    {id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}", position = Vector3.new(1541.6004638671875, 8.505999565124512, 1199.6143798828125), rotation = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", position = Vector3.new(1545.6004638671875, 8.505999565124512, 1191.6143798828125), rotation = 90},
    {id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}", position = Vector3.new(1545.6004638671875, 8.505999565124512, 1189.6143798828125), rotation = 90},
    {id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}", position = Vector3.new(1537.6004638671875, 8.505999565124512, 1189.6143798828125), rotation = 90}
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

--// AVAILABLE CHALLENGES (with display names)
local availableChallenges = {
    {name = "Insane Challenge", id = "Insane Challenge"},
    {name = "Pro Challenge", id = "Pro Challenge"},
    {name = "Easter Challenge #1", id = "Easter Challenge #1"},
    {name = "Easter Challenge #2", id = "Easter Challenge #2"},
    {name = "Godly Challenge", id = "Godly Challenge"}
}

--// ============== GUI ==============
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "TD Auto Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 3)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Parent = mainFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 10, 0, 100)
iconBtn.Text = "TD"
iconBtn.Visible = false
iconBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Parent = gui

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    iconBtn.Visible = true
end)

iconBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    iconBtn.Visible = false
end)

--// TABS
local tabY = 40
local tabButtons = {}

local function createTab(name, text, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 0, 30)
    btn.Position = UDim2.new(0, 5 + (xPos * 98), 0, tabY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = mainFrame
    tabButtons[name] = btn
    return btn
end

createTab("scheduler", "⏰ Schedule", 0)
createTab("easter", "🐰 Easter", 1)
createTab("megaraid", "⚔️ Mega", 2)
createTab("buy", "🛒 Buy", 3)
createTab("challenge", "🎯 Challenge", 4)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -80)
contentFrame.Position = UDim2.new(0, 10, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabs = {
    scheduler = Instance.new("ScrollingFrame"),
    easter = Instance.new("ScrollingFrame"),
    megaraid = Instance.new("ScrollingFrame"),
    buy = Instance.new("ScrollingFrame"),
    challenge = Instance.new("ScrollingFrame")
}

for name, tab in pairs(tabs) do
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.Parent = contentFrame
    local layout = Instance.new("UIListLayout")
    layout.Parent = tab
    layout.Padding = UDim.new(0, 5)
end

--// ============== SCHEDULER TAB (FIXED - Auto runs without clicking) ==============
local schedulerTab = tabs.scheduler

local scheduleStatus = Instance.new("TextLabel")
scheduleStatus.Size = UDim2.new(1, -20, 0, 70)
scheduleStatus.Text = "Schedule Status: RUNNING\n🐰 Easter (:15 & :45): OFF\n⚔️ Mega Raid (:00): OFF\n🏠 Auto Raid: OFF"
scheduleStatus.TextColor3 = Color3.new(1, 1, 1)
scheduleStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
scheduleStatus.TextWrapped = true
scheduleStatus.Parent = schedulerTab

local easterScheduleToggle = Instance.new("TextButton")
easterScheduleToggle.Size = UDim2.new(1, -20, 0, 45)
easterScheduleToggle.Text = "🐰 EASTER SCHEDULE (:15 & :45): OFF"
easterScheduleToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
easterScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
easterScheduleToggle.Parent = schedulerTab

local megaRaidScheduleToggle = Instance.new("TextButton")
megaRaidScheduleToggle.Size = UDim2.new(1, -20, 0, 45)
megaRaidScheduleToggle.Text = "⚔️ MEGA RAID SCHEDULE (:00): OFF"
megaRaidScheduleToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
megaRaidScheduleToggle.TextColor3 = Color3.new(1, 1, 1)
megaRaidScheduleToggle.Parent = schedulerTab

local autoRaidToggle = Instance.new("TextButton")
autoRaidToggle.Size = UDim2.new(1, -20, 0, 45)
autoRaidToggle.Text = "🏠 AUTO NORMAL RAID: OFF"
autoRaidToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoRaidToggle.TextColor3 = Color3.new(1, 1, 1)
autoRaidToggle.Parent = schedulerTab

local lastExecutionInfo = Instance.new("TextLabel")
lastExecutionInfo.Size = UDim2.new(1, -20, 0, 40)
lastExecutionInfo.Text = "Last execution: Never"
lastExecutionInfo.TextColor3 = Color3.new(0.7, 0.7, 0.7)
lastExecutionInfo.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
lastExecutionInfo.Parent = schedulerTab

--// ============== EASTER TAB ==============
local easterTab = tabs.easter

local easterStatus = Instance.new("TextLabel")
easterStatus.Size = UDim2.new(1, -20, 0, 40)
easterStatus.Text = "Easter Status: Ready"
easterStatus.TextColor3 = Color3.new(1, 1, 1)
easterStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
easterStatus.Parent = easterTab

local easterBuildAll = Instance.new("TextButton")
easterBuildAll.Size = UDim2.new(1, -20, 0, 50)
easterBuildAll.Text = "🐰 BUILD ALL EASTER (4 Towers)"
easterBuildAll.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
easterBuildAll.TextColor3 = Color3.new(1, 1, 1)
easterBuildAll.Font = Enum.Font.GothamBold
easterBuildAll.Parent = easterTab

for i, structure in ipairs(easterBuildStructures) do
    local name = structure.id:match("([^{]+)")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Text = "Build: " .. name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = easterTab
    btn.MouseButton1Click:Connect(function()
        task.spawn(function()
            easterStatus.Text = "Building: " .. name
            pcall(function()
                joinEventRaid:FireServer()
                task.wait(1)
                local args = {structure.id, {Rotation = structure.rotation, Position = structure.position}}
                eBuildDefense:InvokeServer(unpack(args))
            end)
            task.wait(1)
            easterStatus.Text = "Easter Status: Ready"
        end)
    end)
end

--// ============== MEGA RAID TAB ==============
local megaRaidTab = tabs.megaraid

local megaRaidStatus = Instance.new("TextLabel")
megaRaidStatus.Size = UDim2.new(1, -20, 0, 40)
megaRaidStatus.Text = "Mega Raid Status: Ready"
megaRaidStatus.TextColor3 = Color3.new(1, 1, 1)
megaRaidStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
megaRaidStatus.Parent = megaRaidTab

local megaRaidBuildAll = Instance.new("TextButton")
megaRaidBuildAll.Size = UDim2.new(1, -20, 0, 50)
megaRaidBuildAll.Text = "⚔️ BUILD ALL MEGA RAID (5 Towers)"
megaRaidBuildAll.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
megaRaidBuildAll.TextColor3 = Color3.new(1, 1, 1)
megaRaidBuildAll.Font = Enum.Font.GothamBold
megaRaidBuildAll.Parent = megaRaidTab

for i, structure in ipairs(megaRaidBuildStructures) do
    local name = structure.id:match("([^{]+)")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Text = "Build: " .. name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = megaRaidTab
    btn.MouseButton1Click:Connect(function()
        task.spawn(function()
            megaRaidStatus.Text = "Building: " .. name
            pcall(function()
                joinCommunityRaid:FireServer()
                task.wait(1)
                local args = {structure.id, {Rotation = structure.rotation, Position = structure.position}}
                cBuildDefense:InvokeServer(unpack(args))
            end)
            task.wait(1)
            megaRaidStatus.Text = "Mega Raid Status: Ready"
        end)
    end)
end

--// ============== AUTO BUY TAB ==============
local buyTab = tabs.buy

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.PlaceholderText = "🔍 Search item..."
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Parent = buyTab

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -20, 0, 250)
itemsScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
itemsScroll.Parent = buyTab

local itemsLayout = Instance.new("UIListLayout", itemsScroll)

local selectedItems = {}
local itemButtons = {}

for name, type in pairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Text = (type=="E" and "🎯 [EVENT] " or "⚔️ [NORMAL] ").."[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = itemsScroll
    itemButtons[name] = btn
    
    local selected = false
    btn.MouseButton1Click:Connect(function()
        selected = not selected
        if selected then
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
local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(1, -20, 0, 45)
autoBuyBtn.Text = "🟢 AUTO BUY (1s): OFF"
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoBuyBtn.TextColor3 = Color3.new(1, 1, 1)
autoBuyBtn.Parent = buyTab

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

autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuyActive = not autoBuyActive
    autoBuyBtn.Text = autoBuyActive and "🔴 AUTO BUY (1s): ON" or "🟢 AUTO BUY (1s): OFF"
    autoBuyBtn.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoBuyActive then autoBuyLoop() end
end)

--// ============== CHALLENGE TAB (Simple checkboxes with intervals) ==============
local challengeTab = tabs.challenge

local challengeStatus = Instance.new("TextLabel")
challengeStatus.Size = UDim2.new(1, -20, 0, 50)
challengeStatus.Text = "Challenge Status: Idle"
challengeStatus.TextColor3 = Color3.new(1, 1, 1)
challengeStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
challengeStatus.TextWrapped = true
challengeStatus.Parent = challengeTab

local challengeTimer = Instance.new("TextLabel")
challengeTimer.Size = UDim2.new(1, -20, 0, 30)
challengeTimer.Text = "Next: --:--"
challengeTimer.TextColor3 = Color3.new(1, 0.8, 0)
challengeTimer.BackgroundTransparency = 1
challengeTimer.Parent = challengeTab

-- Challenge selection frame
local selectFrame = Instance.new("Frame")
selectFrame.Size = UDim2.new(1, -20, 0, 200)
selectFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
selectFrame.Parent = challengeTab

local selectTitle = Instance.new("TextLabel")
selectTitle.Size = UDim2.new(1, 0, 0, 25)
selectTitle.Text = "SELECT CHALLENGES (Tap to enable)"
selectTitle.TextColor3 = Color3.new(1, 1, 0)
selectTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
selectTitle.Parent = selectFrame

local selectScroll = Instance.new("ScrollingFrame")
selectScroll.Size = UDim2.new(1, 0, 1, -30)
selectScroll.Position = UDim2.new(0, 0, 0, 25)
selectScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
selectScroll.Parent = selectFrame

local selectLayout = Instance.new("UIListLayout")
selectLayout.Parent = selectScroll

-- Store selected challenges with intervals
local selectedChallenges = {} -- {name, id, interval, enabled}

-- Initialize selected challenges
for i, challenge in ipairs(availableChallenges) do
    selectedChallenges[i] = {
        name = challenge.name,
        id = challenge.id,
        interval = 300, -- default 5 minutes
        enabled = false,
        order = i
    }
end

-- Create checkboxes for each challenge
local challengeCheckboxes = {}

for i, challenge in ipairs(availableChallenges) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    frame.Parent = selectScroll
    
    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0.35, -5, 0.8, 0)
    checkBtn.Position = UDim2.new(0, 5, 0.1, 0)
    checkBtn.Text = "❌ " .. challenge.name
    checkBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    checkBtn.TextColor3 = Color3.new(1, 1, 1)
    checkBtn.TextXAlignment = Enum.TextXAlignment.Left
    checkBtn.Parent = frame
    
    local intervalBox = Instance.new("TextBox")
    intervalBox.Size = UDim2.new(0.35, -5, 0.8, 0)
    intervalBox.Position = UDim2.new(0.38, 0, 0.1, 0)
    intervalBox.Text = "300"
    intervalBox.PlaceholderText = "Interval (sec)"
    intervalBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    intervalBox.TextColor3 = Color3.new(1, 1, 1)
    intervalBox.Parent = frame
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.1, -5, 0.8, 0)
    upBtn.Position = UDim2.new(0.76, 0, 0.1, 0)
    upBtn.Text = "⬆️"
    upBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    upBtn.TextColor3 = Color3.new(1, 1, 1)
    upBtn.Parent = frame
    
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0.1, -5, 0.8, 0)
    downBtn.Position = UDim2.new(0.88, 0, 0.1, 0)
    downBtn.Text = "⬇️"
    downBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    downBtn.TextColor3 = Color3.new(1, 1, 1)
    downBtn.Parent = frame
    
    local enabled = false
    
    checkBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            checkBtn.Text = "✅ " .. challenge.name
            checkBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
            selectedChallenges[i].enabled = true
        else
            checkBtn.Text = "❌ " .. challenge.name
            checkBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
            selectedChallenges[i].enabled = false
        end
    end)
    
    intervalBox:GetPropertyChangedSignal("Text"):Connect(function()
        local val = tonumber(intervalBox.Text)
        if val and val > 0 then
            selectedChallenges[i].interval = val
        end
    end)
    
    upBtn.MouseButton1Click:Connect(function()
        if i > 1 then
            selectedChallenges[i], selectedChallenges[i-1] = selectedChallenges[i-1], selectedChallenges[i]
            selectedChallenges[i].order = i
            selectedChallenges[i-1].order = i-1
            refreshChallengeDisplay()
        end
    end)
    
    downBtn.MouseButton1Click:Connect(function()
        if i < #availableChallenges then
            selectedChallenges[i], selectedChallenges[i+1] = selectedChallenges[i+1], selectedChallenges[i]
            selectedChallenges[i].order = i
            selectedChallenges[i+1].order = i+1
            refreshChallengeDisplay()
        end
    end)
    
    challengeCheckboxes[i] = {checkBtn, intervalBox, frame, enabled}
end

local function refreshChallengeDisplay()
    -- Rebuild the display to show new order
    for i, challenge in ipairs(selectedChallenges) do
        if challengeCheckboxes[i] then
            local frame = challengeCheckboxes[i][3]
            local checkBtn = challengeCheckboxes[i][1]
            if challenge.enabled then
                checkBtn.Text = "✅ " .. challenge.name
                checkBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
            else
                checkBtn.Text = "❌ " .. challenge.name
                checkBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
            end
        end
    end
end

-- Auto Challenge Toggle
local autoChallengeActive = false
local autoChallengeBtn = Instance.new("TextButton")
autoChallengeBtn.Size = UDim2.new(1, -20, 0, 50)
autoChallengeBtn.Position = UDim2.new(0, 10, 0, 210)
autoChallengeBtn.Text = "🎯 AUTO CHALLENGE: OFF"
autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoChallengeBtn.TextColor3 = Color3.new(1, 1, 1)
autoChallengeBtn.Font = Enum.Font.GothamBold
autoChallengeBtn.Parent = challengeTab

-- UI Detection for cooldown timer
local function findCooldownTimer()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local function search(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                if text:match("%d%d:%d%d") or text:match("%d:%d%d") then
                    local parent = child.Parent
                    for _, sibling in ipairs(parent:GetChildren()) do
                        if sibling:IsA("TextLabel") and (sibling.Text:find("Reward") or sibling.Text:find("Cooldown")) then
                            return child
                        end
                    end
                end
            end
            local found = search(child)
            if found then return found end
        end
        return nil
    end
    return search(pg)
end

local function findStartButton()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local function search(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("TextButton") and child.Text == "Start Challenge" then
                return child
            end
            local found = search(child)
            if found then return found end
        end
        return nil
    end
    return search(pg)
end

local function clickStartButton()
    local button = findStartButton()
    if button and button.Visible and button.Active then
        button:Click()
        return true
    end
    return false
end

local function startChallengeByName(challengeId)
    pcall(function()
        raidStop:FireServer()
        task.wait(1)
        startChallenge:InvokeServer(challengeId)
        task.wait(1)
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

-- Main auto challenge loop
local function runAutoChallenge()
    task.spawn(function()
        while autoChallengeActive do
            -- Get enabled challenges in order
            local enabledList = {}
            for _, challenge in ipairs(selectedChallenges) do
                if challenge.enabled then
                    table.insert(enabledList, challenge)
                end
            end
            
            if #enabledList == 0 then
                challengeStatus.Text = "Status: No challenges selected!"
                task.wait(5)
            else
                for _, challenge in ipairs(enabledList) do
                    if not autoChallengeActive then break end
                    
                    -- Wait for cooldown to end
                    challengeStatus.Text = "Status: Waiting for cooldown - " .. challenge.name
                    
                    local cooldownEnded = false
                    while autoChallengeActive and not cooldownEnded do
                        local timer = findCooldownTimer()
                        if timer then
                            local timeText = timer.Text
                            challengeTimer.Text = "Cooldown: " .. timeText
                            if timeText == "00:00" or timeText == "0:00" then
                                cooldownEnded = true
                            end
                        else
                            challengeTimer.Text = "Cooldown: --- (Open challenge menu)"
                        end
                        task.wait(1)
                    end
                    
                    if autoChallengeActive then
                        -- Start the challenge
                        challengeStatus.Text = "Status: Starting " .. challenge.name
                        challengeTimer.Text = "Running: " .. challenge.name
                        startChallengeByName(challenge.id)
                        
                        -- Wait for the interval
                        local waitTime = challenge.interval
                        for i = waitTime, 1, -1 do
                            if not autoChallengeActive then break end
                            if i % 30 == 0 or i <= 10 then
                                challengeTimer.Text = string.format("Next: %02d:%02d", math.floor(i/60), i%60)
                                challengeStatus.Text = string.format("Status: %s - Next in %d:%02d", challenge.name, math.floor(i/60), i%60)
                            end
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end)
end

autoChallengeBtn.MouseButton1Click:Connect(function()
    autoChallengeActive = not autoChallengeActive
    autoChallengeBtn.Text = autoChallengeActive and "🎯 AUTO CHALLENGE: ON" or "🎯 AUTO CHALLENGE: OFF"
    autoChallengeBtn.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoChallengeActive then
        runAutoChallenge()
    else
        challengeStatus.Text = "Challenge Status: Idle"
        challengeTimer.Text = "Next: --:--"
    end
end)

--// ============== BUILD FUNCTIONS ==============
local function executeEasterBuild()
    print("[Easter] Building...")
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    for _, structure in ipairs(easterBuildStructures) do
        pcall(function()
            local args = {structure.id, {Rotation = structure.rotation, Position = structure.position}}
            eBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    print("[Easter] Complete!")
end

local function executeMegaRaidBuild()
    print("[Mega Raid] Building...")
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    for _, structure in ipairs(megaRaidBuildStructures) do
        pcall(function()
            local args = {structure.id, {Rotation = structure.rotation, Position = structure.position}}
            cBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    print("[Mega Raid] Complete!")
end

local function startNormalRaid()
    print("[Auto Raid] Starting normal raid...")
    pcall(function()
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

easterBuildAll.MouseButton1Click:Connect(function()
    task.spawn(executeEasterBuild)
end)

megaRaidBuildAll.MouseButton1Click:Connect(function()
    task.spawn(executeMegaRaidBuild)
end)

--// ============== SCHEDULER (FIXED - Auto runs) ==============
local easterScheduleEnabled = false
local megaRaidScheduleEnabled = false
local autoRaidEnabled = false
local lastEasterRun = ""
local lastMegaRun = ""
local lastRaidRun = ""

-- Auto raid loop (runs when cooldown ends)
local function autoRaidLoop()
    task.spawn(function()
        while autoRaidEnabled do
            -- Wait for cooldown to end
            local cooldownEnded = false
            while autoRaidEnabled and not cooldownEnded do
                local timer = findCooldownTimer()
                if timer then
                    local timeText = timer.Text
                    if timeText == "00:00" or timeText == "0:00" then
                        cooldownEnded = true
                    end
                end
                task.wait(1)
            end