-- SC'S Auto Shot 💪
-- Rounded rectangle | Blue→Green gradient | Minimize button | 2s cooldown
-- ⚠️ Executor-only (CoreGui parenting)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RequestShot = ReplicatedStorage:WaitForChild("Net"):WaitForChild("RequestShot")
local SHOT_VALUE = 99.64208230376227
local COOLDOWN = 2

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SCAutoShot"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main window (rounded rectangle)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 140)
Main.Position = UDim2.new(0.03, 0, 0.65, 0)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 152, 219)),  -- Blue (top)
    ColorSequenceKeypoint.new(1, Color3.fromRGB(46, 204, 113))   -- Green (bottom)
}
Gradient.Parent = Main

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SC'S Auto Shot 💪"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 24)
MinBtn.Position = UDim2.new(1, -34, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
MinBtn.BackgroundTransparency = 0.85
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Body (hides when minimized)
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -42)
Body.Position = UDim2.new(0, 0, 0, 38)
Body.BackgroundTransparency = 1
Body.Parent = Main

-- Fire button
local FireBtn = Instance.new("TextButton")
FireBtn.Size = UDim2.new(0.7, 0, 0, 44)
FireBtn.Position = UDim2.new(0.15, 0, 0, 8)
FireBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
FireBtn.BackgroundTransparency = 0.8
FireBtn.Text = "🔥 FIRE"
FireBtn.TextColor3 = Color3.new(1,1,1)
FireBtn.Font = Enum.Font.GothamBold
FireBtn.TextSize = 16
FireBtn.AutoButtonColor = false
FireBtn.Parent = Body
Instance.new("UICorner", FireBtn).CornerRadius = UDim.new(0, 10)

-- Cooldown bar (2s timer)
local CooldownBar = Instance.new("Frame")
CooldownBar.Size = UDim2.new(0.7, 0, 0, 8)
CooldownBar.Position = UDim2.new(0.15, 0, 0, 62)
CooldownBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
CooldownBar.BackgroundTransparency = 0.85
CooldownBar.Parent = Body
Instance.new("UICorner", CooldownBar).CornerRadius = UDim.new(1, 0)

local CooldownFill = Instance.new("Frame")
CooldownFill.Size = UDim2.new(0, 0, 1, 0)
CooldownFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
CooldownFill.BackgroundTransparency = 0.5
CooldownFill.Parent = CooldownBar
Instance.new("UICorner", CooldownFill).CornerRadius = UDim.new(1, 0)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 16)
Status.Position = UDim2.new(0, 0, 0, 76)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(220,255,220)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = Body

-- ============ LOGIC ============
local onCooldown = false
local minimized = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible = false
        Main.Size = UDim2.new(0, 240, 0, 40)
        MinBtn.Text = "+"
    else
        Body.Visible = true
        Main.Size = UDim2.new(0, 240, 0, 140)
        MinBtn.Text = "—"
    end
end)

FireBtn.MouseButton1Click:Connect(function()
    if onCooldown then return end
    onCooldown = true

    pcall(function()
        RequestShot:InvokeServer(SHOT_VALUE)
    end)

    FireBtn.Text = "⏳ 2.0s"
    Status.Text = "Shot fired — cooldown"

    local start = tick()
    while tick() - start < COOLDOWN do
        local elapsed = tick() - start
        local remaining = COOLDOWN - elapsed
        FireBtn.Text = "⏳ " .. string.format("%.1f", remaining) .. "s"
        CooldownFill.Size = UDim2.new(elapsed / COOLDOWN, 0, 1, 0)
        task.wait(0.05)
    end

    CooldownFill.Size = UDim2.new(0, 0, 1, 0)
    FireBtn.Text = "🔥 FIRE"
    Status.Text = "Ready"
    onCooldown = false
end)

print("SC'S Auto Shot loaded")