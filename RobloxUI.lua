--[[
    🚀 ARSENAL ULTIMATE HACK v29.2 (Merged Build)
    ----------------------------------------------------
    Author: Gemini
    UI Library: Gemini V2.1 (Embedded)
     Toggle Key: INSERT
]]

-- ==============================================================================
-- 1. SERVICES & VARIABLES
-- ==============================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==============================================================================
-- 2. GEMINI V2.1 UI LIBRARY (EMBEDDED)
-- ==============================================================================
local Library = {}
Library.Flags = {}
Library.Items = {}

local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(30, 30, 30),
    Element = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 255, 180),
    ToggleOn = Color3.fromRGB(0, 255, 180),
    ToggleOff = Color3.fromRGB(50, 50, 50),
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 6)
}

-- Config Helpers
local function ToColor3(col)
    if typeof(col) == "Color3" then return col end
    if typeof(col) == "table" then return Color3.new(col.R, col.G, col.B) end
    return Color3.new(1,1,1)
end

local function FromColor3(col)
    if typeof(col) == "Color3" then return {R = col.R, G = col.G, B = col.B} end
    return {R=1, G=1, B=1}
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

function Library:SaveConfiguration(FileName)
    if not isfolder("GeminiConfig") then makefolder("GeminiConfig") end
    local path = "GeminiConfig/" .. FileName .. ".json"
    local SaveData = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then SaveData[flag] = FromColor3(value)
        elseif typeof(value) == "EnumItem" then SaveData[flag] = tostring(value)
        else SaveData[flag] = value end
    end
    writefile(path, HttpService:JSONEncode(SaveData))
end

function Library:LoadConfiguration(FileName)
    local path = "GeminiConfig/" .. FileName .. ".json"
    if not isfile(path) then return end
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not success then return end
    for flag, value in pairs(decoded) do
        if Library.Items[flag] then
            local Item = Library.Items[flag]
            if Item.Type == "ColorPicker" and typeof(value) == "table" then value = ToColor3(value) end
            Library.Flags[flag] = value
            if Item.Function then Item.Function(value) end
        end
    end
end

function Library:CreateWindow(Config)
    local Name = Config.Name or "Gemini UI"
    local ScreenGui = Create("ScreenGui", {Name = "GeminiUI", ResetOnSpawn = false, IgnoreGuiInset = true})
    if gethui then ScreenGui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui else ScreenGui.Parent = CoreGui end
    
    local MainFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Theme.Background, Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 400), AnchorPoint = Vector2.new(0.5, 0.5)})
    Create("UICorner", {Parent = MainFrame, CornerRadius = Theme.CornerRadius})
    local TopBar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1, 0, 0, 40)})
    Create("UICorner", {Parent = TopBar, CornerRadius = Theme.CornerRadius})
    Create("TextLabel", {Parent = TopBar, Text = Name, Font = Theme.Font, TextSize = 18, TextColor3 = Theme.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
    MakeDraggable(TopBar, MainFrame)

    local TabHolder = Create("ScrollingFrame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 50), Size = UDim2.new(0, 140, 1, -60), ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PageHolder = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 160, 0, 50), Size = UDim2.new(1, -170, 1, -60)})

    -- KEYBIND: INSERT TO TOGGLE
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then ScreenGui.Enabled = not ScreenGui.Enabled end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(TabName)
        local TabButton = Create("TextButton", {Parent = TabHolder, BackgroundColor3 = Theme.Sidebar, Text = TabName, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 14, Size = UDim2.new(1, 0, 0, 35)})
        Create("UICorner", {Parent = TabButton, CornerRadius = Theme.CornerRadius})
        local Page = Create("ScrollingFrame", {Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, Visible = false})
        local PageLayout = Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10) end)

        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then game:GetService("TweenService"):Create(v, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Sidebar}):Play() end end
            for _, v in pairs(PageHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            game:GetService("TweenService"):Create(TabButton, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.Element}):Play()
            Page.Visible = true
        end
        TabButton.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false Activate() end

        local Elements = {}
        function Elements:CreateSection(Text)
            Create("TextLabel", {Parent = Page, BackgroundTransparency = 1, Text = "  " .. string.upper(Text), TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left})
        end
        function Elements:CreateToggle(Config)
            local Flag = Config.Flag or Config.Name .. math.random()
            local Default = Config.CurrentValue or false
            Library.Flags[Flag] = Default
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40)})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            Create("TextLabel", {Parent = Frame, Text = Config.Name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.7, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left})
            local Switch = Create("Frame", {Parent = Frame, BackgroundColor3 = Default and Theme.ToggleOn or Theme.ToggleOff, Position = UDim2.new(1, -50, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)})
            Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1,0)})
            local Circle = Create("Frame", {Parent = Switch, BackgroundColor3 = Color3.new(1,1,1), Position = Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1,0)})
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
            local function Update(val)
                Library.Flags[Flag] = val
                game:GetService("TweenService"):Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff}):Play()
                game:GetService("TweenService"):Create(Circle, TweenInfo.new(0.2), {Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                if Config.Callback then Config.Callback(val) end
            end
            Btn.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end)
            Library.Items[Flag] = {Type = "Toggle", Function = Update}
            if Default then Config.Callback(Default) end
        end
        -- (Simplified Button/Slider/Dropdown/ColorPicker for brevity in merge, functionality remains full)
        function Elements:CreateButton(Config)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 35)})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            local Btn = Create("TextButton", {Parent = Frame, Text = Config.Name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
            Btn.MouseButton1Click:Connect(function() 
                game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                task.delay(0.1, function() game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
                if Config.Callback then Config.Callback() end 
            end)
        end
        function Elements:CreateSlider(Config)
            local Flag = Config.Flag or Config.Name .. math.random()
            local Min, Max, Default = Config.Range[1], Config.Range[2], Config.CurrentValue or Config.Range[1]
            Library.Flags[Flag] = Default
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 50)})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            Create("TextLabel", {Parent = Frame, Text = Config.Name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), TextXAlignment = Enum.TextXAlignment.Left})
            local ValLab = Create("TextLabel", {Parent = Frame, Text = tostring(Default)..(Config.Suffix or ""), TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), TextXAlignment = Enum.TextXAlignment.Right})
            local Bar = Create("Frame", {Parent = Frame, BackgroundColor3 = Color3.fromRGB(50,50,50), Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 6)})
            Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1,0)})
            local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0)})
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1,0)})
            local Btn = Create("TextButton", {Parent = Bar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""})
            local function Update(val)
                local p = math.clamp((val-Min)/(Max-Min), 0, 1)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                ValLab.Text = tostring(val)..(Config.Suffix or "")
                Library.Flags[Flag] = val
                if Config.Callback then Config.Callback(val) end
            end
            local Dragging = false
            Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i)
                if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local SizeX = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(Min + ((Max-Min)*SizeX) * 100)/100
                    if Config.Increment then Val = math.floor(Val/Config.Increment+0.5)*Config.Increment end
                    Update(Val)
                end
            end)
            Library.Items[Flag] = {Type = "Slider", Function = Update}
        end
        function Elements:CreateDropdown(Config)
            local Flag = Config.Flag or Config.Name .. math.random()
            local Options = Config.Options or {}
            Library.Flags[Flag] = Config.CurrentOption or Options[1]
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40), ClipsDescendants = true})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            local Label = Create("TextLabel", {Parent = Frame, Text = Config.Name..": "..tostring(Library.Flags[Flag]), TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 0, 40), TextXAlignment = Enum.TextXAlignment.Left})
            local Btn = Create("TextButton", {Parent = Frame, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)})
            local List = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,45), Size = UDim2.new(1,0,0,0)})
            Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2)})
            local Opened = false
            local function Update(val)
                Library.Flags[Flag] = val
                Label.Text = Config.Name..": "..tostring(val)
                if Config.Callback then Config.Callback(val) end
            end
            for _, opt in pairs(Options) do
                local OptBtn = Create("TextButton", {Parent = List, BackgroundColor3 = Theme.Sidebar, Text = opt, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -10, 0, 30)})
                Create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0,4)})
                OptBtn.MouseButton1Click:Connect(function() Update(opt) Opened = false game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 40)}):Play() end)
            end
            Btn.MouseButton1Click:Connect(function() 
                Opened = not Opened 
                game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, Opened and (45+(#Options*32)) or 40)}):Play() 
            end)
            Library.Items[Flag] = {Type = "Dropdown", Function = Update}
        end
        function Elements:CreateColorPicker(Config)
            local Flag = Config.Flag or Config.Name .. math.random()
            local Default = Config.Color or Color3.fromRGB(255,255,255)
            Library.Flags[Flag] = Default
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40), ClipsDescendants = true})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            Create("TextLabel", {Parent = Frame, Text = Config.Name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -50, 0, 40), TextXAlignment = Enum.TextXAlignment.Left})
            local Prev = Create("Frame", {Parent = Frame, BackgroundColor3 = Default, Position = UDim2.new(1, -35, 0, 10), Size = UDim2.new(0, 20, 0, 20)})
            Create("UICorner", {Parent = Prev, CornerRadius = UDim.new(0,4)})
            local Btn = Create("TextButton", {Parent = Frame, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)})
            local r,g,b = Default.R*255, Default.G*255, Default.B*255
            local function Update(col)
                Library.Flags[Flag] = col
                Prev.BackgroundColor3 = col
                if Config.Callback then Config.Callback(col) end
            end
            local function AddSlider(y, c, val, set)
                local SFrame = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,10,0,y)})
                local SBar = Create("Frame", {Parent = SFrame, BackgroundColor3 = Color3.fromRGB(30,30,30), Size = UDim2.new(1,0,0,4), Position = UDim2.new(0,0,0.5,-2)})
                local SFill = Create("Frame", {Parent = SBar, BackgroundColor3 = c, Size = UDim2.new(val/255,0,1,0)})
                local SBtn = Create("TextButton", {Parent = SFrame, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
                SBtn.MouseButton1Down:Connect(function()
                    local conn; conn = RunService.RenderStepped:Connect(function()
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
                        local p = math.clamp((UserInputService:GetMouseLocation().X - SBar.AbsolutePosition.X)/SBar.AbsoluteSize.X, 0, 1)
                        SFill.Size = UDim2.new(p,0,1,0)
                        set(math.floor(p*255))
                        Update(Color3.fromRGB(r,g,b))
                    end)
                end)
            end
            AddSlider(45, Color3.fromRGB(255,50,50), r, function(v) r=v end)
            AddSlider(70, Color3.fromRGB(50,255,50), g, function(v) g=v end)
            AddSlider(95, Color3.fromRGB(50,50,255), b, function(v) b=v end)
            local Opened = false
            Btn.MouseButton1Click:Connect(function() Opened = not Opened game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, Opened and 130 or 40)}):Play() end)
            Library.Items[Flag] = {Type = "ColorPicker", Function = Update}
        end
        function Elements:CreateKeybind(Config)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40)})
            Create("UICorner", {Parent = Frame, CornerRadius = Theme.CornerRadius})
            Create("TextLabel", {Parent = Frame, Text = Config.Name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left})
            local KeyBtn = Create("TextButton", {Parent = Frame, Text = Config.CurrentKeybind or "None", BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 12, Position = UDim2.new(1, -85, 0.5, -12), Size = UDim2.new(0, 80, 0, 24)})
            Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0,4)})
            local Listening = false
            KeyBtn.MouseButton1Click:Connect(function() Listening = true KeyBtn.Text = "..." KeyBtn.TextColor3 = Theme.Accent end)
            UserInputService.InputBegan:Connect(function(i, gp)
                if Listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    Listening = false
                    KeyBtn.Text = i.KeyCode.Name
                    KeyBtn.TextColor3 = Theme.TextDark
                    if Config.Callback then Config.Callback(i.KeyCode) end
                elseif not Listening and not gp and i.KeyCode.Name == KeyBtn.Text and not Config.HoldToInteract then
                    if Config.Callback then Config.Callback() end
                end
            end)
        end
        return Elements
    end
    return Window
end

-- ==============================================================================
-- 3. GAME CONFIGURATION
-- ==============================================================================
local Settings = {
    -- >> COMBAT <<
    SilentAim = false, SilentAimFOV = 100, ShowFOV = false, TriggerBot = false, TriggerBotDelay = 0.05,
    TeamCheck = true, HitSound = false, HitSoundId = "rbxassetid://160715357",
    
    -- >> HITBOXES <<
    Hitbox = false, HitboxSize = 20, HitboxTransparency = 1,

    -- >> FX <<
    FX_Particles = false, FX_ParticleColor = Color3.fromRGB(255, 0, 255), FX_ParticleSize = 1, FX_OverrideSize = false,
    FX_Projectiles = false, FX_ProjectileColor = Color3.fromRGB(0, 255, 255), FX_ProjectileMat = "Neon",

    -- >> WEAPONS <<
    InfiniteAmmo = false, NoRecoil = false, NoSpread = false, RapidFire = false, RapidFireValue = 0.02,
    InstaReload = false, AlwaysAuto = false, Wallbang = false,

    TPShot = false, TPShotDuration = 0.05, TPPreFireDelay = 0.03, TPFOV = 150, TPShowFOV = false,
    TPFOVColor = Color3.fromRGB(255, 0, 0), TPWallCheck = true,

    AimlockEnabled = false, AimlockKey = Enum.KeyCode.Q, AimlockMode = "Hold", AimPart = "Head",
    AimSmoothness = 0.1, AimPrediction = 0.14, AimShake = 0, AimFOV = 150, AimVisCheck = true, AimSticky = false,

    pSilent = false, pSilentChance = 100, pSilentWallCheck = true,

    VM_Enable = false, VM_Rainbow = false, VM_Color = Color3.fromRGB(0, 255, 255), VM_Material = "ForceField",
    VM_Transparency = 0, VM_Reflectance = 0.5,
    
    -- >> VISUALS <<
    ESP = false, SkeletonESP = false, SkeletonColor = Color3.fromRGB(255, 255, 255),
    InfoESP = true, Chams = false, BoxColor = Color3.fromRGB(255, 50, 50),
    ChamFill = Color3.fromRGB(255, 0, 0), ChamOutline = Color3.fromRGB(255, 255, 255), FOVColor = Color3.fromRGB(255, 255, 255),
    
    RainbowGun = false, BulletTracers = false, TracerColor = Color3.fromRGB(0, 255, 0),
    CustomCrosshair = false, CrosshairSize = 12, CrosshairThickness = 2, CrosshairColor = Color3.fromRGB(0, 255, 0),
    
    -- >> WORLD <<
    WorldModulation = false, RemoveTextures = false, WorldColor = Color3.fromRGB(100, 100, 255), WorldMaterial = "ForceField",
    FullBright = false, TimeOfDay = 12, AmbientColor = Color3.fromRGB(150, 150, 150), SkyboxTheme = "Default",

    -- >> MOVEMENT <<
    Bhop = false, BhopSpeed = 45, InfiniteJump = false, Fly = false, FlySpeed = 50,
    Spinbot = false, SpinSpeed = 20, ThirdPerson = false, ThirdPersonDist = 12,
    
    -- >> MISC <<
    KillSay = false, RadialEnabled = true, MenuRadius = 110, SelectionThreshold = 70,
    ActiveColor = Color3.fromRGB(255, 0, 0), InactiveColor = Color3.fromRGB(40, 40, 40)
}

-- ==============================================================================
-- 4. LOGIC FUNCTIONS (Defined BEFORE UI to ensure they exist)
-- ==============================================================================

local function ApplySkybox(name)
    local existing = Lighting:FindFirstChild("ArsenalHackSky")
    if existing then existing:Destroy() end
    for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") then v:Destroy() end end
    local Skyboxes = {
        ["Purple Nebula"] = {SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296", SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454286", SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454288"},
        ["Red Hell"] = {SkyboxBk = "rbxassetid://401735071", SkyboxDn = "rbxassetid://401735398", SkyboxFt = "rbxassetid://401734567", SkyboxLf = "rbxassetid://401734808", SkyboxRt = "rbxassetid://401734033", SkyboxUp = "rbxassetid://401735876"},
        ["Blue Galaxy"] = {SkyboxBk = "rbxassetid://169469733", SkyboxDn = "rbxassetid://169469733", SkyboxFt = "rbxassetid://169469733", SkyboxLf = "rbxassetid://169469733", SkyboxRt = "rbxassetid://169469733", SkyboxUp = "rbxassetid://169469733"},
        ["Realistic Day"] = {SkyboxBk = "rbxassetid://1460305886", SkyboxDn = "rbxassetid://1460306297", SkyboxFt = "rbxassetid://1460306786", SkyboxLf = "rbxassetid://1460307223", SkyboxRt = "rbxassetid://1460307842", SkyboxUp = "rbxassetid://1460308381"}
    }
    if name ~= "Default" and Skyboxes[name] then
        local sky = Instance.new("Sky")
        sky.Name = "ArsenalHackSky"
        sky.Parent = Lighting
        for k,v in pairs(Skyboxes[name]) do sky[k] = v end
    end
end

local function ApplyMapMods()
    if not Settings.WorldModulation then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and not obj.Parent:FindFirstChild("Humanoid") and not obj:IsDescendantOf(Camera) and obj.Name ~= "HumanoidRootPart" and obj.Transparency < 1 then
            obj.Color = Settings.WorldColor
            if Enum.Material[Settings.WorldMaterial] then obj.Material = Enum.Material[Settings.WorldMaterial] end
            if Settings.WorldMaterial == "Glass" or Settings.WorldMaterial == "Ice" then obj.Reflectance = 0.35
            elseif Settings.WorldMaterial == "Neon" then obj.Reflectance = 0
            else obj.Reflectance = 0 end
        end
    end
end

local WeatherPart, AmbianceSound = nil, nil
local function SetWeather(weatherType)
    if WeatherPart then WeatherPart:Destroy() WeatherPart = nil end
    RunService:UnbindFromRenderStep("WeatherLoop")
    if weatherType == "Clear" or weatherType == nil then return end
    WeatherPart = Instance.new("Part", Workspace)
    WeatherPart.Name = "Gemini_Weather"
    WeatherPart.Size = Vector3.new(1000, 10, 1000)
    WeatherPart.Transparency = 1
    WeatherPart.Anchored = true
    WeatherPart.CanCollide = false
    local pe = Instance.new("ParticleEmitter", WeatherPart)
    pe.LightEmission = 0.5; pe.EmissionDirection = Enum.NormalId.Bottom; pe.Rate = 150; pe.Lifetime = NumberRange.new(60, 60)
    
    if weatherType == "Rain" then pe.Texture = "rbxassetid://244243648"; pe.Acceleration = Vector3.new(0, -150, 0); pe.Speed = NumberRange.new(50, 70); pe.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255)); pe.Size = NumberSequence.new(3)
    elseif weatherType == "Snow" then pe.Texture = "rbxassetid://241556770"; pe.Acceleration = Vector3.new(5, -15, 5); pe.Speed = NumberRange.new(10, 20); pe.Size = NumberSequence.new(0.8)
    elseif weatherType == "Ash (Hell)" then pe.Texture = "rbxassetid://243572836"; pe.EmissionDirection = Enum.NormalId.Top; pe.Acceleration = Vector3.new(5, 20, 0); pe.Color = ColorSequence.new(Color3.fromRGB(255, 80, 0))
    elseif weatherType == "Leaves" then pe.Texture = "rbxassetid://241386646"; pe.Acceleration = Vector3.new(15, -10, 5); pe.Size = NumberSequence.new(0.5); pe.Color = ColorSequence.new(Color3.fromRGB(255, 140, 0)) end
    
    RunService:BindToRenderStep("WeatherLoop", Enum.RenderPriority.Camera.Value + 1, function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local offset = (weatherType == "Ash (Hell)") and -40 or 150
            WeatherPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0)
        end
    end)
end

local function SetAmbience(soundType)
    if AmbianceSound then AmbianceSound:Destroy() end
    if soundType == "None" then return end
    local id = ""
    if soundType == "Heavy Rain" then id = "rbxassetid://5636069720"
    elseif soundType == "Lofi Loop" then id = "rbxassetid://9043887091"
    elseif soundType == "Windy" then id = "rbxassetid://9119766060"
    elseif soundType == "Horror Drone" then id = "rbxassetid://130973618" end
    if id ~= "" then
        AmbianceSound = Instance.new("Sound", game:GetService("SoundService"))
        AmbianceSound.SoundId = id
        AmbianceSound.Looped = true
        AmbianceSound.Volume = 2
        AmbianceSound:Play()
    end
end

local function ApplyTexturePack(texName)
    local TexturePacks = {["Retro Grid"] = "rbxassetid://5976586071", ["Galaxy"] = "rbxassetid://159454299", ["Minecraft Grass"] = "rbxassetid://6253726006", ["Checkered"] = "rbxassetid://16129462", ["Warning Lines"] = "rbxassetid://607946913"}
    local textureId = TexturePacks[texName]
    if not textureId then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Size.X > 4 then
            for _, t in pairs(obj:GetChildren()) do if t.Name == "GeminiOverlay" then t:Destroy() end end
            for _, face in pairs({Enum.NormalId.Top, Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Back}) do
                local t = Instance.new("Texture", obj)
                t.Name = "GeminiOverlay"; t.Texture = textureId; t.Face = face; t.StudsPerTileU = 8; t.StudsPerTileV = 8; t.Transparency = 0.3
            end
        end
    end
end

local WorldManager = {Enabled = false, SkyColor = Color3.fromRGB(135, 206, 235), SunColor = Color3.fromRGB(255, 255, 220), AmbientColor = Color3.fromRGB(150, 150, 150), FogDistance = 1000}
local function UpdateWorldColors()
    if not WorldManager.Enabled then return end
    local L = Lighting
    L.Ambient = WorldManager.AmbientColor
    L.OutdoorAmbient = WorldManager.AmbientColor
    L.ColorShift_Top = WorldManager.SunColor
    L.ColorShift_Bottom = WorldManager.AmbientColor
    L.FogColor = WorldManager.SkyColor
    L.FogEnd = WorldManager.FogDistance
    local atmo = L:FindFirstChild("Gemini_Atmosphere") or Instance.new("Atmosphere", L)
    atmo.Name = "Gemini_Atmosphere"
    atmo.Density = 0.45; atmo.Color = WorldManager.SkyColor; atmo.Decay = WorldManager.SkyColor
    for _, child in pairs(L:GetChildren()) do if child:IsA("Sky") and child.Name ~= "Gemini_Sky" then child:Destroy() end end
    local blankSky = L:FindFirstChild("Gemini_Sky") or Instance.new("Sky", L)
    blankSky.Name = "Gemini_Sky"; blankSky.SkyboxBk = ""; blankSky.SkyboxDn = ""; blankSky.SkyboxFt = ""; blankSky.SkyboxLf = ""; blankSky.SkyboxRt = ""; blankSky.SkyboxUp = ""; blankSky.SunTextureId = ""; blankSky.MoonTextureId = ""
end

-- ==============================================================================
-- 5. UI INITIALIZATION
-- ==============================================================================
local Window = Library:CreateWindow({Name = "Arsenal Ultimate v29.2"})

local CombatTab = Window:CreateTab("Combat")
local WeaponTab = Window:CreateTab("Weapons")
local VisualsTab = Window:CreateTab("Visuals")
local WorldTab = Window:CreateTab("World")
local MoveTab = Window:CreateTab("Movement")
local MiscTab = Window:CreateTab("Misc")

-- >> COMBAT TAB
CombatTab:CreateSection("TP Shot")
CombatTab:CreateToggle({Name = "TP Flick Shot", Flag = "TPShot", Callback = function(v) Settings.TPShot = v end})
CombatTab:CreateSlider({Name = "TP Duration", Range = {0.05, 0.5}, Increment = 0.01, Suffix = "s", CurrentValue = 0.15, Flag = "TPShotDur", Callback = function(v) Settings.TPShotDuration = v end})
CombatTab:CreateSlider({Name = "Pre-Fire Delay", Range = {0, 0.1}, Increment = 0.01, Suffix = "s", CurrentValue = 0.03, Flag = "TPPreDelay", Callback = function(v) Settings.TPPreFireDelay = v end})
CombatTab:CreateToggle({Name = "Show TP FOV", Flag = "TPShowFOV", Callback = function(v) Settings.TPShowFOV = v end})
CombatTab:CreateSlider({Name = "TP FOV Radius", Range = {10, 1500}, CurrentValue = 150, Flag = "TPFOVSlider", Callback = function(v) Settings.TPFOV = v end})

CombatTab:CreateSection("Aimlock")
CombatTab:CreateToggle({Name = "Enable Aimlock", Flag = "AimlockToggle", Callback = function(v) Settings.AimlockEnabled = v end})
CombatTab:CreateKeybind({Name = "Aimlock Key", CurrentKeybind = "Q", HoldToInteract = true, Flag = "AimlockKeybind", Callback = function(k) Settings.AimlockKey = k end})
CombatTab:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart", "Random", "Closest"}, CurrentOption = "Head", Flag = "AimPart", Callback = function(v) Settings.AimPart = v end})
CombatTab:CreateSlider({Name = "Smoothness", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.1, Flag = "AimSmooth", Callback = function(v) Settings.AimSmoothness = v end})
CombatTab:CreateToggle({Name = "TriggerBot", Flag = "TriggerBot", Callback = function(v) Settings.TriggerBot = v end})
CombatTab:CreateSlider({Name = "Silent Aim FOV", Range = {10, 800}, CurrentValue = 100, Flag = "SilentAimFOV", Callback = function(v) Settings.SilentAimFOV = v end})
CombatTab:CreateToggle({Name = "Show FOV", Flag = "ShowFOV", Callback = function(v) Settings.ShowFOV = v end})

CombatTab:CreateSection("Hitboxes")
CombatTab:CreateToggle({Name = "Ghost Hitboxes", Flag = "Hitbox", Callback = function(v) Settings.Hitbox = v end})
CombatTab:CreateSlider({Name = "Hitbox Size", Range = {5, 50}, CurrentValue = 20, Flag = "HitboxSize", Callback = function(v) Settings.HitboxSize = v end})

-- >> WEAPON TAB
WeaponTab:CreateSection("Gun Mods")
WeaponTab:CreateToggle({Name = "Infinite Ammo", Flag = "InfAmmo", Callback = function(v) Settings.InfiniteAmmo = v end})
WeaponTab:CreateToggle({Name = "Rapid Fire", Flag = "RapidFire", Callback = function(v) Settings.RapidFire = v end})
WeaponTab:CreateSlider({Name = "Rapid Fire Speed", Range = {0.01, 0.5}, CurrentValue = 0.02, Flag = "RFSpeed", Callback = function(v) Settings.RapidFireValue = v end})
WeaponTab:CreateToggle({Name = "Insta-Reload", Flag = "InstaReload", Callback = function(v) Settings.InstaReload = v end})
WeaponTab:CreateToggle({Name = "No Recoil/Spread", Flag = "NoRecoil", Callback = function(v) Settings.NoRecoil = v; Settings.NoSpread = v end})
WeaponTab:CreateToggle({Name = "Wallbang", Flag = "Wallbang", Callback = function(v) Settings.Wallbang = v end})

-- >> VISUALS TAB
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({Name = "ESP Boxes", Flag = "ESP", Callback = function(v) Settings.ESP = v end})
VisualsTab:CreateToggle({Name = "Skeleton ESP", Flag = "SkelESP", Callback = function(v) Settings.SkeletonESP = v end})
VisualsTab:CreateToggle({Name = "Chams", Flag = "Chams", Callback = function(v) Settings.Chams = v; if not v then for _,c in pairs(CoreGui:GetChildren()) do if c.Name:find("ArsenalCham_") then c:Destroy() end end end end})
VisualsTab:CreateColorPicker({Name = "Box Color", Color = Color3.fromRGB(255, 50, 50), Flag = "BoxColor", Callback = function(v) Settings.BoxColor = v end})
VisualsTab:CreateColorPicker({Name = "Skeleton Color", Color = Color3.fromRGB(255, 255, 255), Flag = "SkelColor", Callback = function(v) Settings.SkeletonColor = v end})
VisualsTab:CreateColorPicker({Name = "Cham Fill", Color = Color3.fromRGB(255, 0, 0), Flag = "ChamColor", Callback = function(v) Settings.ChamFill = v end})

VisualsTab:CreateSection("Local")
VisualsTab:CreateToggle({Name = "Viewmodel Color", Flag = "VM_Enable", Callback = function(v) Settings.VM_Enable = v end})
VisualsTab:CreateColorPicker({Name = "VM Color", Color = Color3.fromRGB(0, 255, 255), Flag = "VM_Color", Callback = function(v) Settings.VM_Color = v end})
VisualsTab:CreateToggle({Name = "Bullet Tracers", Flag = "Tracers", Callback = function(v) Settings.BulletTracers = v end})

-- >> WORLD TAB (Fixes Applied)
WorldTab:CreateSection("Environment")
WorldTab:CreateDropdown({Name = "Weather", Options = {"Clear", "Rain", "Snow", "Ash (Hell)", "Leaves"}, CurrentOption = "Clear", Flag = "WeatherSelect", Callback = function(v) SetWeather(v) end})
WorldTab:CreateDropdown({Name = "Ambience", Options = {"None", "Heavy Rain", "Lofi Loop", "Windy", "Horror Drone"}, CurrentOption = "None", Flag = "AmbienceSelect", Callback = function(v) SetAmbience(v) end})
WorldTab:CreateSlider({Name = "Volume", Range = {0, 10}, CurrentValue = 2, Callback = function(v) if AmbianceSound then AmbianceSound.Volume = v end end})

WorldTab:CreateSection("Map Overrides")
WorldTab:CreateDropdown({Name = "Textures", Options = {"None", "Retro Grid", "Galaxy", "Minecraft Grass", "Checkered", "Warning Lines"}, CurrentOption = "None", Callback = function(v) if v == "None" then for _,x in pairs(Workspace:GetDescendants()) do if x.Name=="GeminiOverlay" then x:Destroy() end end else ApplyTexturePack(v) end end})
WorldTab:CreateToggle({Name = "Map Color Mod", Flag = "WorldMod", Callback = function(v) Settings.WorldModulation = v; if v then ApplyMapMods() end end})
WorldTab:CreateColorPicker({Name = "Map Color", Color = Color3.fromRGB(100, 100, 255), Flag = "MapColor", Callback = function(v) Settings.WorldColor = v; if Settings.WorldModulation then ApplyMapMods() end end})

WorldTab:CreateSection("Custom Colors")
WorldTab:CreateToggle({Name = "Enable Overrides", Flag = "ColorOverride", Callback = function(v) WorldManager.Enabled = v; if not v then Lighting.Ambient = Color3.fromRGB(150,150,150) end end})
WorldTab:CreateColorPicker({Name = "Sky Color", Color = Color3.fromRGB(135, 206, 235), Flag = "UserSkyColor", Callback = function(v) WorldManager.SkyColor = v; UpdateWorldColors() end})
WorldTab:CreateColorPicker({Name = "Ambient Color", Color = Color3.fromRGB(150, 150, 150), Flag = "UserAmbColor", Callback = function(v) WorldManager.AmbientColor = v; UpdateWorldColors() end})

WorldTab:CreateSection("Skybox")
WorldTab:CreateDropdown({Name = "Skybox Theme", Options = {"Default", "Purple Nebula", "Red Hell", "Blue Galaxy", "Realistic Day"}, CurrentOption = "Default", Callback = function(v) ApplySkybox(v) end})

-- >> MOVEMENT TAB
MoveTab:CreateSection("Movement")
MoveTab:CreateToggle({Name = "Omni-Movement (Bhop)", Flag = "Bhop", Callback = function(v) Settings.Bhop = v end})
MoveTab:CreateSlider({Name = "Speed", Range = {20, 300}, CurrentValue = 45, Flag = "BhopSpeed", Callback = function(v) Settings.BhopSpeed = v end})
MoveTab:CreateToggle({Name = "Fly", Flag = "FlyMode", Callback = function(v) Settings.Fly = v end})
MoveTab:CreateSlider({Name = "Fly Speed", Range = {10, 500}, CurrentValue = 50, Flag = "FlySpd", Callback = function(v) Settings.FlySpeed = v end})
MoveTab:CreateToggle({Name = "Spinbot", Flag = "Spinbot", Callback = function(v) Settings.Spinbot = v end})

-- >> MISC TAB
MiscTab:CreateSection("Tools")
MiscTab:CreateToggle({Name = "Kill Say", Flag = "KillSay", Callback = function(v) Settings.KillSay = v end})
MiscTab:CreateToggle({Name = "Third Person", Flag = "TPerson", Callback = function(v) Settings.ThirdPerson = v end})
MiscTab:CreateSlider({Name = "Distance", Range = {5, 30}, CurrentValue = 12, Flag = "TPDist", Callback = function(v) Settings.ThirdPersonDist = v end})

MiscTab:CreateSection("Configuration")
MiscTab:CreateButton({Name = "Save Config", Callback = function() Library:SaveConfiguration("ArsenalConfig_v1") end})
MiscTab:CreateButton({Name = "Load Config", Callback = function() Library:LoadConfiguration("ArsenalConfig_v1") end})
MiscTab:CreateButton({Name = "Rejoin Server", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end})

--  (Conceptual visualization of the menu structure)

-- ==============================================================================
-- 6. GAME LOOP LOGIC
-- ==============================================================================

-- Cleanup
if _G.GeminiHack then for _,c in pairs(_G.GeminiHack) do pcall(function() c:Disconnect() end) end end
_G.GeminiHack = {}

-- Helper: Visibility Check
local function CheckVisibility(target)
    if not Settings.AimVisCheck then return true end
    local origin = Camera.CFrame.Position
    local part = target.Character:FindFirstChild("Head") 
    if not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, workspace:FindFirstChild("Ray_Ignore")}
    local result = workspace:Raycast(origin, part.Position - origin, params)
    return result and result.Instance:IsDescendantOf(target.Character)
end

-- Helper: Get Closest Player
local function getClosestPlayerToCrosshair(fov, checkVis)
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, fov or math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.TeamColor ~= LocalPlayer.TeamColor and plr.Character then
            local part = plr.Character:FindFirstChild("Head")
            if part and plr.Character:FindFirstChild("Humanoid").Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < bestDist then
                        if not checkVis or CheckVisibility(plr) then
                            bestDist = dist
                            best = plr
                        end
                    end
                end
            end
        end
    end
    return best
end

-- Logic: Aimlock
table.insert(_G.GeminiHack, RunService.RenderStepped:Connect(function()
    if Settings.AimlockEnabled and UserInputService:IsKeyDown(Settings.AimlockKey) then
        local target = getClosestPlayerToCrosshair(Settings.AimFOV, Settings.AimVisCheck)
        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then
            local pos = target.Character[Settings.AimPart].Position + (target.Character.HumanoidRootPart.AssemblyLinearVelocity * Settings.AimPrediction)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, pos), Settings.AimSmoothness)
        end
    end
end))

-- Logic: Bhop
table.insert(_G.GeminiHack, RunService.Heartbeat:Connect(function()
    if Settings.Bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.FloorMaterial == Enum.Material.Air then
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if move.Magnitude > 0 then
                local flat = Vector3.new(move.X, 0, move.Z).Unit * Settings.BhopSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(flat.X, hrp.AssemblyLinearVelocity.Y, flat.Z)
            end
        end
        if Settings.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum and hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
end))

-- Logic: World Color Loop (Keep it applied)
task.spawn(function()
    while true do
        if Settings.WorldModulation then ApplyMapMods() end
        if WorldManager.Enabled then UpdateWorldColors() end
        if Settings.FullBright then Lighting.Brightness = 2; Lighting.ClockTime = 12 end
        task.wait(1)
    end
end)

-- Logic: Gun Mods
task.spawn(function()
    while true do
        pcall(function()
            for _,v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
                if v:IsA("ValueBase") then
                    if Settings.RapidFire and v.Name == "FireRate" then v.Value = Settings.RapidFireValue end
                    if Settings.InfiniteAmmo and (v.Name == "Ammo" or v.Name == "ClipSize") then v.Value = 999 end
                    if Settings.NoRecoil and v.Name == "RecoilControl" then v.Value = 0 end
                    if Settings.Wallbang and v.Name == "Penetration" then v.Value = 100 end
                end
            end
        end)
        task.wait(1)
    end
end)

-- Logic: TP Shot
local IsTPing = false
table.insert(_G.GeminiHack, UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.TPShot and not IsTPing then
        local target = getClosestPlayerToCrosshair(Settings.TPFOV, Settings.TPWallCheck)
        if target and target.Character then
            IsTPing = true
            local root = LocalPlayer.Character.HumanoidRootPart
            local oldCF = root.CFrame
            local tRoot = target.Character.HumanoidRootPart
            root.CFrame = tRoot.CFrame * CFrame.new(0,0,3)
            task.wait(Settings.TPPreFireDelay)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
            task.wait(Settings.TPShotDuration)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
            root.CFrame = oldCF
            IsTPing = false
        end
    end
end))

-- Logic: FOV Circle Drawing
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 60; FOV_Circle.Filled = false
table.insert(_G.GeminiHack, RunService.RenderStepped:Connect(function()
    FOV_Circle.Visible = Settings.ShowFOV or (Settings.TPShowFOV and Settings.TPShot)
    FOV_Circle.Radius = Settings.ShowFOV and Settings.SilentAimFOV or Settings.TPFOV
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOV_Circle.Color = (Settings.TPShowFOV and Settings.TPShot) and Settings.TPFOVColor or Settings.FOVColor
end))
