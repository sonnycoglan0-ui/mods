-- ⚠️ Requires Executor — Action Monitor v4
-- Uses hookfunction on FireServer/InvokeServer ONLY — zero lag, movement unaffected.
-- Mobile: tap 👁 to toggle. Long-press any log line to select & copy text.
-- Copy All button copies entire log.

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not hookfunction then
    warn("[ActionMonitor] This executor does not support hookfunction.")
    return
end

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ActionMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 330, 0, 400)
Main.Position = UDim2.new(0.03, 0, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local st = Instance.new("UIStroke", Main)
st.Color = Color3.fromRGB(70, 70, 110); st.Thickness = 1.5

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -140, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Action Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Copy All button
local CopyAllBtn = Instance.new("TextButton")
CopyAllBtn.Size = UDim2.new(0, 60, 0, 26)
CopyAllBtn.Position = UDim2.new(1, -134, 0.5, -13)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 160)
CopyAllBtn.Text = "Copy All"
CopyAllBtn.TextColor3 = Color3.new(1,1,1)
CopyAllBtn.Font = Enum.Font.Gotham
CopyAllBtn.TextSize = 11
CopyAllBtn.Parent = TitleBar
Instance.new("UICorner", CopyAllBtn).CornerRadius = UDim.new(0, 6)

-- Clear button
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 56, 0, 26)
ClearBtn.Position = UDim2.new(1, -66, 0.5, -13)
ClearBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
ClearBtn.Parent = TitleBar
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

-- Log container
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

-- Toggle button
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

-- ============ LOGGING ============
local LogQueue = {}
local FullLog = {}  -- for Copy All
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

-- Process queue — separate loop, throttled
task.spawn(function()
    while true do
        task.wait(0.2)
        if #LogQueue == 0 then continue end

        for _, entry in ipairs(LogQueue) do
            LogCount = LogCount + 1
            -- Use TextBox so text is SELECTABLE + COPYABLE on mobile
            local box = Instance.new("TextBox")
            box.LayoutOrder = LogCount
            box.Size = UDim2.new(1, -6, 0, 0)
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.BackgroundTransparency = 1
            box.Text = entry.text
            box.TextColor3 = entry.color
            box.Font = Enum.Font.Code
            box.TextSize = 11
            box.TextWrapped = true
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.ReadOnly = true  -- can't edit, but CAN select + copy
            box.MultiLine = true
            box.Parent = LogFrame
        end
        table.clear(LogQueue)

        -- Trim old
        local labels = {}
        for _,c in ipairs(LogFrame:GetChildren()) do
            if c:IsA("TextBox") then table.insert(labels, c) end
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
    table.insert(FullLog, text)
    if #FullLog > 500 then table.remove(FullLog, 1) end
end

-- ============ THE HOOKS — ONLY FireServer + InvokeServer ============
-- This is the fix: hookfunction only triggers on actual remote calls.
-- Movement, input, physics calls are NOT intercepted at all.

-- Hook FireServer (RemoteEvent)
local oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
    local ok, args = pcall(FormatArgs, ...)
    PushLog("FireServer: " .. (self.Name or "?"), Color3.fromRGB(100,200,255))
    if ok then PushLog("  -> " .. args, Color3.fromRGB(140,140,160)) end
    return oldFireServer(self, ...)
end)

-- Hook InvokeServer (RemoteFunction)
local oldInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
    local ok, args = pcall(FormatArgs, ...)
    PushLog("InvokeServer: " .. (self.Name or "?"), Color3.fromRGB(255,180,100))
    if ok then PushLog("  -> " .. args, Color3.fromRGB(140,140,160)) end
    local results = {oldInvokeServer(self, ...)}
    local ok2, ret = pcall(FormatArgs, unpack(results))
    if ok2 then PushLog("  <- " .. ret, Color3.fromRGB(100,255,150)) end
    return unpack(results)
end)

-- Also hook fireproximityprompt (executor function) if it exists
if fireproximityprompt then
    local oldFPP = hookfunction(fireproximityprompt, function(prompt, ...)
        PushLog("fireproximityprompt: " .. (prompt and prompt.Name or "?"), Color3.fromRGB(255,120,200))
        return oldFPP(prompt, ...)
    end)
end

-- ============ BUTTONS ============
local visible = false
local function Toggle()
    visible = not visible
    Main.Visible = visible
end
ToggleBtn.MouseButton1Click:Connect(Toggle)

ClearBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(LogFrame:GetChildren()) do
        if c:IsA("TextBox") then c:Destroy() end
    end
    LogCount = 0
    table.clear(FullLog)
    LogFrame.CanvasSize = UDim2.new(0,0,0,0)
end)

CopyAllBtn.MouseButton1Click:Connect(function()
    local text = table.concat(FullLog, "\n")
    if setclipboard then
        setclipboard(text)
        PushLog("[Copied " .. #FullLog .. " lines to clipboard]", Color3.fromRGB(100,255,120))
    else
        PushLog("[setclipboard not supported — long-press lines to copy manually]", Color3.fromRGB(255,200,100))
    end
end)

if UserInputService.KeyboardEnabled then
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.F9 then Toggle() end
    end)
end

PushLog("=== Monitor Active (v4 — no lag) ===", Color3.fromRGB(100,255,120))
PushLog("Tap 👁 to show/hide. Long-press lines to copy.", Color3.fromRGB(150,150,170))
print("[ActionMonitor v4] Loaded — FireServer + InvokeServer hooked.")
