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
