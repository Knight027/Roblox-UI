--[[
    GEMINI V2.1 UI LIBRARY
    + Fixed Config System (Save/Load)
    + Toggle Key: INSERT
    Author: Gemini
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}
Library.Flags = {} -- Stores the values for saving
Library.Items = {} -- Stores the objects for updating visuals

-- >> THEME CONFIGURATION
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

-- >> HELPER: COLOR SERIALIZATION
local function ToColor3(col)
    if typeof(col) == "Color3" then return col end
    if typeof(col) == "table" then return Color3.new(col.R, col.G, col.B) end
    return Color3.new(1,1,1)
end

local function FromColor3(col)
    if typeof(col) == "Color3" then return {R = col.R, G = col.G, B = col.B} end
    return {R=1, G=1, B=1}
end

-- >> HELPER: UI CREATION
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then Update(input) end
    end)
end

-- >> CONFIG SYSTEM
function Library:SaveConfiguration(FileName)
    if not isfolder("GeminiConfig") then makefolder("GeminiConfig") end
    local path = "GeminiConfig/" .. FileName .. ".json"
    
    -- Create a deep copy to handle userdata serialization
    local SaveData = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            SaveData[flag] = FromColor3(value)
        elseif typeof(value) == "EnumItem" then
            SaveData[flag] = tostring(value)
        else
            SaveData[flag] = value
        end
    end
    
    writefile(path, HttpService:JSONEncode(SaveData))
end

function Library:LoadConfiguration(FileName)
    local path = "GeminiConfig/" .. FileName .. ".json"
    if not isfile(path) then return end
    
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not success then return end

    for flag, value in pairs(decoded) do
        -- Check if it's a registered UI element
        if Library.Items[flag] then
            local Item = Library.Items[flag]
            
            -- Handle Color Conversion
            if Item.Type == "ColorPicker" and typeof(value) == "table" then
                value = ToColor3(value)
            end
            
            -- Update the internal flag
            Library.Flags[flag] = value
            
            -- Update the Visuals and Fire Callback
            if Item.Function then
                Item.Function(value)
            end
        end
    end
end

-- >> MAIN WINDOW
function Library:CreateWindow(Config)
    local Name = Config.Name or "Gemini UI"
    
    local ScreenGui = Create("ScreenGui", {
        Name = "GeminiUI_" .. math.random(1000,9999),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    if gethui then ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui
    else ScreenGui.Parent = CoreGui end

    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 400),
        BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5)
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = Theme.CornerRadius})

    local TopBar = Create("Frame", {
        Name = "TopBar", Parent = MainFrame, BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 40), BorderSizePixel = 0
    })
    Create("UICorner", {Parent = TopBar, CornerRadius = Theme.CornerRadius})
    Create("Frame", {
        Parent = TopBar, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0,0,1,-10), BorderSizePixel = 0
    })

    Create("TextLabel", {
        Parent = TopBar, Text = Name, Font = Theme.Font, TextSize = 18,
        TextColor3 = Theme.Text, BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    MakeDraggable(TopBar, MainFrame)

    local TabHolder = Create("ScrollingFrame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 140, 1, -60), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)
    })

    local PageHolder = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 160, 0, 50),
        Size = UDim2.new(1, -170, 1, -60)
    })

    -- >> TOGGLE KEY: INSERT
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(TabName)
        local TabButton = Create("TextButton", {
            Parent = TabHolder, BackgroundColor3 = Theme.Sidebar, Text = TabName,
            TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 14,
            Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = Theme.CornerRadius})

        local Page = Create("ScrollingFrame", {
            Name = TabName .. "_Page", Parent = PageHolder, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent, Visible = false
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Sidebar}):Play()
                end
            end
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.Element}):Play()
            Page.Visible = true
        end

        TabButton.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false Activate() end

        local Elements = {}

        function Elements:CreateSection(Text)
            Create("TextLabel", {
                Parent = Page, BackgroundTransparency = 1, Text = "  " .. string.upper(Text),
                TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 12,
                Size = UDim2.new(1, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function Elements:CreateToggle(Config)
            local Flag = Config.Flag or Config.Name .. tostring(math.random())
            local Default = Config.CurrentValue or false
            local Callback = Config.Callback or function() end
            
            Library.Flags[Flag] = Default

            local ToggleFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = Theme.CornerRadius})

            local Title = Create("TextLabel", {
                Parent = ToggleFrame, Text = Config.Name, TextColor3 = Theme.Text,
                Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.7, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame, BackgroundColor3 = Theme.ToggleOff,
                Position = UDim2.new(1, -50, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1,0)})

            local SwitchCircle = Create("Frame", {
                Parent = SwitchBg, BackgroundColor3 = Color3.new(1,1,1),
                Position = UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = SwitchCircle, CornerRadius = UDim.new(1,0)})

            local Button = Create("TextButton", {
                Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""
            })

            local function Set(val)
                Library.Flags[Flag] = val
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                Callback(val)
            end

            Button.MouseButton1Click:Connect(function() Set(not Library.Flags[Flag]) end)
            
            -- Register for Config
            Library.Items[Flag] = {Type = "Toggle", Function = Set}
            
            -- Initialize
            Set(Default)
        end

        function Elements:CreateButton(Config)
            local ButtonFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 35)
            })
            Create("UICorner", {Parent = ButtonFrame, CornerRadius = Theme.CornerRadius})

            local Interact = Create("TextButton", {
                Parent = ButtonFrame, Text = Config.Name, TextColor3 = Theme.Text,
                Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)
            })

            Interact.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                task.delay(0.1, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
                if Config.Callback then Config.Callback() end
            end)
        end

        function Elements:CreateSlider(Config)
            local Flag = Config.Flag or Config.Name .. tostring(math.random())
            local Min, Max = Config.Range[1], Config.Range[2]
            local Default = Config.CurrentValue or Min
            local Callback = Config.Callback or function() end

            Library.Flags[Flag] = Default

            local SliderFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = Theme.CornerRadius})

            local Label = Create("TextLabel", {
                Parent = SliderFrame, Text = Config.Name, TextColor3 = Theme.Text,
                Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame, Text = tostring(Default), TextColor3 = Theme.TextDark,
                Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBar = Create("Frame", {
                Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(50,50,50),
                Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 6)
            })
            Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(1,0)})

            local Fill = Create("Frame", {
                Parent = SliderBar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0,0,1,0)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1,0)})

            local ClickPad = Create("TextButton", {
                Parent = SliderBar, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = ""
            })

            local function Set(val)
                local percentage = math.clamp((val - Min) / (Max - Min), 0, 1)
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = tostring(val) .. (Config.Suffix or "")
                Library.Flags[Flag] = val
                Callback(val)
            end

            local Dragging = false
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX) * 100) / 100
                if Config.Increment then Value = math.floor(Value / Config.Increment + 0.5) * Config.Increment end
                Set(Value)
            end

            ClickPad.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
            end)
            
            Library.Items[Flag] = {Type = "Slider", Function = Set}
            Set(Default)
        end

        function Elements:CreateDropdown(Config)
            local Flag = Config.Flag or Config.Name .. tostring(math.random())
            local Callback = Config.Callback or function() end
            local Options = Config.Options or {}
            local Opened = false
            
            Library.Flags[Flag] = Config.CurrentOption or Options[1]

            local Container = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40), ClipsDescendants = true
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})

            local Header = Create("TextButton", {Parent = Container, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)})
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name .. ": " .. tostring(Library.Flags[Flag]),
                TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 0, 40), TextXAlignment = Enum.TextXAlignment.Left
            })
            local Arrow = Create("ImageLabel", {
                Parent = Container, Image = "rbxassetid://6034818372", BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 10), Size = UDim2.new(0, 20, 0, 20), ImageColor3 = Theme.TextDark
            })
            
            local OptionList = Create("Frame", {
                Parent = Container, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1,0,0,0)
            })
            local ListLayout = Create("UIListLayout", {Parent = OptionList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

            local function Set(val)
                Library.Flags[Flag] = val
                Label.Text = Config.Name .. ": " .. tostring(val)
                Callback(val)
            end

            local function Refresh()
                for _, v in pairs(OptionList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(Options) do
                    local btn = Create("TextButton", {
                        Parent = OptionList, BackgroundColor3 = Theme.Sidebar, Text = opt,
                        TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13,
                        Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 0, 0)
                    })
                    Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,4)})
                    btn.MouseButton1Click:Connect(function()
                        Set(opt)
                        Opened = false
                        TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 40)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end)
                end
            end
            Refresh()

            Header.MouseButton1Click:Connect(function()
                Opened = not Opened
                local h = Opened and (45 + (#Options * 32)) or 40
                TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, h)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Opened and 180 or 0}):Play()
            end)

            Library.Items[Flag] = {Type = "Dropdown", Function = Set}
        end

        function Elements:CreateColorPicker(Config)
            local Flag = Config.Flag or Config.Name .. tostring(math.random())
            local Default = Config.Color or Color3.fromRGB(255,255,255)
            local Callback = Config.Callback or function() end
            local Opened = false
            
            Library.Flags[Flag] = Default
            
            local Container = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40), ClipsDescendants = true
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})
            local Header = Create("TextButton", {Parent = Container, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)})
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name, TextColor3 = Theme.Text,
                Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -50, 0, 40), TextXAlignment = Enum.TextXAlignment.Left
            })
            local Preview = Create("Frame", {
                Parent = Container, BackgroundColor3 = Default, Position = UDim2.new(1, -35, 0, 10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})

            local r, g, b = Default.R * 255, Default.G * 255, Default.B * 255

            local function Set(col)
                Library.Flags[Flag] = col
                Preview.BackgroundColor3 = col
                r, g, b = col.R * 255, col.G * 255, col.B * 255
                Callback(col)
            end

            local function UpdateColor()
                Set(Color3.fromRGB(r, g, b))
            end

            local function CreateMiniSlider(id, color, val, setter)
               local sFrame = Create("Frame", {Parent = Container, BackgroundTransparency=1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 45 + (id*25))})
               local sBar = Create("Frame", {Parent = sFrame, BackgroundColor3=Color3.fromRGB(30,30,30), Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,0.5,-2)})
               local sFill = Create("Frame", {Parent = sBar, BackgroundColor3=color, Size=UDim2.new(val/255,0,1,0)})
               local btn = Create("TextButton", {Parent = sFrame, Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)})
               
               btn.MouseButton1Down:Connect(function()
                   local c = RunService.RenderStepped:Connect(function()
                       if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
                       local p = math.clamp((UserInputService:GetMouseLocation().X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                       sFill.Size = UDim2.new(p, 0, 1, 0)
                       setter(math.floor(p * 255))
                       UpdateColor()
                   end)
                   UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then if c then c:Disconnect() end end end)
               end)
            end
            
            CreateMiniSlider(0, Color3.fromRGB(255,50,50), r, function(v) r = v end)
            CreateMiniSlider(1, Color3.fromRGB(50,255,50), g, function(v) g = v end)
            CreateMiniSlider(2, Color3.fromRGB(50,50,255), b, function(v) b = v end)
            
            Header.MouseButton1Click:Connect(function()
                Opened = not Opened
                TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, Opened and 130 or 40)}):Play()
            end)
            
            Library.Items[Flag] = {Type = "ColorPicker", Function = Set}
        end

        function Elements:CreateKeybind(Config)
            local Title = Config.Name or "Keybind"
            local CurrentKey = Config.CurrentKeybind or "None"
            local Callback = Config.Callback or function() end
            local Hold = Config.HoldToInteract or false
            
            local Container = Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -5, 0, 40)
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})
            
            local Label = Create("TextLabel", {
                Parent = Container, Text = Title, TextColor3 = Theme.Text, Font = Theme.Font,
                TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local BindBtn = Create("TextButton", {
                Parent = Container, Text = CurrentKey, BackgroundColor3 = Theme.Sidebar,
                TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 12,
                Position = UDim2.new(1, -85, 0.5, -12), Size = UDim2.new(0, 80, 0, 24)
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            
            local Listening = false
            BindBtn.MouseButton1Click:Connect(function() Listening = true BindBtn.Text = "..." BindBtn.TextColor3 = Theme.Accent end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Listening = false
                    CurrentKey = input.KeyCode.Name
                    BindBtn.Text = CurrentKey
                    BindBtn.TextColor3 = Theme.TextDark
                    Callback(input.KeyCode)
                elseif not Listening and not gp and input.KeyCode.Name == CurrentKey and not Hold then
                    Callback()
                end
            end)
        end

        return Elements
    end

    return Window
end

return Library
