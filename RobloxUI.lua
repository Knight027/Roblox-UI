--[[
    GEMINI UI LIBRARY v1.0
    Author: Gemini
    Style: Minimalist Dark, rounded, smooth animations.
    Compatibility: Matches Rayfield table structure for easy migration.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

function Library:CreateWindow(Settings)
    local Window = {}
    
    -- 1. Main ScreenGUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GeminiUI_" .. (Settings.Name or "Hub")
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protect GUI if possible (Synapse/Krnl)
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    -- 2. Main Frame (The Window)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    -- Title Bar
    local Title = Instance.new("TextLabel")
    Title.Text = Settings.Name or "UI Library"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    -- Tab Container (Left Side)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 130, 1, -45)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    -- Page Container (Right Side)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -155, 1, -45)
    PageContainer.Position = UDim2.new(0, 145, 0, 40)
    PageContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PageContainer.Parent = MainFrame
    Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 6)

    local FirstTab = true

    function Window:CreateTab(Name)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Text = Name
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 13
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
        
        -- Tab Page (Scrolling Frame)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name .. "_Page"
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.new(0, 5, 0, 5)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        -- Update Canvas Size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            -- Reset all tabs
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end
            for _, child in pairs(PageContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            
            -- Activate this tab
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 100), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Page.Visible = true
        end

        -- ELEMENTS

        function Tab:CreateSection(Name)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Text = Name
            SectionLabel.Size = UDim2.new(1, 0, 0, 25)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = 14
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Page
        end

        function Tab:CreateToggle(Config)
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Config.Name
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = UDim2.new(1, -30, 0.5, -10)
            Indicator.BackgroundColor3 = Config.CurrentValue and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
            Indicator.Parent = ToggleFrame
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

            local Toggled = Config.CurrentValue or false

            ToggleFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                local targetColor = Toggled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                if Config.Callback then Config.Callback(Toggled) end
            end)
        end

        function Tab:CreateSlider(Config)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 45)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderFrame.Parent = Page
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Config.Name
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 2)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 2)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Text = tostring(Config.CurrentValue) .. (Config.Suffix or "")
            ValueLabel.Parent = SliderFrame

            local SlideBG = Instance.new("TextButton") -- Using button for easier input capture
            SlideBG.Size = UDim2.new(1, -20, 0, 6)
            SlideBG.Position = UDim2.new(0, 10, 0, 30)
            SlideBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SlideBG.AutoButtonColor = false
            SlideBG.Text = ""
            SlideBG.Parent = SliderFrame
            Instance.new("UICorner", SlideBG).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            Fill.Parent = SlideBG
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            -- Logic
            local Min = Config.Range[1]
            local Max = Config.Range[2]
            local Current = Config.CurrentValue or Min

            local function Update(val)
                val = math.clamp(val, Min, Max)
                local percent = (val - Min) / (Max - Min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = string.format("%.2f", val) .. (Config.Suffix or "")
                if Config.Callback then Config.Callback(val) end
            end
            
            -- Set initial
            Update(Current)

            local dragging = false
            SlideBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local MousePos = UserInputService:GetMouseLocation().X
                    local FramePos = SlideBG.AbsolutePosition.X
                    local FrameSize = SlideBG.AbsoluteSize.X
                    local Relative = math.clamp((MousePos - FramePos) / FrameSize, 0, 1)
                    local NewValue = Min + (Relative * (Max - Min))
                    
                    -- Rounding based on Increment
                    if Config.Increment then
                        NewValue = math.floor(NewValue / Config.Increment + 0.5) * Config.Increment
                    end
                    Update(NewValue)
                end
            end)
        end

        function Tab:CreateDropdown(Config)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35) -- Collapsed size
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            DropdownFrame.Parent = Page
            DropdownFrame.ClipsDescendants = true
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Config.Name .. ": " .. Config.CurrentOption
            Label.Size = UDim2.new(1, -40, 0, 35)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "v"
            Arrow.Size = UDim2.new(0, 30, 0, 35)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Parent = DropdownFrame

            local OpenBtn = Instance.new("TextButton")
            OpenBtn.Size = UDim2.new(1, 0, 0, 35)
            OpenBtn.BackgroundTransparency = 1
            OpenBtn.Text = ""
            OpenBtn.Parent = DropdownFrame

            -- Options Container
            local OptionList = Instance.new("Frame")
            OptionList.Size = UDim2.new(1, -10, 0, 0) -- calculated later
            OptionList.Position = UDim2.new(0, 5, 0, 40)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = DropdownFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = OptionList

            local isOpen = false
            
            local function RefreshOptions()
                for _, v in pairs(OptionList:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                
                for _, opt in pairs(Config.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 12
                    OptBtn.Parent = OptionList
                    Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Label.Text = Config.Name .. ": " .. opt
                        if Config.Callback then Config.Callback(opt) end
                        isOpen = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                        Arrow.Text = "v"
                    end)
                end
            end
            
            RefreshOptions()

            OpenBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local count = #Config.Options
                local targetHeight = isOpen and (45 + (count * 27)) or 35
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                Arrow.Text = isOpen and "^" or "v"
            end)
        end

        function Tab:CreateColorPicker(Config)
            -- Simplified RGB Sliders for reliability
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(1, 0, 0, 110)
            PickerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            PickerFrame.Parent = Page
            Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Config.Name
            Label.Size = UDim2.new(1, -50, 0, 25)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = PickerFrame

            local Preview = Instance.new("Frame")
            Preview.Size = UDim2.new(0, 25, 0, 25)
            Preview.Position = UDim2.new(1, -35, 0, 5)
            Preview.BackgroundColor3 = Config.Color or Color3.fromRGB(255, 255, 255)
            Preview.Parent = PickerFrame
            Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

            -- Internal Helper for RGB Sliders
            local function CreateRGBSlider(yPos, colorComponent, initialVal)
                local SFrame = Instance.new("Frame")
                SFrame.Size = UDim2.new(1, -20, 0, 15)
                SFrame.Position = UDim2.new(0, 10, 0, yPos)
                SFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                SFrame.Parent = PickerFrame
                Instance.new("UICorner", SFrame).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(initialVal, 0, 1, 0)
                Fill.BackgroundColor3 = colorComponent == "R" and Color3.fromRGB(255,50,50) or (colorComponent == "G" and Color3.fromRGB(50,255,50) or Color3.fromRGB(50,50,255))
                Fill.Parent = SFrame
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.Parent = SFrame

                return Btn, Fill
            end

            local rVal, gVal, bVal = Config.Color.R, Config.Color.G, Config.Color.B
            
            local btnR, fillR = CreateRGBSlider(35, "R", rVal)
            local btnG, fillG = CreateRGBSlider(60, "G", gVal)
            local btnB, fillB = CreateRGBSlider(85, "B", bVal)

            local function UpdateColor()
                local newColor = Color3.new(rVal, gVal, bVal)
                Preview.BackgroundColor3 = newColor
                if Config.Callback then Config.Callback(newColor) end
            end

            local function HandleSlide(input, btn, component)
                 local MousePos = input.Position.X
                 local FramePos = btn.AbsolutePosition.X
                 local FrameSize = btn.AbsoluteSize.X
                 local pct = math.clamp((MousePos - FramePos) / FrameSize, 0, 1)
                 
                 if component == "R" then rVal = pct fillR.Size = UDim2.new(pct, 0, 1, 0) end
                 if component == "G" then gVal = pct fillG.Size = UDim2.new(pct, 0, 1, 0) end
                 if component == "B" then bVal = pct fillB.Size = UDim2.new(pct, 0, 1, 0) end
                 UpdateColor()
            end

            local dragging = nil
            
            local function BindSlider(btn, comp)
                btn.InputBegan:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = {btn, comp} HandleSlide(input, btn, comp) end 
                end)
            end
            
            BindSlider(btnR, "R")
            BindSlider(btnG, "G")
            BindSlider(btnB, "B")
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    HandleSlide(input, dragging[1], dragging[2])
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = nil end
            end)
        end
        
        function Tab:CreateButton(Config)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Btn.Text = Config.Name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            
            Btn.MouseButton1Click:Connect(function()
                if Config.Callback then Config.Callback() end
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            end)
        end

        function Tab:CreateKeybind(Config)
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, 0, 0, 35)
            KeyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            KeyFrame.Parent = Page
            Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Config.Name
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = KeyFrame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 80, 0, 25)
            BindBtn.Position = UDim2.new(1, -90, 0, 5)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            BindBtn.Text = Config.CurrentKeybind or "None"
            BindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 12
            BindBtn.Parent = KeyFrame
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)

            local listening = false
            local currentKey = Config.CurrentKeybind

            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    BindBtn.Text = currentKey
                    BindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    listening = false
                    -- If the user provided a callback for binding change (uncommon but supported)
                    if Config.Callback then 
                        -- Rayfield keybinds usually don't trigger callback on bind, only on press
                        -- But we need to update the logic in main script to use InputBegan listener for the specific key
                    end
                end
                
                -- Trigger Logic
                if not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
                   if Config.Callback then Config.Callback() end
                end
            end)
            
            -- Handle HoldToInteract logic in the main script using loop checks, or custom events here.
            -- For simplicity in this replacement, we trigger the callback on press.
        end

        return Tab
    end
    
    return Window
end

return Library
