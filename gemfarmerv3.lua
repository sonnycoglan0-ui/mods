-- Sonny's Gem Farmer — NO original UI code at all.
-- Farming logic kept identical. Only Sonny's green/blue UI shows.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ SONNY'S UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 135)
Main.Position = UDim2.new(0.02, 0, 0.70, 0)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 204, 113)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 152, 219))
}
Gradient.Parent = Main
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "💎 Sonny's Gem Farmer"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 18)
Status.Position = UDim2.new(0, 0, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Main

local Count = Instance.new("TextLabel")
Count.Size = UDim2.new(1, 0, 0, 18)
Count.Position = UDim2.new(0, 0, 0, 58)
Count.BackgroundTransparency = 1
Count.Text = "Gems: 0"
Count.TextColor3 = Color3.fromRGB(200, 255, 200)
Count.Font = Enum.Font.Gotham
Count.TextSize = 11
Count.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.75, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.125, 0, 0, 88)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

local running = false
ToggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if _G.GFState then _G.GFState.AutoFarmGems = running end
    if running then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
        Status.Text = "Farming..."
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Status.Text = "Stopped"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.GFState then
            Count.Text = "Gems: " .. tostring(_G.GFState.TotalFarmedGems or 0)
        end
    end
end)

-- ============ FARMING LOGIC ONLY — NO UI ============
local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v112,v113) local v114={};for v142=1, #v112 do v6(v114,v0(v4(v1(v2(v112,v142,v142 + 1 )),v1(v2(v113,1 + (v142% #v113) ,1 + (v142% #v113) + 1 )))%256 ));end return v5(v114);end
local v8=game:GetService(v7("\242\204\201\32\193\174\206","\126\177\163\187\69\134\219\167"))
local v9=game:GetService(v7("\19\193\43\220\249\49\222","\156\67\173\74\165"))
local v10=game:GetService(v7("\6\162\71\37\185\52\80\61\180\76","\38\84\215\41\118\220\70"))
local v13=game:GetService(v7("\116\216\38\240\73\123\228\236\67\217\5\232\79\106\228\255\67","\152\38\189\86\156\32\24\133"))
local v14=game:GetService(v7("\203\88\181\77\239\71\166\69\249","\38\156\55\199"))
local v15=v9.LocalPlayer
local v16=v15:WaitForChild(v7("\152\113\125\49\22\102\221\86\161","\35\200\29\28\72\115\20\154"))

-- State (exposed for Sonny's button)
_G.GFState = {
    [v7("\226\26\150\248\236\194\29\143\208\207\206\28","\170\163\111\226\151")]=false,
    [v7("\37\63\166\57\66\17\40\3\61\183\60\105\50\36\2","\73\113\80\210\88\46\87")]=584 -(57 + 527)
}
local v104 = _G.GFState

-- Remotes
local v106=v13:WaitForChild(v7("\159\224\194\195\62\203","\30\222\146\161\162\90\174\210"))
local v107=v106:WaitForChild(v7("\196\92\115\11\225\75\66\15\245\65\98\30","\106\133\46\16"))
local v108=v106:WaitForChild(v7("\121\50\112\253\94\69\107\37\96\239\83\79\86","\32\56\64\19\156\58"))

-- Camera fly bypass
pcall(function()
    local v138=require(v106:WaitForChild(v7("\123\218\230\87\94\247\163\85\198\227\95\93","\224\58\168\133\54\58\146")))
    v138.Machine.CameraFlyTime=0
end)

-- Anti-cheat bypass every frame
v10.RenderStepped:Connect(function()
    if v104.AutoFarmGems then
        local v147=v16:FindFirstChild(v7("\29\189\130\77\231\124\75\63\189\132\73\237","\24\92\207\225\44\131\25"))
        if v147 and v147.Enabled then v147.Enabled=false end
        v15:SetAttribute(v7("\120\68\72\252\113\131\183\7\88\79\66\243\114","\107\57\54\43\157\21\230\231"),nil)
        v15:SetAttribute(v7("\245\142\20\241\181\217\230\213\155\4\225\149\211\204\208\142\21","\175\187\235\113\149\217\188"),nil)
    end
end)

-- Gem prompt finder (cached)
local v109=nil
local function v110()
    if v109 and v109.Parent then return v109 end
    local v140=v14:FindFirstChild(v7("\106\193\187\77\31\120\11\254\185\79\19\116\69\214","\29\43\179\216\44\123"),true)
    if v140 then v109=v140:FindFirstChild(v7("\141\213\33\85\141\203\47\65\173\205","\44\221\185\64"),true) end
    if not v109 then
        for v189,v190 in ipairs(v14:GetDescendants()) do
            if v190:IsA(v7("\49\245\71\71\122\12\238\92\70\67\19\232\69\79\103","\19\97\135\40\63")) and v190.Name==v7("\158\80\50\34\31\35\161\81\35\47","\81\206\60\83\91\79") then
                v109=v190 break
            end
        end
    end
    if v109 then
        v109.HoldDuration=0
        v109.MaxActivationDistance=math.huge
        v109.RequiresLineOfSight=false
        v109.ClickablePrompt=true
    end
    return v109
end

-- Farming worker — loop condition changed from "v18 exists" to true (no UI to check)
local function v111()
    task.spawn(function()
        while true do
            if v104.AutoFarmGems then
                pcall(function()
                    local v187=v110()
                    if v187 then
                        if fireproximityprompt then fireproximityprompt(v187,0)
                        else v187:InputHoldBegin(); v187:InputHoldEnd() end
                    end
                    v107:FireServer(v7("\69\162\220\126\60","\196\46\203\176\18\79\163\45"),40,2)
                    v104.TotalFarmedGems=v104.TotalFarmedGems + (2599 -(1913 + 62))
                    v108:FireServer(v7("\169\55\119\10","\143\216\66\30\126\68\155"),1934 -(565 + 1368),23466 -17226)
                end)
                task.wait()
            else
                task.wait(0.2)
            end
        end
    end)
end

-- Spawn 4 workers
for v141=1,308 -(244 + 60) do v111() end

print("SonysGemFarmer loaded — farming ready")
