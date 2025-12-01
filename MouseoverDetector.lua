--------------------------------------------------------------------------------
-- Mouseover Detection
--------------------------------------------------------------------------------
local ZenUI = _G.ZenUI
local Utils = ZenUI.Utils
local StateManager = ZenUI.StateManager

local MouseoverDetector = {
    checkFrame = nil,
    lastState = false,
}

-- Hover hotspots for reliable detection when frames are hidden
local hoverHotspots = {}

local function CreateHoverHotspot(parentFrame, name)
    if hoverHotspots[name] or not parentFrame then return end

    local hotspot = CreateFrame("Frame", "ZenUI_Hover_" .. name, UIParent)
    hotspot:SetFrameStrata("LOW")
    hotspot:SetFrameLevel(1)
    hotspot:SetAllPoints(parentFrame)
    hotspot:EnableMouse(true)
    hotspot:Show()

    hoverHotspots[name] = hotspot
    Utils.Print("Created hover hotspot: " .. name, true)
end

function MouseoverDetector:CreateHotspots()
    -- Action bars
    if MainMenuBar then CreateHoverHotspot(MainMenuBar, "MainMenuBar") end
    if MultiBarBottomLeft then CreateHoverHotspot(MultiBarBottomLeft, "MultiBarBottomLeft") end
    if MultiBarBottomRight then CreateHoverHotspot(MultiBarBottomRight, "MultiBarBottomRight") end
    if MultiBarLeft then CreateHoverHotspot(MultiBarLeft, "MultiBarLeft") end
    if MultiBarRight then CreateHoverHotspot(MultiBarRight, "MultiBarRight") end
    if PetActionBarFrame then CreateHoverHotspot(PetActionBarFrame, "PetActionBarFrame") end
    if ShapeshiftBarFrame then CreateHoverHotspot(ShapeshiftBarFrame, "ShapeshiftBarFrame") end

    -- Player frame
    if PlayerFrame then CreateHoverHotspot(PlayerFrame, "PlayerFrame") end

    Utils.Print(string.format("Created %d hover hotspots", #hoverHotspots), true)
end

local function IsUIFrame(name)
    if not name then return false end

    -- Hover hotspots (always active, even when frames are hidden)
    if string.find(name, "^ZenUI_Hover_") then
        return true
    end

    -- Action buttons
    if string.find(name, "ActionButton") or string.find(name, "MultiBar") or
       string.find(name, "PetActionButton") or string.find(name, "ShapeshiftButton") then
        return true
    end

    -- Action bar containers
    if name == "MainMenuBar" or name == "PetActionBarFrame" or name == "ShapeshiftBarFrame" then
        return true
    end

    -- Player frame
    if name == "PlayerFrame" or string.find(name, "^PlayerFrame") then
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
    -- Re-fetch StateManager if needed
    StateManager = ZenUI.StateManager

    local focus = GetMouseFocus()
    local name = focus and focus.GetName and focus:GetName()
    local isOver = IsUIFrame(name)

    if isOver ~= self.lastState then
        self.lastState = isOver
        if StateManager then
            StateManager:SetMouseover(isOver)
        end
    end
end

ZenUI.MouseoverDetector = MouseoverDetector
