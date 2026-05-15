--// RSPY-STYLE REMOTE MONITOR FOR DELTA MOBILE
--// This mimics how RSPY captures remotes

pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RSPYStyle"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 255, 0)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "RSPY STYLE - REMOTE LISTER"
title.TextColor3 = Color3.new(0, 255, 0)
title.BackgroundColor3 = Color3.new(30, 30, 30)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.3, 0, 0, 30)
refreshBtn.Position = UDim2.new(0.35, 0, 0, 45)
refreshBtn.Text = "REFRESH LIST"
refreshBtn.BackgroundColor3 = Color3.new(0, 100, 0)
refreshBtn.TextColor3 = Color3.new(255, 255, 255)
refreshBtn.TextSize = 12
refreshBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.3, 0, 0, 30)
copyBtn.Position = UDim2.new(0.68, 0, 0, 45)
copyBtn.Text = "COPY ALL"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local remoteScroll = Instance.new("ScrollingFrame")
remoteScroll.Size = UDim2.new(1, -20, 0, 480)
remoteScroll.Position = UDim2.new(0, 10, 0, 85)
remoteScroll.BackgroundColor3 = Color3.new(15, 15, 25)
remoteScroll.BorderSizePixel = 1
remoteScroll.BorderColor3 = Color3.new(80, 80, 80)
remoteScroll.Parent = mainFrame

local remoteList = Instance.new("UIListLayout")
remoteList.Parent = remoteScroll
remoteList.Padding = UDim.new(0, 2)

local remoteContent = Instance.new("Frame")
remoteContent.Size = UDim2.new(1, 0, 0, 0)
remoteContent.BackgroundTransparency = 1
remoteContent.Parent = remoteScroll

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 575)
statusLabel.Text = "Status: Ready. Click REFRESH to scan all remotes"
statusLabel.TextColor3 = Color3.new(0, 255, 0)
statusLabel.BackgroundColor3 = Color3.new(20, 20, 30)
statusLabel.TextSize = 10
statusLabel.Parent = mainFrame

local allRemotes = {}

local function addRemoteToList(name, remoteType, path, parent)
    table.insert(allRemotes, {
        name = name,
        type = remoteType,
        path = path,
        parent = parent
    })
end

local function scanAllRemotes()
    -- Clear previous list
    allRemotes = {}
    for _, child in ipairs(remoteContent:GetChildren()) do
        child:Destroy()
    end
    
    local function scanInstance(instance, currentPath)
        for _, child in ipairs(instance:GetChildren()) do
            local childPath = currentPath .. "/" .. child.Name
            if child:IsA("RemoteEvent") then
                addRemoteToList(child.Name, "RemoteEvent", childPath, instance.Name)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -10, 0, 20)
                label.Text = string.format("[EVENT] %s", child.Name)
                label.TextColor3 = Color3.new(255, 200, 100)
                label.BackgroundTransparency = 1
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = remoteContent
            elseif child:IsA("RemoteFunction") then
                addRemoteToList(child.Name, "RemoteFunction", childPath, instance.Name)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -10, 0, 20)
                label.Text = string.format("[FUNCTION] %s", child.Name)
                label.TextColor3 = Color3.new(100, 255, 100)
                label.BackgroundTransparency = 1
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = remoteContent
            elseif child:IsA("Folder") or child:IsA("Model") then
                -- Add folder label
                local folderLabel = Instance.new("TextLabel")
                folderLabel.Size = UDim2.new(1, -10, 0, 18)
                folderLabel.Text = string.format("📁 %s/", child.Name)
                folderLabel.TextColor3 = Color3.new(255, 255, 0)
                folderLabel.BackgroundTransparency = 1
                folderLabel.TextSize = 10
                folderLabel.TextXAlignment = Enum.TextXAlignment.Left
                folderLabel.Font = Enum.Font.SourceSansBold
                folderLabel.Parent = remoteContent
                
                -- Recursively scan inside folder
                scanInstance(child, childPath)
            else
                -- Scan other instances
                scanInstance(child, childPath)
            end
        end
    end
    
    -- Start scanning from ReplicatedStorage
    local header1 = Instance.new("TextLabel")
    header1.Size = UDim2.new(1, -10, 0, 22)
    header1.Text = "=== REPLICATEDSTORAGE ==="
    header1.TextColor3 = Color3.new(0, 255, 255)
    header1.BackgroundTransparency = 1
    header1.TextSize = 12
    header1.TextXAlignment = Enum.TextXAlignment.Left
    header1.Font = Enum.Font.SourceSansBold
    header1.Parent = remoteContent
    
    scanInstance(ReplicatedStorage, "ReplicatedStorage")
    
    -- Scan player for remotes
    local header2 = Instance.new("TextLabel")
    header2.Size = UDim2.new(1, -10, 0, 22)
    header2.Position = UDim2.new(0, 0, 0, 20)
    header2.Text = "=== PLAYER OBJECTS ==="
    header2.TextColor3 = Color3.new(0, 255, 255)
    header2.BackgroundTransparency = 1
    header2.TextSize = 12
    header2.TextXAlignment = Enum.TextXAlignment.Left
    header2.Font = Enum.Font.SourceSansBold
    header2.Parent = remoteContent
    
    scanInstance(player, "Player")
    
    -- Scan workspace for any remotes (some games put them there)
    local header3 = Instance.new("TextLabel")
    header3.Size = UDim2.new(1, -10, 0, 22)
    header3.Text = "=== WORKSPACE ==="
    header3.TextColor3 = Color3.new(0, 255, 255)
    header3.BackgroundTransparency = 1
    header3.TextSize = 12
    header3.TextXAlignment = Enum.TextXAlignment.Left
    header3.Font = Enum.Font.SourceSansBold
    header3.Parent = remoteContent
    
    scanInstance(workspace, "Workspace")
    
    statusLabel.Text = string.format("Found %d remotes", #allRemotes)
    statusLabel.TextColor3 = Color3.new(0, 255, 0)
    
    -- Auto-scroll to top
    task.wait()
    remoteScroll.CanvasPosition = Vector2.new(0, 0)
    remoteScroll.CanvasSize = UDim2.new(0, 0, 0, remoteContent.AbsoluteSize.Y)
end

-- Function to copy all data
local function copyAllData()
    local data = "=== RSPY REMOTE LIST ===\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Total Remotes Found: " .. #allRemotes .. "\n"
    data = data .. "========================\n\n"
    
    for _, remote in ipairs(allRemotes) do
        data = data .. string.format("[%s] %s\n", remote.type, remote.name)
        data = data .. "  Path: " .. remote.path .. "\n"
        data = data .. "  Parent: " .. remote.parent .. "\n\n"
    end
    
    pcall(function()
        setclipboard(data)
        statusLabel.Text = "Copied " .. #allRemotes .. " remotes to clipboard!"
        task.wait(2)
        statusLabel.Text = string.format("Found %d remotes. Click REFRESH to rescan", #allRemotes)
    end)
end

refreshBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "Scanning for remotes..."
    statusLabel.TextColor3 = Color3.new(255, 255, 0)
    scanAllRemotes()
end)

copyBtn.MouseButton1Click:Connect(function()
    copyAllData()
end)

-- Initial scan
scanAllRemotes()

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

end)
