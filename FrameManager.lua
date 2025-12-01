--------------------------------------------------------------------------------
-- Frame Manager - Manages all controlled frames
--------------------------------------------------------------------------------
local ZenUI = _G.ZenUI
local Config = ZenUI.Config
local Utils = ZenUI.Utils
local FrameController = ZenUI.FrameController

--------------------------------------------------------------------------------
-- Zone Text Detection & Failsafe
--------------------------------------------------------------------------------
local ZoneText = {}

function ZoneText.IsFrameActive(frame)
    if not frame or not frame.IsShown or not frame:IsShown() then
        return false
    end
    if frame.GetAlpha then
        local alpha = frame:GetAlpha() or 1
        if alpha <= 0.1 then
            return false
        end
    end
    return true
end

function ZoneText.IsActive()
    local zoneFrame = _G["ZoneTextFrame"]
    local subZoneFrame = _G["SubZoneTextFrame"]
    return ZoneText.IsFrameActive(zoneFrame) or ZoneText.IsFrameActive(subZoneFrame)
end

ZenUI.ZoneText = ZoneText

--------------------------------------------------------------------------------
-- Failsafe Timer - Forces UI to show if logic breaks
--------------------------------------------------------------------------------
local Failsafe = {
    timer = nil,
    timeout = 4.0,
    elapsed = 0,
}

function Failsafe:Start()
    if not self.timer then
        self.timer = CreateFrame("Frame")
        self.timer:SetScript("OnUpdate", function(_, dt)
            self.elapsed = self.elapsed + dt
            if self.elapsed >= self.timeout then
                self:Stop()
                Utils.Print("Failsafe triggered - forcing UI show", true)
                if ZenUI.FrameManager then
                    ZenUI.FrameManager:ShowAll(false)
                end
            end
        end)
    end

    self.elapsed = 0
    self.timer:Show()
end

function Failsafe:Stop()
    if self.timer then
        self.timer:Hide()
    end
    self.elapsed = 0
end

ZenUI.Failsafe = Failsafe

--------------------------------------------------------------------------------
-- Frame Manager Implementation
--------------------------------------------------------------------------------
local FrameManager = {
    controllers = {},
    updateFrame = nil,
}

-- Frames to control
local CONTROLLED_FRAMES = {
    -- Action bars
    "MainMenuBar", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarLeft", "MultiBarRight", "PetActionBarFrame", "ShapeshiftBarFrame",

    -- XP/Rep
    "MainMenuExpBar", "MainMenuBarMaxLevelBar", "ReputationWatchBar",
    "MainMenuBarArtFrame",

    -- Micro menu
    "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
    "QuestLogMicroButton", "SocialsMicroButton", "WorldMapMicroButton",
    "MainMenuMicroButton", "HelpMicroButton",

    -- Bags
    "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
    "CharacterBag2Slot", "CharacterBag3Slot", "KeyRingButton",

    -- Unit frames
    "PlayerFrame", "PetFrame", "TargetFrameToT",

    -- Buffs
    "BuffFrame", "TemporaryEnchantFrame",

    -- Quest tracker
    "WatchFrame", "QuestWatchFrame",

    -- Chat buttons
    "ChatFrameMenuButton", "ChatFrame1UpButton", "ChatFrame1DownButton",
    "ChatFrame1BottomButton",

    -- Cast bars
    "PetCastingBarFrame",

    -- WotLK-specific frames
    "VehicleMenuBar",           -- Vehicle encounters (Flame Leviathan, etc.)
    "RuneFrame",                -- Death Knight rune cooldowns
    "QuestTimerFrame",          -- Timed quest indicators
    "BonusActionBarFrame",      -- Vehicle/special abilities bar
}

-- Conditional frames (don't force show)
local CONDITIONAL_FRAMES = {
    PetFrame = true,
    TargetFrameToT = true,
    PetCastingBarFrame = true,

    -- WotLK conditionals
    VehicleMenuBar = true,      -- Only when in vehicle
    RuneFrame = true,           -- Only for Death Knights
    BonusActionBarFrame = true, -- Only when vehicle/special abilities active
}

function FrameManager:Initialize()
    -- Re-fetch FrameController in case it wasn't ready at load time (though it should be)
    FrameController = ZenUI.FrameController

    for _, frameName in ipairs(CONTROLLED_FRAMES) do
        local frame = _G[frameName]
        if frame and frame.SetAlpha and frame.Show and frame.Hide then
            local controller = FrameController:New(frame)

            if CONDITIONAL_FRAMES[frameName] then
                controller:SetConditional(true)
            end

            self.controllers[frame] = controller
            Utils.Print("Controlling: " .. frameName, true)
        else
            Utils.Print("Skipped: " .. frameName .. " (not found)", true)
        end
    end

    -- Create update frame
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:Update(elapsed)
    end)

    Utils.Print(string.format("Managing %d frames", self:Count()), true)
end

function FrameManager:Update(dt)
    for _, controller in pairs(self.controllers) do
        controller:Update(dt)
    end
end

function FrameManager:ShowAll(priority)
    -- Check for zone text - delay if active
    if ZoneText.IsActive() then
        Utils.Print("Zone text active - delaying show", true)
        Failsafe:Start()
        Utils.After(0.2, function()
            if not ZoneText.IsActive() then
                self:ShowAll(priority)
            else
                -- Retry with timeout
                Utils.After(3.0, function()
                    Failsafe:Stop()
                    self:ShowAll(priority)
                end)
            end
        end)
        return
    end

    Failsafe:Stop()
    for _, controller in pairs(self.controllers) do
        controller:Show(priority)
    end
end

function FrameManager:HideAll()
    -- Check for zone text - delay if active
    if ZoneText.IsActive() then
        Utils.Print("Zone text active - delaying hide", true)
        Utils.After(0.2, function()
            if not ZoneText.IsActive() then
                self:HideAll()
            else
                -- Retry with timeout
                Utils.After(3.0, function()
                    self:HideAll()
                end)
            end
        end)
        return
    end

    for _, controller in pairs(self.controllers) do
        controller:Hide()
    end
end

function FrameManager:Count()
    local count = 0
    for _ in pairs(self.controllers) do
        count = count + 1
    end
    return count
end

ZenUI.FrameManager = FrameManager
