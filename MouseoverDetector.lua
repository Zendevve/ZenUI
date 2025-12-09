--------------------------------------------------------------------------------
-- Mouseover Detection
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Utils = ZenHUD.Utils
local StateManager = ZenHUD.StateManager

local MouseoverDetector = {
    checkFrame = nil,
    lastState = false,
}

-- Hover hotspots for reliable detection when frames are hidden
local hoverHotspots = {}

local function CreateHoverHotspot(parentFrame, name)
    if hoverHotspots[name] or not parentFrame then return end

    local hotspot = CreateFrame("Frame", "ZenHUD_Hover_" .. name, UIParent)
    hotspot:SetFrameStrata("LOW")
    hotspot:SetFrameLevel(1)
    hotspot:SetAllPoints(parentFrame)
    hotspot:EnableMouse(true)
    hotspot:Show()

    hoverHotspots[name] = hotspot
    Utils.Print("Created hover hotspot: " .. name, true)
end

function MouseoverDetector:CreateHotspots()
    -- Blizzard Action bars
    if MainMenuBar then CreateHoverHotspot(MainMenuBar, "MainMenuBar") end
    if MultiBarBottomLeft then CreateHoverHotspot(MultiBarBottomLeft, "MultiBarBottomLeft") end
    if MultiBarBottomRight then CreateHoverHotspot(MultiBarBottomRight, "MultiBarBottomRight") end
    if MultiBarLeft then CreateHoverHotspot(MultiBarLeft, "MultiBarLeft") end
    if MultiBarRight then CreateHoverHotspot(MultiBarRight, "MultiBarRight") end
    if PetActionBarFrame then CreateHoverHotspot(PetActionBarFrame, "PetActionBarFrame") end
    if ShapeshiftBarFrame then CreateHoverHotspot(ShapeshiftBarFrame, "ShapeshiftBarFrame") end

    -- Player frame
    if PlayerFrame then CreateHoverHotspot(PlayerFrame, "PlayerFrame") end

    -- ElvUI / Tukui frames (scan dynamically)
    self:CreateElvUIHotspots()

    local count = 0
    for _ in pairs(hoverHotspots) do count = count + 1 end
    Utils.Print(string.format("Created %d hover hotspots", count), true)
end

-- ElvUI hotspot patterns
local ELVUI_HOTSPOT_PATTERNS = {
    "ElvUI_Bar%d+",
    "ElvUI_StanceBar",
    "ElvUI_PetBar",
    "ElvUF_Player",
    "ElvUF_Target",
    "TukuiActionBar%d+",
    "TukuiPlayer",
    "TukuiTarget",
}

function MouseoverDetector:CreateElvUIHotspots()
    -- Only run if ElvUI or Tukui is loaded
    if not (_G.ElvUI or _G.Tukui) then return end

    for frameName, frameObj in pairs(_G) do
        if type(frameObj) == "table" and frameObj.GetName then
            for _, pattern in ipairs(ELVUI_HOTSPOT_PATTERNS) do
                if string.match(frameName, "^" .. pattern .. "$") or frameName == pattern then
                    CreateHoverHotspot(frameObj, frameName)
