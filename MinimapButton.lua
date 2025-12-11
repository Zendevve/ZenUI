--------------------------------------------------------------------------------
-- Minimap Button - Quick toggle for ZenHUD
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils

local MinimapButton = {}

-- Button configuration
local BUTTON_RADIUS = 80  -- Distance from minimap center
local BUTTON_SIZE = 31

--------------------------------------------------------------------------------
-- Create the button frame
--------------------------------------------------------------------------------
local button = CreateFrame("Button", "ZenHUDMinimapButton", Minimap)
button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:EnableMouse(true)
button:SetMovable(true)
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")

-- Button textures
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local overlay = button:CreateTexture(nil, "OVERLAY")
overlay:SetSize(53, 53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT")

local icon = button:CreateTexture(nil, "BACKGROUND")
icon:SetSize(20, 20)
icon:SetTexture("Interface\\Icons\\Spell_Nature_Sleep")  -- Zen-like icon
icon:SetPoint("CENTER", 0, 1)

local pushed = button:CreateTexture(nil, "ARTWORK")
pushed:SetSize(BUTTON_SIZE, BUTTON_SIZE)
pushed:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
button:SetPushedTexture(pushed)

--------------------------------------------------------------------------------
-- Position management (drag to move around minimap)
--------------------------------------------------------------------------------
local function UpdatePosition()
    local angle = Config:Get("minimapAngle") or 220
    local radian = math.rad(angle)
    local x = math.cos(radian) * BUTTON_RADIUS
    local y = math.sin(radian) * BUTTON_RADIUS
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function OnDragStart(self)
    self:StartMoving()
    self.isMoving = true
end

local function OnDragStop(self)
    self:StopMovingOrSizing()
    self.isMoving = false

    -- Calculate angle from minimap center
    local mx, my = Minimap:GetCenter()
    local bx, by = self:GetCenter()
