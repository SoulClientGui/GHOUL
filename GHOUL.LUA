-- Ghoul v2.17 | Full Script
-- Key System + Status Bar + Commands Panel + All Features
-- Made for Xeno Executor by soulownsu2
-- Keys: "soul12" = 2-day | "GHOUL-PERM-2024" = permanent (session only)

-- ============================================================
--                        CONFIGURATION
-- ============================================================
local PERM_KEY = "GHOUL-PERM-2024"
local TEMP_KEY = "soul12"

-- ============================================================
--                          SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local Chat             = game:GetService("Chat")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
local Camera           = workspace.CurrentCamera

-- ============================================================
--                    COMMANDS LIST
-- ============================================================
local COMMANDS = {
    { cat = "MOVEMENT", key = ";fly",       desc = "Toggle flight [speed]" },
    { cat = "MOVEMENT", key = ";noclip",    desc = "Walk through walls" },
    { cat = "MOVEMENT", key = ";speed",     desc = "Set walkspeed [n]" },
    { cat = "MOVEMENT", key = ";jumppower", desc = "Set jump power [n]" },
    { cat = "MOVEMENT", key = ";orbit",     desc = "Orbit a player [dist]" },
    { cat = "MOVEMENT", key = ";anims",     desc = "Load animation menu" },
    { cat = "MOVEMENT", key = ";swim",      desc = "Zero-gravity swim state" },
    { cat = "MOVEMENT", key = ";fling",     desc = "Spin fling nearby players" },
    { cat = "MOVEMENT", key = ";walkto",    desc = "Walk to a player" },
    { cat = "PLAYER",   key = ";invisible", desc = "Toggle invisibility (client)" },
    { cat = "PLAYER",   key = ";god",       desc = "Toggle god mode" },
    { cat = "PLAYER",   key = ";heal",      desc = "Restore full health" },
    { cat = "PLAYER",   key = ";kill",      desc = "Kill a player in server" },
    { cat = "PLAYER",   key = ";tp",        desc = "Teleport to a player" },
    { cat = "PLAYER",   key = ";bring",     desc = "Bring a player to you (client)" },
    { cat = "VISUAL",   key = ";esp",       desc = "Toggle player ESP outlines" },
    { cat = "VISUAL",   key = ";box",       desc = "Toggle box ESP" },
    { cat = "VISUAL",   key = ";chams",     desc = "Toggle tracers + name tags" },
    { cat = "VISUAL",   key = ";fullbright",desc = "Toggle full brightness" },
    { cat = "MISC",     key = ";chat",      desc = "Send a chat message" },
    { cat = "MISC",     key = ";shaders",   desc = "Load post-processing shaders" },
    { cat = "MISC",     key = ";gravity",   desc = "Set gravity [n]" },
    { cat = "MISC",     key = ";ftp",       desc = "Flash-TP to mouse on F key" },
}

local ANIMATIONS = {
    "Backflip","Moonwalk","Griddy","Shuffle","Robot",
    "Disco","Hype","Floss","Dab","Samba","Salsa",
    "Wave","Worm","Running Man","Carlton","Dougie",
    "Whip","Nae Nae","Gangnam Style","Dagger",
}

-- ============================================================
--                      HELPER FUNCTIONS
-- ============================================================
local function makeCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p; return c
end
local function makeStroke(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(60,60,60)
    s.Thickness = t or 1
    s.Parent = p; return s
end
local function flashDot(dot)
    local function loop()
        local t1 = TweenService:Create(dot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=1})
        t1:Play(); t1.Completed:Connect(function()
            local t2 = TweenService:Create(dot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=0})
            t2:Play(); t2.Completed:Connect(loop)
        end)
    end; loop()
end

-- Draggable
local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil
    handle = handle or frame
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

-- Toast notification (bottom left, with bell)
local function showToast(msg)
    local ToastGui = Instance.new("ScreenGui")
    ToastGui.Name = "GhoulToast"
    ToastGui.ResetOnSpawn = false
    ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToastGui.Parent = PlayerGui

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(0, 260, 0, 42)
    Toast.Position = UDim2.new(0, -270, 1, -60)
    Toast.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Toast.BorderSizePixel = 0
    Toast.ZIndex = 200
    Toast.Parent = ToastGui
    makeCorner(Toast, 8)
    makeStroke(Toast, Color3.fromRGB(70,70,70), 1)

    local Bell = Instance.new("TextLabel")
    Bell.Size = UDim2.new(0,30,1,0)
    Bell.BackgroundTransparency = 1
    Bell.Text = "🔔"
    Bell.TextSize = 16
    Bell.Font = Enum.Font.GothamBold
    Bell.ZIndex = 201
    Bell.Parent = Toast

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-38,1,0)
    Lbl.Position = UDim2.new(0,32,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = msg
    Lbl.TextColor3 = Color3.fromRGB(230,230,230)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 201
    Lbl.Parent = Toast

    -- Bell sound
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://6026984224"
    snd.Volume = 0.4
    snd.Parent = workspace
    snd:Play()
    game:GetService("Debris"):AddItem(snd, 3)

    TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 12, 1, -60)
    }):Play()
    task.delay(2.5, function()
        TweenService:Create(Toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, -270, 1, -60)
        }):Play()
        task.delay(0.3, function() ToastGui:Destroy() end)
    end)
end

-- Mini GUI builder
local function buildMiniGui(title, width, height, sx, sy)
    local G = Instance.new("ScreenGui")
    G.Name = "Ghoul_"..title:gsub("%s","")
    G.ResetOnSpawn = false
    G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    G.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, width, 0, height+36)
    Main.Position = UDim2.new(0, sx or 200, 0, sy or 200)
    Main.BackgroundColor3 = Color3.fromRGB(14,14,14)
    Main.BorderSizePixel = 0
    Main.ZIndex = 50
    Main.ClipsDescendants = true
    Main.Parent = G
    makeCorner(Main, 10)
    makeStroke(Main, Color3.fromRGB(55,55,55), 1)

    local TBar = Instance.new("Frame")
    TBar.Size = UDim2.new(1,0,0,36)
    TBar.BackgroundColor3 = Color3.fromRGB(22,22,22)
    TBar.BorderSizePixel = 0
    TBar.ZIndex = 51
    TBar.Parent = Main

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1,-80,1,0)
    TitleLbl.Position = UDim2.new(0,14,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 52
    TitleLbl.Parent = TBar

    local TBBorder = Instance.new("Frame")
    TBBorder.Size = UDim2.new(1,0,0,1)
    TBBorder.Position = UDim2.new(0,0,1,-1)
    TBBorder.BackgroundColor3 = Color3.fromRGB(45,45,45)
    TBBorder.BorderSizePixel = 0
    TBBorder.ZIndex = 51
    TBBorder.Parent = TBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,26,0,20)
    MinBtn.Position = UDim2.new(1,-58,0.5,-10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(200,200,200)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 52
    MinBtn.Parent = TBar
    makeCorner(MinBtn, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,26,0,20)
    CloseBtn.Position = UDim2.new(1,-28,0.5,-10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(200,200,200)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 52
    CloseBtn.Parent = TBar
    makeCorner(CloseBtn, 6)

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1,0,1,-36)
    Body.Position = UDim2.new(0,0,0,36)
    Body.BackgroundTransparency = 1
    Body.ZIndex = 51
    Body.Parent = Main

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = minimized and UDim2.new(0,width,0,36) or UDim2.new(0,width,0,height+36)
        }):Play()
        MinBtn.Text = minimized and "□" or "—"
    end)
    CloseBtn.MouseButton1Click:Connect(function() G:Destroy() end)
    makeDraggable(Main, TBar)

    return G, Body, TBar
end

-- Slider
local function makeSlider(parent, yPos, label, minVal, maxVal, defaultVal)
    local zB = 52
    local Con = Instance.new("Frame")
    Con.Size = UDim2.new(1,-28,0,52)
    Con.Position = UDim2.new(0,14,0,yPos)
    Con.BackgroundTransparency = 1
    Con.ZIndex = zB
    Con.Parent = parent

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,0,0,18)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label..": "..tostring(defaultVal)
    Lbl.TextColor3 = Color3.fromRGB(200,200,200)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = zB+1
    Lbl.Parent = Con

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1,0,0,6)
    Track.Position = UDim2.new(0,0,0,26)
    Track.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Track.BorderSizePixel = 0
    Track.ZIndex = zB+1
    Track.Parent = Con
    makeCorner(Track, 3)

    local startPct = (defaultVal-minVal)/(maxVal-minVal)
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(startPct,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = zB+2
    Fill.Parent = Track
    makeCorner(Fill, 3)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,14,0,14)
    Knob.Position = UDim2.new(startPct,-7,0.5,-7)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = zB+3
    Knob.Parent = Track
    makeCorner(Knob, 99)

    local currentVal = defaultVal
    local dragging = false
    local function upd(pct)
        pct = math.clamp(pct,0,1)
        currentVal = math.floor(minVal+(maxVal-minVal)*pct+0.5)
        Fill.Size = UDim2.new(pct,0,1,0)
        Knob.Position = UDim2.new(pct,-7,0.5,-7)
        Lbl.Text = label..": "..tostring(currentVal)
    end
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; upd((i.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            upd((i.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    return Con, function() return currentVal end
end

-- Action button
local function makeBtn(parent, yPos, xPos, text, width, height)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, width or 120, 0, height or 34)
    Btn.Position = UDim2.new(0, xPos or 14, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 52
    Btn.Parent = parent
    makeCorner(Btn, 8)
    makeStroke(Btn, Color3.fromRGB(70,70,70), 1)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(55,55,55)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(35,35,35)}):Play()
    end)
    return Btn
end

-- Player list picker (returns a frame with scrollable player buttons, calls callback(player))
local function makePlayerList(parent, yPos, bodyHeight, callback)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1,-28,0,bodyHeight)
    Scroll.Position = UDim2.new(0,14,0,yPos)
    Scroll.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ZIndex = 52
    Scroll.Parent = parent
    makeCorner(Scroll, 6)
    makeStroke(Scroll, Color3.fromRGB(50,50,50), 1)

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0,2)
    Layout.Parent = Scroll

    local function refresh()
        for _,c in ipairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,0,0,32)
                Btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
                Btn.Text = plr.DisplayName.." (@"..plr.Name..")"
                Btn.TextColor3 = Color3.fromRGB(210,210,210)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 12
                Btn.BorderSizePixel = 0
                Btn.ZIndex = 53
                Btn.LayoutOrder = i
                Btn.Parent = Scroll
                makeCorner(Btn, 6)
                Btn.MouseEnter:Connect(function()
                    Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
                end)
                Btn.MouseLeave:Connect(function()
                    Btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
                end)
                Btn.MouseButton1Click:Connect(function()
                    callback(plr)
                end)
            end
        end
    end
    refresh()
    -- Refresh button
    local RefBtn = makeBtn(parent, yPos+bodyHeight+6, 14, "↻ Refresh", 80, 26)
    RefBtn.MouseButton1Click:Connect(refresh)
    return Scroll
end

-- ============================================================
--                    FEATURE STATE
-- ============================================================
local flyActive     = false
local flyConn       = nil
local noclipActive  = false
local noclipConn    = nil
local swimActive    = false
local swimConn      = nil
local flingActive   = false
local flingConn     = nil
local godActive     = false
local godConn       = nil
local invisActive   = false
local espActive     = false
local espConns      = {}
local boxActive     = false
local boxConns      = {}
local chamsActive   = false
local chamsConns    = {}
local fullbrightActive = false
local walktoActive  = false
local walktoConn    = nil
local orbitActive   = false
local orbitConn     = nil

-- ============================================================
--                    FEATURE FUNCTIONS
-- ============================================================

-- ── FLY ──────────────────────────────────────────────────────
local flyGuiRef = nil
local function openFlyGui()
    if flyGuiRef then flyGuiRef:Destroy() flyGuiRef = nil end
    local G, Body = buildMiniGui("Fly", 260, 130, 200, 160)
    flyGuiRef = G
    local _, getSpd = makeSlider(Body, 8, "Speed", 50, 600, 100)
    local FBtn = makeBtn(Body, 70, 14, flyActive and "Fly OFF" or "Fly ON", 232)
    FBtn.MouseButton1Click:Connect(function()
        flyActive = not flyActive
        FBtn.Text = flyActive and "Fly OFF" or "Fly ON"
        showToast(flyActive and "Fly  ON" or "Fly  OFF")
        if flyActive then
            local char = LocalPlayer.Character; if not char then flyActive=false return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then flyActive=false return end
            hum.PlatformStand = true
            local BV = Instance.new("BodyVelocity"); BV.Velocity=Vector3.new(0,0,0); BV.MaxForce=Vector3.new(1e5,1e5,1e5); BV.Parent=hrp
            local BA = Instance.new("BodyAngularVelocity"); BA.AngularVelocity=Vector3.new(0,0,0); BA.MaxTorque=Vector3.new(1e5,1e5,1e5); BA.Parent=hrp
            flyConn = RunService.RenderStepped:Connect(function()
                if not flyActive then
                    pcall(function() BV:Destroy() BA:Destroy() end)
                    hum.PlatformStand = false
                    if flyConn then flyConn:Disconnect() flyConn=nil end
                    return
                end
                local spd = getSpd()
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
                if dir.Magnitude>0 then dir=dir.Unit end
                BV.Velocity = dir*spd
            end)
        else
            if flyConn then flyConn:Disconnect() flyConn=nil end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp then for _,v in ipairs(hrp:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then v:Destroy() end end end
                if hum then hum.PlatformStand=false end
            end
        end
    end)
end

-- ── NOCLIP ───────────────────────────────────────────────────
local function toggleNoclip()
    noclipActive = not noclipActive
    showToast(noclipActive and "Noclip  ON" or "Noclip  OFF")
    if noclipActive then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn=nil end
        local char = LocalPlayer.Character
        if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
    end
end

-- ── SWIM (zero gravity) ───────────────────────────────────────
local function toggleSwim()
    swimActive = not swimActive
    showToast(swimActive and "Swim / Zero-G  ON" or "Swim / Zero-G  OFF")
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if swimActive then
        workspace.Gravity = 0
        if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end
        swimConn = RunService.Heartbeat:Connect(function()
            if not swimActive then
                workspace.Gravity = 196.2
                if swimConn then swimConn:Disconnect() swimConn=nil end
                return
            end
            local c = LocalPlayer.Character; if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end
        end)
    else
        workspace.Gravity = 196.2
        if swimConn then swimConn:Disconnect() swimConn=nil end
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- ── SPEED ────────────────────────────────────────────────────
local speedGuiRef = nil
local function openSpeedGui()
    if speedGuiRef then speedGuiRef:Destroy() speedGuiRef=nil end
    local G, Body = buildMiniGui("Speed", 260, 110, 240, 220)
    speedGuiRef = G
    local _, getSpd = makeSlider(Body, 8, "Walk Speed", 50, 600, 50)
    local ApplyBtn = makeBtn(Body, 68, 14, "Apply", 108)
    local ResetBtn = makeBtn(Body, 68, 136, "Reset (16)", 108)
    ApplyBtn.MouseButton1Click:Connect(function()
        local char=LocalPlayer.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=getSpd() end
        showToast("Speed → "..getSpd())
    end)
    ResetBtn.MouseButton1Click:Connect(function()
        local char=LocalPlayer.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=16 end
        showToast("Speed → 16 (reset)")
    end)
end

-- ── JUMP POWER ───────────────────────────────────────────────
local jumpGuiRef = nil
local function openJumpGui()
    if jumpGuiRef then jumpGuiRef:Destroy() jumpGuiRef=nil end
    local G, Body = buildMiniGui("Jump Power", 260, 110, 280, 260)
    jumpGuiRef = G
    local _, getJ = makeSlider(Body, 8, "Jump Power", 50, 600, 50)
    local ApplyBtn = makeBtn(Body, 68, 14, "Apply", 108)
    local ResetBtn = makeBtn(Body, 68, 136, "Reset (50)", 108)
    ApplyBtn.MouseButton1Click:Connect(function()
        local char=LocalPlayer.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower=getJ() end
        showToast("Jump Power → "..getJ())
    end)
    ResetBtn.MouseButton1Click:Connect(function()
        local char=LocalPlayer.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower=50 end
        showToast("Jump Power → 50 (reset)")
    end)
end

-- ── ORBIT ────────────────────────────────────────────────────
local orbitGuiRef = nil
local function openOrbitGui()
    if orbitGuiRef then orbitGuiRef:Destroy() orbitGuiRef=nil end
    local G, Body = buildMiniGui("Orbit", 260, 190, 320, 180)
    orbitGuiRef = G
    local orbitAngle = 0
    local orbitRadius = 10

    -- Player list
    local selectedPlayer = nil
    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,20)
    SelLbl.Position = UDim2.new(0,14,0,8)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 32, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local _, getSpd = makeSlider(Body, 128, "Orbit Speed", 10, 200, 60)

    local OBtn = makeBtn(Body, 152, 14, orbitActive and "Stop Orbit" or "Start Orbit", 232)
    OBtn.MouseButton1Click:Connect(function()
        orbitActive = not orbitActive
        OBtn.Text = orbitActive and "Stop Orbit" or "Start Orbit"
        showToast(orbitActive and "Orbit  ON" or "Orbit  OFF")
        if orbitActive then
            orbitConn = RunService.Heartbeat:Connect(function(dt)
                if not orbitActive then
                    if orbitConn then orbitConn:Disconnect() orbitConn=nil end
                    return
                end
                local target = selectedPlayer
                if not target or not target.Character then return end
                local tHRP = target.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
                local myChar = LocalPlayer.Character; if not myChar then return end
                local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
                local myHum = myChar:FindFirstChildOfClass("Humanoid")
                orbitAngle = orbitAngle + dt * (getSpd() / 30)
                local x = tHRP.Position.X + math.cos(orbitAngle) * orbitRadius
                local z = tHRP.Position.Z + math.sin(orbitAngle) * orbitRadius
                local y = tHRP.Position.Y + 0
                if myHum then myHum.PlatformStand = true end
                myHRP.CFrame = CFrame.new(x, y, z)
            end)
        else
            if orbitConn then orbitConn:Disconnect() orbitConn=nil end
            local myChar = LocalPlayer.Character
            if myChar then
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand=false end
            end
        end
    end)
    G.AncestryChanged:Connect(function()
        if not G.Parent then
            orbitActive=false
            if orbitConn then orbitConn:Disconnect() orbitConn=nil end
            local mc=LocalPlayer.Character
            if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end end
        end
    end)
end

-- ── FLING ────────────────────────────────────────────────────
local function toggleFling()
    flingActive = not flingActive
    showToast(flingActive and "Fling  ON" or "Fling  OFF")
    if flingActive then
        local char = LocalPlayer.Character; if not char then flingActive=false return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then flingActive=false return end

        -- Spin self
        local BA = Instance.new("BodyAngularVelocity")
        BA.AngularVelocity = Vector3.new(0, 9999, 0)
        BA.MaxTorque = Vector3.new(0, 9999, 0)
        BA.Parent = hrp

        flingConn = RunService.Heartbeat:Connect(function()
            if not flingActive then
                pcall(function() BA:Destroy() end)
                if flingConn then flingConn:Disconnect() flingConn=nil end
                return
            end
            local myChar = LocalPlayer.Character; if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            -- Fling nearby players
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP and (tHRP.Position - myHRP.Position).Magnitude < 8 then
                        local BV2 = Instance.new("BodyVelocity")
                        BV2.Velocity = (tHRP.Position - myHRP.Position).Unit * 500 + Vector3.new(0, 200, 0)
                        BV2.MaxForce = Vector3.new(1e6,1e6,1e6)
                        BV2.Parent = tHRP
                        game:GetService("Debris"):AddItem(BV2, 0.15)
                    end
                end
            end
        end)
    else
        if flingConn then flingConn:Disconnect() flingConn=nil end
        local char=LocalPlayer.Character
        if char then
            local hrp=char:FindFirstChild("HumanoidRootPart")
            if hrp then for _,v in ipairs(hrp:GetChildren()) do if v:IsA("BodyAngularVelocity") then v:Destroy() end end end
        end
    end
end

-- ── WALKTO ───────────────────────────────────────────────────
local walktoGuiRef = nil
local function openWalktoGui()
    if walktoGuiRef then walktoGuiRef:Destroy() walktoGuiRef=nil end
    local G, Body = buildMiniGui("Walk To", 260, 190, 260, 220)
    walktoGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,20)
    SelLbl.Position = UDim2.new(0,14,0,8)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 32, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local _, getSpd = makeSlider(Body, 128, "Follow Speed", 60, 600, 100)

    local WBtn = makeBtn(Body, 152, 14, walktoActive and "Stop Following" or "Start Following", 232)
    WBtn.MouseButton1Click:Connect(function()
        walktoActive = not walktoActive
        WBtn.Text = walktoActive and "Stop Following" or "Start Following"
        showToast(walktoActive and "WalkTo  ON" or "WalkTo  OFF")
        if walktoActive then
            walktoConn = RunService.Heartbeat:Connect(function()
                if not walktoActive then
                    if walktoConn then walktoConn:Disconnect() walktoConn=nil end
                    local mc=LocalPlayer.Character
                    if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16 end end
                    return
                end
                if not selectedPlayer or not selectedPlayer.Character then return end
                local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
                local myChar = LocalPlayer.Character; if not myChar then return end
                local myHum = myChar:FindFirstChildOfClass("Humanoid"); if not myHum then return end
                local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
                myHum.WalkSpeed = getSpd()
                myHum:MoveTo(tHRP.Position)
            end)
        else
            if walktoConn then walktoConn:Disconnect() walktoConn=nil end
            local mc=LocalPlayer.Character
            if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16 end end
        end
    end)
end

-- ── INVISIBLE (client) ───────────────────────────────────────
local function toggleInvisible()
    invisActive = not invisActive
    showToast(invisActive and "Invisible  ON" or "Invisible  OFF")
    local char = LocalPlayer.Character; if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            p.LocalTransparencyModifier = invisActive and 1 or 0
        end
    end
end

-- ── GOD MODE ─────────────────────────────────────────────────
local function toggleGod()
    godActive = not godActive
    showToast(godActive and "God Mode  ON" or "God Mode  OFF")
    if godActive then
        godConn = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HealthChanged:Connect(function(hp)
                local char=LocalPlayer.Character; if not char then return end
                local hum=char:FindFirstChildOfClass("Humanoid"); if hum and hp < hum.MaxHealth then hum.Health=hum.MaxHealth end
            end)
        -- Also keep via heartbeat for robustness
        godConn = RunService.Heartbeat:Connect(function()
            if not godActive then
                if godConn then godConn:Disconnect() godConn=nil end; return
            end
            local char=LocalPlayer.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health=hum.MaxHealth end
        end)
    else
        if godConn then godConn:Disconnect() godConn=nil end
    end
end

-- ── HEAL ─────────────────────────────────────────────────────
local function doHeal()
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health=hum.MaxHealth end
    showToast("Healed to full HP")
end

-- ── KILL ─────────────────────────────────────────────────────
local killGuiRef = nil
local function openKillGui()
    if killGuiRef then killGuiRef:Destroy() killGuiRef=nil end
    local G, Body = buildMiniGui("Kill Player", 260, 150, 260, 200)
    killGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,20)
    SelLbl.Position = UDim2.new(0,14,0,8)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 32, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local KBtn = makeBtn(Body, 120, 14, "Kill", 232)
    KBtn.MouseButton1Click:Connect(function()
        if not selectedPlayer or not selectedPlayer.Character then showToast("No player selected") return end
        local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            showToast("Killed "..selectedPlayer.DisplayName)
        end
    end)
end

-- ── TELEPORT ─────────────────────────────────────────────────
local tpGuiRef = nil
local function openTpGui()
    if tpGuiRef then tpGuiRef:Destroy() tpGuiRef=nil end
    local G, Body = buildMiniGui("Teleport To", 260, 150, 280, 200)
    tpGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,20)
    SelLbl.Position = UDim2.new(0,14,0,8)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 32, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local TBtn = makeBtn(Body, 120, 14, "Teleport", 232)
    TBtn.MouseButton1Click:Connect(function()
        if not selectedPlayer or not selectedPlayer.Character then showToast("No player selected") return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
        local myChar=LocalPlayer.Character; if not myChar then return end
        local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        myHRP.CFrame = tHRP.CFrame + Vector3.new(2,0,0)
        showToast("Teleported to "..selectedPlayer.DisplayName)
    end)
end

-- ── BRING ────────────────────────────────────────────────────
local bringGuiRef = nil
local function openBringGui()
    if bringGuiRef then bringGuiRef:Destroy() bringGuiRef=nil end
    local G, Body = buildMiniGui("Bring Player", 260, 150, 300, 200)
    bringGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,20)
    SelLbl.Position = UDim2.new(0,14,0,8)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 32, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local BBtn = makeBtn(Body, 120, 14, "Bring", 232)
    BBtn.MouseButton1Click:Connect(function()
        if not selectedPlayer or not selectedPlayer.Character then showToast("No player selected") return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
        local myChar=LocalPlayer.Character; if not myChar then return end
        local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        -- Client-side: move their HRP to us
        tHRP.CFrame = myHRP.CFrame + Vector3.new(3,0,0)
        showToast("Brought "..selectedPlayer.DisplayName)
    end)
end

-- ── ESP ──────────────────────────────────────────────────────
local function clearESP()
    for _, v in ipairs(espConns) do pcall(function() v:Disconnect() end) end
    espConns = {}
    -- Remove highlights
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("GhoulESP")
            if hl then hl:Destroy() end
        end
    end
end

local function applyESP(char)
    if not char then return end
    local existing = char:FindFirstChild("GhoulESP"); if existing then existing:Destroy() end
    -- Highlight shows through walls with AlwaysOnTop depth mode
    local hl = Instance.new("Highlight")
    hl.Name = "GhoulESP"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(0,0,0)
    hl.FillTransparency = 1  -- outline only, no fill
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function toggleESP()
    espActive = not espActive
    showToast(espActive and "ESP  ON" or "ESP  OFF")
    if espActive then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if plr.Character then applyESP(plr.Character) end
                local c1 = plr.CharacterAdded:Connect(function(char) task.wait() applyESP(char) end)
                table.insert(espConns, c1)
            end
        end
        local c2 = Players.PlayerAdded:Connect(function(plr)
            if plr ~= LocalPlayer then
                if plr.Character then applyESP(plr.Character) end
                local c3 = plr.CharacterAdded:Connect(function(char) task.wait() applyESP(char) end)
                table.insert(espConns, c3)
            end
        end)
        table.insert(espConns, c2)
    else
        clearESP()
    end
end

-- ── BOX ESP ──────────────────────────────────────────────────
local function clearBox()
    for _, v in ipairs(boxConns) do pcall(function() v:Disconnect() end) end
    boxConns = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local b = plr.Character:FindFirstChild("GhoulBox")
            if b then b:Destroy() end
        end
    end
end

local function applyBox(char)
    if not char then return end
    local existing = char:FindFirstChild("GhoulBox"); if existing then existing:Destroy() end
    -- Use Highlight so box shows through walls
    local hl = Instance.new("Highlight")
    hl.Name = "GhoulBox"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.92
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function toggleBox()
    boxActive = not boxActive
    showToast(boxActive and "Box ESP  ON" or "Box ESP  OFF")
    if boxActive then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if plr.Character then applyBox(plr.Character) end
                local c = plr.CharacterAdded:Connect(function(char) task.wait() applyBox(char) end)
                table.insert(boxConns, c)
            end
        end
        local c2 = Players.PlayerAdded:Connect(function(plr)
            if plr ~= LocalPlayer then
                if plr.Character then applyBox(plr.Character) end
                local c3 = plr.CharacterAdded:Connect(function(char) task.wait() applyBox(char) end)
                table.insert(boxConns, c3)
            end
        end)
        table.insert(boxConns, c2)
    else
        clearBox()
    end
end

-- ── CHAMS (tracers + name tags) ───────────────────────────────
local chamsGui = nil
local function clearChams()
    for _, v in ipairs(chamsConns) do pcall(function() v:Disconnect() end) end
    chamsConns = {}
    if chamsGui then chamsGui:Destroy() chamsGui=nil end
end

local function toggleChams()
    chamsActive = not chamsActive
    showToast(chamsActive and "Chams  ON" or "Chams  OFF")
    if chamsActive then
        chamsGui = Instance.new("ScreenGui")
        chamsGui.Name = "GhoulChams"
        chamsGui.ResetOnSpawn = false
        chamsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        chamsGui.Parent = PlayerGui

        local function drawChams(plr)
            if plr == LocalPlayer then return end
            RunService.RenderStepped:Connect(function()
                if not chamsActive then return end
                if not plr.Character then return end
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                -- Name tag (BillboardGui over head)
                local head = plr.Character:FindFirstChild("Head"); if not head then return end
                if not head:FindFirstChild("GhoulTag") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "GhoulTag"
                    bb.Size = UDim2.new(0,120,0,30)
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true
                    bb.Parent = head
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = plr.DisplayName
                    lbl.TextColor3 = Color3.fromRGB(255,255,255)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 14
                    lbl.ZIndex = 2
                    lbl.Parent = bb
                end
                -- Tracer line from bottom of screen to player
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local lineId = "GhoulTracer_"..plr.UserId
                    local line = chamsGui:FindFirstChild(lineId)
                    if not line then
                        line = Instance.new("Frame")
                        line.Name = lineId
                        line.BackgroundColor3 = Color3.fromRGB(255,255,255)
                        line.BorderSizePixel = 0
                        line.ZIndex = 10
                        line.Parent = chamsGui
                    end
                    local vp = Camera.ViewportSize
                    local startX, startY = vp.X/2, vp.Y
                    local endX, endY = screenPos.X, screenPos.Y
                    local dx, dy = endX-startX, endY-startY
                    local len = math.sqrt(dx*dx+dy*dy)
                    local angle = math.atan2(dy,dx)
                    line.Size = UDim2.new(0, len, 0, 1)
                    line.Position = UDim2.new(0, startX, 0, startY)
                    line.Rotation = math.deg(angle)
                else
                    local lineId = "GhoulTracer_"..plr.UserId
                    local line = chamsGui:FindFirstChild(lineId)
                    if line then line.Visible=false end
                end
            end)
        end

        for _, plr in ipairs(Players:GetPlayers()) do drawChams(plr) end
        local c = Players.PlayerAdded:Connect(drawChams)
        table.insert(chamsConns, c)
        local c2 = Players.PlayerRemoving:Connect(function(plr)
            local lineId = "GhoulTracer_"..plr.UserId
            local line = chamsGui and chamsGui:FindFirstChild(lineId)
            if line then line:Destroy() end
            local char = plr.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("GhoulTag"); if tag then tag:Destroy() end
                end
            end
        end)
        table.insert(chamsConns, c2)
    else
        clearChams()
        -- Clean up name tags
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("GhoulTag"); if tag then tag:Destroy() end
                end
            end
        end
    end
end

-- ── FULLBRIGHT ───────────────────────────────────────────────
local origAmbient, origOutdoor, origBrightness
local function toggleFullbright()
    fullbrightActive = not fullbrightActive
    showToast(fullbrightActive and "Fullbright  ON" or "Fullbright  OFF")
    if fullbrightActive then
        origAmbient   = Lighting.Ambient
        origOutdoor   = Lighting.OutdoorAmbient
        origBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = origAmbient or Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient = origOutdoor or Color3.fromRGB(100,100,100)
        Lighting.Brightness = origBrightness or 1
    end
end

-- ── CHAT ─────────────────────────────────────────────────────
local chatGuiRef = nil
local function openChatGui()
    if chatGuiRef then chatGuiRef:Destroy() chatGuiRef=nil end
    local G, Body = buildMiniGui("Chat", 280, 100, 220, 300)
    chatGuiRef = G

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1,-28,0,38)
    InputFrame.Position = UDim2.new(0,14,0,8)
    InputFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
    InputFrame.ZIndex = 52
    InputFrame.Parent = Body
    makeCorner(InputFrame, 8)
    makeStroke(InputFrame, Color3.fromRGB(60,60,60), 1)

    local ChatInput = Instance.new("TextBox")
    ChatInput.Size = UDim2.new(1,-16,1,0)
    ChatInput.Position = UDim2.new(0,10,0,0)
    ChatInput.BackgroundTransparency = 1
    ChatInput.PlaceholderText = "Type message..."
    ChatInput.PlaceholderColor3 = Color3.fromRGB(80,80,80)
    ChatInput.Text = ""
    ChatInput.TextColor3 = Color3.fromRGB(220,220,220)
    ChatInput.Font = Enum.Font.Gotham
    ChatInput.TextSize = 13
    ChatInput.TextXAlignment = Enum.TextXAlignment.Left
    ChatInput.ClearTextOnFocus = false
    ChatInput.ZIndex = 53
    ChatInput.Parent = InputFrame

    local SendBtn = makeBtn(Body, 56, 14, "Send", 232)
    local function doSend()
        local msg = ChatInput.Text
        if msg == "" then return end
        -- Try modern TextChatService first
        local sent = false
        pcall(function()
            local tcs = game:GetService("TextChatService")
            if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
                if ch then ch:SendAsync(msg) sent=true end
            end
        end)
        -- Fallback: legacy SayMessageRequest
        if not sent then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
        ChatInput.Text = ""
        showToast("Chat: "..msg:sub(1,24))
    end
    SendBtn.MouseButton1Click:Connect(doSend)
    ChatInput.FocusLost:Connect(function(enter) if enter then doSend() end end)
end

-- ── SHADERS ──────────────────────────────────────────────────
local function loadShaders()
    showToast("Loading shaders...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
    end)
end

-- ── ANIMS ────────────────────────────────────────────────────
local function loadAnims()
    showToast("Loading anims...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SoulClientGui/error/refs/heads/main/er", true))()
    end)
end

-- ── FLASH TELEPORT (;ftp) ─────────────────────────────────────
-- While active: press F to teleport to mouse position + faint blood sound
local ftpActive = false
local ftpConn   = nil
local ftpMouse  = LocalPlayer:GetMouse()

local function playBloodSplatter()
    -- Faint blood splatter sound (Roblox free asset)
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://5221257759" -- blood splatter sfx
    snd.Volume = 0.08  -- very faint
    snd.RollOffMaxDistance = 1
    snd.Parent = workspace
    snd:Play()
    game:GetService("Debris"):AddItem(snd, 3)
end

local function toggleFTP()
    ftpActive = not ftpActive
    showToast(ftpActive and ";ftp  ON  —  press F to teleport" or ";ftp  OFF")
    if ftpActive then
        ftpConn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.F then
                if not ftpActive then
                    if ftpConn then ftpConn:Disconnect() ftpConn=nil end
                    return
                end
                local myChar = LocalPlayer.Character; if not myChar then return end
                local myHRP  = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
                -- Get mouse hit position
                local target = ftpMouse.Hit.Position + Vector3.new(0, 3, 0)
                -- Flash effect: brief white screen
                local FlashGui = Instance.new("ScreenGui")
                FlashGui.Name = "GhoulFTPFlash"
                FlashGui.ResetOnSpawn = false
                FlashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                FlashGui.Parent = PlayerGui
                local FlashFrame = Instance.new("Frame")
                FlashFrame.Size = UDim2.new(1,0,1,0)
                FlashFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
                FlashFrame.BackgroundTransparency = 0
                FlashFrame.BorderSizePixel = 0
                FlashFrame.ZIndex = 999
                FlashFrame.Parent = FlashGui
                -- Teleport
                myHRP.CFrame = CFrame.new(target)
                -- Blood sound
                playBloodSplatter()
                -- Fade flash out
                TweenService:Create(FlashFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
                task.delay(0.35, function() FlashGui:Destroy() end)
            end
        end)
    else
        if ftpConn then ftpConn:Disconnect() ftpConn=nil end
    end
end

-- ============================================================
--          CHAT COMMAND LISTENER (type in chat)
-- ============================================================
local function setupChatListener()
    local function handleCmd(msg)
        msg = msg:lower():gsub("^%s+",""):gsub("%s+$","")
        if msg == ";fly"       then openFlyGui()
        elseif msg == ";noclip"   then toggleNoclip()
        elseif msg == ";swim"     then toggleSwim()
        elseif msg == ";speed"    then openSpeedGui()
        elseif msg == ";jumppower" then openJumpGui()
        elseif msg == ";orbit"    then openOrbitGui()
        elseif msg == ";anims"    then loadAnims()
        elseif msg == ";fling"    then toggleFling()
        elseif msg == ";walkto"   then openWalktoGui()
        elseif msg == ";invisible" then toggleInvisible()
        elseif msg == ";god"      then toggleGod()
        elseif msg == ";heal"     then doHeal()
        elseif msg == ";kill"     then openKillGui()
        elseif msg == ";tp"       then openTpGui()
        elseif msg == ";bring"    then openBringGui()
        elseif msg == ";esp"      then toggleESP()
        elseif msg == ";box"      then toggleBox()
        elseif msg == ";chams"    then toggleChams()
        elseif msg == ";fullbright" then toggleFullbright()
        elseif msg == ";chat"     then openChatGui()
        elseif msg == ";shaders"  then loadShaders()
        elseif msg == ";ftp"      then toggleFTP()
        end
    end

    -- Hook into the chat textbox (Roblox default chat)
    local function hookChat()
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
            if not playerGui then return end
            local chatMain = playerGui:WaitForChild("Chat", 10)
            if not chatMain then return end
            local frame = chatMain:FindFirstChild("Frame", true)
            if not frame then return end
            for _, v in ipairs(frame:GetDescendants()) do
                if v:IsA("TextBox") then
                    v.FocusLost:Connect(function(enter)
                        if enter then handleCmd(v.Text) end
                    end)
                end
            end
        end)
    end

    -- Also listen via LocalPlayer.Chatted (works in most games)
    LocalPlayer.Chatted:Connect(function(msg)
        handleCmd(msg)
    end)

    task.delay(3, hookChat)
end

-- ============================================================
--                   COMMANDS PANEL BUILDER
-- ============================================================
local commandsPanelGui = nil

local cmdActions = {
    [";fly"]        = openFlyGui,
    [";noclip"]     = toggleNoclip,
    [";swim"]       = toggleSwim,
    [";speed"]      = openSpeedGui,
    [";jumppower"]  = openJumpGui,
    [";orbit"]      = openOrbitGui,
    [";anims"]      = loadAnims,
    [";fling"]      = toggleFling,
    [";walkto"]     = openWalktoGui,
    [";invisible"]  = toggleInvisible,
    [";god"]        = toggleGod,
    [";heal"]       = doHeal,
    [";kill"]       = openKillGui,
    [";tp"]         = openTpGui,
    [";bring"]      = openBringGui,
    [";esp"]        = toggleESP,
    [";box"]        = toggleBox,
    [";chams"]      = toggleChams,
    [";fullbright"] = toggleFullbright,
    [";chat"]       = openChatGui,
    [";shaders"]    = loadShaders,
    [";ftp"]        = toggleFTP,
}

local function buildCommandsPanel()
    if commandsPanelGui then
        commandsPanelGui:Destroy()
        commandsPanelGui = nil
        return
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "GhoulCommandsPanel"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = PlayerGui
    commandsPanelGui = Gui

    local Overlay = Instance.new("TextButton")
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.Text = ""
    Overlay.ZIndex = 20
    Overlay.Parent = Gui
    Overlay.MouseButton1Click:Connect(function()
        Gui:Destroy(); commandsPanelGui=nil
    end)

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0,920,0,560)
    Window.Position = UDim2.new(0.5,-460,0.5,-280)
    Window.BackgroundColor3 = Color3.fromRGB(12,12,12)
    Window.BorderSizePixel = 0
    Window.ZIndex = 21
    Window.ClipsDescendants = true
    Window.Parent = Gui
    makeCorner(Window, 16)
    makeStroke(Window, Color3.fromRGB(45,45,45), 1)

    -- Block overlay pass-through on window
    local WBlock = Instance.new("TextButton")
    WBlock.Size = UDim2.new(1,0,1,0)
    WBlock.BackgroundTransparency = 1
    WBlock.Text = ""
    WBlock.ZIndex = 21
    WBlock.Parent = Window

    -- Entry anim
    Window.BackgroundTransparency = 1
    Window.Position = UDim2.new(0.5,-460,0.54,-280)
    TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position=UDim2.new(0.5,-460,0.5,-280), BackgroundTransparency=0
    }):Play()

    -- Minimize/close for main panel
    local panelMin = false
    local MinPBtn = Instance.new("TextButton")
    MinPBtn.Size=UDim2.new(0,26,0,20) MinPBtn.Position=UDim2.new(1,-58,0,12)
    MinPBtn.BackgroundColor3=Color3.fromRGB(35,35,35) MinPBtn.Text="—"
    MinPBtn.TextColor3=Color3.fromRGB(200,200,200) MinPBtn.Font=Enum.Font.GothamBold
    MinPBtn.TextSize=12 MinPBtn.BorderSizePixel=0 MinPBtn.ZIndex=30 MinPBtn.Parent=Window
    makeCorner(MinPBtn, 6)

    local ClosePBtn = Instance.new("TextButton")
    ClosePBtn.Size=UDim2.new(0,26,0,20) ClosePBtn.Position=UDim2.new(1,-28,0,12)
    ClosePBtn.BackgroundColor3=Color3.fromRGB(35,35,35) ClosePBtn.Text="✕"
    ClosePBtn.TextColor3=Color3.fromRGB(200,200,200) ClosePBtn.Font=Enum.Font.GothamBold
    ClosePBtn.TextSize=12 ClosePBtn.BorderSizePixel=0 ClosePBtn.ZIndex=30 ClosePBtn.Parent=Window
    makeCorner(ClosePBtn, 6)

    ClosePBtn.MouseButton1Click:Connect(function() Gui:Destroy() commandsPanelGui=nil end)
    MinPBtn.MouseButton1Click:Connect(function()
        panelMin = not panelMin
        if panelMin then
            -- Collapse: shrink to just the title bar height, hide all inner frames
            TweenService:Create(Window, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 200, 0, 44)
            }):Play()
            MinPBtn.Text = "□"
        else
            TweenService:Create(Window, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 920, 0, 560)
            }):Play()
            MinPBtn.Text = "—"
        end
        -- Hide overlay when minimized so you can click through
        Overlay.Visible = not panelMin
    end)

    makeDraggable(Window)

    local LeftW = 560

    -- ── LEFT PANEL ─────────────────────────────────────────────
    local LeftBg = Instance.new("Frame")
    LeftBg.Size=UDim2.new(0,LeftW,1,0) LeftBg.BackgroundColor3=Color3.fromRGB(18,18,18)
    LeftBg.BorderSizePixel=0 LeftBg.ZIndex=22 LeftBg.Parent=Window

    local Sep=Instance.new("Frame")
    Sep.Size=UDim2.new(0,1,1,0) Sep.Position=UDim2.new(0,LeftW,0,0)
    Sep.BackgroundColor3=Color3.fromRGB(38,38,38) Sep.BorderSizePixel=0 Sep.ZIndex=22 Sep.Parent=Window

    local LTitle=Instance.new("TextLabel")
    LTitle.Size=UDim2.new(0,200,0,54) LTitle.Position=UDim2.new(0,22,0,0)
    LTitle.BackgroundTransparency=1 LTitle.Text="Commands"
    LTitle.TextColor3=Color3.fromRGB(255,255,255) LTitle.Font=Enum.Font.GothamBold
    LTitle.TextSize=22 LTitle.TextXAlignment=Enum.TextXAlignment.Left LTitle.ZIndex=23 LTitle.Parent=LeftBg

    local CountLbl=Instance.new("TextLabel")
    CountLbl.Size=UDim2.new(0,160,0,54) CountLbl.Position=UDim2.new(1,-180,0,0)
    CountLbl.BackgroundTransparency=1 CountLbl.Text=#COMMANDS.." commands"
    CountLbl.TextColor3=Color3.fromRGB(150,150,150) CountLbl.Font=Enum.Font.GothamBold
    CountLbl.TextSize=13 CountLbl.TextXAlignment=Enum.TextXAlignment.Right CountLbl.ZIndex=23 CountLbl.Parent=LeftBg

    local LHBorder=Instance.new("Frame")
    LHBorder.Size=UDim2.new(1,0,0,1) LHBorder.Position=UDim2.new(0,0,0,54)
    LHBorder.BackgroundColor3=Color3.fromRGB(38,38,38) LHBorder.BorderSizePixel=0 LHBorder.ZIndex=22 LHBorder.Parent=LeftBg

    local LSearchFrame=Instance.new("Frame")
    LSearchFrame.Size=UDim2.new(1,-44,0,38) LSearchFrame.Position=UDim2.new(0,22,0,64)
    LSearchFrame.BackgroundColor3=Color3.fromRGB(24,24,24) LSearchFrame.ZIndex=23 LSearchFrame.Parent=LeftBg
    makeCorner(LSearchFrame,9) makeStroke(LSearchFrame,Color3.fromRGB(45,45,45),1)

    local SemiPfx=Instance.new("TextLabel")
    SemiPfx.Size=UDim2.new(0,24,1,0) SemiPfx.Position=UDim2.new(0,12,0,0)
    SemiPfx.BackgroundTransparency=1 SemiPfx.Text=";"
    SemiPfx.TextColor3=Color3.fromRGB(255,255,255) SemiPfx.Font=Enum.Font.GothamBold
    SemiPfx.TextSize=17 SemiPfx.ZIndex=24 SemiPfx.Parent=LSearchFrame

    local LSearchBox=Instance.new("TextBox")
    LSearchBox.Size=UDim2.new(1,-46,1,0) LSearchBox.Position=UDim2.new(0,40,0,0)
    LSearchBox.BackgroundTransparency=1 LSearchBox.PlaceholderText="search commands..."
    LSearchBox.PlaceholderColor3=Color3.fromRGB(70,70,70) LSearchBox.Text=""
    LSearchBox.TextColor3=Color3.fromRGB(220,220,220) LSearchBox.TextSize=13
    LSearchBox.Font=Enum.Font.Gotham LSearchBox.TextXAlignment=Enum.TextXAlignment.Left
    LSearchBox.ClearTextOnFocus=false LSearchBox.ZIndex=24 LSearchBox.Parent=LSearchFrame

    local CmdScroll=Instance.new("ScrollingFrame")
    CmdScroll.Size=UDim2.new(1,-44,1,-114) CmdScroll.Position=UDim2.new(0,22,0,112)
    CmdScroll.BackgroundTransparency=1 CmdScroll.BorderSizePixel=0
    CmdScroll.ScrollBarThickness=3 CmdScroll.ScrollBarImageColor3=Color3.fromRGB(60,60,60)
    CmdScroll.CanvasSize=UDim2.new(0,0,0,0) CmdScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    CmdScroll.ZIndex=23 CmdScroll.Parent=LeftBg

    local CmdLayout=Instance.new("UIListLayout")
    CmdLayout.SortOrder=Enum.SortOrder.LayoutOrder CmdLayout.Padding=UDim.new(0,5) CmdLayout.Parent=CmdScroll

    local function buildCmdRows(filter)
        for _,c in ipairs(CmdScroll:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then c:Destroy() end
        end
        local lastCat,shown="",0
        for i,cmd in ipairs(COMMANDS) do
            local q=(filter or ""):lower()
            if q=="" or cmd.key:lower():find(q,1,true) or cmd.desc:lower():find(q,1,true) then
                if cmd.cat~=lastCat then
                    local CatLbl=Instance.new("TextLabel")
                    CatLbl.Size=UDim2.new(1,0,0,24) CatLbl.BackgroundTransparency=1
                    CatLbl.Text=cmd.cat CatLbl.TextColor3=Color3.fromRGB(140,140,140)
                    CatLbl.Font=Enum.Font.GothamBold CatLbl.TextSize=10
                    CatLbl.TextXAlignment=Enum.TextXAlignment.Left CatLbl.ZIndex=24
                    CatLbl.LayoutOrder=i*10-1 CatLbl.Parent=CmdScroll
                    lastCat=cmd.cat
                end
                local Row=Instance.new("TextButton")
                Row.Size=UDim2.new(1,0,0,44) Row.BackgroundColor3=Color3.fromRGB(22,22,22)
                Row.BorderSizePixel=0 Row.Text="" Row.AutoButtonColor=false
                Row.ZIndex=24 Row.LayoutOrder=i*10 Row.Parent=CmdScroll
                makeCorner(Row,8) makeStroke(Row,Color3.fromRGB(34,34,34),1)

                Row.MouseEnter:Connect(function()
                    TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
                end)
                Row.MouseLeave:Connect(function()
                    TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play()
                end)

                local action=cmdActions[cmd.key]
                if action then Row.MouseButton1Click:Connect(action) end

                local KeyLbl=Instance.new("TextLabel")
                KeyLbl.Size=UDim2.new(0,140,1,0) KeyLbl.Position=UDim2.new(0,14,0,0)
                KeyLbl.BackgroundTransparency=1 KeyLbl.Text=cmd.key
                KeyLbl.TextColor3=Color3.fromRGB(255,255,255) KeyLbl.Font=Enum.Font.GothamBold
                KeyLbl.TextSize=13 KeyLbl.TextXAlignment=Enum.TextXAlignment.Left KeyLbl.ZIndex=25 KeyLbl.Parent=Row

                local Div=Instance.new("Frame")
                Div.Size=UDim2.new(0,1,0,16) Div.Position=UDim2.new(0,152,0.5,-8)
                Div.BackgroundColor3=Color3.fromRGB(50,50,50) Div.BorderSizePixel=0 Div.ZIndex=25 Div.Parent=Row

                local DescLbl=Instance.new("TextLabel")
                DescLbl.Size=UDim2.new(1,-172,1,0) DescLbl.Position=UDim2.new(0,164,0,0)
                DescLbl.BackgroundTransparency=1 DescLbl.Text=cmd.desc
                DescLbl.TextColor3=Color3.fromRGB(165,165,165) DescLbl.Font=Enum.Font.Gotham
                DescLbl.TextSize=12 DescLbl.TextXAlignment=Enum.TextXAlignment.Left DescLbl.ZIndex=25 DescLbl.Parent=Row

                if action then
                    local ActDot=Instance.new("Frame")
                    ActDot.Size=UDim2.new(0,5,0,5) ActDot.Position=UDim2.new(1,-10,0.5,-2.5)
                    ActDot.BackgroundColor3=Color3.fromRGB(180,180,180) ActDot.BorderSizePixel=0 ActDot.ZIndex=25 ActDot.Parent=Row
                    makeCorner(ActDot,99)
                end
                shown+=1
            end
        end
        CountLbl.Text=shown.." commands"
    end

    buildCmdRows()
    LSearchBox:GetPropertyChangedSignal("Text"):Connect(function() buildCmdRows(LSearchBox.Text) end)

    -- ── RIGHT PANEL ─────────────────────────────────────────────
    local RightBg=Instance.new("Frame")
    RightBg.Size=UDim2.new(1,-(LeftW+1),1,0) RightBg.Position=UDim2.new(0,LeftW+1,0,0)
    RightBg.BackgroundColor3=Color3.fromRGB(18,18,18) RightBg.BorderSizePixel=0
    RightBg.ZIndex=22 RightBg.Parent=Window

    local RTitle=Instance.new("TextLabel")
    RTitle.Size=UDim2.new(0,200,0,54) RTitle.Position=UDim2.new(0,20,0,0)
    RTitle.BackgroundTransparency=1 RTitle.Text="Reanimation"
    RTitle.TextColor3=Color3.fromRGB(255,255,255) RTitle.Font=Enum.Font.GothamBold
    RTitle.TextSize=22 RTitle.TextXAlignment=Enum.TextXAlignment.Left RTitle.ZIndex=23 RTitle.Parent=RightBg

    local IdleDot=Instance.new("Frame")
    IdleDot.Size=UDim2.new(0,8,0,8) IdleDot.Position=UDim2.new(1,-72,0,23)
    IdleDot.BackgroundColor3=Color3.fromRGB(155,155,155) IdleDot.BorderSizePixel=0 IdleDot.ZIndex=23 IdleDot.Parent=RightBg
    makeCorner(IdleDot,99)

    local IdleLbl=Instance.new("TextLabel")
    IdleLbl.Size=UDim2.new(0,55,0,54) IdleLbl.Position=UDim2.new(1,-58,0,0)
    IdleLbl.BackgroundTransparency=1 IdleLbl.Text="Idle"
    IdleLbl.TextColor3=Color3.fromRGB(155,155,155) IdleLbl.Font=Enum.Font.Gotham
    IdleLbl.TextSize=13 IdleLbl.TextXAlignment=Enum.TextXAlignment.Left IdleLbl.ZIndex=23 IdleLbl.Parent=RightBg

    local RHBorder=Instance.new("Frame")
    RHBorder.Size=UDim2.new(1,0,0,1) RHBorder.Position=UDim2.new(0,0,0,54)
    RHBorder.BackgroundColor3=Color3.fromRGB(38,38,38) RHBorder.BorderSizePixel=0 RHBorder.ZIndex=22 RHBorder.Parent=RightBg

    local ReanimBtn=Instance.new("TextButton")
    ReanimBtn.Size=UDim2.new(1,-40,0,42) ReanimBtn.Position=UDim2.new(0,20,0,64)
    ReanimBtn.BackgroundColor3=Color3.fromRGB(255,255,255) ReanimBtn.Text="Reanimate"
    ReanimBtn.TextColor3=Color3.fromRGB(12,12,12) ReanimBtn.Font=Enum.Font.GothamBold
    ReanimBtn.TextSize=15 ReanimBtn.BorderSizePixel=0 ReanimBtn.ZIndex=23 ReanimBtn.Parent=RightBg
    makeCorner(ReanimBtn,10)
    ReanimBtn.MouseEnter:Connect(function() TweenService:Create(ReanimBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(225,225,225)}):Play() end)
    ReanimBtn.MouseLeave:Connect(function() TweenService:Create(ReanimBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)

    local tabNames={"Global","Favs","Custom","States"}
    local tabBtns={}
    local activeTab="Global"

    local TabRow=Instance.new("Frame")
    TabRow.Size=UDim2.new(1,-40,0,30) TabRow.Position=UDim2.new(0,20,0,116)
    TabRow.BackgroundTransparency=1 TabRow.ZIndex=23 TabRow.Parent=RightBg

    local TL=Instance.new("UIListLayout")
    TL.FillDirection=Enum.FillDirection.Horizontal TL.Padding=UDim.new(0,6)
    TL.VerticalAlignment=Enum.VerticalAlignment.Center TL.Parent=TabRow

    local function refreshTabs()
        for _,b in ipairs(tabBtns) do
            if b.Name==activeTab then b.BackgroundColor3=Color3.fromRGB(255,255,255) b.TextColor3=Color3.fromRGB(12,12,12)
            else b.BackgroundColor3=Color3.fromRGB(28,28,28) b.TextColor3=Color3.fromRGB(185,185,185) end
        end
    end
    for _,tName in ipairs(tabNames) do
        local Btn=Instance.new("TextButton")
        Btn.Name=tName Btn.Size=UDim2.new(0,72,1,0) Btn.BackgroundColor3=Color3.fromRGB(28,28,28)
        Btn.Text=tName Btn.TextColor3=Color3.fromRGB(185,185,185) Btn.Font=Enum.Font.GothamBold
        Btn.TextSize=12 Btn.BorderSizePixel=0 Btn.ZIndex=24 Btn.Parent=TabRow
        makeCorner(Btn,7) makeStroke(Btn,Color3.fromRGB(45,45,45),1)
        table.insert(tabBtns,Btn)
        Btn.MouseButton1Click:Connect(function() activeTab=tName refreshTabs() end)
    end
    refreshTabs()

    local AnimSFrame=Instance.new("Frame")
    AnimSFrame.Size=UDim2.new(1,-40,0,38) AnimSFrame.Position=UDim2.new(0,20,0,156)
    AnimSFrame.BackgroundColor3=Color3.fromRGB(24,24,24) AnimSFrame.ZIndex=23 AnimSFrame.Parent=RightBg
    makeCorner(AnimSFrame,9) makeStroke(AnimSFrame,Color3.fromRGB(45,45,45),1)

    local SDot=Instance.new("Frame")
    SDot.Size=UDim2.new(0,11,0,11) SDot.Position=UDim2.new(0,12,0.5,-5.5)
    SDot.BackgroundColor3=Color3.fromRGB(170,170,170) SDot.BorderSizePixel=0 SDot.ZIndex=24 SDot.Parent=AnimSFrame
    makeCorner(SDot,99)

    local AnimSearchBox=Instance.new("TextBox")
    AnimSearchBox.Size=UDim2.new(1,-40,1,0) AnimSearchBox.Position=UDim2.new(0,34,0,0)
    AnimSearchBox.BackgroundTransparency=1 AnimSearchBox.PlaceholderText="search animations..."
    AnimSearchBox.PlaceholderColor3=Color3.fromRGB(70,70,70) AnimSearchBox.Text=""
    AnimSearchBox.TextColor3=Color3.fromRGB(220,220,220) AnimSearchBox.Font=Enum.Font.Gotham
    AnimSearchBox.TextSize=13 AnimSearchBox.TextXAlignment=Enum.TextXAlignment.Left
    AnimSearchBox.ClearTextOnFocus=false AnimSearchBox.ZIndex=24 AnimSearchBox.Parent=AnimSFrame

    local AnimScroll=Instance.new("ScrollingFrame")
    AnimScroll.Size=UDim2.new(1,-40,1,-206) AnimScroll.Position=UDim2.new(0,20,0,204)
    AnimScroll.BackgroundTransparency=1 AnimScroll.BorderSizePixel=0
    AnimScroll.ScrollBarThickness=3 AnimScroll.ScrollBarImageColor3=Color3.fromRGB(60,60,60)
    AnimScroll.CanvasSize=UDim2.new(0,0,0,0) AnimScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    AnimScroll.ZIndex=23 AnimScroll.Parent=RightBg

    local AL=Instance.new("UIListLayout")
    AL.SortOrder=Enum.SortOrder.LayoutOrder AL.Padding=UDim.new(0,5) AL.Parent=AnimScroll

    local starredAnims={}
    local function buildAnimRows(filter)
        for _,c in ipairs(AnimScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for i,animName in ipairs(ANIMATIONS) do
            local q=(filter or ""):lower()
            if q=="" or animName:lower():find(q,1,true) then
                local Row=Instance.new("Frame")
                Row.Size=UDim2.new(1,0,0,40) Row.BackgroundColor3=Color3.fromRGB(22,22,22)
                Row.BorderSizePixel=0 Row.ZIndex=24 Row.LayoutOrder=i Row.Parent=AnimScroll
                makeCorner(Row,8) makeStroke(Row,Color3.fromRGB(34,34,34),1)

                local BulletLbl=Instance.new("TextLabel")
                BulletLbl.Size=UDim2.new(0,16,1,0) BulletLbl.Position=UDim2.new(1,-46,0,0)
                BulletLbl.BackgroundTransparency=1 BulletLbl.Text="·"
                BulletLbl.TextColor3=Color3.fromRGB(85,85,85) BulletLbl.Font=Enum.Font.GothamBold
                BulletLbl.TextSize=20 BulletLbl.ZIndex=25 BulletLbl.Parent=Row

                local AnimLbl=Instance.new("TextLabel")
                AnimLbl.Size=UDim2.new(1,-68,1,0) AnimLbl.Position=UDim2.new(0,12,0,0)
                AnimLbl.BackgroundTransparency=1 AnimLbl.Text=animName
                AnimLbl.TextColor3=Color3.fromRGB(205,205,205) AnimLbl.Font=Enum.Font.Gotham
                AnimLbl.TextSize=13 AnimLbl.TextXAlignment=Enum.TextXAlignment.Left AnimLbl.ZIndex=25 AnimLbl.Parent=Row

                local StarBtn=Instance.new("TextButton")
                StarBtn.Size=UDim2.new(0,24,0,24) StarBtn.Position=UDim2.new(1,-28,0.5,-12)
                StarBtn.BackgroundTransparency=1 StarBtn.Text=starredAnims[animName] and "★" or "☆"
                StarBtn.TextColor3=starredAnims[animName] and Color3.fromRGB(255,255,255) or Color3.fromRGB(75,75,75)
                StarBtn.Font=Enum.Font.GothamBold StarBtn.TextSize=15 StarBtn.ZIndex=25 StarBtn.Parent=Row
                StarBtn.MouseButton1Click:Connect(function()
                    starredAnims[animName]=not starredAnims[animName]
                    buildAnimRows(AnimSearchBox.Text)
                end)
                StarBtn.MouseEnter:Connect(function()
                    if not starredAnims[animName] then StarBtn.TextColor3=Color3.fromRGB(180,180,180) end
                end)
                StarBtn.MouseLeave:Connect(function()
                    if not starredAnims[animName] then StarBtn.TextColor3=Color3.fromRGB(75,75,75) end
                end)
            end
        end
    end
    buildAnimRows()
    AnimSearchBox:GetPropertyChangedSignal("Text"):Connect(function() buildAnimRows(AnimSearchBox.Text) end)

    local escConn
    escConn=UserInputService.InputBegan:Connect(function(inp,gp)
        if not gp and inp.KeyCode==Enum.KeyCode.Escape then
            if commandsPanelGui then commandsPanelGui:Destroy() commandsPanelGui=nil end
            escConn:Disconnect()
        end
    end)
end

-- ============================================================
--                   STATUS BAR (TOP RIGHT)
-- ============================================================
local function buildStatusBar()
    local BarGui=Instance.new("ScreenGui")
    BarGui.Name="GhoulStatusBar" BarGui.ResetOnSpawn=false
    BarGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling BarGui.Parent=PlayerGui

    local Bar=Instance.new("Frame")
    Bar.Size=UDim2.new(0,390,0,36) Bar.Position=UDim2.new(1,-400,0,8)
    Bar.BackgroundColor3=Color3.fromRGB(15,13,20) Bar.BorderSizePixel=0 Bar.ZIndex=10 Bar.Parent=BarGui
    makeCorner(Bar,20) makeStroke(Bar,Color3.fromRGB(50,45,65),1)

    local Layout=Instance.new("UIListLayout")
    Layout.FillDirection=Enum.FillDirection.Horizontal Layout.VerticalAlignment=Enum.VerticalAlignment.Center
    Layout.HorizontalAlignment=Enum.HorizontalAlignment.Center Layout.Padding=UDim.new(0,0) Layout.Parent=Bar

    local function makePill(dotColor,labelText,valueText,clickable)
        local Pill=Instance.new(clickable and "TextButton" or "Frame")
        Pill.BackgroundColor3=Color3.fromRGB(28,24,38) Pill.BorderSizePixel=0
        Pill.Size=UDim2.new(0,valueText and 105 or 75,1,-8) Pill.ZIndex=11
        if clickable then Pill.Text="" Pill.AutoButtonColor=false end
        makeCorner(Pill,12)

        local Inner=Instance.new("Frame")
        Inner.Size=UDim2.new(1,0,1,0) Inner.BackgroundTransparency=1 Inner.ZIndex=12 Inner.Parent=Pill
        local IL=Instance.new("UIListLayout")
        IL.FillDirection=Enum.FillDirection.Horizontal IL.VerticalAlignment=Enum.VerticalAlignment.Center
        IL.HorizontalAlignment=Enum.HorizontalAlignment.Center IL.Padding=UDim.new(0,5) IL.Parent=Inner

        local Dot=Instance.new("Frame")
        Dot.Size=UDim2.new(0,7,0,7) Dot.BackgroundColor3=dotColor Dot.BorderSizePixel=0
        Dot.ZIndex=13 Dot.LayoutOrder=1 Dot.Parent=Inner
        makeCorner(Dot,99) flashDot(Dot)

        local Lbl=Instance.new("TextLabel")
        Lbl.BackgroundTransparency=1 Lbl.Text=labelText Lbl.TextColor3=dotColor
        Lbl.Font=Enum.Font.GothamBold Lbl.TextSize=13 Lbl.ZIndex=13 Lbl.LayoutOrder=2
        Lbl.Size=UDim2.new(0,#labelText*8,1,0) Lbl.Parent=Inner

        local ValLbl=nil
        if valueText then
            ValLbl=Instance.new("TextLabel")
            ValLbl.BackgroundTransparency=1 ValLbl.Text=valueText ValLbl.TextColor3=dotColor
            ValLbl.Font=Enum.Font.GothamBold ValLbl.TextSize=13 ValLbl.ZIndex=13 ValLbl.LayoutOrder=3
            ValLbl.Size=UDim2.new(0,48,1,0) ValLbl.Parent=Inner
        end
        return Pill,ValLbl
    end

    local function makeDivider()
        local D=Instance.new("Frame")
        D.Size=UDim2.new(0,1,0,18) D.BackgroundColor3=Color3.fromRGB(60,55,80) D.BorderSizePixel=0 D.ZIndex=11
        return D
    end
    local function makePad(w)
        local P=Instance.new("Frame")
        P.Size=UDim2.new(0,w,1,0) P.BackgroundTransparency=1 P.ZIndex=11
        return P
    end

    makePad(10).Parent=Bar

    local UIPill=makePill(Color3.fromRGB(255,255,255),"UI",nil,true)
    UIPill.Parent=Bar
    UIPill.MouseEnter:Connect(function() TweenService:Create(UIPill,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(45,40,60)}):Play() end)
    UIPill.MouseLeave:Connect(function() TweenService:Create(UIPill,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,24,38)}):Play() end)
    UIPill.MouseButton1Click:Connect(buildCommandsPanel)

    makePad(5).Parent=Bar makeDivider().Parent=Bar makePad(5).Parent=Bar

    local TagsPill=makePill(Color3.fromRGB(255,255,255),"Tags",nil,true)
    TagsPill.Parent=Bar

    makePad(5).Parent=Bar makeDivider().Parent=Bar makePad(5).Parent=Bar

    local FPSPill,FPSVal=makePill(Color3.fromRGB(80,220,100),"FPS","60")
    FPSPill.Parent=Bar

    makePad(5).Parent=Bar makeDivider().Parent=Bar makePad(5).Parent=Bar

    local PingPill,PingVal=makePill(Color3.fromRGB(220,40,40),"PING","0ms")
    PingPill.Parent=Bar

    makePad(10).Parent=Bar

    local fpsCount,lastTime=0,tick()
    RunService.RenderStepped:Connect(function()
        fpsCount+=1
        local now=tick()
        if now-lastTime>=1 then
            if FPSVal then FPSVal.Text=tostring(math.round(fpsCount/(now-lastTime))) end
            fpsCount,lastTime=0,now
        end
    end)
    task.spawn(function()
        while task.wait(2) do
            local ok,ping=pcall(function() return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ok and PingVal then PingVal.Text=tostring(ping).."ms" end
        end
    end)

    -- Start chat listener after bar is built
    setupChatListener()
end

-- ============================================================
--                        KEY SYSTEM UI
-- ============================================================
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="GhoulKeySystem" ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling ScreenGui.Parent=PlayerGui

local KOverlay=Instance.new("Frame")
KOverlay.Size=UDim2.new(1,0,1,0) KOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
KOverlay.BackgroundTransparency=0.4 KOverlay.BorderSizePixel=0 KOverlay.ZIndex=1 KOverlay.Parent=ScreenGui

local KWindow=Instance.new("Frame")
KWindow.Size=UDim2.new(0,580,0,320) KWindow.Position=UDim2.new(0.5,-290,0.5,-160)
KWindow.BackgroundColor3=Color3.fromRGB(18,14,35) KWindow.BorderSizePixel=0 KWindow.ZIndex=2 KWindow.Parent=ScreenGui
makeCorner(KWindow,14) makeStroke(KWindow,Color3.fromRGB(120,80,220),1.5)

local LeftPanel=Instance.new("Frame")
LeftPanel.Size=UDim2.new(0,185,1,0) LeftPanel.BackgroundColor3=Color3.fromRGB(13,10,26)
LeftPanel.BorderSizePixel=0 LeftPanel.ZIndex=3 LeftPanel.Parent=KWindow
makeCorner(LeftPanel,14)

local LeftFix=Instance.new("Frame")
LeftFix.Size=UDim2.new(0,20,1,0) LeftFix.Position=UDim2.new(1,-20,0,0)
LeftFix.BackgroundColor3=Color3.fromRGB(13,10,26) LeftFix.BorderSizePixel=0 LeftFix.ZIndex=3 LeftFix.Parent=LeftPanel

local LogoFrame=Instance.new("Frame")
LogoFrame.Size=UDim2.new(0,64,0,64) LogoFrame.Position=UDim2.new(0.5,-32,0,28)
LogoFrame.BackgroundColor3=Color3.fromRGB(30,22,55) LogoFrame.ZIndex=4 LogoFrame.Parent=LeftPanel
makeCorner(LogoFrame,10)

local LogoLabel=Instance.new("TextLabel")
LogoLabel.Size=UDim2.new(1,0,1,0) LogoLabel.BackgroundTransparency=1 LogoLabel.Text="👻"
LogoLabel.TextScaled=true LogoLabel.Font=Enum.Font.GothamBold LogoLabel.ZIndex=5 LogoLabel.Parent=LogoFrame

local ScriptName=Instance.new("TextLabel")
ScriptName.Size=UDim2.new(1,-10,0,22) ScriptName.Position=UDim2.new(0,5,0,100)
ScriptName.BackgroundTransparency=1 ScriptName.Text="GHOUL" ScriptName.TextColor3=Color3.fromRGB(255,255,255)
ScriptName.TextScaled=true ScriptName.Font=Enum.Font.GothamBold ScriptName.ZIndex=4 ScriptName.Parent=LeftPanel

local ByLabel=Instance.new("TextLabel")
ByLabel.Size=UDim2.new(1,-10,0,16) ByLabel.Position=UDim2.new(0,5,0,124)
ByLabel.BackgroundTransparency=1 ByLabel.Text="by soulownsu2" ByLabel.TextColor3=Color3.fromRGB(140,120,180)
ByLabel.TextScaled=true ByLabel.Font=Enum.Font.Gotham ByLabel.ZIndex=4 ByLabel.Parent=LeftPanel

local function makeInfoBox(yPos,small,big,bigColor)
    local Box=Instance.new("Frame")
    Box.Size=UDim2.new(1,-20,0,36) Box.Position=UDim2.new(0,10,0,yPos)
    Box.BackgroundColor3=Color3.fromRGB(22,17,42) Box.ZIndex=4 Box.Parent=LeftPanel
    makeCorner(Box,8)
    local S=Instance.new("TextLabel")
    S.Size=UDim2.new(1,-8,0,14) S.Position=UDim2.new(0,8,0,2) S.BackgroundTransparency=1
    S.Text=small S.TextColor3=Color3.fromRGB(120,100,160) S.TextScaled=true S.Font=Enum.Font.Gotham S.ZIndex=5 S.Parent=Box
    local V=Instance.new("TextLabel")
    V.Size=UDim2.new(1,-8,0,16) V.Position=UDim2.new(0,8,0,16) V.BackgroundTransparency=1
    V.Text=big V.TextColor3=bigColor or Color3.fromRGB(255,255,255) V.TextScaled=true V.Font=Enum.Font.GothamBold V.ZIndex=5 V.Parent=Box
end
makeInfoBox(170,"Version","v2.17",Color3.fromRGB(120,180,255))
makeInfoBox(214,"Executor","Xeno",Color3.fromRGB(255,255,255))

local YellowDot=Instance.new("Frame")
YellowDot.Size=UDim2.new(0,10,0,10) YellowDot.Position=UDim2.new(0.5,-5,1,-18)
YellowDot.BackgroundColor3=Color3.fromRGB(255,200,50) YellowDot.ZIndex=4 YellowDot.Parent=LeftPanel
makeCorner(YellowDot,99)

local function makeRightLabel(text,size,yPos,color,bold,xAlign)
    local L=Instance.new("TextLabel")
    L.Size=UDim2.new(0,360,0,size) L.Position=UDim2.new(0,200,0,yPos) L.BackgroundTransparency=1
    L.Text=text L.TextColor3=color L.TextScaled=true
    L.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    L.TextXAlignment=xAlign or Enum.TextXAlignment.Left L.ZIndex=3 L.Parent=KWindow
    return L
end
makeRightLabel("Authentication",28,22,Color3.fromRGB(255,255,255),true)
makeRightLabel("Verifying your access to Ghoul V2",16,50,Color3.fromRGB(120,100,160),false)

local WelcomeBanner=Instance.new("Frame")
WelcomeBanner.Size=UDim2.new(0,350,0,56) WelcomeBanner.Position=UDim2.new(0,200,0,74)
WelcomeBanner.BackgroundColor3=Color3.fromRGB(90,50,180) WelcomeBanner.ZIndex=3 WelcomeBanner.Parent=KWindow
makeCorner(WelcomeBanner,10)

local WelcomeName=Instance.new("TextLabel")
WelcomeName.Size=UDim2.new(1,-14,0,26) WelcomeName.Position=UDim2.new(0,14,0,4)
WelcomeName.BackgroundTransparency=1 WelcomeName.Text="Welcome, "..LocalPlayer.DisplayName
WelcomeName.TextColor3=Color3.fromRGB(255,255,255) WelcomeName.TextScaled=true
WelcomeName.Font=Enum.Font.GothamBold WelcomeName.TextXAlignment=Enum.TextXAlignment.Left
WelcomeName.ZIndex=4 WelcomeName.Parent=WelcomeBanner

local WelcomeSub=Instance.new("TextLabel")
WelcomeSub.Size=UDim2.new(1,-14,0,18) WelcomeSub.Position=UDim2.new(0,14,0,30)
WelcomeSub.BackgroundTransparency=1 WelcomeSub.Text="Enter your key below to continue."
WelcomeSub.TextColor3=Color3.fromRGB(210,190,255) WelcomeSub.TextScaled=true
WelcomeSub.Font=Enum.Font.Gotham WelcomeSub.TextXAlignment=Enum.TextXAlignment.Left
WelcomeSub.ZIndex=4 WelcomeSub.Parent=WelcomeBanner

local StatusDot=Instance.new("Frame")
StatusDot.Size=UDim2.new(0,9,0,9) StatusDot.Position=UDim2.new(0,200,0,145)
StatusDot.BackgroundColor3=Color3.fromRGB(255,180,50) StatusDot.ZIndex=3 StatusDot.Parent=KWindow
makeCorner(StatusDot,99)

local StatusLabel=Instance.new("TextLabel")
StatusLabel.Size=UDim2.new(0,340,0,20) StatusLabel.Position=UDim2.new(0,214,0,141)
StatusLabel.BackgroundTransparency=1 StatusLabel.Text="Key required every execute"
StatusLabel.TextColor3=Color3.fromRGB(255,180,50) StatusLabel.TextScaled=true
StatusLabel.Font=Enum.Font.GothamBold StatusLabel.TextXAlignment=Enum.TextXAlignment.Left
StatusLabel.ZIndex=3 StatusLabel.Parent=KWindow

local InputBox=Instance.new("Frame")
InputBox.Size=UDim2.new(0,350,0,40) InputBox.Position=UDim2.new(0,200,0,168)
InputBox.BackgroundColor3=Color3.fromRGB(24,18,45) InputBox.ZIndex=3 InputBox.Parent=KWindow
makeCorner(InputBox,9) makeStroke(InputBox,Color3.fromRGB(60,45,100),1)

local Arrow=Instance.new("TextLabel")
Arrow.Size=UDim2.new(0,24,1,0) Arrow.Position=UDim2.new(0,8,0,0) Arrow.BackgroundTransparency=1
Arrow.Text=">" Arrow.TextColor3=Color3.fromRGB(140,120,180) Arrow.TextScaled=true
Arrow.Font=Enum.Font.GothamBold Arrow.ZIndex=4 Arrow.Parent=InputBox

local KeyInput=Instance.new("TextBox")
KeyInput.Size=UDim2.new(1,-46,1,0) KeyInput.Position=UDim2.new(0,36,0,0) KeyInput.BackgroundTransparency=1
KeyInput.Text="" KeyInput.PlaceholderText="Paste your key here..."
KeyInput.PlaceholderColor3=Color3.fromRGB(100,80,140) KeyInput.TextColor3=Color3.fromRGB(220,210,255)
KeyInput.TextScaled=true KeyInput.Font=Enum.Font.Gotham KeyInput.ClearTextOnFocus=false
KeyInput.ZIndex=4 KeyInput.Parent=InputBox

local AuthButton=Instance.new("TextButton")
AuthButton.Size=UDim2.new(0,350,0,40) AuthButton.Position=UDim2.new(0,200,0,216)
AuthButton.BackgroundColor3=Color3.fromRGB(110,60,210) AuthButton.Text="Authenticate"
AuthButton.TextColor3=Color3.fromRGB(255,255,255) AuthButton.TextScaled=true
AuthButton.Font=Enum.Font.GothamBold AuthButton.BorderSizePixel=0 AuthButton.ZIndex=3 AuthButton.Parent=KWindow
makeCorner(AuthButton,9)

local DiscordHint=Instance.new("TextLabel")
DiscordHint.Size=UDim2.new(0,350,0,20) DiscordHint.Position=UDim2.new(0,200,0,264)
DiscordHint.BackgroundTransparency=1 DiscordHint.Text="Don't have a key? Get one free from the Discord server."
DiscordHint.TextColor3=Color3.fromRGB(100,80,140) DiscordHint.TextScaled=true
DiscordHint.Font=Enum.Font.Gotham DiscordHint.ZIndex=3 DiscordHint.Parent=KWindow

local ProgressBg=Instance.new("Frame")
ProgressBg.Size=UDim2.new(1,-205,0,3) ProgressBg.Position=UDim2.new(0,200,1,-5)
ProgressBg.BackgroundColor3=Color3.fromRGB(40,30,70) ProgressBg.BorderSizePixel=0 ProgressBg.ZIndex=3 ProgressBg.Parent=KWindow

local ProgressFill=Instance.new("Frame")
ProgressFill.Size=UDim2.new(0.3,0,1,0) ProgressFill.BackgroundColor3=Color3.fromRGB(120,70,220)
ProgressFill.BorderSizePixel=0 ProgressFill.ZIndex=4 ProgressFill.Parent=ProgressBg
makeCorner(ProgressFill,99)
TweenService:Create(ProgressFill,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{
    Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0.1,0,0,0)
}):Play()

KWindow.Position=UDim2.new(0.5,-290,0.6,-160) KWindow.BackgroundTransparency=1
TweenService:Create(KWindow,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0.5,-290,0.5,-160),BackgroundTransparency=0
}):Play()

local function setStatus(text,color)
    StatusLabel.Text=text StatusLabel.TextColor3=color StatusDot.BackgroundColor3=color
end

local function closeAndLaunch(delay)
    task.delay(delay,function()
        TweenService:Create(KWindow,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
            BackgroundTransparency=1,Position=UDim2.new(0.5,-290,0.4,-160)
        }):Play()
        TweenService:Create(KOverlay,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.delay(0.4,function()
            ScreenGui:Destroy()
            buildStatusBar()
        end)
    end)
end

local function onAuthenticate()
    local key=KeyInput.Text
    if key==PERM_KEY then
        setStatus("✔ Permanent key accepted!",Color3.fromRGB(100,230,120))
        AuthButton.BackgroundColor3=Color3.fromRGB(50,160,80) AuthButton.Text="Access Granted ✔"
        print("[GHOUL] Permanent key accepted (session only).") closeAndLaunch(1.5)
    elseif key==TEMP_KEY then
        setStatus("✔ Access granted — 2 days remaining",Color3.fromRGB(100,200,255))
        AuthButton.BackgroundColor3=Color3.fromRGB(40,120,200) AuthButton.Text="Access Granted ✔"
        print("[GHOUL] 2-day key accepted.") closeAndLaunch(1.5)
    elseif key=="" then
        setStatus("⚠ Please enter a key first",Color3.fromRGB(255,180,50))
    else
        setStatus("✘ Invalid key — try again",Color3.fromRGB(240,80,80))
        AuthButton.BackgroundColor3=Color3.fromRGB(180,40,40) AuthButton.Text="Invalid Key"
        task.delay(1.2,function() AuthButton.BackgroundColor3=Color3.fromRGB(110,60,210) AuthButton.Text="Authenticate" end)
        for i=1,4 do
            task.delay(i*0.05,function()
                local off=i%2==0 and 6 or -6
                TweenService:Create(KWindow,TweenInfo.new(0.05),{Position=UDim2.new(0.5,-290+off,0.5,-160)}):Play()
            end)
        end
        task.delay(0.25,function()
            TweenService:Create(KWindow,TweenInfo.new(0.05),{Position=UDim2.new(0.5,-290,0.5,-160)}):Play()
        end)
    end
end

AuthButton.MouseButton1Click:Connect(onAuthenticate)
KeyInput.FocusLost:Connect(function(enter) if enter then onAuthenticate() end end)
AuthButton.MouseEnter:Connect(function()
    TweenService:Create(AuthButton,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(135,80,235)}):Play()
end)
AuthButton.MouseLeave:Connect(function()
    if AuthButton.Text=="Authenticate" then
        TweenService:Create(AuthButton,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(110,60,210)}):Play()
    end
end)
