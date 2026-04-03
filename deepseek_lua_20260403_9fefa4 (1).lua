--// COMPLETE TOWER DEFENSE AUTO FARM - FULL WORKING VERSION
pcall(function()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

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

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TDAutoFarm"
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "TD Auto Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Parent = mainFrame

-- Minimize
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

--// EASTER TAB
local easterBtn = Instance.new("TextButton")
easterBtn.Size = UDim2.new(0.45, -5, 0, 40)
easterBtn.Position = UDim2.new(0, 10, 0, 45)
easterBtn.Text = "🐰 Easter Build"
easterBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
easterBtn.Parent = mainFrame

local megaBtn = Instance.new("TextButton")
megaBtn.Size = UDim2.new(0.45, -5, 0, 40)
megaBtn.Position = UDim2.new(0.52, 0, 0, 45)
megaBtn.Text = "⚔️ Mega Build"
megaBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 100)
megaBtn.Parent = mainFrame

-- Auto Buy
local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(0.45, -5, 0, 40)
autoBuyBtn.Position = UDim2.new(0, 10, 0, 95)
autoBuyBtn.Text = "🛒 Auto Buy: OFF"
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoBuyBtn.Parent = mainFrame

-- Auto Challenge
local autoChallengeBtn = Instance.new("TextButton")
autoChallengeBtn.Size = UDim2.new(0.45, -5, 0, 40)
autoChallengeBtn.Position = UDim2.new(0.52, 0, 0, 95)
autoChallengeBtn.Text = "🎯 Challenge: OFF"
autoChallengeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
autoChallengeBtn.Parent = mainFrame

-- Schedule
local scheduleBtn = Instance.new("TextButton")
scheduleBtn.Size = UDim2.new(0.45, -5, 0, 40)
scheduleBtn.Position = UDim2.new(0, 10, 0, 145)
scheduleBtn.Text = "⏰ Schedule: OFF"
scheduleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
scheduleBtn.Parent = mainFrame

-- Status display
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 60)
statusText.Position = UDim2.new(0, 10, 0, 195)
statusText.Text = "Status: Ready"
statusText.TextColor3 = Color3.new(1, 1, 0)
statusText.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusText.TextWrapped = true
statusText.Parent = mainFrame

local timerText = Instance.new("TextLabel")
timerText.Size = UDim2.new(1, -20, 0, 30)
timerText.Position = UDim2.new(0, 10, 0, 260)
timerText.Text = "Next: --:--"
timerText.TextColor3 = Color3.new(0.5, 0.8, 1)
timerText.BackgroundTransparency = 1
timerText.Parent = mainFrame

-- Item selection area
local itemFrame = Instance.new("ScrollingFrame")
itemFrame.Size = UDim2.new(1, -20, 0, 180)
itemFrame.Position = UDim2.new(0, 10, 0, 300)
itemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
itemFrame.Parent = mainFrame

local itemLayout = Instance.new("UIListLayout", itemFrame)

local selectedItems = {}
local itemButtons = {}

for name, typ in pairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Text = (typ=="E" and "🎯 " or "⚔️ ").."[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = itemFrame
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

--// FUNCTIONS
local function executeEasterBuild()
    statusText.Text = "Building Easter structures..."
    pcall(function() joinEventRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(easterBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            eBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    statusText.Text = "Easter build complete!"
    task.wait(2)
    statusText.Text = "Ready"
end

local function executeMegaBuild()
    statusText.Text = "Building Mega structures..."
    pcall(function() joinCommunityRaid:FireServer() end)
    task.wait(1)
    for _, s in ipairs(megaRaidBuildStructures) do
        pcall(function()
            local args = {s.id, {Rotation = s.rot, Position = s.pos}}
            cBuildDefense:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
    statusText.Text = "Mega build complete!"
    task.wait(2)
    statusText.Text = "Ready"
end

local autoBuyActive = false
local function autoBuyLoop()
    task.spawn(function()
        while autoBuyActive do
            for item,_ in pairs(selectedItems) do
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

-- UI Detection
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

local function clickStart()
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

local autoChallengeActive = false
local challengeList = {"Insane Challenge", "Pro Challenge", "Easter Challenge #2", "Godly Challenge"}
local challengeIndex = 1
local challengeInterval = 300

local function runAutoChallenge()
    task.spawn(function()
        while autoChallengeActive do
            statusText.Text = "Waiting for cooldown..."
            local ready = false
            while autoChallengeActive and not ready do
                local timer = findCooldownTimer()
                if timer then
                    local t = timer.Text
                    timerText.Text = "Cooldown: " .. t
                    if t == "00:00" or t == "0:00" then
                        ready = true
                    end
                end
                task.wait(1)
            end
            if autoChallengeActive then
                statusText.Text = "Starting: " .. challengeList[challengeIndex]
                pcall(function()
                    raidStop:FireServer()
                    task.wait(1)
                    startChallenge:InvokeServer(challengeList[challengeIndex])
                    task.wait(1)
                    changeSetting:InvokeServer("AutoRaid", "On")
                end)
                for i = challengeInterval, 1, -1 do
                    if not autoChallengeActive then break end
                    timerText.Text = string.format("Next: %02d:%02d", math.floor(i/60), i%60)
                    task.wait(1)
                end
                challengeIndex = challengeIndex + 1
                if challengeIndex > #challengeList then challengeIndex = 1 end
            end
        end
    end)
end

-- Schedule
local scheduleActive = false
local function scheduleChecker()
    task.spawn(function()
        while true do
            if scheduleActive then
                local now = os.date("*t")
                local min = now.min
                if min == 15 or min == 45 then
                    statusText.Text = "Schedule: Running Easter..."
                    executeEasterBuild()
                    task.wait(60)
                elseif min == 0 then
                    statusText.Text = "Schedule: Running Mega..."
                    executeMegaBuild()
                    task.wait(60)
                end
            end
            task.wait(30)
        end
    end)
end

--// BUTTON CONNECTIONS
easterBtn.MouseButton1Click:Connect(function()
    task.spawn(executeEasterBuild)
end)

megaBtn.MouseButton1Click:Connect(function()
    task.spawn(executeMegaBuild)
end)

autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuyActive = not autoBuyActive
    autoBuyBtn.Text = autoBuyActive and "🛒 Auto Buy: ON" or "🛒 Auto Buy: OFF"
    autoBuyBtn.BackgroundColor3 = autoBuyActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoBuyActive then autoBuyLoop() end
end)

autoChallengeBtn.MouseButton1Click:Connect(function()
    autoChallengeActive = not autoChallengeActive
    autoChallengeBtn.Text = autoChallengeActive and "🎯 Challenge: ON" or "🎯 Challenge: OFF"
    autoChallengeBtn.BackgroundColor3 = autoChallengeActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if autoChallengeActive then runAutoChallenge() end
end)

scheduleBtn.MouseButton1Click:Connect(function()
    scheduleActive = not scheduleActive
    scheduleBtn.Text = scheduleActive and "⏰ Schedule: ON" or "⏰ Schedule: OFF"
    scheduleBtn.BackgroundColor3 = scheduleActive and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(70, 50, 50)
    if scheduleActive then scheduleChecker() end
end)

print("TD Auto Farm Loaded Successfully!")
statusText.Text = "Ready - Select items and toggle features"

end)
