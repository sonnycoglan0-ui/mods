-- ⚠️ Requires Executor — Action Monitor v2
-- Uses hookmetamethod on __namecall — the correct way to intercept FireServer/InvokeServer
-- Mobile: tap the floating button to toggle. No keyboard needed.

-- ============ SERVICES ============
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============ CHECK EXECUTOR FUNCTIONS ============
if not hookmetamethod or not getnamecallmethod then
    warn("[ActionMonitor] This executor does not support hookmetamethod/getnamecallmethod.")
    return
end

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ActionMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Main window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.03, 0, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 110)
stroke.Thickness = 1.5
stroke.Parent = Main

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Action Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Clear button
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 60, 0, 26)
ClearBtn.Position = UDim2.new(1, -68, 0.5, -13)
ClearBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
ClearBtn.Parent = TitleBar
local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = ClearBtn

-- Log container
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -12, 1, -46)
LogFrame.Position = UDim2.new(0, 6, 0, 42)
LogFrame.BackgroundTransparency = 1
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 3)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = LogFrame

-- Floating toggle button (mobile friendly)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.82, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 200)
ToggleBtn.Text = "👁"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = ToggleBtn
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(100, 160, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = ToggleBtn

-- ============ LOGGING ============
local LogCount = 0
local MaxLogs = 80

local function FormatValue(v)
    local t = typeof(v)
    if t == "string" then
        return '"' .. v .. '"'
    elseif t == "number" then
        return tostring(math.floor(v * 1000) / 1000)
    elseif t == "Instance" then
        return v.Name .. " (" .. v.ClassName .. ")"
    elseif t == "Vector3" then
        return string.format("Vector3(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then
        local p = v.Position
        return string.format("CFrame(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
    elseif t == "boolean" then
        return tostring(v)
    elseif t == "nil" then
        return "nil"
    else
        return tostring(v)
    end
end

local function FormatArgs(...)
    local args = {...}
    if #args == 0 then return "(no args)" end
    local parts = {}
    for i, v in ipairs(args) do
        table.insert(parts, "[" .. i .. "]=" .. FormatValue(v))
    end
    return table.concat(parts, "  ")
end

local function AddLog(text, color)
    LogCount = LogCount + 1
    local Entry = Instance.new("TextLabel")
    Entry.LayoutOrder = LogCount
    Entry.Size = UDim2.new(1, -6, 0, 0)
    Entry.AutomaticSize = Enum.AutomaticSize.Y
    Entry.BackgroundTransparency = 1
    Entry.Text = text
    Entry.TextColor3 = color or Color3.fromRGB(190, 190, 200)
    Entry.Font = Enum.Font.Code
    Entry.TextSize = 11
    Entry.TextWrapped = true
    Entry.TextXAlignment = Enum.TextXAlignment.Left
    Entry.Parent = LogFrame

    -- Auto-scroll to bottom
    task.wait(0.01)
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    LogFrame.CanvasPosition = Vector2.new(0, ListLayout.AbsoluteContentSize.Y)

    -- Trim old entries
    local children = LogFrame:GetChildren()
    local labels = {}
    for _, c in ipairs(children) do
        if c:IsA("TextLabel") then table.insert(labels, c) end
    end
    if #labels > MaxLogs then
        table.sort(labels, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        labels[1]:Destroy()
    end
end

-- ============ THE HOOK — CORRECT METHOD ============
-- Save original __namecall
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- FireServer (RemoteEvent)
    if method == "FireServer" and self:IsA("RemoteEvent") then
        AddLog("▶ FireServer: " .. self.Name, Color3.fromRGB(100, 200, 255))
        AddLog("   Args: " .. FormatArgs(...), Color3.fromRGB(140, 140, 160))
    end

    -- InvokeServer (RemoteFunction)
    if method == "InvokeServer" and self:IsA("RemoteFunction") then
        AddLog("▶ InvokeServer: " .. self.Name, Color3.fromRGB(255, 180, 100))
        AddLog("   Args: " .. FormatArgs(...), Color3.fromRGB(140, 140, 160))
        local results = {oldNamecall(self, ...)}
        AddLog("   ↩ Return: " .. FormatArgs(unpack(results)), Color3.fromRGB(100, 255, 150))
        return unpack(results)
    end

    return oldNamecall(self, ...)
end)

-- Also hook FireServer directly on instances (some executors need this)
pcall(function()
    local oldFire = Instance.new("RemoteEvent").FireServer
    -- Not all executors support this; __namecall covers most cases
end)

-- ============ TOGGLE ============
local visible = false
local function Toggle()
    visible = not visible
    Main.Visible = visible
end

ToggleBtn.MouseButton1Click:Connect(Toggle)
ClearBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(LogFrame:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    LogCount = 0
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Keyboard toggle too (F9) if device has keyboard
if UserInputService.KeyboardEnabled then
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.F9 then
            Toggle()
        end
    end)
end

-- ============ START ============
AddLog("=== Monitor Active ===", Color3.fromRGB(100, 255, 120))
AddLog("Tap 👁 button to show/hide", Color3.fromRGB(150, 150, 170))
AddLog("Do something in game → watch here", Color3.fromRGB(150, 150, 170))
print("[ActionMonitor] Loaded. Hooked __namecall.")
