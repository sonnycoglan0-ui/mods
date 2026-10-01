-- ⚠️ Requires Executor — Action Monitor v3 (Lag-Free)
-- Hook is instant (zero overhead). Logging is queued and processed separately.
-- Mobile: tap 👁 button to toggle. Draggable window.

local UserInputService = game:GetService("UserInputService")

if not hookmetamethod or not getnamecallmethod then
    warn("[ActionMonitor] Executor missing hookmetamethod/getnamecallmethod.")
    return
end

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ActionMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.03, 0, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local st = Instance.new("UIStroke", Main)
st.Color = Color3.fromRGB(70, 70, 110); st.Thickness = 1.5

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

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

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 60, 0, 26)
ClearBtn.Position = UDim2.new(1, -68, 0.5, -13)
ClearBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
ClearBtn.Parent = TitleBar
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -12, 1, -46)
LogFrame.Position = UDim2.new(0, 6, 0, 42)
LogFrame.BackgroundTransparency = 1
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.CanvasSize = UDim2.new(0,0,0,0)
LogFrame.Parent = Main
local ListLayout = Instance.new("UIListLayout", LogFrame)
ListLayout.Padding = UDim.new(0, 3)

-- Toggle button (mobile friendly)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.82, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 200)
ToggleBtn.Text = "👁"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ts = Instance.new("UIStroke", ToggleBtn)
ts.Color = Color3.fromRGB(100,160,255); ts.Thickness = 2

-- ============ LOG QUEUE (no UI work inside hook) ============
local LogQueue = {}
local MaxLogs = 60
local LogCount = 0

local function FormatValue(v)
    local t = typeof(v)
    if t == "string" then return '"'..v..'"'
    elseif t == "number" then return tostring(math.floor(v*1000)/1000)
    elseif t == "Instance" then return v.Name.."("..v.ClassName..")"
    elseif t == "Vector3" then return string.format("Vec(%.0f,%.0f,%.0f)",v.X,v.Y,v.Z)
    elseif t == "boolean" then return tostring(v)
    elseif t == "nil" then return "nil"
    else return tostring(v) end
end

local function FormatArgs(...)
    local args = {...}
    if #args == 0 then return "(none)" end
    local parts = {}
    for i,v in ipairs(args) do table.insert(parts, "["..i.."]="..FormatValue(v)) end
    return table.concat(parts, " ")
end

-- Process queue in separate loop — never inside the hook
task.spawn(function()
    while true do
        task.wait(0.15) -- throttle UI updates
        if #LogQueue == 0 then continue end

        for _, entry in ipairs(LogQueue) do
            LogCount = LogCount + 1
            local lbl = Instance.new("TextLabel")
            lbl.LayoutOrder = LogCount
            lbl.Size = UDim2.new(1, -6, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.BackgroundTransparency = 1
            lbl.Text = entry.text
            lbl.TextColor3 = entry.color
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 11
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = LogFrame
        end
        table.clear(LogQueue)

        -- Trim + scroll
        local labels = {}
        for _,c in ipairs(LogFrame:GetChildren()) do
            if c:IsA("TextLabel") then table.insert(labels, c) end
        end
        if #labels > MaxLogs then
            table.sort(labels, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
            for i = 1, #labels - MaxLogs do labels[i]:Destroy() end
        end
        LogFrame.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y)
        LogFrame.CanvasPosition = Vector2.new(0, ListLayout.AbsoluteContentSize.Y)
    end
end)

local function PushLog(text, color)
    table.insert(LogQueue, {text = text, color = color or Color3.fromRGB(190,190,200)})
end

-- ============ THE HOOK — INSTANT, ZERO OVERHEAD ============
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    -- Instant check — if not a remote call, pass through with zero work
    local method = getnamecallmethod()
    if method == "FireServer" and self:IsA("RemoteEvent") then
        -- Queue only — no UI, no string concat heavy work here
        local ok, args = pcall(FormatArgs, ...)
        PushLog("FireServer: "..self.Name, Color3.fromRGB(100,200,255))
        if ok then PushLog("  -> "..args, Color3.fromRGB(140,140,160)) end
    elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
        local ok, args = pcall(FormatArgs, ...)
        PushLog("InvokeServer: "..self.Name, Color3.fromRGB(255,180,100))
        if ok then PushLog("  -> "..args, Color3.fromRGB(140,140,160)) end
        local results = {oldNamecall(self, ...)}
        local ok2, ret = pcall(FormatArgs, unpack(results))
        if ok2 then PushLog("  <- "..ret, Color3.fromRGB(100,255,150)) end
        return unpack(results)
    end
    -- Everything else passes through instantly
    return oldNamecall(self, ...)
end)

-- ============ TOGGLE ============
local visible = false
local function Toggle()
    visible = not visible
    Main.Visible = visible
end
ToggleBtn.MouseButton1Click:Connect(Toggle)
ClearBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(LogFrame:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    LogCount = 0
    LogFrame.CanvasSize = UDim2.new(0,0,0,0)
end)
if UserInputService.KeyboardEnabled then
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.F9 then Toggle() end
    end)
end

PushLog("=== Monitor Active ===", Color3.fromRGB(100,255,120))
PushLog("Tap 👁 to show/hide", Color3.fromRGB(150,150,170))
print("[ActionMonitor v3] Loaded — lag-free hook active.")
