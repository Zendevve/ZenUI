--------------------------------------------------------------------------------
-- Frame Manager - Manages all controlled frames
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils
local FrameController = ZenHUD.FrameController

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

ZenHUD.ZoneText = ZoneText

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
                if ZenHUD.FrameManager then
                    ZenHUD.FrameManager:ShowAll(false)
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

ZenHUD.Failsafe = Failsafe

--------------------------------------------------------------------------------
-- Frame Manager Implementation
--------------------------------------------------------------------------------
local FrameManager = {
    controllers = {},
    updateFrame = nil,
}

-- Frames to control
-- Frame Group Mappings
local FRAME_GROUPS = {
    -- Action Bars
    MainMenuBar = "actionBars",
    MultiBarBottomLeft = "actionBars",
    MultiBarBottomRight = "actionBars",
    MultiBarLeft = "actionBars",
    MultiBarRight = "actionBars",
    PetActionBarFrame = "actionBars",
    ShapeshiftBarFrame = "actionBars",
    VehicleMenuBar = "actionBars",
    BonusActionBarFrame = "actionBars",

    -- Unit Frames
    PlayerFrame = "unitFrames",
    PetFrame = "unitFrames",
    TargetFrameToT = "unitFrames",
    RuneFrame = "unitFrames",
    PetCastingBarFrame = "unitFrames",

    -- Buffs
    BuffFrame = "buffs",
    TemporaryEnchantFrame = "buffs",

    -- Quest
    WatchFrame = "quest",
    QuestWatchFrame = "quest",
    QuestTimerFrame = "quest",

    -- Chat
    ChatFrameMenuButton = "chat",
    ChatFrame1UpButton = "chat",
    ChatFrame1DownButton = "chat",
    ChatFrame1BottomButton = "chat",

    -- Misc (everything else defaults to misc if not in this list)
    MainMenuExpBar = "misc",
    MainMenuBarMaxLevelBar = "misc",
    ReputationWatchBar = "misc",
    MainMenuBarArtFrame = "misc",
    CharacterMicroButton = "misc",
    SpellbookMicroButton = "misc",
    TalentMicroButton = "misc",
    QuestLogMicroButton = "misc",
    SocialsMicroButton = "misc",
    WorldMapMicroButton = "misc",
    MainMenuMicroButton = "misc",
    HelpMicroButton = "misc",
    MainMenuBarBackpackButton = "misc",
    CharacterBag0Slot = "misc",
    CharacterBag1Slot = "misc",
    CharacterBag2Slot = "misc",
    CharacterBag3Slot = "misc",
    KeyRingButton = "misc",
}

-- Frames to control (List for iteration)
local CONTROLLED_FRAMES = {
    "MainMenuBar", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarLeft", "MultiBarRight", "PetActionBarFrame", "ShapeshiftBarFrame",
    "MainMenuExpBar", "MainMenuBarMaxLevelBar", "ReputationWatchBar",
    "MainMenuBarArtFrame",
    "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
    "QuestLogMicroButton", "SocialsMicroButton", "WorldMapMicroButton",
    "MainMenuMicroButton", "HelpMicroButton",
    "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
    "CharacterBag2Slot", "CharacterBag3Slot", "KeyRingButton",
    "PlayerFrame", "PetFrame", "TargetFrameToT",
    "BuffFrame", "TemporaryEnchantFrame",
    "WatchFrame", "QuestWatchFrame",
