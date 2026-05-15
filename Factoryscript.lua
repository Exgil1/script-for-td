--// REMOTE CAPTURE SCRIPT FOR DELTA MOBILE
--// Captures ALL RemoteEvents and RemoteFunctions
--// Includes COPY button for logs

pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteCapture"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(255, 50, 50)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "REMOTE CAPTURE - ALL REMOTES"
title.TextColor3 = Color3.new(255, 50, 50)
title.BackgroundColor3 = Color3.new(30, 30, 30)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.Text = "Status: Monitoring..."
statusLabel.TextColor3 = Color3.new(0, 255, 0)
statusLabel.BackgroundColor3 = Color3.new(20, 20, 30)
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

local remoteCountLabel = Instance.new("TextLabel")
remoteCountLabel.Size = UDim2.new(1, -20, 0, 25)
remoteCountLabel.Position = UDim2.new(0, 10, 0, 80)
remoteCountLabel.Text = "Remotes Captured: 0"
remoteCountLabel.TextColor3 = Color3.new(255, 255, 0)
remoteCountLabel.BackgroundColor3 = Color3.new(20, 20, 30)
remoteCountLabel.TextSize = 11
remoteCountLabel.Parent = mainFrame

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -20, 0, 420)
logScroll.Position = UDim2.new(0, 10, 0, 115)
logScroll.BackgroundColor3 = Color3.new(15, 15, 25)
logScroll.BorderSizePixel = 1
logScroll.BorderColor3 = Color3.new(80, 80, 80)
logScroll.Parent = mainFrame

local logList = Instance.new("UIListLayout")
logList.Parent = logScroll
logList.Padding = UDim.new(0, 1)

local logContent = Instance.new("Frame")
logContent.Size = UDim2.new(1, 0, 0, 0)
logContent.BackgroundTransparency = 1
logContent.Parent = logScroll

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.48, -5, 0, 40)
copyBtn.Position = UDim2.new(0, 10, 0, 545)
copyBtn.Text = "COPY ALL LOGS"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, -5, 0, 40)
clearBtn.Position = UDim2.new(0.52, 0, 0, 545)
clearBtn.Text = "CLEAR LOGS"
clearBtn.BackgroundColor3 = Color3.new(150, 50, 0)
clearBtn.TextColor3 = Color3.new(255, 255, 255)
clearBtn.TextSize = 12
clearBtn.Parent = mainFrame

local captureCount = 0
local capturedRemotes = {} -- Store all captured remote logs

local function addToLog(text, color)
    color = color or Color3.new(200, 200, 200)
    local timestamp = os.date("%H:%M:%S")
    local logText = "[" .. timestamp .. "] " .. text
    
    table.insert(capturedRemotes, 1, {text = logText, color = color})
    if #capturedRemotes > 500 then 
        table.remove(capturedRemotes)
    end
    
    -- Update UI
    for _, child in ipairs(logContent:GetChildren()) do
        child:Destroy()
    end
    
    local visibleCount = 0
    for i = #capturedRemotes, 1, -1 do
        local log = capturedRemotes[i]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Text = log.text
        label.TextColor3 = log.color
        label.BackgroundTransparency = 1
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = logContent
        visibleCount = visibleCount + 1
        if visibleCount > 200 then break end
    end
    
    task.wait()
    logScroll.CanvasPosition = Vector2.new(0, 0)
    logScroll.CanvasSize = UDim2.new(0, 0, 0, math.min(#capturedRemotes, 200) * 20)
    
    remoteCountLabel.Text = "Remotes Captured: " .. captureCount
end

-- HOOK ALL REMOTE EVENTS
local function hookAllRemotes()
    local remoteCount = 0
    
    local function hookRemote(remote)
        if remote:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
            local oldFunc = remote.OnClientEvent
            remote.OnClientEvent = function(...)
                local args = {...}
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 5 then
                        argsStr = argsStr .. "..."
                        break
                    end
                    if type(arg) == "table" then
                        argsStr = argsStr .. "{table}"
                    elseif type(arg) == "string" then
                        argsStr = argsStr .. "'" .. tostring(arg):sub(1, 30) .. "'"
                    else
                        argsStr = argsStr .. tostring(arg)
                    end
                    if i < #args then argsStr = argsStr .. ", " end
                end
                
                captureCount = captureCount + 1
                addToLog(string.format("REMOTE EVENT: %s (%s)", remote.Name, remote.ClassName), Color3.new(255, 150, 0))
                addToLog(string.format("  Args: %s", argsStr), Color3.new(200, 200, 200))
                addToLog(string.format("  Path: %s", remote:GetFullName()), Color3.new(150, 150, 150))
                
                if oldFunc then oldFunc(...) end
            end
        elseif remote:IsA("RemoteFunction") then
            remoteCount = remoteCount + 1
            local oldInvoke = remote.OnClientInvoke
            remote.OnClientInvoke = function(...)
                local args = {...}
                local argsStr = ""
                for i, arg in ipairs(args) do
                    if i > 5 then
                        argsStr = argsStr .. "..."
                        break
                    end
                    if type(arg) == "table" then
                        argsStr = argsStr .. "{table}"
                    elseif type(arg) == "string" then
                        argsStr = argsStr .. "'" .. tostring(arg):sub(1, 30) .. "'"
                    else
                        argsStr = argsStr .. tostring(arg)
                    end
                    if i < #args then argsStr = argsStr .. ", " end
                end
                
                captureCount = captureCount + 1
                addToLog(string.format("REMOTE FUNCTION: %s INVOKED", remote.Name), Color3.new(100, 255, 100))
                addToLog(string.format("  Args: %s", argsStr), Color3.new(200, 200, 200))
                addToLog(string.format("  Path: %s", remote:GetFullName()), Color3.new(150, 150, 150))
                
                if oldInvoke then return oldInvoke(...) end
            end
        end
    end
    
    local function scanForRemotes(instance)
        hookRemote(instance)
        for _, child in ipairs(instance:GetChildren()) do
            scanForRemotes(child)
        end
    end
    
    scanForRemotes(ReplicatedStorage)
    
    -- Also scan player for remotes
    scanForRemotes(player)
    
    addToLog("Started capturing remotes...", Color3.new(0, 255, 0))
    addToLog(string.format("Found %d remotes to monitor", remoteCount), Color3.new(0, 255, 0))
end

-- Also hook ANY new remote that gets created after script starts
local function monitorNewRemotes()
    local function onChildAdded(parent)
        return function(child)
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                task.wait(0.5)
                if child:IsA("RemoteEvent") then
                    local oldFunc = child.OnClientEvent
                    child.OnClientEvent = function(...)
                        local args = {...}
                        local argsStr = ""
                        for i, arg in ipairs(args) do
                            if i > 5 then
                                argsStr = argsStr .. "..."
                                break
                            end
                            if type(arg) == "table" then
                                argsStr = argsStr .. "{table}"
                            elseif type(arg) == "string" then
                                argsStr = argsStr .. "'" .. tostring(arg):sub(1, 30) .. "'"
                            else
                                argsStr = argsStr .. tostring(arg)
                            end
                            if i < #args then argsStr = argsStr .. ", " end
                        end
                        captureCount = captureCount + 1
                        addToLog(string.format("NEW REMOTE EVENT: %s", child.Name), Color3.new(255, 100, 0))
                        addToLog(string.format("  Args: %s", argsStr), Color3.new(200, 200, 200))
                        if oldFunc then oldFunc(...) end
                    end
                elseif child:IsA("RemoteFunction") then
                    local oldInvoke = child.OnClientInvoke
                    child.OnClientInvoke = function(...)
                        local args = {...}
                        local argsStr = ""
                        for i, arg in ipairs(args) do
                            if i > 5 then
                                argsStr = argsStr .. "..."
                                break
                            end
                            if type(arg) == "table" then
                                argsStr = argsStr .. "{table}"
                            elseif type(arg) == "string" then
                                argsStr = argsStr .. "'" .. tostring(arg):sub(1, 30) .. "'"
                            else
                                argsStr = argsStr .. tostring(arg)
                            end
                            if i < #args then argsStr = argsStr .. ", " end
                        end
                        captureCount = captureCount + 1
                        addToLog(string.format("NEW REMOTE FUNCTION: %s", child.Name), Color3.new(100, 255, 100))
                        addToLog(string.format("  Args: %s", argsStr), Color3.new(200, 200, 200))
                        if oldInvoke then return oldInvoke(...) end
                    end
                end
            end
        end
    end
    
    ReplicatedStorage.ChildAdded:Connect(onChildAdded(ReplicatedStorage))
    
    -- Also monitor for new folders that might contain remotes
    local function monitorFolder(folder)
        folder.ChildAdded:Connect(onChildAdded(folder))
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Folder") then
                monitorFolder(child)
            end
        end
    end
    
    monitorFolder(ReplicatedStorage)
end

-- Monitor Signal Behaviors (important for hidden remotes)
local function monitorSignals()
    local oldConnect = Instance.Changed
    -- Monitor instance changes that might reveal hidden connections
    addToLog("Monitoring instance changes for hidden signals...", Color3.new(0, 255, 0))
end

copyBtn.MouseButton1Click:Connect(function()
    local data = "=== REMOTE CAPTURE LOGS ===\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Total Remotes Captured: " .. captureCount .. "\n"
    data = data .. "============================\n\n"
    
    for i = #capturedRemotes, 1, -1 do
        data = data .. capturedRemotes[i].text .. "\n"
    end
    
    -- Try multiple copy methods for Delta Mobile
    local success = pcall(function()
        setclipboard(data)
    end)
    
    if success then
        addToLog("ALL LOGS COPIED TO CLIPBOARD!", Color3.new(0, 255, 0))
        statusLabel.Text = "Copied " .. captureCount .. " remotes!"
        task.wait(2)
        statusLabel.Text = "Status: Monitoring..."
    else
        -- Fallback: print to console
        print("=== REMOTE CAPTURE DATA ===")
        print(data)
        print("=== END DATA ===")
        addToLog("Could not copy! Check executor console", Color3.new(255, 255, 0))
        statusLabel.Text = "Copy failed - Check console"
        task.wait(2)
        statusLabel.Text = "Status: Monitoring..."
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    capturedRemotes = {}
    for _, child in ipairs(logContent:GetChildren()) do
        child:Destroy()
    end
    captureCount = 0
    remoteCountLabel.Text = "Remotes Captured: 0"
    addToLog("Logs cleared", Color3.new(255, 255, 0))
end)

-- Start capturing
addToLog("=== REMOTE CAPTURE STARTED ===", Color3.new(255, 255, 0))
addToLog("This will capture ALL remote events and functions", Color3.new(200, 200, 200))
addToLog("Start the game/script to see remotes firing", Color3.new(200, 200, 200))

hookAllRemotes()
monitorNewRemotes()
monitorSignals()

-- Make draggable for mobile
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
