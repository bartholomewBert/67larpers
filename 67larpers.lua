-- language: Luau, file: 67larpers.lua, target: Roblox (Delta Executor)
-- modules: Skeleton, ESP Box, Tracers, Spinbot (persistent), Chams, Health Bar (team check)
-- UI: fullscreen on exec, minimize to golden 67 icon, categories top-center, modules left, options right
-- movement: Speed, Fly, Spinbot. misc: "In development"

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

local Config = {
    Skeleton   = false,
    ESP        = false,
    Tracers    = false,
    Spinbot    = false,
    Chams      = false,
    HealthBar  = false,
    TeamCheck  = false,
    Speed      = false,
    Fly        = false,
    SpeedValue = 100,
    FlySpeed   = 120,
    SpinSpeed  = 6,
}

local SpinAngle = 0

-- ============================================================
-- UI
-- ============================================================
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function safeParent()
    if gethui then return gethui() end
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Gui = make("ScreenGui", {
    Name = "larpers67",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, safeParent())

-- ============================================================
-- MAIN FRAME (starts almost-fullscreen rectangle)
-- ============================================================
local Main = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0.9, 0, 0.88, 0),
    Position = UDim2.new(0.05, 0, 0.06, 0),
    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
}, Gui)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, Main)
make("UIStroke", {
    Color = Color3.fromRGB(200, 165, 60),
    Thickness = 1.5,
    Transparency = 0.2,
}, Main)

-- Title bar
local TitleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Color3.fromRGB(20, 20, 26),
    BorderSizePixel = 0,
}, Main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, TitleBar)

make("TextLabel", {
    Text = "67larpers",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(220, 185, 70),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, TitleBar)

-- Minimize button
local MinBtn = make("TextButton", {
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(220, 185, 70),
    BackgroundColor3 = Color3.fromRGB(32, 32, 40),
    Size = UDim2.new(0, 26, 0, 24),
    Position = UDim2.new(1, -34, 0, 5),
    BorderSizePixel = 0,
    AutoButtonColor = true,
}, TitleBar)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, MinBtn)

-- Categories row (top center)
local CatBar = make("Frame", {
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 40),
    BackgroundTransparency = 1,
}, Main)
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, CatBar)

-- Content area
local Content = make("Frame", {
    Size = UDim2.new(1, -24, 1, -94),
    Position = UDim2.new(0, 12, 0, 82),
    BackgroundTransparency = 1,
}, Main)

local LeftPanel = make("Frame", {
    Size = UDim2.new(0.42, -6, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 26),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
}, Content)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, LeftPanel)

local RightPanel = make("Frame", {
    Size = UDim2.new(0.58, -6, 1, 0),
    Position = UDim2.new(0.42, 6, 0, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 26),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
}, Content)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, RightPanel)

local LeftLayout = make("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, LeftPanel)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
}, LeftPanel)

local RightLayout = make("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, RightPanel)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
}, RightPanel)

-- Category storage
local Categories = {}
local ActiveCat = nil

local function clear(frame)
    for _, c in ipairs(frame:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function buildToggle(parent, name, key, callback)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, row)

    local lbl = make("TextLabel", {
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local ind = make("Frame", {
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -42, 0.5, -9),
        BackgroundColor3 = Config[key] and Color3.fromRGB(200, 165, 60) or Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, ind)

    local knob = make("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = Config[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        BorderSizePixel = 0,
    }, ind)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

    local function paint()
        if Config[key] then
            ind.BackgroundColor3 = Color3.fromRGB(200, 165, 60)
            knob.Position = UDim2.new(1, -16, 0.5, -7)
        else
            ind.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            knob.Position = UDim2.new(0, 2, 0.5, -7)
        end
    end

    make("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
    }, row).MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        paint()
        if callback then callback(Config[key]) end
    end)
end

local function buildSlider(parent, name, key, min, max)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, row)

    local lbl = make("TextLabel", {
        Text = name .. ": " .. tostring(Config[key]),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local track = make("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, track)

    local fill = make("Frame", {
        Size = UDim2.new((Config[key] - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(200, 165, 60),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)

    local dragging = false
    local function set(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        Config[key] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = name .. ": " .. tostring(val)
    end

    local btn = make("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, track)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then set(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function buildLabel(parent, text)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, row)
    make("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 165, 60),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, row)
end

local function showCategory(cat)
    ActiveCat = cat
    clear(LeftPanel)
    clear(RightPanel)

    for _, c in ipairs(CatBar:GetChildren()) do
        if c:IsA("TextButton") then
            c.BackgroundColor3 = (c.Name == cat) and Color3.fromRGB(200, 165, 60) or Color3.fromRGB(32, 32, 40)
            c.TextColor3 = (c.Name == cat) and Color3.fromRGB(14, 14, 18) or Color3.fromRGB(220, 220, 225)
        end
    end

    if cat == "Visuals" then
        buildToggle(LeftPanel, "Skeleton",     "Skeleton",  function() end)
        buildToggle(LeftPanel, "ESP (Box)",    "ESP",       function() end)
        buildToggle(LeftPanel, "Tracers",      "Tracers",   function() end)
        buildToggle(LeftPanel, "Spinbot (visual)", "Spinbot", function() end)
        buildToggle(LeftPanel, "Chams",        "Chams",     function() end)
        buildToggle(LeftPanel, "Health Bar",   "HealthBar", function() end)
        buildToggle(LeftPanel, "Team Check",   "TeamCheck", function() end)
    elseif cat == "Movement" then
        buildToggle(LeftPanel, "Speed", "Speed", function() end)
        buildToggle(LeftPanel, "Fly",   "Fly",   function() end)
        buildSlider(LeftPanel, "Speed Value", "SpeedValue", 16, 500)
        buildSlider(LeftPanel, "Fly Speed",   "FlySpeed",   16, 500)
        buildSlider(LeftPanel, "Spin Speed",  "SpinSpeed",  1, 30)
    elseif cat == "Misc" then
        buildLabel(LeftPanel, "In development")
    end
end

local function makeCategory(name)
    local b = make("TextButton", {
        Name = name,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        BackgroundColor3 = Color3.fromRGB(32, 32, 40),
        Size = UDim2.new(0, 110, 0, 28),
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, CatBar)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
    b.MouseButton1Click:Connect(function() showCategory(name) end)
    Categories[name] = b
end

makeCategory("Visuals")
makeCategory("Misc")
makeCategory("Movement")
showCategory("Visuals")

-- ============================================================
-- DRAGGING (title bar)
-- ============================================================
do
    local dragging, startPos, startInput = false, nil, nil
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = Main.Position
            startInput = i.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - startInput
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ============================================================
-- MINIMIZE → golden 67 icon
-- ============================================================
local Icon = make("TextButton", {
    Name = "Icon67",
    Text = "67",
    Font = Enum.Font.GothamBlack,
    TextSize = 28,
    TextColor3 = Color3.fromRGB(20, 15, 0),
    BackgroundColor3 = Color3.fromRGB(220, 180, 60),
    Size = UDim2.new(0, 64, 0, 64),
    Position = UDim2.new(0, 20, 0.4, 0),
    BorderSizePixel = 0,
    Visible = false,
    AutoButtonColor = false,
}, Gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, Icon)
make("UIStroke", {Color = Color3.fromRGB(255, 230, 140), Thickness = 2}, Icon)

local function minimize()
    Main.Visible = false
    Icon.Visible = true
end
local function restore()
    Icon.Visible = false
    Main.Visible = true
end

MinBtn.MouseButton1Click:Connect(minimize)
Icon.MouseButton1Click:Connect(restore)

do
    local dragging, startPos, startInput = false, nil, nil
    Icon.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = Icon.Position
            startInput = i.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - startInput
            Icon.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ============================================================
-- DRAWING LIBRARY
-- ============================================================
local Draw = Drawing or (function()
    local ok, m = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/.../drawing.lua"))() end)
    return ok and m or nil
end)()

local function newDrawing(class)
    if Drawing and Drawing.new then return Drawing.new(class) end
    return nil
end

-- ============================================================
-- ESP / CHAMS / TRACERS / SKELETON / HEALTH
-- ============================================================
local ESPCache = {}

local function clearESP(entry)
    for _, d in pairs(entry.draw) do
        if d and d.Remove then d:Remove() end
    end
    entry.draw = {}
end

local function newESPEntry(plr)
    local e = {draw = {}, chams = {}, healthConn = nil, plr = plr}

    e.draw.box = {
        top    = newDrawing("Line"),
        bottom = newDrawing("Line"),
        left   = newDrawing("Line"),
        right  = newDrawing("Line"),
    }
    e.draw.tracer = newDrawing("Line")
    e.draw.name   = newDrawing("Text")

    e.draw.skel = {
        head      = newDrawing("Line"),
        spine     = newDrawing("Line"),
        larm      = newDrawing("Line"),
        rarm      = newDrawing("Line"),
        lleg      = newDrawing("Line"),
        rleg      = newDrawing("Line"),
    }

    e.draw.hpBg   = newDrawing("Square")
    e.draw.hpFill = newDrawing("Square")

    for k, d in pairs(e.draw.box) do
        if d then
            d.Thickness = 1
            d.Color = Color3.fromRGB(255, 60, 60)
            d.Transparency = 1
        end
    end
    if e.draw.tracer then
        e.draw.tracer.Thickness = 1
        e.draw.tracer.Color = Color3.fromRGB(255, 200, 60)
        e.draw.tracer.Transparency = 1
    end
    if e.draw.name then
        e.draw.name.Size = 14
        e.draw.name.Center = true
        e.draw.name.Outline = true
        e.draw.name.Color = Color3.fromRGB(255, 255, 255)
        e.draw.name.Transparency = 1
    end
    for _, d in pairs(e.draw.skel) do
        if d then
            d.Thickness = 1
            d.Color = Color3.fromRGB(230, 230, 240)
            d.Transparency = 1
        end
    end
    if e.draw.hpBg then
        e.draw.hpBg.Thickness = 1
        e.draw.hpBg.Color = Color3.fromRGB(0, 0, 0)
        e.draw.hpBg.Filled = true
        e.draw.hpBg.Transparency = 0.4
    end
    if e.draw.hpFill then
        e.draw.hpFill.Thickness = 1
        e.draw.hpFill.Filled = true
        e.draw.hpFill.Transparency = 0.1
    end

    return e
end

local function buildChams(plr)
    local char = plr.Character
    if not char then return end
    local folder = Instance.new("Folder")
    folder.Name = "67_chams_" .. plr.Name
    folder.Parent = char

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("67_cham") then
            local hl = Instance.new("Highlight")
            hl.Name = "67_cham"
            hl.Adornee = part
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = Color3.fromRGB(200, 60, 60)
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(255, 200, 60)
            hl.OutlineTransparency = 0
            hl.Parent = char
        end
    end
end

local function destroyChams(plr)
    local char = plr.Character
    if not char then return end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Highlight") and c.Name == "67_cham" then c:Destroy() end
    end
end

local function getHealth(plr)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return 0, 100
end

local function sameTeam(plr)
    if not Config.TeamCheck then return false end
    return plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
end

local function worldToScreen(v3)
    local sp, onScreen = Camera:WorldToViewportPoint(v3)
    if not onScreen then return nil end
    return Vector2.new(sp.X, sp.Y), sp.Z
end

RunService.RenderStepped:Connect(function()
    local cam = Camera
    local vp = cam.ViewportSize

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            if ESPCache[plr] then clearESP(ESPCache[plr]); ESPCache[plr] = nil end
        elseif plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local skip = sameTeam(plr)

            if not ESPCache[plr] then ESPCache[plr] = newESPEntry(plr) end
            local e = ESPCache[plr]

            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if not skip and head and hum then
                local topSp = worldToScreen(head.Position + Vector3.new(0, 1.2, 0))
                local botSp = worldToScreen(hrp.Position - Vector3.new(0, 3, 0))
                local rootSp = worldToScreen(hrp.Position)

                if topSp and botSp then
                    local h = math.abs(botSp.Y - topSp.Y)
                    local w = h * 0.55
                    local x = topSp.X - w / 2
                    local y = topSp.Y

      
