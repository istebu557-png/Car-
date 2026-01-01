--[[
    Roblox Araç Kontrol Sistemi
    Değiştirilebilir tuş atamaları
    WASD varsayılan kontroller
    
    Kullanım: LocalScript olarak StarterPlayerScripts'e yerleştirin
]]

local InputController = {}
InputController.__index = InputController

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Varsayılan tuş atamaları
local DEFAULT_KEYBINDS = {
    -- Hareket kontrolleri
    Throttle = {
        Primary = Enum.KeyCode.W,
        Secondary = Enum.KeyCode.Up,
        Description = "İleri git / Gaz",
    },
    Brake = {
        Primary = Enum.KeyCode.S,
        Secondary = Enum.KeyCode.Down,
        Description = "Fren / Geri git",
    },
    SteerLeft = {
        Primary = Enum.KeyCode.A,
        Secondary = Enum.KeyCode.Left,
        Description = "Sola dön",
    },
    SteerRight = {
        Primary = Enum.KeyCode.D,
        Secondary = Enum.KeyCode.Right,
        Description = "Sağa dön",
    },
    
    -- Vites kontrolleri
    ShiftUp = {
        Primary = Enum.KeyCode.E,
        Secondary = Enum.KeyCode.PageUp,
        Description = "Vites yükselt",
    },
    ShiftDown = {
        Primary = Enum.KeyCode.Q,
        Secondary = Enum.KeyCode.PageDown,
        Description = "Vites düşür",
    },
    Clutch = {
        Primary = Enum.KeyCode.LeftShift,
        Secondary = Enum.KeyCode.RightShift,
        Description = "Debriyaj",
    },
    Neutral = {
        Primary = Enum.KeyCode.N,
        Secondary = nil,
        Description = "Boş vites",
    },
    Reverse = {
        Primary = Enum.KeyCode.R,
        Secondary = nil,
        Description = "Geri vites",
    },
    
    -- Araç özellikleri
    Headlights = {
        Primary = Enum.KeyCode.L,
        Secondary = Enum.KeyCode.H,
        Description = "Farlar aç/kapat",
    },
    Horn = {
        Primary = Enum.KeyCode.G,
        Secondary = nil,
        Description = "Korna",
    },
    Handbrake = {
        Primary = Enum.KeyCode.Space,
        Secondary = nil,
        Description = "El freni",
    },
    EngineToggle = {
        Primary = Enum.KeyCode.Y,
        Secondary = nil,
        Description = "Motor aç/kapat",
    },
    
    -- Kamera kontrolleri
    CameraToggle = {
        Primary = Enum.KeyCode.V,
        Secondary = nil,
        Description = "Kamera değiştir",
    },
    LookBack = {
        Primary = Enum.KeyCode.C,
        Secondary = nil,
        Description = "Arkaya bak",
    },
    
    -- Menü
    OpenSettings = {
        Primary = Enum.KeyCode.Tab,
        Secondary = Enum.KeyCode.Escape,
        Description = "Ayarlar menüsü",
    },
}

-- Yeni input controller oluştur
function InputController.new()
    local self = setmetatable({}, InputController)
    
    self.Keybinds = table.clone(DEFAULT_KEYBINDS)
    self.InputStates = {}
    self.Callbacks = {}
    self.IsEnabled = false
    self.InVehicle = false
    
    -- Input durumlarını başlat
    for action, _ in pairs(self.Keybinds) do
        self.InputStates[action] = false
    end
    
    -- Analog input değerleri
    self.AnalogInputs = {
        Throttle = 0,
        Brake = 0,
        Steering = 0,
    }
    
    -- Hassasiyet ayarları
    self.Sensitivity = {
        Steering = 1.0,
        SteeringSmoothing = 0.15,
        ThrottleSmoothing = 0.1,
    }
    
    return self
end

-- Tuş atamasını değiştir
function InputController:SetKeybind(action, keyType, keyCode)
    if self.Keybinds[action] then
        if keyType == "Primary" then
            self.Keybinds[action].Primary = keyCode
        elseif keyType == "Secondary" then
            self.Keybinds[action].Secondary = keyCode
        end
        return true
    end
    return false
end

-- Tuş atamasını al
function InputController:GetKeybind(action)
    return self.Keybinds[action]
end

-- Tüm tuş atamalarını al
function InputController:GetAllKeybinds()
    return self.Keybinds
end

-- Varsayılana sıfırla
function InputController:ResetToDefault()
    self.Keybinds = table.clone(DEFAULT_KEYBINDS)
end

-- Belirli bir aksiyonu varsayılana sıfırla
function InputController:ResetActionToDefault(action)
    if DEFAULT_KEYBINDS[action] then
        self.Keybinds[action] = table.clone(DEFAULT_KEYBINDS[action])
        return true
    end
    return false
end

-- Callback kaydet
function InputController:OnAction(action, callback)
    if not self.Callbacks[action] then
        self.Callbacks[action] = {}
    end
    table.insert(self.Callbacks[action], callback)
end

-- Callback'leri tetikle
function InputController:TriggerCallbacks(action, state)
    if self.Callbacks[action] then
        for _, callback in ipairs(self.Callbacks[action]) do
            callback(state)
        end
    end
end

-- Input'u kontrol et
function InputController:IsKeyForAction(keyCode, action)
    local keybind = self.Keybinds[action]
    if keybind then
        return keyCode == keybind.Primary or keyCode == keybind.Secondary
    end
    return false
end

-- Aksiyonu bul
function InputController:FindActionForKey(keyCode)
    for action, keybind in pairs(self.Keybinds) do
        if keyCode == keybind.Primary or keyCode == keybind.Secondary then
            return action
        end
    end
    return nil
end

-- Input işleyicilerini başlat
function InputController:Enable()
    if self.IsEnabled then return end
    self.IsEnabled = true
    
    -- Tuş basma olayı
    self.InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self.InVehicle then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = self:FindActionForKey(input.KeyCode)
            if action then
                self.InputStates[action] = true
                self:TriggerCallbacks(action, true)
            end
        end
    end)
    
    -- Tuş bırakma olayı
    self.InputEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not self.InVehicle then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local action = self:FindActionForKey(input.KeyCode)
            if action then
                self.InputStates[action] = false
                self:TriggerCallbacks(action, false)
            end
        end
    end)
    
    -- Analog input güncelleme
    self.UpdateConnection = RunService.RenderStepped:Connect(function(deltaTime)
        self:UpdateAnalogInputs(deltaTime)
    end)
end

-- Input işleyicilerini durdur
function InputController:Disable()
    if not self.IsEnabled then return end
    self.IsEnabled = false
    
    if self.InputBeganConnection then
        self.InputBeganConnection:Disconnect()
    end
    if self.InputEndedConnection then
        self.InputEndedConnection:Disconnect()
    end
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    
    -- Tüm input durumlarını sıfırla
    for action, _ in pairs(self.InputStates) do
        self.InputStates[action] = false
    end
end

-- Araç durumunu ayarla
function InputController:SetInVehicle(inVehicle)
    self.InVehicle = inVehicle
    
    if not inVehicle then
        -- Araçtan çıkınca tüm inputları sıfırla
        for action, _ in pairs(self.InputStates) do
            self.InputStates[action] = false
        end
        self.AnalogInputs.Throttle = 0
        self.AnalogInputs.Brake = 0
        self.AnalogInputs.Steering = 0
    end
end

-- Analog inputları güncelle (yumuşak geçiş)
function InputController:UpdateAnalogInputs(deltaTime)
    local sensitivity = self.Sensitivity
    
    -- Gaz
    local targetThrottle = self.InputStates.Throttle and 1 or 0
    self.AnalogInputs.Throttle = self.AnalogInputs.Throttle + 
        (targetThrottle - self.AnalogInputs.Throttle) * sensitivity.ThrottleSmoothing
    
    -- Fren
    local targetBrake = self.InputStates.Brake and 1 or 0
    self.AnalogInputs.Brake = self.AnalogInputs.Brake + 
        (targetBrake - self.AnalogInputs.Brake) * sensitivity.ThrottleSmoothing
    
    -- Direksiyon
    local targetSteering = 0
    if self.InputStates.SteerLeft then
        targetSteering = targetSteering - 1
    end
    if self.InputStates.SteerRight then
        targetSteering = targetSteering + 1
    end
    targetSteering = targetSteering * sensitivity.Steering
    
    self.AnalogInputs.Steering = self.AnalogInputs.Steering + 
        (targetSteering - self.AnalogInputs.Steering) * sensitivity.SteeringSmoothing
end

-- Input durumunu al
function InputController:GetInputState(action)
    return self.InputStates[action] or false
end

-- Analog input değerini al
function InputController:GetAnalogInput(inputName)
    return self.AnalogInputs[inputName] or 0
end

-- Tüm input verilerini al
function InputController:GetAllInputs()
    return {
        States = self.InputStates,
        Analog = self.AnalogInputs,
    }
end

-- Hassasiyet ayarla
function InputController:SetSensitivity(setting, value)
    if self.Sensitivity[setting] ~= nil then
        self.Sensitivity[setting] = value
        return true
    end
    return false
end

-- Tuş atamalarını kaydet (DataStore için)
function InputController:SerializeKeybinds()
    local serialized = {}
    for action, keybind in pairs(self.Keybinds) do
        serialized[action] = {
            Primary = keybind.Primary and keybind.Primary.Name or nil,
            Secondary = keybind.Secondary and keybind.Secondary.Name or nil,
        }
    end
    return serialized
end

-- Tuş atamalarını yükle (DataStore'dan)
function InputController:DeserializeKeybinds(data)
    for action, keybind in pairs(data) do
        if self.Keybinds[action] then
            if keybind.Primary then
                self.Keybinds[action].Primary = Enum.KeyCode[keybind.Primary]
            end
            if keybind.Secondary then
                self.Keybinds[action].Secondary = Enum.KeyCode[keybind.Secondary]
            end
        end
    end
end

-- Tuş çakışması kontrolü
function InputController:CheckKeyConflict(keyCode, excludeAction)
    for action, keybind in pairs(self.Keybinds) do
        if action ~= excludeAction then
            if keybind.Primary == keyCode or keybind.Secondary == keyCode then
                return action
            end
        end
    end
    return nil
end

-- Tuş adını al (görüntüleme için)
function InputController:GetKeyName(keyCode)
    if keyCode then
        return keyCode.Name
    end
    return "Yok"
end

-- Aksiyon açıklamasını al
function InputController:GetActionDescription(action)
    if self.Keybinds[action] then
        return self.Keybinds[action].Description
    end
    return ""
end

-- Mobil kontrol desteği
function InputController:SetupMobileControls(mobileGui)
    -- Mobil butonları bağla
    if mobileGui then
        -- Gaz butonu
        local throttleButton = mobileGui:FindFirstChild("ThrottleButton")
        if throttleButton then
            throttleButton.MouseButton1Down:Connect(function()
                self.InputStates.Throttle = true
            end)
            throttleButton.MouseButton1Up:Connect(function()
                self.InputStates.Throttle = false
            end)
        end
        
        -- Fren butonu
        local brakeButton = mobileGui:FindFirstChild("BrakeButton")
        if brakeButton then
            brakeButton.MouseButton1Down:Connect(function()
                self.InputStates.Brake = true
            end)
            brakeButton.MouseButton1Up:Connect(function()
                self.InputStates.Brake = false
            end)
        end
        
        -- Direksiyon (joystick veya butonlar)
        -- Bu kısım mobil UI'a göre özelleştirilebilir
    end
end

-- Gamepad desteği
function InputController:SetupGamepadControls()
    -- Gamepad bağlantı kontrolü
    UserInputService.GamepadConnected:Connect(function(gamepad)
        print("Gamepad bağlandı: " .. tostring(gamepad))
    end)
    
    -- Gamepad input işleme
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self.InVehicle then return end
        
        -- Sağ tetik (RT) - Gaz
        if input.KeyCode == Enum.KeyCode.ButtonR2 then
            self.AnalogInputs.Throttle = input.Position.Z
        end
        
        -- Sol tetik (LT) - Fren
        if input.KeyCode == Enum.KeyCode.ButtonL2 then
            self.AnalogInputs.Brake = input.Position.Z
        end
        
        -- Sol analog çubuk - Direksiyon
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            self.AnalogInputs.Steering = input.Position.X * self.Sensitivity.Steering
        end
    end)
end

-- Table.clone fonksiyonu (Roblox'ta mevcut değilse)
if not table.clone then
    function table.clone(t)
        local clone = {}
        for k, v in pairs(t) do
            if type(v) == "table" then
                clone[k] = table.clone(v)
            else
                clone[k] = v
            end
        end
        return clone
    end
end

return InputController
