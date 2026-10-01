-- ⚠️ Requires Executor — Action Monitor (Mobile Friendly)
-- Toggles: Tap floating button or press F9 to show/hide
-- Output: Shows RemoteEvents, arguments, and timing

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local LogContainer = Instance.new("ScrollingFrame")
local ToggleBtn = Instance.new("TextButton")
local ClearBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

-- Properties
ScreenGui.Name = "ActionMonitor"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "📡 Action Monitor"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

ClearBtn.Name = "ClearBtn"
ClearBtn.Size = UDim2.new(0, 70, 0, 30)
ClearBtn.Position = UDim2.new(1, -75, 0, 2)
ClearBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
ClearBtn.Parent = Title

LogContainer.Name = "LogContainer"
LogContainer.Size = UDim2.new(1, -10, 1, -45)
LogContainer.Position = UDim2.new(0, 5, 0, 40)
LogContainer.BackgroundTransparency = 1
LogContainer.ScrollBarThickness = 4
LogContainer.Parent = MainFrame

UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = LogContainer
LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.85, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
ToggleBtn.Text = "👁️"
ToggleBtn.TextSize = 28
ToggleBtn.Parent = ScreenGui

-- State
local LogEntries = {}
local isVisible = false

-- Add log entry
local function AddLog(text, color)
    color = color or Color3.fromRGB(200, 200, 200)
    
    local Entry = Instance.new("TextLabel")
    Entry.Size = UDim2.new(1, -8, 0, 0)
    Entry.AutomaticSize = Enum.AutomaticSize.Y
    Entry.BackgroundTransparency = 1
    Entry.Text = text
    Entry.TextColor3 = color
    Entry.Font = Enum.Font.Gotham
    Entry.TextSize = 11
    Entry.TextWrapped = true
    Entry.TextXAlignment = Enum.TextXAlignment.Left
    Entry.Parent = LogContainer
    
    table.insert(LogEntries, Entry)
    
    -- Limit log size
    if #LogEntries > 50 then
        LogEntries[1]:Destroy()
        table.remove(LogEntries, 1)
    end
    
    task.wait(0.01)
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    LogContainer.ScrollPosition = LogContainer.CanvasSize.Y.Offset
end

-- Format arguments safely
local function FormatArgs(...)
    local args = {...}
    if #args == 0 then return "None" end
    local parts = {}
    for i, v in ipairs(args) do
        local val
        if type(v) == "string" then
            val = "\"" .. v .. "\""
        elseif type(v) == "number" then
            val = tostring(math.floor(v * 100) / 100)
        elseif typeof(v) == "Instance" then
            val = v.Name .. " (" .. v.ClassName .. ")"
        else
            val = tostring(v)
        end
        table.insert(parts, "[" .. i .. "] " .. val)
    end
    return table.concat(parts, ", ")
end

-- Toggle visibility
local function ToggleUI()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
end

-- Connections
ToggleBtn.MouseButton1Click:Connect(ToggleUI)
if game:GetService("UserInputService").KeyboardEnabled then
    game:GetService("UserInputService").InputBegan:Connect(function(Input, gp)
        if not gp and Input.KeyCode == Enum.KeyCode.F9 then
            ToggleUI()
        end
    end)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(LogEntries) do v:Destroy() end
    table.clear(LogEntries)
end)

-- ⚠️ Executor-Only Feature — Hook RemoteEvents
-- Watches ALL RemoteEvents and RemoteFunctions being used in-game
local OldFireServer
local OldInvokeServer

pcall(function()
    local mt = getmetatable(game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent") or Instance.new("RemoteEvent"))
    OldFireServer = mt.__index.FireServer
    mt.__index.FireServer = function(self, ...)
        local args = FormatArgs(...)
        AddLog("▶️ RemoteEvent: " .. self.Name, Color3.fromRGB(100, 200, 255))
        AddLog("   Sent: " .. args, Color3.fromRGB(160, 160, 160))
        return OldFireServer(self, ...)
    end
end)

pcall(function()
    local mt = getmetatable(game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteFunction") or Instance.new("RemoteFunction"))
    OldInvokeServer = mt.__index.InvokeServer
    mt.__index.InvokeServer = function(self, ...)
        local args = FormatArgs(...)
        AddLog("▶️ RemoteFunction: " .. self.Name, Color3.fromRGB(255, 180, 100))
        AddLog("   Sent: " .. args, Color3.fromRGB(160, 160, 160))
        local results = {OldInvokeServer(self, ...)}
        AddLog("   Received: " .. FormatArgs(unpack(results)), Color3.fromRGB(100, 255, 150))
        return unpack(results)
    end
end)

-- Initial
AddLog("✅ Action Monitor Started", Color3.fromRGB(100, 255, 100))
AddLog("👁️ Tap blue button to show/hide", Color3.fromRGB(150, 150, 150))
AddLog("Perform an action in-game — watch this window", Color3.fromRGB(150, 150, 150))
