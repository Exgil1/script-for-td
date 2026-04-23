--// FIND WAVE REMOTES - FOR DELTA MOBILE
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteFinder"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(255, 100, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔍 REMOTE & WAVE FINDER"
title.TextColor3 = Color3.new(255, 255, 255)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Wave display
local waveBox = Instance.new("Frame")
waveBox.Size = UDim2.new(1, -20, 0, 80)
waveBox.Position = UDim2.new(0, 10, 0, 50)
waveBox.BackgroundColor3 = Color3.new(30, 30, 30)
waveBox.Parent = mainFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(1, 0, 0, 50)
waveLabel.Position = UDim2.new(0, 0, 0, 10)
waveLabel.Text = "Wave: ???"
waveLabel.TextColor3 = Color3.new(0, 255, 0)
waveLabel.TextSize = 28
waveLabel.BackgroundTransparency = 1
waveLabel.Font = Enum.Font.SourceSansBold
waveLabel.Parent = waveBox

local waveSourceLabel = Instance.new("TextLabel")
waveSourceLabel.Size = UDim2.new(1, 0, 0, 20)
waveSourceLabel.Position = UDim2.new(0, 0, 0, 60)
waveSourceLabel.Text = "Source: Unknown"
waveSourceLabel.TextColor3 = Color3.new(200, 200, 200)
waveSourceLabel.TextSize = 10
waveSourceLabel.BackgroundTransparency = 1
waveSourceLabel.Parent = waveBox

-- Remote events log
local remoteLabel = Instance.new("TextLabel")
remoteLabel.Size = UDim2.new(1, -20, 0, 25)
remoteLabel.Position = UDim2.new(0, 10, 0, 140)
remoteLabel.Text = "📡 DETECTED REMOTE EVENTS:"
remoteLabel.TextColor3 = Color3.new(255, 255, 0)
remoteLabel.BackgroundColor3 = Color3.new(30, 30, 30)
remoteLabel.TextSize = 11
remoteLabel.Parent = mainFrame

local remoteScroll = Instance.new("ScrollingFrame")
remoteScroll.Size = UDim2.new(1, -20, 0, 200)
remoteScroll.Position = UDim2.new(0, 10, 0, 170)
remoteScroll.BackgroundColor3 = Color3.new(20, 20, 20)
remoteScroll.BorderSizePixel = 1
remoteScroll.BorderColor3 = Color3.new(100, 100, 100)
remoteScroll.Parent = mainFrame

local remoteList = Instance.new("UIListLayout")
remoteList.Parent = remoteScroll
remoteList.Padding = UDim.new(0, 2)

local remoteContent = Instance.new("Frame")
remoteContent.Size = UDim2.new(1, 0, 0, 0)
remoteContent.BackgroundTransparency = 1
remoteContent.Parent = remoteScroll

-- Buttons
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.48, -5, 0, 40)
copyBtn.Position = UDim2.new(0, 10, 0, 380)
copyBtn.Text = "📋 COPY DATA"
copyBtn.BackgroundColor3 = Color3.new(0, 100, 200)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, -5, 0, 40)
clearBtn.Position = UDim2.new(0.52, 0, 0, 380)
clearBtn.Text = "🗑️ CLEAR"
clearBtn.BackgroundColor3 = Color3.new(200, 100, 50)
clearBtn.TextColor3 = Color3.new(255, 255, 255)
clearBtn.TextSize = 12
clearBtn.Parent = mainFrame

local testEndBtn = Instance.new("TextButton")
testEndBtn.Size = UDim2.new(0.48, -5, 0, 40)
testEndBtn.Position = UDim2.new(0, 10, 0, 430)
testEndBtn.Text = "⚡ TEST END RAID"
testEndBtn.BackgroundColor3 = Color3.new(200, 50, 50)
testEndBtn.TextColor3 = Color3.new(255, 255, 255)
testEndBtn.TextSize = 12
testEndBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.48, -5, 0, 40)
closeBtn.Position = UDim2.new(0.52, 0, 0, 430)
closeBtn.Text = "❌ CLOSE"
closeBtn.BackgroundColor3 = Color3.new(100, 50, 100)
closeBtn.TextColor3 = Color3.new(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame

-- Data storage
local remoteEventsFired = {}  -- Store {remote, args, time}
local waveHistory = {}
local currentWave = 0
local lastWave = 0

-- Add log to remote display
local function addRemoteLog(remoteName, args)
    local time = os.date("%H:%M:%S")
    local argsStr = ""
    for i, arg in ipairs(args) do
        if i > 2 then
            argsStr = argsStr .. "..."
            break
        end
        if type(arg) == "number" then
            argsStr = argsStr .. tostring(arg)
        elseif type(arg) == "string" then
            argsStr = argsStr .. "'" .. tostring(arg) .. "'"
        else
            argsStr = argsStr .. type(arg)
        end
        argsStr = argsStr .. (i < #args and #args > 2 and ", " or "")
    end
    
    local logText = "[" .. time .. "] " .. remoteName
    if argsStr ~= "" then
        logText = logText .. " → " .. argsStr
    end
    
    -- Store
    table.insert(remoteEventsFired, 1, {text = logText, remote = remoteName, args = args, time = time})
    while #remoteEventsFired > 50 do table.remove(remoteEventsFired) end
    
    -- Update UI
    for _, child in ipairs(remoteContent:GetChildren()) do
        child:Destroy()
    end
    
    for i = #remoteEventsFired, 1, -1 do
        local ev = remoteEventsFired[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Text = ev.text
        -- Highlight wave-related remotes
        if string.find(string.lower(ev.remote), "wave") or string.find(string.lower(ev.remote), "round") then
            label.TextColor3 = Color3.new(255, 200, 0)
        else
            label.TextColor3 = Color3.new(150, 150, 150)
        end
        label.BackgroundTransparency = 1
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = remoteContent
    end
    
    task.wait()
    remoteScroll.CanvasPosition = Vector2.new(0, 0)
    remoteScroll.CanvasSize = UDim2.new(0, 0, 0, #remoteEventsFired * 20)
end

-- HOOK ALL REMOTE EVENTS (Simple method that works on Delta)
local function hookAllRemotes()
    local function scanAndHook(instance)
        if instance:IsA("RemoteEvent") then
            local oldFunc = instance.OnClientEvent
            instance.OnClientEvent = function(...)
                local args = {...}
                addRemoteLog(instance.Name, args)
                
                -- If this remote has wave numbers in args, highlight it!
                for _, arg in ipairs(args) do
                    if type(arg) == "number" and arg > 0 and arg < 500 then
                        addRemoteLog("⚠️ WAVE NUMBER DETECTED IN: " .. instance.Name, {arg})
                    end
                end
                
                if oldFunc then oldFunc(...) end
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            scanAndHook(child)
        end
    end
    
    scanAndHook(ReplicatedStorage)
    addRemoteLog("Remote monitor ACTIVE", {})
end

-- Simple wave detection (to see when wave changes with remotes)
local function detectWave()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil, nil end
    
    local function search(instance)
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("TextLabel") then
                local text = child.Text or ""
                local num = text:match("Wave%s*(%d+)") or text:match("WAVE%s*(%d+)") or text:match("wave%s*(%d+)")
                if num then
                    return tonumber(num), child.Name
                end
            end
            local result, src = search(child)
            if result then return result, src end
        end
        return nil, nil
    end
    
    return search(playerGui)
end

-- Main monitoring
spawn(function()
    while true do
        local wave, source = detectWave()
        
        if wave and wave ~= lastWave then
            lastWave = wave
            currentWave = wave
            waveLabel.Text = "Wave: " .. wave
            waveSourceLabel.Text = "Source: " .. (source or "Unknown")
            
            if wave >= 408 then
                waveLabel.TextColor3 = Color3.new(255, 0, 0)
                addRemoteLog("⚠️ TARGET WAVE " .. wave .. " REACHED", {})
            else
                waveLabel.TextColor3 = Color3.new(0, 255, 0)
            end
            
            -- Log wave change to remote list
            addRemoteLog("📊 WAVE CHANGED TO: " .. wave, {})
        end
        
        wait(0.3)
    end
end)

-- Test end raid function
local function testEndRaid()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local remotes = events:FindFirstChild("Remotes")
        if remotes then
            local raidStop = remotes:FindFirstChild("RaidStop")
            if raidStop then
                pcall(function()
                    raidStop:FireServer()
                    addRemoteLog("✅ TEST: RaidStop fired", {})
                end)
            else
                addRemoteLog("❌ RaidStop not found", {})
            end
        end
    end
end

-- Button functions
copyBtn.MouseButton1Click:Connect(function()
    local data = "=== REMOTE & WAVE DATA ===\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Wave: " .. currentWave .. "\n"
    data = data .. "Total Remotes Logged: " .. #remoteEventsFired .. "\n"
    data = data .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    data = data .. "REMOTE EVENTS:\n"
    
    for i = #remoteEventsFired, 1, -1 do
        data = data .. remoteEventsFired[i].text .. "\n"
    end
    
    pcall(function()
        setclipboard(data)
        addRemoteLog("✅ Data copied to clipboard!", {})
    end)
end)

clearBtn.MouseButton1Click:Connect(function()
    remoteEventsFired = {}
    for _, child in ipairs(remoteContent:GetChildren()) do
        child:Destroy()
    end
    addRemoteLog("Console cleared", {})
end)

testEndBtn.MouseButton1Click:Connect(function()
    testEndRaid()
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
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

-- Start
hookAllRemotes()
addRemoteLog("=== REMOTE FINDER ACTIVE ===", {})
addRemoteLog("Start a raid! Any remote that fires will appear here", {})
addRemoteLog("Look for remotes with WAVE NUMBERS in them", {})
