--[[
    Roblox Araç Ayarlar Menüsü UI
    Tuş atamaları, motor ayarları, şanzıman profilleri
    
    Kullanım: LocalScript olarak StarterGui'ye yerleştirin
]]

local SettingsUI = {}
SettingsUI.__index = SettingsUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- UI Renk Paleti
local COLORS = {
    Background = Color3.fromRGB(20, 20, 25),
    BackgroundSecondary = Color3.fromRGB(30, 30, 40),
    BackgroundTertiary = Color3.fromRGB(40, 40, 55),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentHover = Color3.fromRGB(0, 220, 255),
    AccentPressed = Color3.fromRGB(0, 150, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 160),
    TextMuted = Color3.fromRGB(100, 100, 110),
    Success = Color3.fromRGB(50, 255, 100),
    Warning = Color3.fromRGB(255, 180, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Divider = Color3.fromRGB(50, 50, 60),
}

-- Yeni ayarlar UI oluştur
function SettingsUI.new(player, inputController, carEngine, transmissionSystem)
    local self = setmetatable({}, SettingsUI)
    
    self.Player = player or Players.LocalPlayer
    self.InputController = inputController
    self.CarEngine = carEngine
    self.TransmissionSystem = transmissionSystem
    
    self.ScreenGui = nil
    self.MainFrame = nil
    self.IsVisible = false
    self.CurrentTab = "controls"
    
    -- Tuş atama modu
    self.IsBindingKey = false
    self.BindingAction = nil
    self.BindingType = nil
    
    return self
end

-- Ana UI'ı oluştur
function SettingsUI:Create()
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CarSettings"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = self.Player:WaitForChild("PlayerGui")
    
    -- Karartma arka planı
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.BorderSizePixel = 0
    backdrop.Parent = self.ScreenGui
    
    backdrop.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Hide()
        end
    end)
    
    -- Ana Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "SettingsFrame"
    self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.MainFrame
    
    -- Başlık çubuğu
    self:CreateTitleBar()
    
    -- Tab menüsü
    self:CreateTabMenu()
    
    -- İçerik alanı
    self:CreateContentArea()
    
    -- Varsayılan olarak gizle
    self.ScreenGui.Enabled = false
    
    return self.ScreenGui
end

-- Başlık çubuğu oluştur
function SettingsUI:CreateTitleBar()
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = COLORS.BackgroundSecondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Alt köşeleri düzelt
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 15)
    titleFix.Position = UDim2.new(0, 0, 1, -15)
    titleFix.BackgroundColor3 = COLORS.BackgroundSecondary
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Başlık metni
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚙️ Araç Ayarları"
    titleText.TextColor3 = COLORS.Text
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Kapat butonu
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = COLORS.Danger
    closeButton.BackgroundTransparency = 0.8
    closeButton.Text = "✕"
    closeButton.TextColor3 = COLORS.Text
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundTransparency = 0.5
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundTransparency = 0.8
    end)
end

-- Tab menüsü oluştur
function SettingsUI:CreateTabMenu()
    local tabMenu = Instance.new("Frame")
    tabMenu.Name = "TabMenu"
    tabMenu.Size = UDim2.new(0, 180, 1, -60)
    tabMenu.Position = UDim2.new(0, 0, 0, 50)
    tabMenu.BackgroundColor3 = COLORS.BackgroundSecondary
    tabMenu.BorderSizePixel = 0
    tabMenu.Parent = self.MainFrame
    
    local tabs = {
        {id = "controls", text = "🎮 Kontroller", icon = "🎮"},
        {id = "engine", text = "🔧 Motor", icon = "🔧"},
        {id = "transmission", text = "⚙️ Şanzıman", icon = "⚙️"},
        {id = "display", text = "📊 Gösterge", icon = "📊"},
    }
    
    self.TabButtons = {}
    
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.id .. "Tab"
        tabButton.Size = UDim2.new(1, -20, 0, 45)
        tabButton.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 50)
        tabButton.BackgroundColor3 = COLORS.BackgroundTertiary
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tab.text
        tabButton.TextColor3 = COLORS.TextSecondary
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabMenu
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = tabButton
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(tab.id)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab.id then
                tabButton.BackgroundTransparency = 0.7
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab.id then
                tabButton.BackgroundTransparency = 1
            end
        end)
        
        self.TabButtons[tab.id] = tabButton
    end
    
    -- Varsayılan tab'ı seç
    self:SwitchTab("controls")
end

-- İçerik alanı oluştur
function SettingsUI:CreateContentArea()
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -190, 1, -60)
    contentArea.Position = UDim2.new(0, 185, 0, 55)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = self.MainFrame
    
    self.ContentArea = contentArea
    
    -- Tab içeriklerini oluştur
    self:CreateControlsTab()
    self:CreateEngineTab()
    self:CreateTransmissionTab()
    self:CreateDisplayTab()
end

-- Kontroller tab'ı
function SettingsUI:CreateControlsTab()
    local container = Instance.new("ScrollingFrame")
    container.Name = "ControlsTab"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = COLORS.Accent
    container.CanvasSize = UDim2.new(0, 0, 0, 600)
    container.Visible = true
    container.Parent = self.ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container
    
    -- Başlık
    self:CreateSectionHeader(container, "Tuş Atamaları", 1)
    
    -- Tuş atama satırları
    local keybinds = {
        {action = "Throttle", order = 2},
        {action = "Brake", order = 3},
        {action = "SteerLeft", order = 4},
        {action = "SteerRight", order = 5},
        {action = "ShiftUp", order = 6},
        {action = "ShiftDown", order = 7},
        {action = "Handbrake", order = 8},
        {action = "Headlights", order = 9},
        {action = "EngineToggle", order = 10},
    }
    
    for _, bind in ipairs(keybinds) do
        self:CreateKeybindRow(container, bind.action, bind.order)
    end
    
    -- Sıfırla butonu
    local resetButton = self:CreateButton(container, "Varsayılana Sıfırla", 20)
    resetButton.MouseButton1Click:Connect(function()
        if self.InputController then
            self.InputController:ResetToDefault()
            self:RefreshKeybinds()
        end
    end)
    
    self.ControlsTab = container
end

-- Motor tab'ı
function SettingsUI:CreateEngineTab()
    local container = Instance.new("ScrollingFrame")
    container.Name = "EngineTab"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = COLORS.Accent
    container.CanvasSize = UDim2.new(0, 0, 0, 500)
    container.Visible = false
    container.Parent = self.ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container
    
    -- Motor Özellikleri
    self:CreateSectionHeader(container, "Motor Özellikleri", 1)
    
    self:CreateSlider(container, "Maksimum HP", 100, 1000, 350, 2, function(value)
        if self.CarEngine then
            self.CarEngine:UpdateConfig({Engine = {MaxHP = value}})
        end
    end)
    
    self:CreateSlider(container, "Maksimum Tork (Nm)", 200, 800, 450, 3, function(value)
        if self.CarEngine then
            self.CarEngine:UpdateConfig({Engine = {MaxTorque = value}})
        end
    end)
    
    self:CreateSlider(container, "Redline RPM", 5000, 10000, 7500, 4, function(value)
        if self.CarEngine then
            self.CarEngine:UpdateConfig({Engine = {RedlineRPM = value}})
        end
    end)
    
    -- Yakıt Sistemi
    self:CreateSectionHeader(container, "Yakıt Sistemi", 10)
    
    self:CreateSlider(container, "Tank Kapasitesi (L)", 30, 150, 65, 11, function(value)
        if self.CarEngine then
            self.CarEngine:UpdateConfig({Fuel = {MaxFuel = value}})
        end
    end)
    
    self.EngineTab = container
end

-- Şanzıman tab'ı
function SettingsUI:CreateTransmissionTab()
    local container = Instance.new("ScrollingFrame")
    container.Name = "TransmissionTab"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = COLORS.Accent
    container.CanvasSize = UDim2.new(0, 0, 0, 700)
    container.Visible = false
    container.Parent = self.ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container
    
    -- Şanzıman Tipi
    self:CreateSectionHeader(container, "Şanzıman Tipi", 1)
    
    local transmissionTypes = {"Manual", "Automatic"}
    self:CreateDropdown(container, "Tip", transmissionTypes, "Manual", 2, function(value)
        if self.TransmissionSystem then
            self.TransmissionSystem:SetTransmissionType(value)
        end
    end)
    
    -- Profiller
    self:CreateSectionHeader(container, "Şanzıman Profili", 5)
    
    local profiles = {"Standard", "Sport", "Economy", "Racing", "OffRoad"}
    self:CreateDropdown(container, "Profil", profiles, "Standard", 6, function(value)
        if self.TransmissionSystem then
            self.TransmissionSystem:SetProfile(value)
        end
    end)
    
    -- Vites Oranları
    self:CreateSectionHeader(container, "Vites Oranları", 10)
    
    for i = 1, 6 do
        local defaultRatio = ({3.5, 2.3, 1.7, 1.3, 1.0, 0.8})[i]
        self:CreateSlider(container, i .. ". Vites", 0.5, 5.0, defaultRatio, 10 + i, function(value)
            if self.TransmissionSystem then
                self.TransmissionSystem:SetGearRatio(i, value)
            end
        end, true)
    end
    
    -- Diferansiyel
    self:CreateSlider(container, "Diferansiyel Oranı", 2.5, 5.5, 3.7, 20, function(value)
        if self.TransmissionSystem then
            self.TransmissionSystem:SetFinalDriveRatio(value)
        end
    end, true)
    
    self.TransmissionTab = container
end

-- Gösterge tab'ı
function SettingsUI:CreateDisplayTab()
    local container = Instance.new("ScrollingFrame")
    container.Name = "DisplayTab"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = COLORS.Accent
    container.CanvasSize = UDim2.new(0, 0, 0, 300)
    container.Visible = false
    container.Parent = self.ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container
    
    -- Gösterge Ayarları
    self:CreateSectionHeader(container, "Gösterge Ayarları", 1)
    
    self:CreateToggle(container, "Hız Göstergesi", true, 2, function(enabled)
        -- Hız göstergesini aç/kapat
    end)
    
    self:CreateToggle(container, "RPM Göstergesi", true, 3, function(enabled)
        -- RPM göstergesini aç/kapat
    end)
    
    self:CreateToggle(container, "Yakıt Göstergesi", true, 4, function(enabled)
        -- Yakıt göstergesini aç/kapat
    end)
    
    -- Birim Seçimi
    self:CreateSectionHeader(container, "Birimler", 10)
    
    local speedUnits = {"KM/S", "MPH"}
    self:CreateDropdown(container, "Hız Birimi", speedUnits, "KM/S", 11, function(value)
        -- Hız birimini değiştir
    end)
    
    self.DisplayTab = container
end

-- Yardımcı fonksiyonlar
function SettingsUI:CreateSectionHeader(parent, text, order)
    local header = Instance.new("Frame")
    header.Name = "Header_" .. text
    header.Size = UDim2.new(1, -20, 0, 35)
    header.BackgroundTransparency = 1
    header.LayoutOrder = order
    header.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Accent
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = header
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = COLORS.Divider
    divider.BorderSizePixel = 0
    divider.Parent = header
    
    return header
end

function SettingsUI:CreateKeybindRow(parent, action, order)
    local row = Instance.new("Frame")
    row.Name = "Keybind_" .. action
    row.Size = UDim2.new(1, -20, 0, 40)
    row.BackgroundColor3 = COLORS.BackgroundSecondary
    row.BackgroundTransparency = 0.5
    row.LayoutOrder = order
    row.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = row
    
    -- Aksiyon adı
    local description = self.InputController and self.InputController:GetActionDescription(action) or action
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = description
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    -- Tuş butonu
    local keybind = self.InputController and self.InputController:GetKeybind(action)
    local keyName = keybind and keybind.Primary and keybind.Primary.Name or "Yok"
    
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.Size = UDim2.new(0, 100, 0, 30)
    keyButton.Position = UDim2.new(1, -115, 0.5, -15)
    keyButton.BackgroundColor3 = COLORS.BackgroundTertiary
    keyButton.Text = keyName
    keyButton.TextColor3 = COLORS.Accent
    keyButton.TextSize = 12
    keyButton.Font = Enum.Font.GothamMedium
    keyButton.BorderSizePixel = 0
    keyButton.Parent = row
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyButton
    
    keyButton.MouseButton1Click:Connect(function()
        self:StartKeyBinding(action, "Primary", keyButton)
    end)
    
    return row
end

function SettingsUI:CreateSlider(parent, label, min, max, default, order, callback, decimal)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. label
    container.Size = UDim2.new(1, -20, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 0, 20)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = COLORS.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueText = Instance.new("TextLabel")
    valueText.Name = "Value"
    valueText.Size = UDim2.new(0.4, 0, 0, 20)
    valueText.Position = UDim2.new(0.6, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = decimal and string.format("%.2f", default) or tostring(default)
    valueText.TextColor3 = COLORS.Accent
    valueText.TextSize = 13
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = COLORS.BackgroundTertiary
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    -- Slider etkileşimi
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local value = min + (max - min) * relativeX
            if not decimal then
                value = math.floor(value)
            end
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            valueText.Text = decimal and string.format("%.2f", value) or tostring(value)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    return container
end

function SettingsUI:CreateToggle(parent, label, default, order, callback)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. label
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = COLORS.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 50, 0, 26)
    toggleBg.Position = UDim2.new(1, -55, 0.5, -13)
    toggleBg.BackgroundColor3 = default and COLORS.Accent or COLORS.BackgroundTertiary
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 13)
    toggleCorner.Parent = toggleBg
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = default and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleKnob.BackgroundColor3 = COLORS.Text
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    local enabled = default
    
    toggleBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
            TweenService:Create(toggleBg, tweenInfo, {
                BackgroundColor3 = enabled and COLORS.Accent or COLORS.BackgroundTertiary
            }):Play()
            TweenService:Create(toggleKnob, tweenInfo, {
                Position = enabled and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
            }):Play()
            
            if callback then
                callback(enabled)
            end
        end
    end)
    
    return container
end

function SettingsUI:CreateDropdown(parent, label, options, default, order, callback)
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. label
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = COLORS.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.45, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0.55, 0, 0.5, -15)
    dropdownButton.BackgroundColor3 = COLORS.BackgroundTertiary
    dropdownButton.Text = default .. " ▼"
    dropdownButton.TextColor3 = COLORS.Text
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Parent = container
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdownButton
    
    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == default then
            currentIndex = i
            break
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        local newValue = options[currentIndex]
        dropdownButton.Text = newValue .. " ▼"
        
        if callback then
            callback(newValue)
        end
    end)
    
    return container
end

function SettingsUI:CreateButton(parent, text, order)
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = COLORS.Accent
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.LayoutOrder = order
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.AccentHover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.Accent
    end)
    
    return button
end

-- Tab değiştir
function SettingsUI:SwitchTab(tabId)
    self.CurrentTab = tabId
    
    -- Tüm tab butonlarını güncelle
    for id, button in pairs(self.TabButtons) do
        if id == tabId then
            button.BackgroundTransparency = 0.3
            button.TextColor3 = COLORS.Accent
        else
            button.BackgroundTransparency = 1
            button.TextColor3 = COLORS.TextSecondary
        end
    end
    
    -- Tüm tab içeriklerini gizle
    if self.ControlsTab then self.ControlsTab.Visible = false end
    if self.EngineTab then self.EngineTab.Visible = false end
    if self.TransmissionTab then self.TransmissionTab.Visible = false end
    if self.DisplayTab then self.DisplayTab.Visible = false end
    
    -- Seçili tab'ı göster
    if tabId == "controls" and self.ControlsTab then
        self.ControlsTab.Visible = true
    elseif tabId == "engine" and self.EngineTab then
        self.EngineTab.Visible = true
    elseif tabId == "transmission" and self.TransmissionTab then
        self.TransmissionTab.Visible = true
    elseif tabId == "display" and self.DisplayTab then
        self.DisplayTab.Visible = true
    end
end

-- Tuş atama başlat
function SettingsUI:StartKeyBinding(action, bindType, button)
    self.IsBindingKey = true
    self.BindingAction = action
    self.BindingType = bindType
    self.BindingButton = button
    
    button.Text = "Tuşa bas..."
    button.TextColor3 = COLORS.Warning
    
    -- Tuş dinleyici
    self.KeyBindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            self:CompleteKeyBinding(input.KeyCode)
        end
    end)
end

-- Tuş atama tamamla
function SettingsUI:CompleteKeyBinding(keyCode)
    if self.KeyBindConnection then
        self.KeyBindConnection:Disconnect()
    end
    
    if self.InputController and self.BindingAction then
        -- Çakışma kontrolü
        local conflict = self.InputController:CheckKeyConflict(keyCode, self.BindingAction)
        if conflict then
            -- Çakışma varsa uyar
            self.BindingButton.Text = "Çakışma!"
            self.BindingButton.TextColor3 = COLORS.Danger
            
            task.delay(1, function()
                self:RefreshKeybinds()
            end)
        else
            self.InputController:SetKeybind(self.BindingAction, self.BindingType, keyCode)
            self.BindingButton.Text = keyCode.Name
            self.BindingButton.TextColor3 = COLORS.Accent
        end
    end
    
    self.IsBindingKey = false
    self.BindingAction = nil
    self.BindingType = nil
    self.BindingButton = nil
end

-- Tuş atamalarını yenile
function SettingsUI:RefreshKeybinds()
    if not self.ControlsTab or not self.InputController then return end
    
    for _, child in ipairs(self.ControlsTab:GetChildren()) do
        if child.Name:match("^Keybind_") then
            local action = child.Name:gsub("Keybind_", "")
            local keyButton = child:FindFirstChild("KeyButton")
            if keyButton then
                local keybind = self.InputController:GetKeybind(action)
                keyButton.Text = keybind and keybind.Primary and keybind.Primary.Name or "Yok"
                keyButton.TextColor3 = COLORS.Accent
            end
        end
    end
end

-- Göster
function SettingsUI:Show()
    if not self.ScreenGui then return end
    
    self.IsVisible = true
    self.ScreenGui.Enabled = true
    
    -- Giriş animasyonu
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250)
    })
    tween:Play()
end

-- Gizle
function SettingsUI:Hide()
    if not self.ScreenGui then return end
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        self.IsVisible = false
        self.ScreenGui.Enabled = false
    end)
end

-- Değiştir
function SettingsUI:Toggle()
    if self.IsVisible then
        self:Hide()
    else
        self:Show()
    end
end

-- Yok et
function SettingsUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return SettingsUI
