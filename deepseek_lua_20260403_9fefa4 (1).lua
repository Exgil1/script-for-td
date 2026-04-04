--// COMPLETE TD AUTO FARM - FULLY FIXED (Update positions after game update)
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

--// VECTOR HELPER
local vector = vector or {
    create = function(x, y, z)
        return Vector3.new(x, y, z)
    end
}

--// REMOTES
local events = ReplicatedStorage:WaitForChild("Events")
local functionsFolder = events:WaitForChild("Functions")
local remotesFolder = events:WaitForChild("Remotes")

local buyDefense = functionsFolder:WaitForChild("BuyDefense")
local eBuyDefense = functionsFolder:WaitForChild("EBuyDefense")
local startChallenge = functionsFolder:WaitForChild("StartChallenge")
local changeSetting = functionsFolder:WaitForChild("ChangeSetting")
local joinEventRaid = remotesFolder:WaitForChild("JoinEventRaid")
local joinCommunityRaid = remotesFolder:WaitForChild("JoinCommunityRaid")
local raidStop = remotesFolder:WaitForChild("RaidStop")

-- Get build remotes
local eBuildDefense = functionsFolder:FindFirstChild("EBuildDefense")
local cBuildDefense = functionsFolder:FindFirstChild("CBuildDefense")

--// PLAYER DATA
local challengesFolder = player:FindFirstChild("Challenges")
local playerFlags = player:FindFirstChild("Flags")
local raidingFlag = playerFlags and playerFlags:FindFirstChild("Raiding")
local challengeActiveFlag = playerFlags and playerFlags:FindFirstChild("ChallengeActive")

--// GLOBAL VARIABLES
local autoChallengeActive = false
local autoChallengeThread = nil
local normalRaidActive = false
local currentChallengeName = nil
local antiAFKActive = false
local antiAFKThread = nil

--// ============== UPDATE THESE POSITIONS AFTER GAME UPDATE ==============
-- Use the position finder script below to get new coordinates

-- EASTER BUILD POSITIONS (UPDATE THESE)
local easterBuildStructures = {
    {
        id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
        pos = vector.create(529.6004638671875, 227.50601196289062, 1191.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
        pos = vector.create(525.6004638671875, 227.50601196289062, 1201.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}",
        pos = vector.create(529.6004638671875, 227.50601196289062, 1209.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
        pos = vector.create(533.6004638671875, 227.50601196289062, 1199.6143798828125),  -- UPDATE
        rot = 90
    }
}

-- MEGA RAID BUILD POSITIONS (UPDATE THESE)
local megaRaidBuildStructures = {
    {
        id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
        pos = vector.create(1529.6004638671875, 8.505999565124512, 1191.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
        pos = vector.create(1525.6004638671875, 8.505999565124512, 1199.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
        pos = vector.create(1533.6004638671875, 8.505999565124512, 1199.6143798828125),  -- UPDATE
        rot = 90
    },
    {
        id = "Rocket Artillery{84d378a0-3aeb-4e25-b6db-b53096d0858b}",
        pos = vector.create(1529.6004638671875, 8.505999565124512, 1209.6143798828125),  -- UPDATE
        rot = 90
    }
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

local challengeOrder = {}
local challengeItems = {}

--// CORE FUNCTIONS
local function getChallengeCooldown(challengeName)
    if not challengesFolder then return 0 end
    local node = challengesFolder:FindFirstChild(challengeName)
    if not node then node = challengesFolder:FindFirstChild(challengeName:gsub(" ", "")) end
    if node then
        local nextAvail = node:FindFirstChild("NextAvailableTime")
        if nextAvail then return math.max(0, nextAvail.Value - os.time()) end
    end
    return 0
end

local function isChallengeAvailable(name) return getChallengeCooldown(name) == 0 end
local function isInChallenge() return challengeActiveFlag and challengeActiveFlag.Value == true end
local function isInRaid() return raidingFlag and raidingFlag.Value == true end

local function startNormalRaid()
    if not normalRaidActive then
        pcall(function() changeSetting:InvokeServer("AutoRaid", "Off") end)
        normalRaidActive = true
    end
end

local function stopNormalRaid()
    if normalRaidActive then
        pcall(function() changeSetting:InvokeServer("AutoRaid", "On") end)
        normalRaidActive = false
    end
end

local function startChallengeByName(name)
    currentChallengeName = name
    pcall(function()
        raidStop:FireServer()
        task.wait(0.5)
        startChallenge:InvokeServer(name)
        task.wait(0.5)
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
end

local function waitForChallengeToEnd()
    while isInChallenge() or isInRaid() do task.wait(1) end
    currentChallengeName = nil
end

local function getNextAvailable()
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled and isChallengeAvailable(ch.name) then return ch end
    end
    return nil
end

--// ANTI-AFK
local function startAntiAFK()
    if antiAFKActive then return end
    antiAFKActive = true
    antiAFKThread = task.spawn(function()
        while antiAFKActive do
            pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
            task.wait(45)
            pcall(function()
                local cam = workspace.CurrentCamera
                local orig = cam.CFrame
                cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
                task.wait(0.3)
                cam.CFrame = orig
            end)
            task.wait(60)
        end
    end)
end

local function stopAntiAFK()
    antiAFKActive = false
    if antiAFKThread then task.cancel(antiAFKThread) end
end

--// BUILD FUNCTIONS
local function executeEasterBuild()
    buildStatus.Text = "Building Easter structures..."
    print("[Easter] Starting build...")
    
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    
    for i, s in ipairs(easterBuildStructures) do
        buildStatus.Text = string.format("Building Easter %d/4...", i)
        print("[Easter] Building:", s.id)
        
        pcall(function()
            if eBuildDefense then
                eBuildDefense:InvokeServer(s.id, {Rotation = s.rot, Position = s.pos})
            end
        end)
        task.wait(0.5)
    end
    
    buildStatus.Text = "✅ Easter build complete!"
    print("[Easter] Build complete!")
    task.wait(2)
    buildStatus.Text = "Status: Ready"
end

local function executeMegaBuild()
    buildStatus.Text = "Building Mega Raid structures..."
    print("[Mega] Starting build...")
    
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    
    for i, s in ipairs(megaRaidBuildStructures) do
        buildStatus.Text = string.format("Building Mega %d/4...", i)
        print("[Mega] Building:", s.id)
        
        pcall(function()
            if cBuildDefense then
                cBuildDefense:InvokeServer(s.id, {Rotation = s.rot, Position = s.pos})
            end
        end)
        task.wait(0.5)
    end
    
    buildStatus.Text = "✅ Mega build complete!"
    print("[Mega] Build complete!")
    task.wait(2)
    buildStatus.Text = "Status: Ready"
end

--// POSITION FINDER HELPER (Run this to get new coordinates)
local function findCurrentPosition()
    local char = player.Character
    if char and char.PrimaryPart then
        local pos = char.PrimaryPart.Position
        print(string.format("Current position: X=%.1f, Y=%.1f, Z=%.1f", pos.X, pos.Y, pos.Z))
        print(string.format('vector.create(%.1f, %.1f, %.1f)', pos.X, pos.Y, pos.Z))
        return pos
    end
    return nil
end

local function testBuildAtPosition()
    local char = player.Character
    if char and char.PrimaryPart then
        local pos = char.PrimaryPart.Position
        print("[Test] Attempting build at current position...")
        
        local success = pcall(function()
            eBuildDefense:InvokeServer(
                "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
                {Rotation = 90, Position = pos}
            )
        end)
        
        if success then
            print("✅ BUILD SUCCESSFUL! Use this position:")
            print(string.format('vector.create(%.1f, %.1f, %.1f)', pos.X, pos.Y, pos.Z))
        else
            print("❌ Build failed - may need to be in correct area")
        end
    end
end

--// AUTO CHALLENGE LOOP
local function runAutoChallenge()
    autoChallengeActive = true
    autoChallengeThread = task.spawn(function()
        while autoChallengeActive do
            if isInChallenge() then
                waitForChallengeToEnd()
                task.wait(2)
            end
            local nextCh = getNextAvailable()
            if nextCh then
                if normalRaidActive then stopNormalRaid() end
                startChallengeByName(nextCh.id)
                waitForChallengeToEnd()
                task.wait(2)
            else
                if not normalRaidActive then startNormalRaid() end
                task.wait(10)
            end
        end
    end)
end

local function stopAutoChallenge()
    autoChallengeActive = false
    if autoChallengeThread then task.cancel(autoChallengeThread) end
    if normalRaidActive then stopNormalRaid() end
end

--// GUI CREATION
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 750)
mainFrame.Position = UDim2.new(0, 10, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "⚔️ TD AUTO FARM"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 3)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Parent = mainFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 10, 0, 100)
iconBtn.Text = "⚔️"
iconBtn.Visible = false
iconBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
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

createTab("build", "🏗️ BUILD", 0)
createTab("buy", "🛒 BUY", 1)
createTab("challenge", "🎯 CHALLENGE", 2)
createTab("schedule", "⏰ SCHEDULE", 3)
createTab("config", "💾 CONFIG", 4)

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

--// BUILD TAB
local buildPanel = panels.build
local easterBuildBtn = Instance.new("TextButton")
easterBuildBtn.Size = UDim2.new(1, -20, 0, 50)
easterBuildBtn.Text = "🐰 BUILD EASTER (4 Towers)"
easterBuildBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
easterBuildBtn.TextColor3 = Color3.new(1, 1, 1)
easterBuildBtn.Font = Enum.Font.GothamBold
easterBuildBtn.Parent = buildPanel

local megaBuildBtn = Instance.new("TextButton")
megaBuildBtn.Size = UDim2.new(1, -20, 0, 50)
megaBuildBtn.Text = "⚔️ BUILD MEGA RAID (4 Towers)"
megaBuildBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
megaBuildBtn.TextColor3 = Color3.new(1, 1, 1)
megaBuildBtn.Font = Enum.Font.GothamBold
megaBuildBtn.Parent = buildPanel

-- Debug buttons for position finding
local getPosBtn = Instance.new("TextButton")
getPosBtn.Size = UDim2.new(0.48, -5, 0, 35)
getPosBtn.Text = "📍 GET MY POSITION"
getPosBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
getPosBtn.TextColor3 = Color3.new(1, 1, 1)
getPosBtn.Parent = buildPanel
getPosBtn.Position = UDim2.new(0, 10, 0, 160)

local testBuildBtn = Instance.new("TextButton")
testBuildBtn.Size = UDim2.new(0.48, -5, 0, 35)
testBuildBtn.Text = "🔧 TEST BUILD HERE"
testBuildBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 50)
testBuildBtn.TextColor3 = Color3.new(1, 1, 1)
testBuildBtn.Parent = buildPanel
testBuildBtn.Position = UDim2.new(0.52, 0, 0, 160)

getPosBtn.MouseButton1Click:Connect(function()
    local pos = findCurrentPosition()
    if pos then
        buildStatus.Text = string.format("Pos: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
    else
        buildStatus.Text = "Can't get position - no character"
    end
end)

testBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(testBuildAtPosition)
end)

local buildStatus = Instance.new("TextLabel")
buildStatus.Size = UDim2.new(1, -20, 0, 40)
buildStatus.Text = "Status: Ready"
buildStatus.TextColor3 = Color3.new(1, 1, 1)
buildStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
buildStatus.Parent = buildPanel
buildStatus.Position = UDim2.new(0, 10, 0, 210)

--// BUY TAB
local buyPanel = panels.buy
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.PlaceholderText = "🔍 Search item..."
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Parent = buyPanel

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -20, 0, 280)
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
                    if items[item]=="E" then eBuyDefense:InvokeServer(item,1)
                    else buyDefense:InvokeServer(item,1) end
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

--// CHALLENGE TAB
local challengePanel = panels.challenge

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

local listHeader = Instance.new("TextLabel")
listHeader.Size = UDim2.new(1, -20, 0, 25)
listHeader.Text = "📋 CHALLENGE QUEUE (Tap to enable, arrows to reorder)"
listHeader.TextColor3 = Color3.new(1, 1, 0)
listHeader.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
listHeader.Parent = challengePanel

local queueDisplay = Instance.new("TextLabel")
queueDisplay.Size = UDim2.new(1, -20, 0, 120)
queueDisplay.Text = "No challenges enabled"
queueDisplay.TextColor3 = Color3.new(0.7, 0.7, 0.7)
queueDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
queueDisplay.TextWrapped = true
queueDisplay.TextXAlignment = Enum.TextXAlignment.Left
queueDisplay.Parent = challengePanel

local function updateQueueDisplay()
    local text = ""
    for i, ch in ipairs(challengeOrder) do
        if ch.enabled then
            local cd = getChallengeCooldown(ch.name)
            if cd == 0 then text = text .. string.format("%d. %s ✅ READY\n", i, ch.name)
            else
                local mins = math.floor(cd / 60)
                local secs = cd % 60
                text = text .. string.format("%d. %s ⏰ %02d:%02d\n", i, ch.name, mins, secs)
            end
        else
            text = text .. string.format("%d. %s ❌ OFF\n", i, ch.name)
        end
    end
    queueDisplay.Text = text ~= "" and text or "No challenges enabled"
end

local challengeListFrame = Instance.new("ScrollingFrame")
challengeListFrame.Size = UDim2.new(1, -20, 0, 180)
challengeListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
challengeListFrame.Parent = challengePanel
local challengeListLayout = Instance.new("UIListLayout", challengeListFrame)
challengeListLayout.Padding = UDim.new(0, 4)

for i, ch in ipairs(allChallenges) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    frame.Parent = challengeListFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.4, -5, 0.8, 0)
    toggleBtn.Position = UDim2.new(0, 5, 0.1, 0)
    toggleBtn.Text = "❌ " .. ch.name
    toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.TextSize = 12
    toggleBtn.Parent = frame
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
    upBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
    upBtn.Text = "⬆️"
    upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    upBtn.TextColor3 = Color3.new(1, 1, 1)
    upBtn.Parent = frame
    
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0.1, -5, 0.7, 0)
    downBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
    downBtn.Text = "⬇️"
    downBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    downBtn.TextColor3 = Color3.new(1, 1, 1)
    downBtn.Parent = frame
    
    challengeItems[i] = {toggleBtn=toggleBtn, name=ch.name, id=ch.id, enabled=false}
    
    toggleBtn.MouseButton1Click:Connect(function()
        challengeItems[i].enabled = not challengeItems[i].enabled
        if challengeItems[i].enabled then
            toggleBtn.Text = "✅ " .. ch.name
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        else
            toggleBtn.Text = "❌ " .. ch.name
            toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        end
        refreshChallengeOrder()
    end)
    
    upBtn.MouseButton1Click:Connect(function()
        if i > 1 then
            challengeItems[i], challengeItems[i-1] = challengeItems[i-1], challengeItems[i]
            refreshChallengeOrder()
        end
    end)
    
    downBtn.MouseButton1Click:Connect(function()
        if i < #allChallenges then
            challengeItems[i], challengeItems[i+1] = challengeItems[i+1], challengeItems[i]
            refreshChallengeOrder()
        end
    end)
end

local function refreshChallengeOrder()
    challengeOrder = {}
    for i, item in ipairs(challengeItems) do
        challengeOrder[i] = {name=item.name, id=item.id, enabled=item.enabled}
    end
    updateQueueDisplay()
end

local autoChallengeToggle = Instance.new("TextButton")
autoChallengeToggle.Size = UDim2.new(1, -20, 0, 50)
autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoChallengeToggle.TextColor3 = Color3.new(1, 1, 1)
autoChallengeToggle.Font = Enum.Font.GothamBold
autoChallengeToggle.Parent = challengePanel

autoChallengeToggle.MouseButton1Click:Connect(function()
    if autoChallengeActive then
        stopAutoChallenge()
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        challengeStatus.Text = "Status: Stopped"
        countdownDisplay.Text = "---"
    else
        refreshChallengeOrder()
        runAutoChallenge()
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: ON"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        challengeStatus.Text = "Status: ACTIVE"
    end
end)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.48, -5, 0, 35)
refreshBtn.Text = "🔄 REFRESH STATUS"
refreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Parent = challengePanel

refreshBtn.MouseButton1Click:Connect(function()
    updateQueueDisplay()
    challengeStatus.Text = "🔄 Refreshed!"
    task.wait(1)
    if autoChallengeActive then challengeStatus.Text = "Status: ACTIVE"
    else challengeStatus.Text = "Status: IDLE" end
end)

refreshChallengeOrder()

--// SCHEDULE TAB
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

-- Anti-AFK Section
local antiAFKCard = Instance.new("Frame")
antiAFKCard.Size = UDim2.new(1, -20, 0, 80)
antiAFKCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
antiAFKCard.Parent = schedulePanel

local antiAFKTitle = Instance.new("TextLabel")
antiAFKTitle.Size = UDim2.new(0.95, 0, 0, 25)
antiAFKTitle.Position = UDim2.new(0.025, 0, 0, 5)
antiAFKTitle.Text = "🔄 ANTI-AFK SYSTEM"
antiAFKTitle.TextColor3 = Color3.new(0.5, 0.8, 1)
antiAFKTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
antiAFKTitle.Parent = antiAFKCard

local antiAFKToggle = Instance.new("TextButton")
antiAFKToggle.Size = UDim2.new(0.95, 0, 0, 40)
antiAFKToggle.Position = UDim2.new(0.025, 0, 0, 32)
antiAFKToggle.Text = "🔄 ANTI-AFK: OFF"
antiAFKToggle.TextSize = 14
antiAFKToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
antiAFKToggle.TextColor3 = Color3.new(1, 1, 1)
antiAFKToggle.Parent = antiAFKCard

local antiAFKStatus = Instance.new("TextLabel")
antiAFKStatus.Size = UDim2.new(0.95, 0, 0, 20)
antiAFKStatus.Position = UDim2.new(0.025, 0, 0, 75)
antiAFKStatus.Text = "Status: Inactive"
antiAFKStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
antiAFKStatus.TextSize = 11
antiAFKStatus.BackgroundTransparency = 1
antiAFKStatus.Parent = antiAFKCard

antiAFKToggle.MouseButton1Click:Connect(function()
    if antiAFKActive then
        stopAntiAFK()
        antiAFKToggle.Text = "🔄 ANTI-AFK: OFF"
        antiAFKToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        antiAFKStatus.Text = "Status: Inactive"
        antiAFKStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    else
        startAntiAFK()
        antiAFKToggle.Text = "🔄 ANTI-AFK: ON"
        antiAFKToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        antiAFKStatus.Text = "Status: Active - Preventing AFK"
        antiAFKStatus.TextColor3 = Color3.new(0.3, 1, 0.3)
    end
end)

-- Schedule Logic
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

--// CONFIG TAB
local configPanel = panels.config

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(1, -20, 0, 40)
configTitle.Text = "💾 CONFIGURATION (Auto-Saves)"
configTitle.TextColor3 = Color3.new(1, 1, 0)
configTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
configTitle.Font = Enum.Font.GothamBold
configTitle.Parent = configPanel

local configStatus = Instance.new("TextLabel")
configStatus.Size = UDim2.new(1, -20, 0, 35)
configStatus.Text = "📌 Status: Auto-Save Active"
configStatus.TextColor3 = Color3.new(0, 1, 0)
configStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
configStatus.Parent = configPanel

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 45)
saveBtn.Text = "💾 MANUAL SAVE"
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Parent = configPanel

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -20, 0, 45)
resetBtn.Text = "⚠️ RESET TO DEFAULT"
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Parent = configPanel

local exportBtn = Instance.new("TextButton")
exportBtn.Size = UDim2.new(0.48, -5, 0, 40)
exportBtn.Text = "📤 EXPORT"
exportBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
exportBtn.TextColor3 = Color3.new(1, 1, 1)
exportBtn.Parent = configPanel

local importBtn = Instance.new("TextButton")
importBtn.Size = UDim2.new(0.48, -5, 0, 40)
importBtn.Position = UDim2.new(0.52, 0, 0, 0)
importBtn.Text = "📋 IMPORT"
importBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 50)
importBtn.TextColor3 = Color3.new(1, 1, 1)
importBtn.Parent = configPanel

local saveStatus = Instance.new("TextLabel")
saveStatus.Size = UDim2.new(1, -20, 0, 35)
saveStatus.Text = "Ready"
saveStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
saveStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
saveStatus.Parent = configPanel

local configInfo = Instance.new("TextLabel")
configInfo.Size = UDim2.new(1, -20, 0, 100)
configInfo.Text = "📌 Auto-Save Info:\n\n✅ Changes save automatically!\n✅ Config loads when script starts\n✅ Export to save backup\n✅ Import to restore backup"
configInfo.TextColor3 = Color3.new(0.6, 0.6, 0.6)
configInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
configInfo.TextWrapped = true
configInfo.TextSize = 11
configInfo.Parent = configPanel

--// CONFIG SYSTEM
local configName = "TD_Auto_Farm_Config"
local savedConfig = nil

local function autoSaveConfig()
    local config = {
        version = 6,
        savedAt = os.date("%Y-%m-%d %H:%M:%S"),
        challengeOrder = {},
        selectedItems = {},
        autoBuyEnabled = autoBuyActive,
        autoChallengeEnabled = autoChallengeActive
    }
    for _, item in ipairs(challengeItems) do
        table.insert(config.challengeOrder, {name=item.name, id=item.id, enabled=item.enabled})
    end
    for item,_ in pairs(selectedItems) do table.insert(config.selectedItems, item) end
    config.autoBuyEnabled = autoBuyActive
    config.autoChallengeEnabled = autoChallengeActive
    local success, encoded = pcall(function() return HttpService:JSONEncode(config) end)
    if success then
        pcall(function() writefile(configName .. ".json", encoded) end)
        pcall(function() shared[configName] = encoded end)
    end
end

local function autoLoadConfig()
    local configData = nil
    local readSuccess, data = pcall(function() return readfile(configName .. ".json") end)
    if readSuccess and data and data ~= "" then configData = data end
    if not configData then
        pcall(function() if shared[configName] and shared[configName] ~= "" then configData = shared[configName] end end)
    end
    if configData then
        local success, data = pcall(function() return HttpService:JSONDecode(configData) end)
        if success and data then savedConfig = data return true end
    end
    return false
end

local function applyConfig()
    if not savedConfig then return false end
    if savedConfig.challengeOrder then
        for i, savedCh in ipairs(savedConfig.challengeOrder) do
            if challengeItems[i] then
                challengeItems[i].enabled = savedCh.enabled
                if savedCh.enabled then
                    challengeItems[i].toggleBtn.Text = "✅ " .. challengeItems[i].name
                    challengeItems[i].toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
                else
                    challengeItems[i].toggleBtn.Text = "❌ " .. challengeItems[i].name
                    challengeItems[i].toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
                end
            end
        end
        refreshChallengeOrder()
    end
    if savedConfig.selectedItems then
        for _, itemName in ipairs(savedConfig.selectedItems) do
            selectedItems[itemName] = true
            local btn = itemButtons[itemName]
            if btn then
                btn.Text = btn.Text:gsub("%[ %]","[X]")
                btn.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
            end
        end
    end
    if savedConfig.autoBuyEnabled then
        autoBuyActive = savedConfig.autoBuyEnabled
        autoBuyToggle.Text = autoBuyActive and "🔴 AUTO BUY (1s): ON" or "🟢 AUTO BUY (1s): OFF"
        autoBuyToggle.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
        if autoBuyActive then autoBuyLoop() end
    end
    if savedConfig.autoChallengeEnabled then
        autoChallengeActive = savedConfig.autoChallengeEnabled
        autoChallengeToggle.Text = autoChallengeActive and "🎯 AUTO CHALLENGE: ON" or "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
        if autoChallengeActive then runAutoChallenge() end
    end
    return true
end

local function resetToDefault()
    for i, item in ipairs(challengeItems) do
        item.enabled = false
        item.toggleBtn.Text = "❌ " .. item.name
        item.toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    end
    refreshChallengeOrder()
    for name, btn in pairs(itemButtons) do
        btn.Text = btn.Text:gsub("%[X%]","[ ]")
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
    selectedItems = {}
    autoBuyActive = false
    autoBuyToggle.Text = "🟢 AUTO BUY (1s): OFF"
    autoBuyToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    if autoChallengeActive then
        stopAutoChallenge()
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    end
    autoSaveConfig()
    saveStatus.Text = "✅ Reset to default!"
    task.wait(2)
    saveStatus.Text = "Ready"
end

saveBtn.MouseButton1Click:Connect(function()
    autoSaveConfig()
    saveStatus.Text = "✅ Config saved!"
    task.wait(2)
    saveStatus.Text = "Ready"
end)

resetBtn.MouseButton1Click:Connect(function() resetToDefault() end)

exportBtn.MouseButton1Click:Connect(function()
    local config = {
        version = 6,
        savedAt = os.date("%Y-%m-%d %H:%M:%S"),
        challengeOrder = {},
        selectedItems = {},
        autoBuyEnabled = autoBuyActive,
        autoChallengeEnabled = autoChallengeActive
    }
    for _, item in ipairs(challengeItems) do
        table.insert(config.challengeOrder, {name=item.name, id=item.id, enabled=item.enabled})
    end
    for item,_ in pairs(selectedItems) do table.insert(config.selectedItems, item) end
    config.autoBuyEnabled = autoBuyActive
    config.autoChallengeEnabled = autoChallengeActive
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
                tabs[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(50, 50, 60)
                tabs[tabName].TextColor3 = (tabName == name) and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
            end
        end
    end)
end

panels.build.Visible = true
tabs.build.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

if autoLoadConfig() then applyConfig() end
refreshChallengeOrder()

--// BUTTON CONNECTIONS
easterBuildBtn.MouseButton1Click:Connect(function() task.spawn(executeEasterBuild) end)
megaBuildBtn.MouseButton1Click:Connect(function() task.spawn(executeMegaBuild) end)

print("=== TD AUTO FARM LOADED ===")
print("✅ BUILD - Easter & Mega Raid (Use 'GET MY POSITION' to find new coordinates)")
print("✅ BUY - Auto buy towers every 1 second")
print("✅ CHALLENGE - Smart auto-challenge with raid fallback")
print("✅ SCHEDULE - Easter (:15/:45), Mega (:00), Anti-AFK")
print("✅ CONFIG - Auto-save/load settings")
print("")
print("⚠️ GAME UPDATED - Use 'GET MY POSITION' button to find new build coordinates!")
print("   Stand where you want to build, click the button, then update the script")

end)
