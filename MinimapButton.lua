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
    local angle = math.deg(math.atan2(by - my, bx - mx))

    Config:Set("minimapAngle", angle)
    UpdatePosition()
end

button:SetScript("OnDragStart", OnDragStart)
button:SetScript("OnDragStop", OnDragStop)

--------------------------------------------------------------------------------
-- Click handlers
--------------------------------------------------------------------------------
button:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
        -- Toggle addon enabled
        local enabled = not Config:Get("enabled")
        Config:Set("enabled", enabled)
        Utils.Print(string.format("Addon %s", enabled and "enabled" or "disabled"))
        if enabled and ZenHUD.StateManager then
            ZenHUD.StateManager:Update()
        end
    elseif btn == "RightButton" then
        -- Open options panel
        InterfaceOptionsFrame_OpenToCategory("ZenHUD")
        InterfaceOptionsFrame_OpenToCategory("ZenHUD")  -- Called twice due to Blizzard bug
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("ZenHUD")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cFF00FF00Left-click|r to toggle addon", 1, 1, 1)
    GameTooltip:AddLine("|cFF00FF00Right-click|r to open options", 1, 1, 1)
    GameTooltip:AddLine("|cFF00FF00Drag|r to move button", 1, 1, 1)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

--------------------------------------------------------------------------------
-- MinimapButton API
--------------------------------------------------------------------------------
function MinimapButton:Show()
    button:Show()
end

function MinimapButton:Hide()
    button:Hide()
end

function MinimapButton:Initialize()
    UpdatePosition()

    -- Show/hide based on config
    if Config:Get("showMinimapButton") then
        button:Show()
    else
        button:Hide()
    end
end

-- Initialize on load
MinimapButton:Initialize()

-- Export to ZenHUD namespace
ZenHUD.MinimapButton = MinimapButton
