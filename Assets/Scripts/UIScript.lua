local GLOBAL_FONT = "Fonts/DenkOne-Regular.ttf"
local textUIWidget = nil
local statusText = nil
local cameraUpButton = nil
local cameraDownButton = nil

function OnCreate(entity)
    local root = UIWidget.new()
    statusText = UIText.new(_G.StatusText, GLOBAL_FONT)
    statusText.Anchor = Math.Vec2.new(0.5, 0.05)
    statusText.Pivot = Math.Vec2.new(0, 0)
    statusText.FontSize = 40
    statusText.TextAlignment = TextAlignment.CENTER
    statusText.TextVAlignment = TextVerticalAlignment.CENTER
    statusText.Color = Math.Vec4.new(0, 0, 0, 1)
    root:AddChild(statusText)
    textUIWidget = statusText

    cameraUpButton = UIButton.new("UP", GLOBAL_FONT, "")
    cameraUpButton.Anchor = Math.Vec2.new(1, 0)
    cameraUpButton.Pivot = Math.Vec2.new(1, 0)
    cameraUpButton.Size = Math.Vec2.new(200, 200)
    cameraUpButton.NormalColor = Math.Vec4.new(0.1, 0.1, 0.1, 1.0)
    local txt = cameraUpButton:GetText()
    txt.Color = Math.Vec4.new(0, 1, 0, 1)
    txt.FontSize = 30
    txt.TextAlignment = TextAlignment.CENTER
    txt.TextVAlignment = TextVerticalAlignment.CENTER 
    txt.Pivot = Math.Vec2.new(0, 0)
    txt.Size = Math.Vec2.new(0, 0)
    cameraUpButton:OnClick(
    function(self)
        _G.TowerCameraTargetY = Math.Max(0, _G.TowerCameraTargetY + 5);
    end)

    root:AddChild(cameraUpButton)

    cameraDownButton = UIButton.new("DOWN", GLOBAL_FONT, "")
    cameraDownButton.Anchor = Math.Vec2.new(1, 1)
    cameraDownButton.Pivot = Math.Vec2.new(1, 1)
    cameraDownButton.Size = Math.Vec2.new(200, 200)
    cameraDownButton.NormalColor = Math.Vec4.new(0.1, 0.1, 0.1, 1.0)
    txt = cameraDownButton:GetText()
    txt.Color = Math.Vec4.new(1, 0, 0, 1)
    txt.FontSize = 30
    txt.TextAlignment = TextAlignment.CENTER
    txt.TextVAlignment = TextVerticalAlignment.CENTER 
    txt.Pivot = Math.Vec2.new(0, 0)
    txt.Size = Math.Vec2.new(0, 0)
    cameraDownButton:OnClick(
    function(self)
        _G.TowerCameraTargetY = Math.Max(0, _G.TowerCameraTargetY - 5);
    end)
    
    root:AddChild(cameraDownButton)

    SetUIRoot(root)
end

function OnUpdate(entity, dt)
    textUIWidget.Text = _G.StatusText
end

function OnDestroy(entity)
    cameraUpButton = nil
    cameraDownButton = nil
    statusText = nil
    textUIWidget = nil
    SetUIRoot(nil)
end
