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
                    break
                end
            end
        end
    end
end

local function IsUIFrame(name)
    if not name then return false end

    -- Hover hotspots (always active, even when frames are hidden)
    if string.find(name, "^ZenHUD_Hover_") then
        return true
    end

    -- Blizzard Action buttons
    if string.find(name, "ActionButton") or string.find(name, "MultiBar") or
       string.find(name, "PetActionButton") or string.find(name, "ShapeshiftButton") then
        return true
    end

    -- Blizzard Action bar containers
    if name == "MainMenuBar" or name == "PetActionBarFrame" or name == "ShapeshiftBarFrame" then
        return true
    end

    -- Blizzard Player frame
    if name == "PlayerFrame" or string.find(name, "^PlayerFrame") then
        return true
    end

    -- ElvUI / Tukui frames
    if string.find(name, "^ElvUI_Bar") or string.find(name, "^ElvUF_") or
       string.find(name, "^Tukui") then
        return true
    end

    return false
end

function MouseoverDetector:Initialize()
    self.checkFrame = CreateFrame("Frame")
    self.checkFrame:SetScript("OnUpdate", function(_, elapsed)
        self:Check()
    end)
    -- Start hidden, will be shown when addon activates
    self.checkFrame:Hide()
end

function MouseoverDetector:Start()
    if self.checkFrame then
        self.checkFrame:Show()
    end
end

function MouseoverDetector:Check()
    local focus = GetMouseFocus()
    local name = focus and focus.GetName and focus:GetName()
    local isOver = IsUIFrame(name)

    if isOver ~= self.lastState then
        self.lastState = isOver
        -- Re-fetch StateManager in case it wasn't available at load time
        local StateManager = ZenHUD.StateManager
        if StateManager then
            StateManager:SetMouseover(isOver)
        end
    end
end

-- Export to ZenHUD namespace
ZenHUD.MouseoverDetector = MouseoverDetector
