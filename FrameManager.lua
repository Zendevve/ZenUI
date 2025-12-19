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
    "ChatFrameMenuButton", "ChatFrame1UpButton", "ChatFrame1DownButton",
    "ChatFrame1BottomButton",
    "PetCastingBarFrame",
    "VehicleMenuBar", "RuneFrame", "QuestTimerFrame", "BonusActionBarFrame",
}

-- Conditional frames (don't force show)
local CONDITIONAL_FRAMES = {
    PetFrame = true,
    TargetFrameToT = true,
    PetCastingBarFrame = true,
    VehicleMenuBar = true,
    RuneFrame = true,
    BonusActionBarFrame = true,
}

--------------------------------------------------------------------------------
-- ElvUI / Tukui Frame Detection
--------------------------------------------------------------------------------
-- Known ElvUI frame name patterns to search for
local ELVUI_FRAME_PATTERNS = {
    -- Action Bars (ElvUI uses ElvUI_Bar1 through ElvUI_Bar10)
    { pattern = "ElvUI_Bar%d+", group = "elvui", fadeOnly = true },
    -- Unit Frames
    { pattern = "ElvUF_Player", group = "elvui", conditional = false },
    { pattern = "ElvUF_Target", group = "elvui", conditional = false },
    { pattern = "ElvUF_Pet", group = "elvui", conditional = true },
    -- Tukui equivalents
    { pattern = "TukuiActionBar%d+", group = "elvui", fadeOnly = true },
    { pattern = "TukuiPlayer", group = "elvui", conditional = false },
    { pattern = "TukuiTarget", group = "elvui", conditional = false },
}

--------------------------------------------------------------------------------
-- Frame Manager Functions
--------------------------------------------------------------------------------
function FrameManager:Initialize()
    -- Initialize Blizzard frames
    for _, frameName in ipairs(CONTROLLED_FRAMES) do
        local frame = _G[frameName]
        if frame and frame.SetAlpha and frame.Show and frame.Hide then
            -- Check if frame group is enabled
            local group = FRAME_GROUPS[frameName] or "misc"
            if Config:IsFrameGroupEnabled(group) then
                local controller = FrameController:New(frame)

                if CONDITIONAL_FRAMES[frameName] then
                    controller:SetConditional(true)
                end

                self.controllers[frame] = controller
                Utils.Print("Controlling: " .. frameName, true)
            end
        else
            Utils.Print("Skipped: " .. frameName .. " (not found)", true)
        end
    end

    -- Detect and initialize ElvUI/Tukui frames
    if _G.ElvUI or _G.Tukui then
        self:InitializeElvUIFrames()
    end

    -- Create update frame for animations
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
        self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
            self:Update(elapsed)
        end)
    end

    Utils.Print(string.format("Managing %d frames", self:Count()), true)
end

function FrameManager:InitializeElvUIFrames()
    if not Config:IsFrameGroupEnabled("elvui") then return end

    for frameName, frameObj in pairs(_G) do
        if type(frameObj) == "table" and frameObj.SetAlpha and frameObj.Show and frameObj.Hide then
            for _, patternInfo in ipairs(ELVUI_FRAME_PATTERNS) do
                if string.match(frameName, "^" .. patternInfo.pattern .. "$") or frameName == patternInfo.pattern then
                    if not self.controllers[frameObj] then
                        local controller = FrameController:New(frameObj)
                        if patternInfo.fadeOnly then
                            controller:SetFadeOnly(true)
                        end
                        if patternInfo.conditional then
                            controller:SetConditional(true)
                        end
                        self.controllers[frameObj] = controller
                        Utils.Print("Controlling ElvUI frame: " .. frameName, true)
                    end
                    break
                end
            end
        end
    end
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

-- Export to ZenHUD namespace
ZenHUD.FrameManager = FrameManager
