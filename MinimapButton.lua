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
