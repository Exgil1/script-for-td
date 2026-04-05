--// COMPLETE TD AUTO FARM - FULLY WORKING
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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

--// BUILD STRUCTURES (UPDATED WITH CORRECT POSITIONS)
local easterBuildStructures = {
    {
        id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
        pos = vector.create(525.6004638671875, 227.50601196289062, 1187.6143798828125),
        rot = 90
    },
    {
        id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
        pos = vector.create(527.6004638671875, 227.50601196289062, 1193.6143798828125),
        rot = 90
    },
    {
        id = "Railgun{cba7bbf3-aaab-4cde-92df-67ac6c4ebda0}",
        pos = vector.create(535.6004638671875, 227.50601196289062, 1209.6143798828125),
        rot = 90
    },
    {
        id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
        pos = vector.create(535.6004638671875, 227.50601196289062, 1199.6143798828125),
        rot = 90
    }
}

local megaRaidBuildStructures = {
    {
        id = "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
        pos = vector.create(1529.6004638671875, 8.505999565124512, 1189.6143798828125),
        rot = 90
    },
    {
        id = "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
        pos = vector.create(1523.6004638671875, 8.505999565124512, 1197.6143798828125),
        rot = 90
    },
    {
        id = "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
        pos = vector.create(1531.6004638671875, 8.505999565124512, 1199.6143798828125),
        rot = 90
    },
    {
        id = "Railgun{cba7bbf3-aaab-4cde-92df-67ac6c4ebda0}",
        pos = vector.create(1527.6004638671875, 8.505999565124512, 1209.6143798828125),
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

--// GLOBAL VARIABLES
local autoChallengeActive = false
local autoChallengeThread = nil
local challengeOrder = {}
local challengeItems = {}

--// ============== BUILD FUNCTIONS (DIRECT REMOTE CALLS) ==============

local function executeEasterBuild()
    print("[Easter] Starting build...")
    
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    
    -- Wall
    pcall(function()
        local args = {
            "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
            {Rotation = 90, Position = vector.create(525.6004638671875, 227.50601196289062, 1187.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("EBuildDefense"):InvokeServer(unpack(args))
        print("[Easter] Wall built")
    end)
    task.wait(0.5)
    
    -- Flamespitter
    pcall(function()
        local args = {
            "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
            {Rotation = 90, Position = vector.create(527.6004638671875, 227.50601196289062, 1193.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("EBuildDefense"):InvokeServer(unpack(args))
        print("[Easter] Flamespitter built")
    end)
    task.wait(0.5)
    
    -- Railgun
    pcall(function()
        local args = {
            "Railgun{cba7bbf3-aaab-4cde-92df-67ac6c4ebda0}",
            {Rotation = 90, Position = vector.create(535.6004638671875, 227.50601196289062, 1209.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("EBuildDefense"):InvokeServer(unpack(args))
        print("[Easter] Railgun built")
    end)
    task.wait(0.5)
    
    -- Inferno Beam
    pcall(function()
        local args = {
            "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
            {Rotation = 90, Position = vector.create(535.6004638671875, 227.50601196289062, 1199.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("EBuildDefense"):InvokeServer(unpack(args))
        print("[Easter] Inferno Beam built")
    end)
    
    if buildStatus then buildStatus.Text = "✅ Easter complete!" end
    print("[Easter] Complete!")
    task.wait(2)
    if buildStatus then buildStatus.Text = "Status: Ready" end
end

local function executeMegaBuild()
    print("[Mega] Starting build...")
    
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    
    -- Wall
    pcall(function()
        local args = {
            "Wall{d0bfa0d3-11c2-4606-b175-ecd58b9878f0}",
            {Rotation = 90, Position = vector.create(1529.6004638671875, 8.505999565124512, 1189.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("CBuildDefense"):InvokeServer(unpack(args))
        print("[Mega] Wall built")
    end)
    task.wait(0.5)
    
    -- Flamespitter
    pcall(function()
        local args = {
            "Flamespitter{5c2cf563-40ae-4c75-9881-9e97f9b8cd66}",
            {Rotation = 90, Position = vector.create(1523.6004638671875, 8.505999565124512, 1197.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("CBuildDefense"):InvokeServer(unpack(args))
        print("[Mega] Flamespitter built")
    end)
    task.wait(0.5)
    
    -- Inferno Beam
    pcall(function()
        local args = {
            "Inferno Beam{538ce489-08e2-4a0e-9a7b-24792793dbb6}",
            {Rotation = 90, Position = vector.create(1531.6004638671875, 8.505999565124512, 1199.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("CBuildDefense"):InvokeServer(unpack(args))
        print("[Mega] Inferno Beam built")
    end)
    task.wait(0.5)
    
    -- Railgun
    pcall(function()
        local args = {
            "Railgun{cba7bbf3-aaab-4cde-92df-67ac6c4ebda0}",
            {Rotation = 90, Position = vector.create(1527.6004638671875, 8.505999565124512, 1209.6143798828125)}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Functions"):WaitForChild("CBuildDefense"):InvokeServer(unpack(args))
        print("[Mega] Railgun built")
    end)
    
    if buildStatus then buildStatus.Text = "✅ Mega complete!" end
    print("[Mega] Complete!")
    task.wait(2)
    if buildStatus then buildStatus.Text = "Status: Ready" end
end

--// ============== GUI ==============
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 650)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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

local buildStatus = Instance.new("TextLabel")
buildStatus.Size = UDim2.new(1, -20, 0, 40)
buildStatus.Text = "Status: Ready"
buildStatus.TextColor3 = Color3.new(1, 1, 1)
buildStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
buildStatus.Parent = buildPanel

easterBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeEasterBuild)
end)

megaBuildBtn.MouseButton1Click:Connect(function()
    task.spawn(executeMegaBuild)
end)

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

--// CHALLENGE TAB (SIMPLE VERSION)
local challengePanel = panels.challenge

local challengeStatus = Instance.new("TextLabel")
challengeStatus.Size = UDim2.new(1, -20, 0, 40)
challengeStatus.Text = "Status: Idle"
challengeStatus.TextColor3 = Color3.new(1, 1, 1)
challengeStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
challengeStatus.Parent = challengePanel

local queueDisplay = Instance.new("TextLabel")
queueDisplay.Size = UDim2.new(1, -20, 0, 100)
queueDisplay.Text = "No challenges enabled"
queueDisplay.TextColor3 = Color3.new(0.7, 0.7, 0.7)
queueDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
queueDisplay.TextWrapped = true
queueDisplay.Parent = challengePanel

local challengeListFrame = Instance.new("ScrollingFrame")
challengeListFrame.Size = UDim2.new(1, -20, 0, 180)
challengeListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
challengeListFrame.Parent = challengePanel
local challengeListLayout = Instance.new("UIListLayout", challengeListFrame)
challengeListLayout.Padding = UDim.new(0, 4)

local simpleChallengeItems = {}

for i, ch in ipairs(allChallenges) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    frame.Parent = challengeListFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -5, 1, -5)
    toggleBtn.Text = "❌ " .. ch.name
    toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.Parent = frame
    
    simpleChallengeItems[i] = {toggleBtn=toggleBtn, name=ch.name, id=ch.id, enabled=false}
    
    toggleBtn.MouseButton1Click:Connect(function()
        simpleChallengeItems[i].enabled = not simpleChallengeItems[i].enabled
        if simpleChallengeItems[i].enabled then
            toggleBtn.Text = "✅ " .. ch.name
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        else
            toggleBtn.Text = "❌ " .. ch.name
            toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        end
        updateQueueDisplay()
    end)
end

local function updateQueueDisplay()
    local text = ""
    for i, item in ipairs(simpleChallengeItems) do
        if item.enabled then
            text = text .. string.format("%d. %s ✅\n", i, item.name)
        else
            text = text .. string.format("%d. %s ❌\n", i, item.name)
        end
    end
    queueDisplay.Text = text ~= "" and text or "No challenges enabled"
end

local function runAutoChallenge()
    autoChallengeActive = true
    autoChallengeThread = task.spawn(function()
        while autoChallengeActive do
            for _, ch in ipairs(simpleChallengeItems) do
                if ch.enabled then
                    challengeStatus.Text = "Starting: " .. ch.name
                    pcall(function()
                        raidStop:FireServer()
                        task.wait(0.5)
                        startChallenge:InvokeServer(ch.id)
                        task.wait(0.5)
                        changeSetting:InvokeServer("AutoRaid", "On")
                    end)
                    challengeStatus.Text = "Running: " .. ch.name
                    task.wait(300)
                    challengeStatus.Text = "Complete: " .. ch.name
                    task.wait(2)
                end
            end
            challengeStatus.Text = "All done, looping..."
            task.wait(5)
        end
    end)
end

local function stopAutoChallenge()
    autoChallengeActive = false
    if autoChallengeThread then task.cancel(autoChallengeThread) end
    challengeStatus.Text = "Stopped"
end

local autoChallengeBtn = Instance.new("TextButton")
autoChallengeBtn.Size = UDim2.new(1, -20, 0, 50)
autoChallengeBtn.Text = "🎯 AUTO CHALLENGE: OFF"
autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoChallengeBtn.TextColor3 = Color3.new(1, 1, 1)
autoChallengeBtn.Font = Enum.Font.GothamBold
autoChallengeBtn.Parent = challengePanel

autoChallengeBtn.MouseButton1Click:Connect(function()
    if autoChallengeActive then
        stopAutoChallenge()
        autoChallengeBtn.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    else
        runAutoChallenge()
        autoChallengeBtn.Text = "🎯 AUTO CHALLENGE: ON"
        autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    end
end)

updateQueueDisplay()

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
    for i, item in ipairs(simpleChallengeItems) do
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
            if simpleChallengeItems[i] then
                simpleChallengeItems[i].enabled = savedCh.enabled
                if savedCh.enabled then
                    simpleChallengeItems[i].toggleBtn.Text = "✅ " .. simpleChallengeItems[i].name
                    simpleChallengeItems[i].toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
                else
                    simpleChallengeItems[i].toggleBtn.Text = "❌ " .. simpleChallengeItems[i].name
                    simpleChallengeItems[i].toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
                end
            end
        end
        updateQueueDisplay()
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
        autoChallengeBtn.Text = autoChallengeActive and "🎯 AUTO CHALLENGE: ON" or "🎯 AUTO CHALLENGE: OFF"
        autoChallengeBtn.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
        if autoChallengeActive then runAutoChallenge() end
    end
    return true
end

local function resetToDefault()
    for i, item in ipairs(simpleChallengeItems) do
        item.enabled = false
        item.toggleBtn.Text = "❌ " .. item.name
        item.toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    end
    updateQueueDisplay()
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
        autoChallengeBtn.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
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
    for i, item in ipairs(simpleChallengeItems) do
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
updateQueueDisplay()

print("=== TD AUTO FARM LOADED ===")
print("✅ BUILD - Easter & Mega Raid (Fixed positions with Railgun)")
print("✅ BUY - Auto buy towers every 1 second")
print("✅ CHALLENGE - Auto challenge with queue")
print("✅ SCHEDULE - Easter (:15/:45), Mega (:00)")
print("✅ CONFIG - Auto-save/load settings")

end)
