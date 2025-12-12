--[[
    GEMINI V2 UI LIBRARY
    A lightweight, modern UI library for Roblox Executors.
    Author: Gemini
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

-- >> THEME CONFIGURATION
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(30, 30, 30),
    Element = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 255, 180), -- Cyan/Green mix
    ToggleOn = Color3.fromRGB(0, 255, 180),
    ToggleOff = Color3.fromRGB(50, 50, 50),
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 6)
}

-- >> HELPER FUNCTIONS
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
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- >> MAIN WINDOW FUNCTION
function Library:CreateWindow(Config)
    local Name = Config.Name or "Gemini UI"
    
    -- Protect GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "GeminiUI_" .. math.random(1000,9999),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Attempt to parent to CoreGui (Secure), else PlayerGui
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = Theme.CornerRadius})

    -- Drag Bar / Title
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = TopBar, CornerRadius = Theme.CornerRadius})
    -- Cover bottom corners of topbar
    Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0,0,1,-10),
        BorderSizePixel = 0
    })

    Create("TextLabel", {
        Parent = TopBar,
        Text = Name,
        Font = Theme.Font,
        TextSize = 18,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    MakeDraggable(TopBar, MainFrame)

    -- Container for Tabs
    local TabHolder = Create("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 140, 1, -60),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0) -- Auto resize later
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    -- Container for Elements (Pages)
    local PageHolder = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 50),
        Size = UDim2.new(1, -170, 1, -60)
    })

    -- Toggle UI Keybind (Right Control)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(TabName)
        -- 1. Create The Tab Button
        local TabButton = Create("TextButton", {
            Parent = TabHolder,
            BackgroundColor3 = Theme.Sidebar,
            Text = TabName,
            TextColor3 = Theme.TextDark,
            Font = Theme.Font,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 35),
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = Theme.CornerRadius})

        -- 2. Create The Page (Scrolling Frame)
        local Page = Create("ScrollingFrame", {
            Name = TabName .. "_Page",
            Parent = PageHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        -- Auto Canvas Size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Selection Logic
        local function Activate()
            -- Deactivate all others
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Sidebar}):Play()
                end
            end
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end

            -- Activate this
            TweenService:Create(TabButton, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.Element}):Play()
            Page.Visible = true
        end

        TabButton.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        local Elements = {}

        -- >> SECTION (Header)
        function Elements:CreateSection(Text)
            local SectionLabel = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Text = "  " .. string.upper(Text),
                TextColor3 = Theme.TextDark,
                Font = Theme.Font,
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 25),
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        -- >> TOGGLE
        function Elements:CreateToggle(Config)
            local ToggleTitle = Config.Name or "Toggle"
            local Default = Config.CurrentValue or false
            local Callback = Config.Callback or function() end
            local State = Default

            local ToggleFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 40)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = Theme.CornerRadius})

            local Title = Create("TextLabel", {
                Parent = ToggleFrame,
                Text = ToggleTitle,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = State and Theme.ToggleOn or Theme.ToggleOff,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1,0)})

            local SwitchCircle = Create("Frame", {
                Parent = SwitchBg,
                BackgroundColor3 = Color3.new(1,1,1),
                Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = SwitchCircle, CornerRadius = UDim.new(1,0)})

            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = ""
            })

            local function Update()
                local TargetColor = State and Theme.ToggleOn or Theme.ToggleOff
                local TargetPos = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = TargetPos}):Play()
                
                Callback(State)
            end

            Button.MouseButton1Click:Connect(function()
                State = not State
                Update()
            end)
            
            if Default then Update() end -- Initialize
        end

        -- >> BUTTON
        function Elements:CreateButton(Config)
            local ButtonText = Config.Name or "Button"
            local Callback = Config.Callback or function() end

            local ButtonFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 35)
            })
            Create("UICorner", {Parent = ButtonFrame, CornerRadius = Theme.CornerRadius})

            local Interact = Create("TextButton", {
                Parent = ButtonFrame,
                Text = ButtonText,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0)
            })

            Interact.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                task.delay(0.1, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
                end)
                Callback()
            end)
        end

        -- >> SLIDER
        function Elements:CreateSlider(Config)
            local Title = Config.Name or "Slider"
            local Min = Config.Range[1] or 0
            local Max = Config.Range[2] or 100
            local Default = Config.CurrentValue or Min
            local Callback = Config.Callback or function() end

            local SliderFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = Theme.CornerRadius})

            local Label = Create("TextLabel", {
                Parent = SliderFrame,
                Text = Title,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(Default),
                TextColor3 = Theme.TextDark,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBar = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(50,50,50),
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 6)
            })
            Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(1,0)})

            local Fill = Create("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1,0)})

            local ClickPad = Create("TextButton", {
                Parent = SliderBar,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = ""
            })

            local Dragging = false

            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX) * 100) / 100 -- Round to 2 decimals usually, or 0 if integers
                
                -- Adjust if Increment provided
                if Config.Increment then
                    Value = math.floor(Value / Config.Increment + 0.5) * Config.Increment
                end

                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(Value) .. (Config.Suffix or "")
                Callback(Value)
            end

            ClickPad.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
        end

        -- >> DROPDOWN
        function Elements:CreateDropdown(Config)
            local Title = Config.Name or "Dropdown"
            local Options = Config.Options or {}
            local Callback = Config.Callback or function() end
            local Opened = false
            
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 40),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})

            local Header = Create("TextButton", {
                Parent = Container,
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40)
            })

            local Label = Create("TextLabel", {
                Parent = Container,
                Text = Title .. ": " .. (Config.CurrentOption or "Select..."),
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -30, 0, 40),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Create("ImageLabel", {
                Parent = Container,
                Image = "rbxassetid://6034818372", -- Down Arrow
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 10),
                Size = UDim2.new(0, 20, 0, 20),
                ImageColor3 = Theme.TextDark
            })

            local OptionList = Create("Frame", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 45),
                Size = UDim2.new(1, 0, 0, 0) -- Resized dynamically
            })
            local ListLayout = Create("UIListLayout", {
                Parent = OptionList,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })

            local function RefreshOptions()
                for _, v in pairs(OptionList:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end

                for _, opt in pairs(Options) do
                    local btn = Create("TextButton", {
                        Parent = OptionList,
                        BackgroundColor3 = Theme.Sidebar,
                        Text = opt,
                        TextColor3 = Theme.TextDark,
                        Font = Theme.Font,
                        TextSize = 13,
                        Size = UDim2.new(1, -10, 0, 30),
                        Position = UDim2.new(0, 5, 0, 0)
                    })
                    Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,4)})
                    
                    btn.MouseButton1Click:Connect(function()
                        Opened = false
                        Label.Text = Title .. ": " .. opt
                        Callback(opt)
                        TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 40)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end)
                end
            end
            
            RefreshOptions()

            Header.MouseButton1Click:Connect(function()
                Opened = not Opened
                local height = Opened and (45 + (#Options * 32)) or 40
                TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, height)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Opened and 180 or 0}):Play()
            end)
        end
        
        -- >> COLOR PICKER (Simplified RGB Sliders)
        function Elements:CreateColorPicker(Config)
            local Title = Config.Name or "Color"
            local Current = Config.Color or Color3.fromRGB(255, 255, 255)
            local Callback = Config.Callback or function() end
            local Opened = false
            
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 40),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})
            
            local Header = Create("TextButton", {
                Parent = Container,
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            local Label = Create("TextLabel", {
                Parent = Container,
                Text = Title,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 0, 40),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Preview = Create("Frame", {
                Parent = Container,
                BackgroundColor3 = Current,
                Position = UDim2.new(1, -35, 0, 10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})

            -- Internal RGB Sliders
            local r, g, b = Current.R * 255, Current.G * 255, Current.B * 255
            
            local function UpdateColor()
                local newColor = Color3.fromRGB(r, g, b)
                Preview.BackgroundColor3 = newColor
                Callback(newColor)
            end
            
            local function CreateMiniSlider(id, color, val, setter)
               local sFrame = Create("Frame", {Parent = Container, BackgroundTransparency=1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 45 + (id*25))})
               local sBar = Create("Frame", {Parent = sFrame, BackgroundColor3=Color3.fromRGB(30,30,30), Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,0.5,-2)})
               local sFill = Create("Frame", {Parent = sBar, BackgroundColor3=color, Size=UDim2.new(val/255,0,1,0)})
               local btn = Create("TextButton", {Parent = sFrame, Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)})
               
               btn.MouseButton1Down:Connect(function()
                   local connection
                   connection = RunService.RenderStepped:Connect(function()
                       if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() return end
                       local mPos = UserInputService:GetMouseLocation().X
                       local rPos = sBar.AbsolutePosition.X
                       local size = sBar.AbsoluteSize.X
                       local p = math.clamp((mPos - rPos) / size, 0, 1)
                       sFill.Size = UDim2.new(p, 0, 1, 0)
                       setter(math.floor(p * 255))
                       UpdateColor()
                   end)
               end)
            end
            
            CreateMiniSlider(0, Color3.fromRGB(255,50,50), r, function(v) r = v end)
            CreateMiniSlider(1, Color3.fromRGB(50,255,50), g, function(v) g = v end)
            CreateMiniSlider(2, Color3.fromRGB(50,50,255), b, function(v) b = v end)
            
            Header.MouseButton1Click:Connect(function()
                Opened = not Opened
                TweenService:Create(Container, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, Opened and 130 or 40)}):Play()
            end)
        end
        
        -- >> KEYBIND
        function Elements:CreateKeybind(Config)
            local Title = Config.Name or "Keybind"
            local CurrentKey = Config.CurrentKeybind or "None"
            local Callback = Config.Callback or function() end
            local HoldToInteract = Config.HoldToInteract or false
            
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, -5, 0, 40)
            })
            Create("UICorner", {Parent = Container, CornerRadius = Theme.CornerRadius})
            
            local Label = Create("TextLabel", {
                Parent = Container,
                Text = Title,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local BindBtn = Create("TextButton", {
                Parent = Container,
                Text = CurrentKey,
                BackgroundColor3 = Theme.Sidebar,
                TextColor3 = Theme.TextDark,
                Font = Theme.Font,
                TextSize = 12,
                Position = UDim2.new(1, -85, 0.5, -12),
                Size = UDim2.new(0, 80, 0, 24)
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            
            local Listening = false
            
            BindBtn.MouseButton1Click:Connect(function()
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Theme.Accent
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Listening = false
                    BindBtn.Text = input.KeyCode.Name
                    BindBtn.TextColor3 = Theme.TextDark
                    CurrentKey = input.KeyCode.Name
                    -- Note: Keybinds usually need logic in the main loop, we just call callback to update the variable
                    Callback(input.KeyCode)
                elseif not Listening and not gp then
                    if input.KeyCode.Name == CurrentKey then
                        -- For toggle style
                        if not HoldToInteract then Callback() end
                    end
                end
            end)
        end

        return Elements
    end

    return Window
end

return Library
