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
    { cat = "PLAYER",   key = ";emotes",    desc = "Open emotes menu" },
    { cat = "PLAYER",   key = ";emotes2",   desc = "Open emotes menu 2" },
    { cat = "PLAYER",   key = ";fakeout",   desc = "Block headsit / facebang on you" },
    { cat = "PLAYER",   key = ";facepalm",  desc = "Fall forward [T key]" },
    { cat = "PLAYER",   key = ";timereverse", desc = "Reverse facepalm [Z key]" },
    { cat = "PLAYER",   key = ";facebang",  desc = "Face Fuck — speed/dist GUI" },
    { cat = "PLAYER",   key = ";headsit",   desc = "Sit on nearest player head [X]" },
    { cat = "PLAYER",   key = ";jerk",      desc = "Toggle jerk — speed GUI + tool" },
    { cat = "PLAYER",   key = ";lock",      desc = "Silent aim + aimlock + FOV" },
    { cat = "VISUAL",   key = ";esp",       desc = "Toggle player ESP outlines" },
    { cat = "VISUAL",   key = ";box",       desc = "Toggle box ESP" },
    { cat = "VISUAL",   key = ";chams",     desc = "Toggle tracers + name tags" },
    { cat = "VISUAL",   key = ";fullbright",desc = "Toggle full brightness" },
    { cat = "VISUAL",   key = ";reanim",    desc = "Open reanimation dance menu" },
    { cat = "VISUAL",   key = ";baseplate", desc = "Expand baseplate + colour picker" },
    { cat = "MISC",     key = ";chat",      desc = "Send a chat message" },
    { cat = "MISC",     key = ";hide",      desc = ";hide [name] — hide player + VC" },
    { cat = "MISC",     key = ";unhide",    desc = ";unhide [name] — unhide player + VC" },
    { cat = "MISC",     key = ";shaders",   desc = "Load post-processing shaders" },
    { cat = "MISC",     key = ";gravity",   desc = "Set gravity [n]" },
    { cat = "MISC",     key = ";ftp",       desc = "Flash-TP to mouse on F key" },
    { cat = "EXTERNALS", key = ";iy",       desc = "⚡ Infinite Yield console" },
}

local ANIMATIONS = {
    -- Default Roblox moves
    "Default Walk", "Default Run", "Default Jump", "Default Idle",
    "Default Climb", "Default Fall", "Default Swim",
    -- Hype dances
    "Griddy", "Hype", "Floss", "Dab", "Twerk",
    "Renegade", "Whoa", "Woah", "Nae Nae", "Whip",
    "Shoot", "Shoot Dance", "Orange Justice", "Fresh",
    -- Meme dances
    "Gangnam Style", "Harlem Shake", "Cha Cha Slide",
    "Running Man", "Macarena", "YMCA", "Cotton Eye Joe",
    "Coffin Dance", "Distracted Boyfriend", "Rickroll",
    "Fortnite Default", "Fortnite Floss", "Fortnite Orange Justice",
    -- Smooth / classic
    "Moonwalk", "Robot", "Worm", "Windmill", "Backflip",
    "Carlton", "Samba", "Salsa", "Disco", "Shuffle",
    "Dougie", "Wave", "Griddy Slide", "Bounce",
    -- TikTok / viral
    "Savage", "WAP", "Up", "Blinding Lights",
    "Toosie Slide", "Lottery", "Cannibal",
    "Do Your Thang", "Doja Cat", "Laffy Taffy",
    -- Idle / chill
    "Lean", "Headbang", "Air Guitar", "Finger Gun",
    "Clap", "Snap", "Point", "Shrug", "Facepalm",
    -- Extras
    "Backpack Kid", "Pen Pineapple", "Juju", "Dagger",
    "Go Stupid", "Wheezing", "Sped Up Walk",
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

-- Searchable player list picker
local function makePlayerList(parent, yPos, bodyHeight, callback)
    -- Search bar
    local SFrame = Instance.new("Frame")
    SFrame.Size = UDim2.new(1,-28,0,30)
    SFrame.Position = UDim2.new(0,14,0,yPos)
    SFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
    SFrame.ZIndex = 52
    SFrame.Parent = parent
    makeCorner(SFrame, 7)
    makeStroke(SFrame, Color3.fromRGB(50,50,50), 1)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1,-14,1,0)
    SearchBox.Position = UDim2.new(0,8,0,0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "Search player..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(75,75,75)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(210,210,210)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 53
    SearchBox.Parent = SFrame

    -- Player scroll list below search
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1,-28,0,bodyHeight)
    Scroll.Position = UDim2.new(0,14,0,yPos+34)
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

    local function refresh(filter)
        for _,c in ipairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local q = (filter or ""):lower()
        for i, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local name = plr.DisplayName.." (@"..plr.Name..")"
                if q == "" or plr.Name:lower():find(q,1,true) or plr.DisplayName:lower():find(q,1,true) then
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1,0,0,32)
                    Btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
                    Btn.Text = name
                    Btn.TextColor3 = Color3.fromRGB(210,210,210)
                    Btn.Font = Enum.Font.Gotham
                    Btn.TextSize = 12
                    Btn.BorderSizePixel = 0
                    Btn.ZIndex = 53
                    Btn.LayoutOrder = i
                    Btn.Parent = Scroll
                    makeCorner(Btn, 6)
                    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(40,40,40) end)
                    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(28,28,28) end)
                    Btn.MouseButton1Click:Connect(function() callback(plr) end)
                end
            end
        end
    end

    refresh()
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function() refresh(SearchBox.Text) end)

    -- Refresh button sits below the scroll
    local RefBtn = makeBtn(parent, yPos+34+bodyHeight+6, 14, "↻ Refresh", 80, 26)
    RefBtn.MouseButton1Click:Connect(function() refresh(SearchBox.Text) end)
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
local speedGuiRef  = nil
local speedConn    = nil
local speedLocked  = false
local lockedSpeed  = 16

local function openSpeedGui()
    if speedGuiRef then speedGuiRef:Destroy() speedGuiRef = nil end
    local G, Body = buildMiniGui("Speed", 260, 130, 240, 220)
    speedGuiRef = G

    local _, getSpd = makeSlider(Body, 8, "Walk Speed", 16, 500, lockedSpeed)

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1,-28,0,18)
    StatusLbl.Position = UDim2.new(0,14,0,52)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = speedLocked and ("Active: "..lockedSpeed) or "Drag slider — applies live"
    StatusLbl.TextColor3 = Color3.fromRGB(130,130,130)
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 11
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.ZIndex = 52
    StatusLbl.Parent = Body

    local ResetBtn = makeBtn(Body, 78, 136, "Reset (16)", 108)

    -- Live-apply: start locked immediately, slider changes update in real time
    speedLocked = true
    lockedSpeed = getSpd()

    if speedConn then speedConn:Disconnect() end
    speedConn = RunService.Heartbeat:Connect(function()
        if not speedLocked then
            if speedConn then speedConn:Disconnect() speedConn = nil end
            return
        end
        local spd = getSpd()
        if spd ~= lockedSpeed then
            lockedSpeed = spd
            StatusLbl.Text = "Speed: " .. lockedSpeed
        end
        local c = LocalPlayer.Character; if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
        if h.WalkSpeed ~= lockedSpeed then
            h.WalkSpeed = lockedSpeed
        end
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        speedLocked = false
        lockedSpeed = 16
        if speedConn then speedConn:Disconnect() speedConn = nil end
        StatusLbl.Text = "Speed reset to 16"
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        showToast("Speed reset to 16")
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent then speedGuiRef = nil end
        -- Note: speedConn keeps running after GUI closes so speed stays locked
    end)

    showToast("Speed active — drag slider to change")
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
    local G, Body = buildMiniGui("Orbit", 270, 240, 320, 180)
    orbitGuiRef = G
    local orbitAngle = 0
    local orbitRadius = 10

    local selectedPlayer = nil
    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,18)
    SelLbl.Position = UDim2.new(0,14,0,6)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    -- search bar at y=26, list height=70, refresh btn auto-placed
    makePlayerList(Body, 26, 70, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    -- slider and button sit below: 26+30(search)+70(list)+32(refresh)+8gap = 166
    local _, getSpd = makeSlider(Body, 168, "Orbit Speed", 10, 200, 60)

    local OBtn = makeBtn(Body, 192, 14, orbitActive and "Stop Orbit" or "Start Orbit", 242)
    OBtn.MouseButton1Click:Connect(function()
        orbitActive = not orbitActive
        OBtn.Text = orbitActive and "Stop Orbit" or "Start Orbit"
        showToast(orbitActive and "Orbit  ON" or "Orbit  OFF")
        if orbitActive then
            orbitConn = RunService.Heartbeat:Connect(function(dt)
                if not orbitActive then
                    if orbitConn then orbitConn:Disconnect() orbitConn=nil end; return
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
                local y = tHRP.Position.Y
                if myHum then myHum.PlatformStand = true end
                myHRP.CFrame = CFrame.new(x, y, z)
            end)
        else
            if orbitConn then orbitConn:Disconnect() orbitConn=nil end
            local mc = LocalPlayer.Character
            if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end end
        end
    end)
    G.AncestryChanged:Connect(function()
        if not G.Parent then
            orbitActive = false
            if orbitConn then orbitConn:Disconnect() orbitConn=nil end
            local mc=LocalPlayer.Character
            if mc then local h=mc:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end end
        end
    end)
end

-- ── FLING ────────────────────────────────────────────────────
local function toggleFling()
    flingActive = not flingActive
    showToast(flingActive and "Fling  ON  —  walk near players" or "Fling  OFF")
    if flingActive then
        flingConn = RunService.Heartbeat:Connect(function()
            if not flingActive then
                if flingConn then flingConn:Disconnect() flingConn=nil end
                return
            end
            local myChar = LocalPlayer.Character; if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP and (tHRP.Position - myHRP.Position).Magnitude < 12 then
                        -- Remove any existing fling velocity to avoid stacking
                        for _, v in ipairs(tHRP:GetChildren()) do
                            if v.Name == "GhoulFlingBV" then v:Destroy() end
                        end
                        local dir = (tHRP.Position - myHRP.Position)
                        if dir.Magnitude < 0.1 then dir = Vector3.new(1,0,0) end
                        dir = dir.Unit
                        local BV = Instance.new("BodyVelocity")
                        BV.Name = "GhoulFlingBV"
                        BV.Velocity = dir * 800 + Vector3.new(0, 250, 0)
                        BV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                        BV.Parent = tHRP
                        game:GetService("Debris"):AddItem(BV, 0.12)
                    end
                end
            end
        end)
    else
        if flingConn then flingConn:Disconnect() flingConn=nil end
    end
end

-- ── WALKTO ───────────────────────────────────────────────────
local walktoGuiRef = nil
local function openWalktoGui()
    if walktoGuiRef then walktoGuiRef:Destroy() walktoGuiRef=nil end
    local G, Body = buildMiniGui("Walk To", 270, 240, 260, 220)
    walktoGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,18)
    SelLbl.Position = UDim2.new(0,14,0,6)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 26, 70, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local _, getSpd = makeSlider(Body, 168, "Follow Speed", 60, 600, 100)

    local WBtn = makeBtn(Body, 192, 14, walktoActive and "Stop Following" or "Start Following", 242)
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

-- ── FACEPALM (T key) — fall forward ──────────────────────────
local facepalmActive   = false
local facepalmConn     = nil
local facepalmAnimTrack = nil

local function toggleFacepalm()
    facepalmActive = not facepalmActive
    showToast(facepalmActive and "Facepalm  ON  [T = fall forward]" or "Facepalm  OFF")

    if facepalmActive then
        -- T key listener
        facepalmConn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp and UserInputService:GetFocusedTextBox() then return end
            if inp.KeyCode ~= Enum.KeyCode.T then return end
            if not facepalmActive then return end

            local char = LocalPlayer.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local animator = hum:FindFirstChildOfClass("Animator"); if not animator then return end

            -- Stop existing tracks
            for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end

            -- Tip character forward by changing CFrame rotation
            -- Use PlatformStand so physics doesn't fight us
            hum.PlatformStand = true

            -- Animate falling forward over 0.4 seconds using tween on CFrame
            local startCF = hrp.CFrame
            local targetCF = startCF * CFrame.Angles(math.rad(90), 0, 0)

            TweenService:Create(hrp, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                CFrame = targetCF
            }):Play()

            showToast("😑 Facepalm!")
        end)
    else
        if facepalmConn then facepalmConn:Disconnect() facepalmConn = nil end
        -- Stand back up
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

-- ── TIME REVERSE (Z key) — stand back up ─────────────────────
local timeReverseActive = false
local timeReverseConn   = nil

local function toggleTimeReverse()
    timeReverseActive = not timeReverseActive
    showToast(timeReverseActive and "Time Reverse  ON  [Z = stand up]" or "Time Reverse  OFF")

    if timeReverseActive then
        timeReverseConn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp and UserInputService:GetFocusedTextBox() then return end
            if inp.KeyCode ~= Enum.KeyCode.Z then return end
            if not timeReverseActive then return end

            local char = LocalPlayer.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end

            -- Reverse: stand upright again
            local currentCF = hrp.CFrame
            -- Strip rotation, keep position
            local pos = currentCF.Position
            local uprightCF = CFrame.new(pos) * CFrame.Angles(0, currentCF:ToEulerAnglesYXZ(), 0)

            -- Just slam upright instantly via a quick tween
            TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    * CFrame.Angles(0, select(2, currentCF:ToEulerAnglesYXZ()), 0)
            }):Play()

            task.delay(0.35, function()
                if hum then
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)

            showToast("⏪ Time Reversed!")
        end)
    else
        if timeReverseConn then timeReverseConn:Disconnect() timeReverseConn = nil end
    end
end

-- ── FACEBANG ─────────────────────────────────────────────────
local facebangGuiRef = nil
local function openFacebangGui()
    if facebangGuiRef then facebangGuiRef:Destroy() facebangGuiRef = nil end
    local G, Body = buildMiniGui("Face Bang", 270, 150, 260, 200)
    facebangGuiRef = G

    local _, getSpeed = makeSlider(Body, 8,  "Speed",    1, 20, 8)
    local _, getDist  = makeSlider(Body, 68, "Distance", 1, 20, 5)

    local LoadBtn = makeBtn(Body, 128, 14, "▶  Load Face Bang", 242)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
    LoadBtn.MouseEnter:Connect(function()
        TweenService:Create(LoadBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200,40,40)}):Play()
    end)
    LoadBtn.MouseLeave:Connect(function()
        TweenService:Create(LoadBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(160,30,30)}):Play()
    end)
    LoadBtn.MouseButton1Click:Connect(function()
        showToast("Face Bang loaded — Z to activate")
        -- Store values as globals so the external script can read them if needed
        _G.GhoulFacebangSpeed    = getSpeed()
        _G.GhoulFacebangDistance = getDist()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EnterpriseExperience/bruhlolw/refs/heads/main/face_bang_script.lua"))()
        end)
    end)
end
-- keep a simple alias so chat ;facebang opens the GUI
local function loadFacebang() openFacebangGui() end

-- ── HEADSIT ──────────────────────────────────────────────────
local headsitActive  = false
local headsitHBConn  = nil
local headsitGuiRef  = nil

local function openHeadsitGui()
    if headsitGuiRef then headsitGuiRef:Destroy() headsitGuiRef = nil end
    local G, Body = buildMiniGui("Head Sit", 270, 200, 280, 200)
    headsitGuiRef = G

    local selectedHRP = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,18)
    SelLbl.Position = UDim2.new(0,14,0,6)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player to sit on:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    -- Searchable player list — picks their HumanoidRootPart
    makePlayerList(Body, 26, 80, function(plr)
        if plr.Character then
            selectedHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            SelLbl.Text = "Target: " .. plr.DisplayName
        end
    end)

    local function stopSit()
        headsitActive = false
        if headsitHBConn then headsitHBConn:Disconnect() headsitHBConn = nil end
        local char = LocalPlayer.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if hum then hum.Sit = false end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero end
        showToast("HeadSit OFF")
    end

    -- Sit / Stop button
    local SitBtn = makeBtn(Body, 168, 14, "▶  Sit on Head", 242)
    SitBtn.MouseButton1Click:Connect(function()
        if headsitActive then
            stopSit()
            SitBtn.Text = "▶  Sit on Head"
            SitBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        else
            if not selectedHRP or not selectedHRP.Parent then
                showToast("Select a player first!")
                return
            end
            local char = LocalPlayer.Character; if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local target = selectedHRP
            headsitActive = true
            hum.Sit = true
            SitBtn.Text = "⏹  Stop Sitting"
            SitBtn.BackgroundColor3 = Color3.fromRGB(140,30,30)
            if headsitHBConn then headsitHBConn:Disconnect() end
            headsitHBConn = RunService.Heartbeat:Connect(function()
                if not headsitActive or not target.Parent then
                    stopSit()
                    SitBtn.Text = "▶  Sit on Head"
                    SitBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
                    return
                end
                hum.Sit = true
                hrp.CFrame      = target.CFrame * CFrame.new(0, 3, 0)
                hrp.Velocity    = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end)
            showToast("HeadSit ON — click Stop to exit")
        end
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent then stopSit() end
    end)
end
local function toggleHeadsit() openHeadsitGui() end

-- ── JERK ─────────────────────────────────────────────────────
local jerkingEnabled = false
local jerkingSpeed   = 0.6
local jerkAnim       = nil
local jerkTrack      = nil
local jerkGuiRef     = nil
local jerkTool       = nil
local jerkSpeedConn  = nil  -- heartbeat that updates speed live

local function startJerk()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid  = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end

    -- Works for both R6 and R15: get Animator from Humanoid
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        -- Some R6 games don't have Animator yet — wait briefly
        task.wait(0.1)
        animator = humanoid:FindFirstChildOfClass("Animator")
    end
    if not animator then
        -- Last resort: create one (R6 fallback)
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    jerkAnim = Instance.new("Animation")
    -- 698251653 works on R15; 507770239 is a good R6 fallback
    local isR6 = character:FindFirstChild("Torso") ~= nil
    jerkAnim.AnimationId = isR6 and "rbxassetid://507770239" or "rbxassetid://698251653"

    local ok = pcall(function() jerkTrack = animator:LoadAnimation(jerkAnim) end)
    if not ok or not jerkTrack then return end

    jerkTrack.Looped = true
    jerkTrack:Play(0)
    jerkTrack:AdjustSpeed(jerkingSpeed)
end

local function stopJerk()
    if jerkSpeedConn then jerkSpeedConn:Disconnect() jerkSpeedConn = nil end
    if jerkTrack then pcall(function() jerkTrack:Stop(0) end) jerkTrack = nil end
    if jerkAnim  then pcall(function() jerkAnim:Destroy() end) jerkAnim = nil end
end

local function openJerkGui()
    if jerkGuiRef then jerkGuiRef:Destroy() jerkGuiRef = nil end
    local G, Body = buildMiniGui("Ghoul JRK", 270, 110, 240, 210)
    jerkGuiRef = G

    local _, getSpeed = makeSlider(Body, 8, "Jerk Speed", 1, 30, 6)

    local JBtn = makeBtn(Body, 68, 14, jerkingEnabled and "⏹ Stop Jerk" or "▶  Start Jerk", 242)
    JBtn.BackgroundColor3 = jerkingEnabled and Color3.fromRGB(140,30,30) or Color3.fromRGB(35,35,35)

    local function updateJBtn()
        JBtn.Text = jerkingEnabled and "⏹ Stop Jerk" or "▶  Start Jerk"
        JBtn.BackgroundColor3 = jerkingEnabled and Color3.fromRGB(140,30,30) or Color3.fromRGB(35,35,35)
    end

    -- Live speed heartbeat — zero overhead
    if jerkSpeedConn then jerkSpeedConn:Disconnect() end
    jerkSpeedConn = RunService.Heartbeat:Connect(function()
        if not jerkingEnabled or not jerkTrack then return end
        local spd = getSpeed() / 10
        if spd ~= jerkingSpeed then
            jerkingSpeed = spd
            pcall(function() jerkTrack:AdjustSpeed(jerkingSpeed) end)
        end
    end)

    JBtn.MouseButton1Click:Connect(function()
        jerkingEnabled = not jerkingEnabled
        jerkingSpeed = getSpeed() / 10
        showToast(jerkingEnabled and "Jerk ON" or "Jerk OFF")
        if jerkingEnabled then startJerk() else stopJerk() end
        updateJBtn()
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent then jerkGuiRef = nil end
    end)

    -- Add GHOUL JRK tool to hotbar (equip = start, unequip = stop)
    if jerkTool then pcall(function() jerkTool:Destroy() end) jerkTool = nil end
    local tool = Instance.new("Tool")
    tool.Name = "GHOUL JRK"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ToolTip = "GHOUL JRK — equip to start jerk"

    -- Give it a visible TextLabel handle so it shows in hotbar
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1,1,1)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Parent = tool

    tool.Equipped:Connect(function()
        if not jerkingEnabled then
            jerkingEnabled = true
            jerkingSpeed = getSpeed() / 10
            startJerk()
            showToast("GHOUL JRK equipped — Jerk ON")
            updateJBtn()
        end
    end)
    tool.Unequipped:Connect(function()
        if jerkingEnabled then
            jerkingEnabled = false
            stopJerk()
            showToast("GHOUL JRK unequipped — Jerk OFF")
            updateJBtn()
        end
    end)

    tool.Parent = LocalPlayer.Backpack
    jerkTool = tool
    showToast("GHOUL JRK added to hotbar!")
end

local function toggleJerk() openJerkGui() end

-- ── LOCK (Silent Aim + Aimlock + FOV) ────────────────────────
local lockGuiRef      = nil
local lockTarget      = nil
local lockActive      = false
local aimlockConn     = nil
local silentAimActive = false
local aimlockEnabled  = false
local lockFOV         = 150
local lockFovGui      = nil
local fovHidden       = false   -- toggled by H key to hide circle + kill aim

-- Rebuild the FOV circle. Respects fovHidden so H key hides it instantly.
local function updateFovCircle()
    if lockFovGui then lockFovGui:Destroy() lockFovGui = nil end
    if not (silentAimActive or aimlockEnabled) then return end
    if fovHidden then return end

    local FG = Instance.new("ScreenGui")
    FG.Name = "GhoulFOV"
    FG.ResetOnSpawn = false
    FG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FG.Parent = PlayerGui
    lockFovGui = FG

    local cx, cy = 0.5, 0.5
    local segments = 64
    for i = 1, segments do
        local angle     = (i / segments) * math.pi * 2
        local nextAngle = ((i + 1) / segments) * math.pi * 2
        local x1 = cx + math.cos(angle)     * (lockFOV / Camera.ViewportSize.X)
        local y1 = cy + math.sin(angle)     * (lockFOV / Camera.ViewportSize.Y)
        local x2 = cx + math.cos(nextAngle) * (lockFOV / Camera.ViewportSize.X)
        local y2 = cy + math.sin(nextAngle) * (lockFOV / Camera.ViewportSize.Y)
        local dx, dy = x2 - x1, y2 - y1
        local len = math.sqrt(dx*dx + dy*dy)
        local seg = Instance.new("Frame")
        seg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        seg.BorderSizePixel  = 0
        seg.Size             = UDim2.new(len, 0, 0, 1)
        seg.Position         = UDim2.new(x1, 0, y1, 0)
        seg.Rotation         = math.deg(math.atan2(dy, dx))
        seg.ZIndex           = 5
        seg.Parent           = FG
    end
end

-- Turns off aimlock, silent aim and FOV circle all at once.
-- Called either by the keybind or programmatically.
local function killAllLock(saBtn, alBtn)
    silentAimActive = false
    aimlockEnabled  = false
    if aimlockConn then aimlockConn:Disconnect() aimlockConn = nil end
    RunService:UnbindFromRenderStep("GhoulSilentAim")
    if lockFovGui then lockFovGui:Destroy() lockFovGui = nil end
    if saBtn then
        saBtn.Text = "Silent Aim: OFF"
        saBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
    if alBtn then
        alBtn.Text = "Aimlock: OFF"
        alBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
    showToast("Lock — all OFF")
end

-- Get player within FOV closest to screen centre
local function getTargetInFOV()
    local bestPlr, bestDist = nil, math.huge
    local vp = Camera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local part = head or hrp
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dx, dy = screenPos.X - cx, screenPos.Y - cy
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist < lockFOV and dist < bestDist then
                        bestDist = dist
                        bestPlr  = plr
                    end
                end
            end
        end
    end
    return bestPlr
end

local lockKeybind    = Enum.KeyCode.Unknown
local fovHideKeybind = Enum.KeyCode.Unknown
local silentAimKeyHeld = false  -- K key hold state for silent aim

-- Global K key listener for hold-to-silent-aim
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp and UserInputService:GetFocusedTextBox() then return end
    if inp.KeyCode == Enum.KeyCode.K then
        silentAimKeyHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.K then
        silentAimKeyHeld = false
    end
end)

local function openLockGui()
    if lockGuiRef then lockGuiRef:Destroy() lockGuiRef = nil end
    local G, Body = buildMiniGui("Lock / Aim", 290, 470, 300, 100)
    lockGuiRef = G

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1,-28,0,18)
    StatusLbl.Position = UDim2.new(0,14,0,6)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "No target — auto aims nearest in FOV"
    StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 11
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.ZIndex = 52
    StatusLbl.Parent = Body

    -- ── THROUGH-WALL PLAYER LIST ──────────────────────────────
    -- Search bar
    local SFrame = Instance.new("Frame")
    SFrame.Size = UDim2.new(1,-28,0,28)
    SFrame.Position = UDim2.new(0,14,0,28)
    SFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
    SFrame.ZIndex = 52
    SFrame.Parent = Body
    makeCorner(SFrame, 7)
    makeStroke(SFrame, Color3.fromRGB(50,50,50), 1)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1,-14,1,0)
    SearchBox.Position = UDim2.new(0,8,0,0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "Search player..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(70,70,70)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(210,210,210)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 53
    SearchBox.Parent = SFrame

    -- Scroll list for player names — AlwaysOnTop BillboardGui means we can click
    -- even when they're behind walls in the 3D world
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1,-28,0,80)
    Scroll.Position = UDim2.new(0,14,0,60)
    Scroll.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ZIndex = 52
    Scroll.Parent = Body
    makeCorner(Scroll, 6)
    makeStroke(Scroll, Color3.fromRGB(50,50,50), 1)

    local SLayout = Instance.new("UIListLayout")
    SLayout.Padding = UDim.new(0,2)
    SLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SLayout.Parent = Scroll

    local function refreshList(filter)
        for _, c in ipairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local q = (filter or ""):lower()
        for i, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local name = plr.DisplayName .. " (@" .. plr.Name .. ")"
                if q == "" or plr.Name:lower():find(q,1,true) or plr.DisplayName:lower():find(q,1,true) then
                    local Row = Instance.new("TextButton")
                    Row.Size = UDim2.new(1,0,0,30)
                    Row.BackgroundColor3 = Color3.fromRGB(28,28,28)
                    Row.Text = name
                    Row.TextColor3 = Color3.fromRGB(210,210,210)
                    Row.Font = Enum.Font.Gotham
                    Row.TextSize = 12
                    Row.BorderSizePixel = 0
                    Row.LayoutOrder = i
                    Row.ZIndex = 53
                    Row.Parent = Scroll
                    makeCorner(Row, 6)
                    Row.MouseEnter:Connect(function() Row.BackgroundColor3 = Color3.fromRGB(40,40,40) end)
                    Row.MouseLeave:Connect(function() Row.BackgroundColor3 = Color3.fromRGB(28,28,28) end)
                    Row.MouseButton1Click:Connect(function()
                        lockTarget = plr
                        StatusLbl.Text = "Target: " .. plr.DisplayName
                        -- Highlight selected row
                        for _, c2 in ipairs(Scroll:GetChildren()) do
                            if c2:IsA("TextButton") then c2.BackgroundColor3 = Color3.fromRGB(28,28,28) end
                        end
                        Row.BackgroundColor3 = Color3.fromRGB(20,60,20)
                        showToast("Locked → " .. plr.DisplayName)
                    end)
                end
            end
        end
    end
    refreshList()
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function() refreshList(SearchBox.Text) end)

    local RefBtn = makeBtn(Body, 144, 14, "↻ Refresh", 80, 22)
    RefBtn.MouseButton1Click:Connect(function() refreshList(SearchBox.Text) end)

    -- Also: clicking their GhoulNameTag in the world locks them through walls
    -- We hook this via a module-level InputBegan for AlwaysOnTop billboard click
    -- (This is handled in buildStatusBar after tags are created — see note below)

    local ClearBtn = makeBtn(Body, 144, 104, "✕ Clear Target", 132, 22)
    ClearBtn.MouseButton1Click:Connect(function()
        lockTarget = nil
        StatusLbl.Text = "No target — auto aims nearest in FOV"
        for _, c2 in ipairs(Scroll:GetChildren()) do
            if c2:IsA("TextButton") then c2.BackgroundColor3 = Color3.fromRGB(28,28,28) end
        end
        showToast("Target cleared")
    end)

    local _, getFOV = makeSlider(Body, 175, "FOV Radius (px)", 20, 800, lockFOV)

    local SABtn = makeBtn(Body, 237, 14, silentAimActive and "Silent Aim: ON" or "Silent Aim: OFF", 128)
    SABtn.BackgroundColor3 = silentAimActive and Color3.fromRGB(20,120,20) or Color3.fromRGB(35,35,35)
    local ALBtn = makeBtn(Body, 237, 150, aimlockEnabled and "Aimlock: ON" or "Aimlock: OFF", 126)
    ALBtn.BackgroundColor3 = aimlockEnabled and Color3.fromRGB(20,80,160) or Color3.fromRGB(35,35,35)

    -- K key hint
    local KHintLbl = Instance.new("TextLabel")
    KHintLbl.Size = UDim2.new(1,-28,0,14)
    KHintLbl.Position = UDim2.new(0,14,0,278)
    KHintLbl.BackgroundTransparency = 1
    KHintLbl.Text = "Hold K = activate silent aim snap | Aimlock always tracks"
    KHintLbl.TextColor3 = Color3.fromRGB(100,100,100)
    KHintLbl.Font = Enum.Font.Gotham
    KHintLbl.TextSize = 10
    KHintLbl.TextXAlignment = Enum.TextXAlignment.Left
    KHintLbl.ZIndex = 52
    KHintLbl.Parent = Body

    local KLabel = Instance.new("TextLabel")
    KLabel.Size = UDim2.new(1,-28,0,14)
    KLabel.Position = UDim2.new(0,14,0,298)
    KLabel.BackgroundTransparency = 1
    KLabel.Text = "Keybinds:"
    KLabel.TextColor3 = Color3.fromRGB(120,120,120)
    KLabel.Font = Enum.Font.Gotham
    KLabel.TextSize = 11
    KLabel.TextXAlignment = Enum.TextXAlignment.Left
    KLabel.ZIndex = 52
    KLabel.Parent = Body

    local KillBtn = makeBtn(Body, 316, 14, lockKeybind == Enum.KeyCode.Unknown and "Set kill-all key" or "Kill: "..lockKeybind.Name, 118)
    local FovKBtn = makeBtn(Body, 316, 148, fovHideKeybind == Enum.KeyCode.Unknown and "Set FOV hide key" or "FOV: "..fovHideKeybind.Name, 118)

    local listeningKill, listeningFov = false, false
    KillBtn.MouseButton1Click:Connect(function()
        listeningKill = true
        KillBtn.Text = "Press any key..."
        KillBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
    end)
    FovKBtn.MouseButton1Click:Connect(function()
        listeningFov = true
        FovKBtn.Text = "Press any key..."
        FovKBtn.BackgroundColor3 = Color3.fromRGB(60,40,10)
    end)

    local fovConn = RunService.Heartbeat:Connect(function() lockFOV = getFOV() end)

    local inputConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp and UserInputService:GetFocusedTextBox() then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end

        if listeningKill then
            listeningKill = false
            lockKeybind = inp.KeyCode
            KillBtn.Text = "Kill: " .. inp.KeyCode.Name
            KillBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
            showToast("Kill-all key → " .. inp.KeyCode.Name)
            return
        end
        if listeningFov then
            listeningFov = false
            fovHideKeybind = inp.KeyCode
            FovKBtn.Text = "FOV: " .. inp.KeyCode.Name
            FovKBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
            showToast("FOV hide key → " .. inp.KeyCode.Name)
            return
        end

        if fovHideKeybind ~= Enum.KeyCode.Unknown and inp.KeyCode == fovHideKeybind then
            fovHidden = not fovHidden
            if fovHidden then
                if lockFovGui then lockFovGui:Destroy() lockFovGui = nil end
            else
                updateFovCircle()
            end
            showToast(fovHidden and "FOV hidden" or "FOV shown")
            return
        end

        if lockKeybind ~= Enum.KeyCode.Unknown and inp.KeyCode == lockKeybind then
            silentAimActive = false
            aimlockEnabled  = false
            if aimlockConn then aimlockConn:Disconnect() aimlockConn = nil end
            RunService:UnbindFromRenderStep("GhoulSilentAim")
            if lockFovGui then lockFovGui:Destroy() lockFovGui = nil end
            SABtn.Text = "Silent Aim: OFF"; SABtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
            ALBtn.Text = "Aimlock: OFF";    ALBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
            showToast("Lock — all OFF")
        end
    end)

    SABtn.MouseButton1Click:Connect(function()
        silentAimActive = not silentAimActive
        SABtn.Text = silentAimActive and "Silent Aim: ON" or "Silent Aim: OFF"
        SABtn.BackgroundColor3 = silentAimActive and Color3.fromRGB(20,120,20) or Color3.fromRGB(35,35,35)
        lockFOV = getFOV(); updateFovCircle()
        showToast(silentAimActive and "Silent Aim ON — hold K to snap" or "Silent Aim OFF")
        if silentAimActive then
            RunService:BindToRenderStep("GhoulSilentAim", 200, function()
                if not silentAimActive then RunService:UnbindFromRenderStep("GhoulSilentAim"); return end
                -- Only actually move camera when K is held — otherwise tracking is invisible
                if not silentAimKeyHeld then return end
                lockFOV = getFOV()
                local target = lockTarget or getTargetInFOV()
                if not target or not target.Character then return end
                local head = target.Character:FindFirstChild("Head"); if not head then return end
                local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
                local predicted = head.Position
                if hrp then
                    local dist = (Camera.CFrame.Position - head.Position).Magnitude
                    predicted  = head.Position + hrp.AssemblyLinearVelocity * (0.08 + dist/1500)
                end
                local sp, on = Camera:WorldToViewportPoint(predicted)
                if not on then
                    local _, on2 = Camera:WorldToViewportPoint(head.Position)
                    if not on2 then return end
                    predicted = head.Position
                    sp, on = Camera:WorldToViewportPoint(predicted)
                end
                local vp = Camera.ViewportSize
                if math.sqrt((sp.X-vp.X/2)^2+(sp.Y-vp.Y/2)^2) <= lockFOV then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), 0.3)
                end
            end)
        else
            RunService:UnbindFromRenderStep("GhoulSilentAim")
        end
    end)

    ALBtn.MouseButton1Click:Connect(function()
        aimlockEnabled = not aimlockEnabled
        ALBtn.Text = aimlockEnabled and "Aimlock: ON" or "Aimlock: OFF"
        ALBtn.BackgroundColor3 = aimlockEnabled and Color3.fromRGB(20,80,160) or Color3.fromRGB(35,35,35)
        lockFOV = getFOV(); updateFovCircle()

        -- Aimlock also enables silent aim
        silentAimActive = aimlockEnabled
        SABtn.Text = aimlockEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
        SABtn.BackgroundColor3 = aimlockEnabled and Color3.fromRGB(20,120,20) or Color3.fromRGB(35,35,35)

        showToast(aimlockEnabled and "Aimlock ON — hold K for snap too" or "Aimlock + Silent Aim OFF")

        if not aimlockEnabled then
            if aimlockConn then aimlockConn:Disconnect() aimlockConn = nil end
            RunService:UnbindFromRenderStep("GhoulSilentAim")
            return
        end

        -- Re-bind silent aim with K-hold gate
        RunService:UnbindFromRenderStep("GhoulSilentAim")
        RunService:BindToRenderStep("GhoulSilentAim", 200, function()
            if not silentAimActive then RunService:UnbindFromRenderStep("GhoulSilentAim"); return end
            if not silentAimKeyHeld then return end
            lockFOV = getFOV()
            local target = lockTarget or getTargetInFOV()
            if not target or not target.Character then return end
            local head = target.Character:FindFirstChild("Head"); if not head then return end
            local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
            local predicted = head.Position
            if hrp then
                local dist = (Camera.CFrame.Position - head.Position).Magnitude
                predicted  = head.Position + hrp.AssemblyLinearVelocity * (0.08 + dist/1500)
            end
            local sp, on = Camera:WorldToViewportPoint(predicted)
            if not on then return end
            local vp = Camera.ViewportSize
            if math.sqrt((sp.X-vp.X/2)^2+(sp.Y-vp.Y/2)^2) <= lockFOV then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), 0.3)
            end
        end)

        local velHistory = {}
        local velHistoryMax = 6

        if aimlockConn then aimlockConn:Disconnect() end
        aimlockConn = RunService.RenderStepped:Connect(function(dt)
            if not aimlockEnabled then
                if aimlockConn then aimlockConn:Disconnect() aimlockConn = nil end
                return
            end

            lockFOV = getFOV()
            local target = lockTarget or getTargetInFOV()
            if not target or not target.Character then return end

            local head = target.Character:FindFirstChild("Head")
            local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
            if not head or not hrp then return end

            local curVel = hrp.AssemblyLinearVelocity
            table.insert(velHistory, curVel)
            if #velHistory > velHistoryMax then table.remove(velHistory, 1) end

            local avgVel = Vector3.zero
            for _, v in ipairs(velHistory) do avgVel = avgVel + v end
            avgVel = avgVel / math.max(#velHistory, 1)

            local accel = Vector3.zero
            if #velHistory >= 2 then
                local newest = velHistory[#velHistory]
                local oldest = velHistory[1]
                accel = (newest - oldest) / math.max(#velHistory * dt, 0.01)
            end

            local camPos = Camera.CFrame.Position
            local dist   = (camPos - head.Position).Magnitude
            local lookahead = 0.08 + dist / 1200 + accel.Magnitude * 0.002
            local predicted = head.Position + avgVel * lookahead + accel * (lookahead * lookahead * 0.5)

            local predDist = (predicted - head.Position).Magnitude
            if predDist > dist * 0.5 then
                predicted = head.Position + (predicted - head.Position).Unit * (dist * 0.5)
            end

            local sp, on = Camera:WorldToViewportPoint(predicted)
            if not on then
                Camera.CFrame = CFrame.new(camPos, head.Position); return
            end

            local vp = Camera.ViewportSize
            if math.sqrt((sp.X-vp.X/2)^2+(sp.Y-vp.Y/2)^2) <= lockFOV then
                Camera.CFrame = CFrame.new(camPos, predicted)
            end
        end)
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent then lockGuiRef = nil; fovConn:Disconnect(); inputConn:Disconnect() end
    end)
end
local function toggleLock() openLockGui() end
local function loadIY()
    showToast("⚡ Loading Infinite Yield...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
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
    local G, Body = buildMiniGui("Teleport To", 270, 200, 280, 200)
    tpGuiRef = G
    local selectedPlayer = nil

    local SelLbl = Instance.new("TextLabel")
    SelLbl.Size = UDim2.new(1,-28,0,18)
    SelLbl.Position = UDim2.new(0,14,0,6)
    SelLbl.BackgroundTransparency = 1
    SelLbl.Text = "Select a player:"
    SelLbl.TextColor3 = Color3.fromRGB(160,160,160)
    SelLbl.Font = Enum.Font.Gotham
    SelLbl.TextSize = 12
    SelLbl.TextXAlignment = Enum.TextXAlignment.Left
    SelLbl.ZIndex = 52
    SelLbl.Parent = Body

    makePlayerList(Body, 26, 80, function(plr)
        selectedPlayer = plr
        SelLbl.Text = "Target: "..plr.DisplayName
    end)

    local TBtn = makeBtn(Body, 170, 14, "Teleport", 242)
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
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("GhoulESP")
            if hl then hl:Destroy() end
            -- Remove name tag
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("GhoulESPTag")
                if tag then tag:Destroy() end
            end
        end
    end
end

-- Shared colour state for ESP, Box and Chams
local espColor   = Color3.fromRGB(255, 255, 255)
local boxColor   = Color3.fromRGB(255, 255, 255)
local chamsColor = Color3.fromRGB(255, 255, 255)

-- Rainbow colour swatches used by all three colour pickers
local RAINBOW_COLORS = {
    {n="Red",    c=Color3.fromRGB(255,50,50)},
    {n="Orange", c=Color3.fromRGB(255,140,0)},
    {n="Yellow", c=Color3.fromRGB(255,230,0)},
    {n="Green",  c=Color3.fromRGB(50,200,80)},
    {n="Cyan",   c=Color3.fromRGB(0,220,220)},
    {n="Blue",   c=Color3.fromRGB(30,100,255)},
    {n="Purple", c=Color3.fromRGB(160,60,240)},
    {n="Pink",   c=Color3.fromRGB(255,80,180)},
    {n="White",  c=Color3.fromRGB(255,255,255)},
    {n="Black",  c=Color3.fromRGB(20,20,20)},
}

-- Builds a row of colour swatches in a parent frame, calls onPick(Color3)
local function makeColorPicker(parent, yPos, onPick)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,-28,0,28)
    Row.Position = UDim2.new(0,14,0,yPos)
    Row.BackgroundTransparency = 1
    Row.ZIndex = 52
    Row.Parent = parent

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0,4)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Parent = Row

    for _, entry in ipairs(RAINBOW_COLORS) do
        local Swatch = Instance.new("TextButton")
        Swatch.Size = UDim2.new(0,22,0,22)
        Swatch.BackgroundColor3 = entry.c
        Swatch.Text = ""
        Swatch.BorderSizePixel = 0
        Swatch.ZIndex = 53
        Swatch.Parent = Row
        makeCorner(Swatch, 5)
        Swatch.MouseEnter:Connect(function()
            TweenService:Create(Swatch, TweenInfo.new(0.1), {Size = UDim2.new(0,26,0,26)}):Play()
        end)
        Swatch.MouseLeave:Connect(function()
            TweenService:Create(Swatch, TweenInfo.new(0.1), {Size = UDim2.new(0,22,0,22)}):Play()
        end)
        Swatch.MouseButton1Click:Connect(function()
            onPick(entry.c)
            showToast("Colour → " .. entry.n)
        end)
    end
    return Row
end

local function applyESP(char)
    if not char then return end
    local existing = char:FindFirstChild("GhoulESP"); if existing then existing:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "GhoulESP"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(0,0,0)
    hl.FillTransparency = 1
    hl.OutlineColor = espColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char

    local head = char:FindFirstChild("Head")
    if head then
        local existingTag = head:FindFirstChild("GhoulESPTag")
        if existingTag then existingTag:Destroy() end

        local plr = Players:GetPlayerFromCharacter(char)
        local tagName = plr and (plr.DisplayName .. "\n@" .. plr.Name) or char.Name

        local bb = Instance.new("BillboardGui")
        bb.Name = "GhoulESPTag"
        bb.Size = UDim2.new(0,160,0,48)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 500
        bb.ResetOnSpawn = false
        bb.Parent = head

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = tagName
        lbl.TextColor3 = espColor
        lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 15
        lbl.TextScaled = false
        lbl.Parent = bb
    end
end

-- Re-applies ESP with new colour to all currently highlighted characters
local function refreshESPColor()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("GhoulESP")
            if hl then hl.OutlineColor = espColor end
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("GhoulESPTag")
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel")
                    if lbl then lbl.TextColor3 = espColor end
                end
            end
        end
    end
end

local espGuiRef = nil
local function toggleESP()
    espActive = not espActive

    if espActive then
        -- Open colour picker GUI
        if espGuiRef then espGuiRef:Destroy() espGuiRef = nil end
        local G, Body = buildMiniGui("ESP Settings", 280, 80, 340, 120)
        espGuiRef = G

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1,-28,0,16)
        Lbl.Position = UDim2.new(0,14,0,6)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = "ESP Colour  (auto-applies live)"
        Lbl.TextColor3 = Color3.fromRGB(150,150,150)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 52
        Lbl.Parent = Body

        makeColorPicker(Body, 26, function(col)
            espColor = col
            refreshESPColor()
        end)

        G.AncestryChanged:Connect(function()
            if not G.Parent then espGuiRef = nil end
        end)

        -- Apply ESP to all players
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
        showToast("ESP  ON")
    else
        if espGuiRef then espGuiRef:Destroy() espGuiRef = nil end
        clearESP()
        showToast("ESP  OFF")
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
    local hl = Instance.new("Highlight")
    hl.Name = "GhoulBox"
    hl.Adornee = char
    hl.FillColor = boxColor
    hl.FillTransparency = 0.92
    hl.OutlineColor = boxColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function refreshBoxColor()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("GhoulBox")
            if hl then
                hl.FillColor = boxColor
                hl.OutlineColor = boxColor
            end
        end
    end
end

local boxGuiRef = nil
local function toggleBox()
    boxActive = not boxActive

    if boxActive then
        if boxGuiRef then boxGuiRef:Destroy() boxGuiRef = nil end
        local G, Body = buildMiniGui("Box ESP Settings", 280, 80, 360, 140)
        boxGuiRef = G

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1,-28,0,16)
        Lbl.Position = UDim2.new(0,14,0,6)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = "Box Colour  (auto-applies live)"
        Lbl.TextColor3 = Color3.fromRGB(150,150,150)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 52
        Lbl.Parent = Body

        makeColorPicker(Body, 26, function(col)
            boxColor = col
            refreshBoxColor()
        end)

        G.AncestryChanged:Connect(function()
            if not G.Parent then boxGuiRef = nil end
        end)

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
        showToast("Box ESP  ON")
    else
        if boxGuiRef then boxGuiRef:Destroy() boxGuiRef = nil end
        clearBox()
        showToast("Box ESP  OFF")
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
-- ── HIDE / UNHIDE PLAYER ─────────────────────────────────────
local hiddenPlayers = {}  -- [userId] = { parts = {...}, transparency = {...}, vcGui = vcGui }

local function findPlayerByName(name)
    name = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == name or plr.DisplayName:lower() == name
           or plr.Name:lower():sub(1,#name) == name then
            return plr
        end
    end
    return nil
end

local function hidePlayer(name)
    local plr = findPlayerByName(name)
    if not plr then showToast("Player not found: "..name) return end
    if plr == LocalPlayer then showToast("Can't hide yourself") return end
    if hiddenPlayers[plr.UserId] then showToast(plr.DisplayName.." already hidden") return end

    local char = plr.Character
    if not char then showToast("No character for "..plr.DisplayName) return end

    local saved = { parts = {}, accessories = {} }

    -- Hide all BaseParts
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("MeshPart") or p:IsA("SpecialMesh") then
            saved.parts[p] = p.Transparency
            p.Transparency = 1
        elseif p:IsA("Decal") or p:IsA("Texture") then
            saved.parts[p] = p.Transparency
            p.Transparency = 1
        end
    end

    -- Hide accessories (hats etc)
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                saved.accessories[handle] = handle.Transparency
                handle.Transparency = 1
            end
        end
    end

    -- Hide ESP tag and highlight if present
    local head = char:FindFirstChild("Head")
    if head then
        local tag = head:FindFirstChild("GhoulESPTag")
        if tag then tag.Enabled = false end
    end

    -- Hide voice chat — Roblox VC uses BillboardGuis on the Head and
    -- also SurfaceGuis / Folders in PlayerGui named "VoiceChat" etc.
    local head = char:FindFirstChild("Head")
    if head then
        for _, v in ipairs(head:GetDescendants()) do
            if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                saved.parts[v] = v.Enabled
                v.Enabled = false
            end
        end
        -- Also catch accessories that might have VC indicators
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("BillboardGui") then
                saved.parts[v] = v.Enabled
                v.Enabled = false
            end
        end
    end
    -- Kill any VC gui in PlayerGui that references this player
    for _, g in ipairs(PlayerGui:GetDescendants()) do
        if g:IsA("TextLabel") or g:IsA("ImageLabel") then
            local ok, pid = pcall(function()
                return g:FindFirstAncestor("VoiceChat") or
                       g:FindFirstAncestorWhichIsA("ScreenGui")
            end)
            -- Try to match by player name displayed
            if g:IsA("TextLabel") and (g.Text == plr.DisplayName or g.Text == plr.Name) then
                local frame = g.Parent
                if frame then
                    saved.parts[frame] = frame.Visible
                    frame.Visible = false
                end
            end
        end
    end
    -- Nuclear option: find any ScreenGui with "Voice" in name and hide player's entry
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name:lower():find("voice") or g.Name:lower():find("vc")) then
            saved.parts[g] = g.Enabled
            -- Don't disable whole gui (affects all players), hide per-player frames
            for _, child in ipairs(g:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("ImageLabel") then
                    local lbl = child:FindFirstChildWhichIsA("TextLabel")
                    if lbl and (lbl.Text == plr.DisplayName or lbl.Text == "@"..plr.Name) then
                        saved.parts[child] = child.Visible
                        child.Visible = false
                    end
                end
            end
        end
    end

    hiddenPlayers[plr.UserId] = saved
    showToast("Hidden: "..plr.DisplayName)
end

local function unhidePlayer(name)
    local plr = findPlayerByName(name)
    if not plr then showToast("Player not found: "..name) return end
    local saved = hiddenPlayers[plr.UserId]
    if not saved then showToast(plr.DisplayName.." is not hidden") return end

    local char = plr.Character
    if char then
        for part, transparency in pairs(saved.parts) do
            pcall(function() part.Transparency = transparency end)
        end
        for handle, transparency in pairs(saved.accessories) do
            pcall(function() handle.Transparency = transparency end)
        end
        -- Re-enable ESP tag
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("GhoulESPTag")
            if tag then tag.Enabled = true end
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("BillboardGui") and (v.Name:find("Voice") or v.Name:find("VC") or v.Name == "SpeakerIcon") then
                    v.Enabled = true
                end
            end
        end
    end

    hiddenPlayers[plr.UserId] = nil
    showToast("Unhidden: "..plr.DisplayName)
end

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

-- ── REANIM GUI ────────────────────────────────────────────────
local reanimGuiRef = nil

-- Snake reanim state (from the provided script)
local snakeorder = {
    "Head","UpperTorso","LowerTorso",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot"
}
local snakeDistance    = 1.0
local snakeSmoothing   = 0.1
local ghostEnabled     = false
local originalCharacter, ghostClone, originalCFrame
local snakeUpdateConn  = nil
local previousPositions, targetPositions = {}, {}

local function updateSnakeParts()
    if not ghostEnabled or not originalCharacter or not originalCharacter.Parent
       or not ghostClone or not ghostClone.Parent then
        if snakeUpdateConn then snakeUpdateConn:Disconnect() snakeUpdateConn = nil end
        return
    end
    local rootPart = ghostClone:FindFirstChild("HumanoidRootPart"); if not rootPart then return end
    local isMoving = rootPart.AssemblyLinearVelocity.Magnitude > 0.1
    local firstPartName = snakeorder[1]
    local firstPart = originalCharacter:FindFirstChild(firstPartName)
    if firstPart then
        if not targetPositions[firstPartName] then targetPositions[firstPartName] = firstPart.CFrame end
        if not previousPositions[firstPartName] then previousPositions[firstPartName] = firstPart.CFrame end
        if isMoving then
            local targetCF = CFrame.new(rootPart.Position) * (rootPart.CFrame - rootPart.Position)
            targetPositions[firstPartName] = targetCF
        end
        local smoothCF = previousPositions[firstPartName]:Lerp(targetPositions[firstPartName], snakeSmoothing)
        firstPart.CFrame = smoothCF
        firstPart.AssemblyLinearVelocity = Vector3.zero
        firstPart.AssemblyAngularVelocity = Vector3.zero
        previousPositions[firstPartName] = smoothCF
        for i = 2, #snakeorder do
            local partName = snakeorder[i]
            local currentPart  = originalCharacter:FindFirstChild(partName)
            local previousPart = originalCharacter:FindFirstChild(snakeorder[i-1])
            if currentPart and previousPart then
                if not targetPositions[partName] then targetPositions[partName] = currentPart.CFrame end
                if not previousPositions[partName] then previousPositions[partName] = currentPart.CFrame end
                if isMoving then
                    local prevPartPos = previousPart.Position
                    local prevPartRot = previousPart.CFrame - previousPart.Position
                    local directionVector
                    if i == 2 then
                        directionVector = (prevPartPos - rootPart.Position).Unit
                    else
                        local beforePreviousPart = originalCharacter:FindFirstChild(snakeorder[i-2])
                        if beforePreviousPart then
                            directionVector = (prevPartPos - beforePreviousPart.Position).Unit
                        else
                            directionVector = prevPartRot.LookVector
                        end
                    end
                    if directionVector.Magnitude < 0.1 then directionVector = prevPartRot.LookVector end
                    local targetPosition = prevPartPos + directionVector * snakeDistance
                    targetPositions[partName] = CFrame.new(targetPosition) * prevPartRot
                end
                local smoothCF2 = previousPositions[partName]:Lerp(targetPositions[partName], snakeSmoothing)
                currentPart.CFrame = smoothCF2
                currentPart.AssemblyLinearVelocity = Vector3.zero
                currentPart.AssemblyAngularVelocity = Vector3.zero
                previousPositions[partName] = smoothCF2
            end
        end
    end
end

local function setSnakeEnabled(newState)
    ghostEnabled = newState
    if ghostEnabled then
        local char = LocalPlayer.Character; if not char then return end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        if originalCharacter or ghostClone then return end
        originalCharacter = char
        originalCFrame = root.CFrame
        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false
        ghostClone.Name = originalCharacter.Name .. "_clone"
        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalCharacter.Name .. "_clone"
            ghostHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then ghostClone.PrimaryPart = hrp end
        end
        for _, part in ipairs(ghostClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1; part.CanCollide = false
                part.Anchored = false; part.CanQuery = false
            elseif part:IsA("Decal") then
                part.Transparency = 1
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 1; handle.CanCollide = false; handle.CanQuery = false
                end
            end
        end
        local animate = originalCharacter:FindFirstChild("Animate")
        if animate then animate.Disabled = true; animate.Parent = ghostClone end
        ghostClone.Parent = workspace
        LocalPlayer.Character = ghostClone
        if ghostHumanoid then workspace.CurrentCamera.CameraSubject = ghostHumanoid end
        if animate and animate.Parent == ghostClone then animate.Disabled = false end
        -- Try game-specific ragdoll events
        pcall(function()
            game:GetService("ReplicatedStorage").Events.RagdollState:FireServer(true)
        end)
        targetPositions = {}; previousPositions = {}
        if snakeUpdateConn then snakeUpdateConn:Disconnect() end
        snakeUpdateConn = RunService.Heartbeat:Connect(updateSnakeParts)
    else
        if not originalCharacter or not ghostClone then return end
        if snakeUpdateConn then snakeUpdateConn:Disconnect() snakeUpdateConn = nil end
        pcall(function()
            game:GetService("ReplicatedStorage").Events.RagdollState:FireServer(false)
        end)
        local targetCF = originalCFrame
        local ghostPrimary = ghostClone.PrimaryPart
        if ghostPrimary then targetCF = ghostPrimary.CFrame end
        local animate = ghostClone:FindFirstChild("Animate")
        if animate then animate.Disabled = true; animate.Parent = originalCharacter end
        ghostClone:Destroy(); ghostClone = nil
        if originalCharacter and originalCharacter.Parent then
            local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
            local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
            if origRoot then
                origRoot.CFrame = targetCF
                origRoot.AssemblyLinearVelocity = Vector3.zero
                origRoot.AssemblyAngularVelocity = Vector3.zero
            end
            LocalPlayer.Character = originalCharacter
            if origHumanoid then
                workspace.CurrentCamera.CameraSubject = origHumanoid
                origHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            if animate and animate.Parent == originalCharacter then
                task.wait(0.1); animate.Disabled = false
            end
        end
        originalCharacter = nil
    end
end

local function openReanimGui()
    if reanimGuiRef then reanimGuiRef:Destroy() reanimGuiRef = nil end
    local G, Body = buildMiniGui("Reanimation", 280, 200, 300, 120)
    reanimGuiRef = G

    -- Title info
    local InfoLbl = Instance.new("TextLabel")
    InfoLbl.Size = UDim2.new(1,-28,0,36)
    InfoLbl.Position = UDim2.new(0,14,0,8)
    InfoLbl.BackgroundTransparency = 1
    InfoLbl.Text = "Snake Reanimation\nMakes your character snake-like while moving"
    InfoLbl.TextColor3 = Color3.fromRGB(150,150,150)
    InfoLbl.Font = Enum.Font.Gotham
    InfoLbl.TextSize = 12
    InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
    InfoLbl.TextWrapped = true
    InfoLbl.ZIndex = 52
    InfoLbl.Parent = Body

    -- Distance slider
    local _, getDist = makeSlider(Body, 52, "Snake Distance", 1, 100, 10)

    -- Smoothing slider  
    local _, getSmooth = makeSlider(Body, 110, "Smoothing", 1, 20, 1)

    -- Snake toggle button
    local SnakeBtn = makeBtn(Body, 170, 14, "🐍  Enable Snake Reanim", 252)
    SnakeBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
    SnakeBtn.MouseEnter:Connect(function()
        if not ghostEnabled then
            TweenService:Create(SnakeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30,110,30)}):Play()
        end
    end)
    SnakeBtn.MouseLeave:Connect(function()
        local col = ghostEnabled and Color3.fromRGB(80,20,20) or Color3.fromRGB(20,80,20)
        TweenService:Create(SnakeBtn, TweenInfo.new(0.1), {BackgroundColor3 = col}):Play()
    end)
    SnakeBtn.MouseButton1Click:Connect(function()
        snakeDistance  = getDist() / 10  -- scale 1-100 → 0.1-10
        snakeSmoothing = getSmooth() / 100  -- scale 1-20 → 0.01-0.2
        setSnakeEnabled(not ghostEnabled)
        if ghostEnabled then
            SnakeBtn.Text = "🐍  Disable Snake Reanim"
            SnakeBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
            showToast("Snake Reanim ON")
        else
            SnakeBtn.Text = "🐍  Enable Snake Reanim"
            SnakeBtn.BackgroundColor3 = Color3.fromRGB(20,80,20)
            showToast("Snake Reanim OFF")
        end
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent and ghostEnabled then
            setSnakeEnabled(false)
        end
    end)
end

-- ── BASEPLATE ────────────────────────────────────────────────
local baseplateGuiRef = nil
local baseplateConn   = nil
local baseplateActive = false
local baseplateRef    = nil  -- the actual baseplate part

local function openBaseplateGui()
    if baseplateGuiRef then baseplateGuiRef:Destroy() baseplateGuiRef = nil end

    local G, Body = buildMiniGui("Baseplate", 280, 260, 250, 180)
    baseplateGuiRef = G

    -- Find or create the baseplate
    local function getBaseplate()
        -- Try common baseplate names
        for _, part in ipairs(workspace:GetChildren()) do
            if part:IsA("BasePart") and (part.Name == "Baseplate" or part.Name == "Base" or part.Name == "SpawnLocation") then
                return part
            end
        end
        -- Create one if not found
        local bp = Instance.new("Part")
        bp.Name = "Baseplate"
        bp.Anchored = true
        bp.Size = Vector3.new(512, 4, 512)
        bp.Position = Vector3.new(0, -2, 0)
        bp.Color = Color3.fromRGB(106, 127, 63)
        bp.Material = Enum.Material.Grass
        bp.Parent = workspace
        return bp
    end

    baseplateRef = getBaseplate()

    -- Status label
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1,-28,0,18)
    StatusLbl.Position = UDim2.new(0,14,0,8)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "Baseplate: " .. tostring(math.round(baseplateRef and baseplateRef.Size.X or 512)) .. " studs"
    StatusLbl.TextColor3 = Color3.fromRGB(160,160,160)
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 12
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.ZIndex = 52
    StatusLbl.Parent = Body

    -- Size slider
    local _, getSize = makeSlider(Body, 30, "Size (studs)", 64, 12288, 512)

    -- Expand button
    local ExpandBtn = makeBtn(Body, 90, 14, "Expand Baseplate", 242)
    ExpandBtn.MouseButton1Click:Connect(function()
        baseplateRef = getBaseplate()
        if not baseplateRef then showToast("No baseplate found") return end
        local sz = getSize()
        TweenService:Create(baseplateRef, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(sz, baseplateRef.Size.Y, sz)
        }):Play()
        StatusLbl.Text = "Baseplate: " .. sz .. " studs"
        showToast("Baseplate → " .. sz .. " studs")
    end)

    -- Walk-expand toggle
    local walkActive = false
    local WalkBtn = makeBtn(Body, 132, 14, "Walk Expand: OFF", 242)
    WalkBtn.MouseButton1Click:Connect(function()
        walkActive = not walkActive
        WalkBtn.Text = walkActive and "Walk Expand: ON" or "Walk Expand: OFF"
        showToast(walkActive and "Walk expand ON" or "Walk expand OFF")
        if walkActive then
            baseplateConn = RunService.Heartbeat:Connect(function()
                if not walkActive then
                    if baseplateConn then baseplateConn:Disconnect() baseplateConn = nil end
                    return
                end
                local char = LocalPlayer.Character; if not char then return end
                local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                local bp   = baseplateRef or getBaseplate(); if not bp then return end
                -- Expand by 2 studs per frame near edges
                local distFromCenter = Vector3.new(hrp.Position.X, 0, hrp.Position.Z).Magnitude
                local halfSize = bp.Size.X / 2
                if distFromCenter > halfSize * 0.7 then
                    local newSize = math.min(bp.Size.X + 4, 12288)
                    bp.Size = Vector3.new(newSize, bp.Size.Y, newSize)
                    StatusLbl.Text = "Baseplate: " .. math.round(newSize) .. " studs"
                end
            end)
        else
            if baseplateConn then baseplateConn:Disconnect() baseplateConn = nil end
        end
    end)

    -- Colour presets
    local ColourLbl = Instance.new("TextLabel")
    ColourLbl.Size = UDim2.new(1,-28,0,16)
    ColourLbl.Position = UDim2.new(0,14,0,174)
    ColourLbl.BackgroundTransparency = 1
    ColourLbl.Text = "Colour:"
    ColourLbl.TextColor3 = Color3.fromRGB(140,140,140)
    ColourLbl.Font = Enum.Font.Gotham
    ColourLbl.TextSize = 12
    ColourLbl.TextXAlignment = Enum.TextXAlignment.Left
    ColourLbl.ZIndex = 52
    ColourLbl.Parent = Body

    local colours = {
        {name="Green",  col=Color3.fromRGB(106,127,63)},
        {name="Grey",   col=Color3.fromRGB(105,105,105)},
        {name="White",  col=Color3.fromRGB(242,243,243)},
        {name="Black",  col=Color3.fromRGB(27,42,53)},
        {name="Red",    col=Color3.fromRGB(196,40,28)},
        {name="Blue",   col=Color3.fromRGB(13,105,172)},
        {name="Yellow", col=Color3.fromRGB(245,205,48)},
        {name="Pink",   col=Color3.fromRGB(255,102,204)},
    }

    local ColRow = Instance.new("Frame")
    ColRow.Size = UDim2.new(1,-28,0,32)
    ColRow.Position = UDim2.new(0,14,0,193)
    ColRow.BackgroundTransparency = 1
    ColRow.ZIndex = 52
    ColRow.Parent = Body

    local ColLayout = Instance.new("UIListLayout")
    ColLayout.FillDirection = Enum.FillDirection.Horizontal
    ColLayout.Padding = UDim.new(0,5)
    ColLayout.Parent = ColRow

    for _, c in ipairs(colours) do
        local Swatch = Instance.new("TextButton")
        Swatch.Size = UDim2.new(0,26,0,26)
        Swatch.BackgroundColor3 = c.col
        Swatch.Text = ""
        Swatch.BorderSizePixel = 0
        Swatch.ZIndex = 53
        Swatch.Parent = ColRow
        makeCorner(Swatch, 6)
        Swatch.MouseButton1Click:Connect(function()
            baseplateRef = getBaseplate()
            if baseplateRef then
                baseplateRef.Color = c.col
                showToast("Baseplate → " .. c.name)
            end
        end)
        Swatch.MouseEnter:Connect(function()
            TweenService:Create(Swatch, TweenInfo.new(0.1), {Size = UDim2.new(0,30,0,30)}):Play()
        end)
        Swatch.MouseLeave:Connect(function()
            TweenService:Create(Swatch, TweenInfo.new(0.1), {Size = UDim2.new(0,26,0,26)}):Play()
        end)
    end

    -- Reset button
    local ResetBtn = makeBtn(Body, 232, 14, "Reset Size", 116)
    ResetBtn.MouseButton1Click:Connect(function()
        baseplateRef = getBaseplate()
        if baseplateRef then
            TweenService:Create(baseplateRef, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                Size = Vector3.new(512, baseplateRef.Size.Y, 512)
            }):Play()
            StatusLbl.Text = "Baseplate: 512 studs"
            showToast("Baseplate reset to 512")
        end
    end)

    G.AncestryChanged:Connect(function()
        if not G.Parent then
            if baseplateConn then baseplateConn:Disconnect() baseplateConn = nil end
        end
    end)
end

-- ── EMOTES ───────────────────────────────────────────────────
local function loadEmotes()
    showToast("Loading Emotes...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    end)
end

local function loadEmotes2()
    showToast("Loading Emotes 2...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs"))()
    end)
end

-- fakeout: rapidly randomises HumanoidRootPart CFrame each frame so
-- anyone trying to sit on you or facebang you gets thrown off
local fakeoutActive = false
local fakeoutConn   = nil

local function toggleFakeout()
    fakeoutActive = not fakeoutActive
    showToast(fakeoutActive and "Fakeout ON — blocking grabs" or "Fakeout OFF")

    if fakeoutActive then
        fakeoutConn = RunService.Heartbeat:Connect(function()
            if not fakeoutActive then
                if fakeoutConn then fakeoutConn:Disconnect() fakeoutConn = nil end
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- jitter position very slightly so HRP-lock scripts can't stick
            local jitter = Vector3.new(
                math.random(-4, 4) * 0.01,
                0,
                math.random(-4, 4) * 0.01
            )
            hrp.CFrame = hrp.CFrame + jitter
        end)
    else
        if fakeoutConn then fakeoutConn:Disconnect() fakeoutConn = nil end
    end
end

-- ── FLASH TELEPORT (;ftp) ─────────────────────────────────────
-- Toggle with ;ftp — while active press F to teleport to mouse silently.
local ftpActive = false
local ftpConn   = nil
local ftpMouse  = LocalPlayer:GetMouse()

local function toggleFTP()
    if ftpConn then ftpConn:Disconnect() ftpConn = nil end
    ftpActive = not ftpActive
    showToast(ftpActive and ";ftp  ON  —  press F to teleport" or ";ftp  OFF")
    if not ftpActive then return end

    ftpConn = UserInputService.InputBegan:Connect(function(inp, gameProcessed)
        if gameProcessed and UserInputService:GetFocusedTextBox() then return end
        if inp.KeyCode ~= Enum.KeyCode.F then return end
        if not ftpActive then return end

        local myChar = LocalPlayer.Character; if not myChar then return end
        local myHRP  = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end

        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {myChar}
        params.FilterType = Enum.RaycastFilterType.Exclude

        local unitRay = Camera:ScreenPointToRay(ftpMouse.X, ftpMouse.Y)
        local result  = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, params)

        local target
        if result then
            target = result.Position + Vector3.new(0, 3, 0)
        else
            target = ftpMouse.Hit.Position + Vector3.new(0, 3, 0)
        end

        myHRP.CFrame = CFrame.new(target)
    end)
end

-- ============================================================
--          CHAT COMMAND LISTENER (type in chat)
-- ============================================================
local function setupChatListener()
    local function handleCmd(rawMsg)
        -- Keep original case for name arguments, lowercase only the command part
        local msg = rawMsg:lower():gsub("^%s+",""):gsub("%s+$","")

        -- Commands with name arguments — parse before lowercasing names
        if msg:sub(1,6) == ";hide " then
            local name = rawMsg:gsub("^%s*",""):sub(7)  -- preserve case for name
            hidePlayer(name)
            return
        elseif msg:sub(1,8) == ";unhide " then
            local name = rawMsg:gsub("^%s*",""):sub(9)
            unhidePlayer(name)
            return
        elseif msg == ";hide" or msg == ";unhide" then
            showToast("Usage: ;hide PlayerName  /  ;unhide PlayerName")
            return
        end

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
        elseif msg == ";emotes"   then loadEmotes()
        elseif msg == ";emotes2"  then loadEmotes2()
        elseif msg == ";fakeout"  then toggleFakeout()
        elseif msg == ";facepalm" then toggleFacepalm()
        elseif msg == ";timereverse" then toggleTimeReverse()
        elseif msg == ";facebang"  then loadFacebang()
        elseif msg == ";headsit"   then openHeadsitGui()
        elseif msg == ";jerk"      then toggleJerk()
        elseif msg == ";lock"      then openLockGui()
        elseif msg == ";iy"        then loadIY()
        elseif msg == ";esp"      then toggleESP()
        elseif msg == ";box"      then toggleBox()
        elseif msg == ";chams"    then toggleChams()
        elseif msg == ";fullbright" then toggleFullbright()
        elseif msg == ";reanim"   then openReanimGui()
        elseif msg == ";baseplate" then openBaseplateGui()
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
    [";emotes"]     = loadEmotes,
    [";emotes2"]    = loadEmotes2,
    [";fakeout"]    = toggleFakeout,
    [";facepalm"]   = toggleFacepalm,
    [";timereverse"]= toggleTimeReverse,
    [";facebang"]   = loadFacebang,
    [";headsit"]    = openHeadsitGui,
    [";jerk"]       = toggleJerk,
    [";iy"]         = loadIY,
    [";esp"]        = toggleESP,
    [";box"]        = toggleBox,
    [";chams"]      = toggleChams,
    [";fullbright"] = toggleFullbright,
    [";reanim"]     = openReanimGui,
    [";baseplate"]  = openBaseplateGui,
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
                local isExternal = cmd.cat == "EXTERNALS"

                if cmd.cat~=lastCat then
                    local CatLbl=Instance.new("TextLabel")
                    CatLbl.Size=UDim2.new(1,0,0,24) CatLbl.BackgroundTransparency=1
                    CatLbl.Text=cmd.cat
                    -- EXTERNALS gets gold colour to stand out
                    CatLbl.TextColor3 = isExternal and Color3.fromRGB(255,200,40) or Color3.fromRGB(140,140,140)
                    CatLbl.Font=Enum.Font.GothamBold CatLbl.TextSize=10
                    CatLbl.TextXAlignment=Enum.TextXAlignment.Left CatLbl.ZIndex=24
                    CatLbl.LayoutOrder=i*10-1 CatLbl.Parent=CmdScroll
                    lastCat=cmd.cat
                end

                -- EXTERNALS rows get a darker gold background
                local rowBg = isExternal and Color3.fromRGB(35,28,8) or Color3.fromRGB(22,22,22)
                local rowStroke = isExternal and Color3.fromRGB(80,60,10) or Color3.fromRGB(34,34,34)
                local Row=Instance.new("TextButton")
                Row.Size=UDim2.new(1,0,0,44) Row.BackgroundColor3=rowBg
                Row.BorderSizePixel=0 Row.Text="" Row.AutoButtonColor=false
                Row.ZIndex=24 Row.LayoutOrder=i*10 Row.Parent=CmdScroll
                makeCorner(Row,8) makeStroke(Row,rowStroke,1)

                Row.MouseEnter:Connect(function()
                    local hov = isExternal and Color3.fromRGB(50,38,10) or Color3.fromRGB(30,30,30)
                    TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=hov}):Play()
                end)
                Row.MouseLeave:Connect(function()
                    TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=rowBg}):Play()
                end)

                local action=cmdActions[cmd.key]
                if action then Row.MouseButton1Click:Connect(action) end

                -- Key label — yellow for EXTERNALS
                local KeyLbl=Instance.new("TextLabel")
                KeyLbl.Size=UDim2.new(0,140,1,0) KeyLbl.Position=UDim2.new(0,14,0,0)
                KeyLbl.BackgroundTransparency=1 KeyLbl.Text=cmd.key
                KeyLbl.TextColor3 = isExternal and Color3.fromRGB(255,210,40) or Color3.fromRGB(255,255,255)
                KeyLbl.Font=Enum.Font.GothamBold
                KeyLbl.TextSize=13 KeyLbl.TextXAlignment=Enum.TextXAlignment.Left KeyLbl.ZIndex=25 KeyLbl.Parent=Row

                local Div=Instance.new("Frame")
                Div.Size=UDim2.new(0,1,0,16) Div.Position=UDim2.new(0,152,0.5,-8)
                Div.BackgroundColor3=Color3.fromRGB(50,50,50) Div.BorderSizePixel=0 Div.ZIndex=25 Div.Parent=Row

                local DescLbl=Instance.new("TextLabel")
                DescLbl.Size=UDim2.new(1,-172,1,0) DescLbl.Position=UDim2.new(0,164,0,0)
                DescLbl.BackgroundTransparency=1 DescLbl.Text=cmd.desc
                DescLbl.TextColor3 = isExternal and Color3.fromRGB(200,170,80) or Color3.fromRGB(165,165,165)
                DescLbl.Font=Enum.Font.Gotham
                DescLbl.TextSize=12 DescLbl.TextXAlignment=Enum.TextXAlignment.Left DescLbl.ZIndex=25 DescLbl.Parent=Row

                if action then
                    local ActDot=Instance.new("Frame")
                    ActDot.Size=UDim2.new(0,5,0,5) ActDot.Position=UDim2.new(1,-10,0.5,-2.5)
                    ActDot.BackgroundColor3 = isExternal and Color3.fromRGB(255,200,40) or Color3.fromRGB(180,180,180)
                    ActDot.BorderSizePixel=0 ActDot.ZIndex=25 ActDot.Parent=Row
                    makeCorner(ActDot,99)
                end
                shown+=1
            end
        end
        CountLbl.Text=shown.." commands"
    end

    buildCmdRows()
    LSearchBox:GetPropertyChangedSignal("Text"):Connect(function() buildCmdRows(LSearchBox.Text) end)

    -- ── RIGHT PANEL — empty (Reanimation moved to ;reanim command) ──
    local RightBg=Instance.new("Frame")
    RightBg.Size=UDim2.new(1,-(LeftW+1),1,0) RightBg.Position=UDim2.new(0,LeftW+1,0,0)
    RightBg.BackgroundColor3=Color3.fromRGB(14,14,14) RightBg.BorderSizePixel=0
    RightBg.ZIndex=22 RightBg.Parent=Window

    -- Centered hint text
    local HintLbl=Instance.new("TextLabel")
    HintLbl.Size=UDim2.new(1,-40,0,60) HintLbl.Position=UDim2.new(0,20,0.5,-30)
    HintLbl.BackgroundTransparency=1
    HintLbl.Text="Type  ;reanim  or click it\nin the commands list\nto open the dance menu"
    HintLbl.TextColor3=Color3.fromRGB(55,55,55) HintLbl.Font=Enum.Font.Gotham
    HintLbl.TextSize=13 HintLbl.TextXAlignment=Enum.TextXAlignment.Center
    HintLbl.TextWrapped=true HintLbl.ZIndex=23 HintLbl.Parent=RightBg

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

    local TagsPill = makePill(Color3.fromRGB(255,255,255), "Tags", nil, true)
    TagsPill.Parent = Bar
    local tagsVisible = true
    TagsPill.MouseEnter:Connect(function()
        TweenService:Create(TagsPill, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45,40,60)}):Play()
    end)
    TagsPill.MouseLeave:Connect(function()
        local col = tagsVisible and Color3.fromRGB(28,24,38) or Color3.fromRGB(60,20,20)
        TweenService:Create(TagsPill, TweenInfo.new(0.1), {BackgroundColor3 = col}):Play()
    end)
    TagsPill.MouseButton1Click:Connect(function()
        tagsVisible = not tagsVisible
        -- Toggle all GhoulNameTag BillboardGuis in the whole workspace
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("GhoulNameTag")
                    if tag then tag.Enabled = tagsVisible end
                end
            end
        end
        TagsPill.BackgroundColor3 = tagsVisible and Color3.fromRGB(28,24,38) or Color3.fromRGB(60,20,20)
        showToast(tagsVisible and "Tags  ON" or "Tags  OFF")
    end)

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

    -- ── CUSTOM NAMETAGS ──────────────────────────────────────────
    -- Only injectors get the Ghoul User tag.
    -- VIP IDs get their own tag regardless of injection.

    local OWNER_ID   = 8046725466
    local CIVITCC_ID = 2638943293
    local BANRI_ID   = 5431956202
    local TEA_ID     = 10670249589

    local function buildTag(head, cfg)
        local existing = head:FindFirstChild("GhoulNameTag")
        if existing then existing:Destroy() end

        local bb = Instance.new("BillboardGui")
        bb.Name         = "GhoulNameTag"
        bb.Size         = UDim2.new(0, cfg.w or 220, 0, cfg.h or 54)
        bb.StudsOffset  = Vector3.new(0, cfg.y or 2.6, 0)
        bb.AlwaysOnTop  = false
        bb.MaxDistance  = 80
        bb.ResetOnSpawn = false
        bb.Parent       = head

        -- Black pill background
        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.35
        bg.BorderSizePixel        = 0
        bg.ZIndex                 = 3
        bg.Parent                 = bb
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 12)
        bgCorner.Parent = bg

        -- White border stroke on the background
        local bgStroke = Instance.new("UIStroke")
        bgStroke.Color     = Color3.fromRGB(255, 255, 255)
        bgStroke.Thickness = 2.5
        bgStroke.Transparency = 0
        bgStroke.Parent    = bg

        -- White outline text label behind main label for readability
        local outline = Instance.new("TextLabel")
        outline.Size                   = UDim2.new(1, 8, 1, 8)
        outline.Position               = UDim2.new(0, -4, 0, -4)
        outline.BackgroundTransparency = 1
        outline.Font                   = Enum.Font.GothamBold
        outline.TextScaled             = false
        outline.TextSize               = (cfg.size or 20) + 1
        outline.Text                   = cfg.text
        outline.TextColor3             = Color3.fromRGB(255, 255, 255)
        outline.TextStrokeColor3       = Color3.fromRGB(255, 255, 255)
        outline.TextStrokeTransparency = 0
        outline.ZIndex                 = 4
        outline.Parent                 = bb

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextScaled             = false
        lbl.TextSize               = cfg.size or 20
        lbl.Text                   = cfg.text
        lbl.TextColor3             = cfg.color
        lbl.TextStrokeColor3       = cfg.stroke or Color3.fromRGB(0, 0, 0)
        lbl.TextStrokeTransparency = cfg.strokeT or 0.3
        lbl.ZIndex                 = 5
        lbl.Parent                 = bb

        -- E key to teleport to this player
        -- We listen globally for E key and check which player is closest to crosshair
        -- The BillboardGui has an invisible TextButton overlay that catches click/tap too
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size                   = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text                   = ""
        clickBtn.ZIndex                 = 6
        clickBtn.Parent                 = bb
        clickBtn.MouseButton1Click:Connect(function()
            -- Click the tag to teleport AND lock onto this player
            local myChar = LocalPlayer.Character; if not myChar then return end
            local myHRP  = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            if head and head.Parent then
                local targetHRP = head.Parent:FindFirstChild("HumanoidRootPart")
                local plr = Players:GetPlayerFromCharacter(head.Parent)
                if targetHRP then
                    myHRP.CFrame = targetHRP.CFrame + Vector3.new(3, 0, 0)
                    showToast("Teleported to " .. head.Parent.Name)
                end
                -- Also set as aimlock target so clicking through walls locks onto them
                if plr and plr ~= LocalPlayer then
                    lockTarget = plr
                    showToast("Locked → " .. plr.DisplayName)
                end
            end
        end)

        return bb, lbl, outline
    end

    local function applyTagForId(userId, head)
        if userId == OWNER_ID then
            local bb, lbl, outline = buildTag(head, {
                text = "👑 Ghoul OWNER", color = Color3.fromRGB(255,30,30),
                stroke = Color3.fromRGB(60,0,0), strokeT = 0,
                size = 19, w = 230, h = 48, y = 2.6,
            })
            -- Override the outline to dark red instead of white so the tag reads red throughout
            outline.TextColor3             = Color3.fromRGB(180, 0, 0)
            outline.TextStrokeColor3       = Color3.fromRGB(80, 0, 0)
            outline.TextStrokeTransparency = 0

            local gc = RunService.Heartbeat:Connect(function()
                if not head.Parent then gc:Disconnect() return end
                local fire = math.sin(tick() * 38) > 0.82
                if fire then
                    bb.StudsOffset = Vector3.new(math.random(-3,3)*0.05, 2.6+math.random(-2,2)*0.04, 0)
                    local bright = math.random() > 0.5
                    local col    = bright and Color3.fromRGB(255,0,0) or Color3.fromRGB(200,30,30)
                    lbl.TextColor3     = col
                    outline.TextColor3 = bright and Color3.fromRGB(160,0,0) or Color3.fromRGB(120,0,0)
                    local txt = math.random()>0.88 and "👑 Gh0ul 0WNER" or "👑 Ghoul OWNER"
                    lbl.Text = txt; outline.Text = txt
                else
                    bb.StudsOffset     = Vector3.new(0,2.6,0)
                    lbl.TextColor3     = Color3.fromRGB(255,30,30)
                    outline.TextColor3 = Color3.fromRGB(180,0,0)
                    lbl.Text = "👑 Ghoul OWNER"; outline.Text = "👑 Ghoul OWNER"
                end
            end)

        elseif userId == CIVITCC_ID then
            local bb, lbl, outline = buildTag(head, {
                text = "Civiticc clout chaser", color = Color3.fromRGB(25,45,160),
                stroke = Color3.fromRGB(5,10,60), strokeT = 0,
                size = 16, w = 260, h = 44, y = 2.4,
            })
            local gc = RunService.Heartbeat:Connect(function()
                if not head.Parent then gc:Disconnect() return end
                local fire = math.sin(tick() * 35) > 0.84
                if fire then
                    bb.StudsOffset = Vector3.new(math.random(-2,2)*0.04, 2.4, 0)
                    lbl.TextColor3 = math.random()>0.5 and Color3.fromRGB(15,30,130) or Color3.fromRGB(40,60,200)
                    local alts = {"C1viticc clout chaser","Civiticc cl0ut chaser","Civiticc clout ch4ser"}
                    local txt = math.random()>0.85 and alts[math.random(1,3)] or "Civiticc clout chaser"
                    lbl.Text = txt; outline.Text = txt
                else
                    bb.StudsOffset = Vector3.new(0,2.4,0)
                    lbl.TextColor3 = Color3.fromRGB(25,45,160)
                    lbl.Text = "Civiticc clout chaser"; outline.Text = "Civiticc clout chaser"
                end
            end)

        elseif userId == BANRI_ID then
            local bb, lbl, outline = buildTag(head, {
                text = "✦ Banri ✦", color = Color3.fromRGB(170,80,255),
                stroke = Color3.fromRGB(90,0,180), strokeT = 0,
                size = 19, w = 190, h = 48, y = 2.5,
            })
            local gc = RunService.Heartbeat:Connect(function()
                if not head.Parent then gc:Disconnect() return end
                local pulse = math.abs(math.sin(tick() * 2.5))
                lbl.TextStrokeTransparency    = 1 - pulse * 0.9
                outline.TextStrokeTransparency = 1 - pulse * 0.6
                lbl.TextColor3 = Color3.fromRGB(math.min(math.floor(170+pulse*60),255), math.max(math.floor(80-pulse*20),0), 255)
            end)

        elseif userId == TEA_ID then
            buildTag(head, {
                text = "Tea Drinker", color = Color3.fromRGB(255,182,210),
                stroke = Color3.fromRGB(120,40,80), strokeT = 0.2,
                size = 17, w = 200, h = 44, y = 2.4,
            })

        else
            buildTag(head, {
                text = "Ghoul User", color = Color3.fromRGB(220,220,220),
                stroke = Color3.fromRGB(0,0,0), strokeT = 0.5,
                size = 17, w = 180, h = 42, y = 2.3,
            })
        end
    end

    -- Self tag — only the injector gets "Ghoul User" (or their VIP tag)
    -- CharacterAdded fires on respawn AND on outfit/model swaps (Mic Up modify etc.)
    local function setupSelfTag(char)
        if not char then return end
        task.wait(0.5)
        local head = char:FindFirstChild("Head"); if not head then return end
        applyTagForId(LocalPlayer.UserId, head)
    end
    if LocalPlayer.Character then task.spawn(setupSelfTag, LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(char) task.spawn(setupSelfTag, char) end)

    -- VIP tags — apply to hardcoded IDs whenever they're in the server
    local VIP_IDS = { OWNER_ID, CIVITCC_ID, BANRI_ID, TEA_ID }
    local function checkVIPTag(plr)
        local isVIP = false
        for _, id in ipairs(VIP_IDS) do if plr.UserId == id then isVIP = true break end end
        if not isVIP then return end
        local function setup(char)
            task.wait(0.5)
            local head = char and char:FindFirstChild("Head"); if not head then return end
            applyTagForId(plr.UserId, head)
        end
        if plr.Character then task.spawn(setup, plr.Character) end
        -- Also reconnect on character change so outfit swaps persist the tag
        plr.CharacterAdded:Connect(function(char) task.spawn(setup, char) end)
    end
    for _, plr in ipairs(Players:GetPlayers()) do checkVIPTag(plr) end
    Players.PlayerAdded:Connect(checkVIPTag)

    -- H key: hide FOV circle + kill silent aim + kill aimlock all at once
    -- Press again to bring the FOV circle back (aim stays off until you re-enable)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp and UserInputService:GetFocusedTextBox() then return end
        if inp.KeyCode ~= Enum.KeyCode.H then return end

        fovHidden = not fovHidden

        if fovHidden then
            -- Destroy the circle
            if lockFovGui then lockFovGui:Destroy() lockFovGui = nil end
            -- Kill silent aim
            if silentAimActive then
                silentAimActive = false
                RunService:UnbindFromRenderStep("GhoulSilentAim")
            end
            -- Kill aimlock
            if aimlockEnabled then
                aimlockEnabled = false
                if aimlockConn then aimlockConn:Disconnect() aimlockConn = nil end
            end
            showToast("H — Aim OFF + FOV hidden")
        else
            -- Redraw circle if either aim mode is on
            updateFovCircle()
            showToast("H — FOV visible")
        end
    end)

    -- E key: teleport to the closest player who has a GhoulNameTag
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp and UserInputService:GetFocusedTextBox() then return end
        if inp.KeyCode ~= Enum.KeyCode.E then return end
        local myChar = LocalPlayer.Character; if not myChar then return end
        local myHRP  = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        local best, bestDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                local head = plr.Character:FindFirstChild("Head")
                if tHRP and head and head:FindFirstChild("GhoulNameTag") then
                    local d = (tHRP.Position - myHRP.Position).Magnitude
                    if d < bestDist then bestDist = d; best = tHRP end
                end
            end
        end
        if best then
            myHRP.CFrame = best.CFrame + Vector3.new(3, 0, 0)
            showToast("E — Teleported to " .. best.Parent.Name)
        end
    end)

    -- Comma key: open/close the commands panel (matches the requested keybind)
    UserInputService.InputBegan:Connect(function(inp, gameProcessed)
        if gameProcessed then return end
        if inp.KeyCode == Enum.KeyCode.Comma then
            buildCommandsPanel()
        end
    end)
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
