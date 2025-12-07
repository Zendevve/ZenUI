--------------------------------------------------------------------------------
-- Frame Controller - Manages fade animations for individual frames
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils

local FrameController = {}
FrameController.__index = FrameController

function FrameController:New(frame)
    local instance = {
        frame = frame,
        name = frame:GetName() or "Unknown",
        visible = frame:IsShown(),

        -- Animation state
        animating = false,
        startAlpha = frame:GetAlpha() or 1,
        targetAlpha = 1,
        currentAlpha = frame:GetAlpha() or 1,
        duration = 0,
        elapsed = 0,

        -- Behavior flags
        fadeOnly = false,  -- Don't call Hide(), just set alpha to 0
        conditional = false,  -- Don't force Show() if frame is hidden

        -- Buff frame anti-flicker (defer system)
        deferFadeIn = false,
        deferFadeOut = false,
        deferReason = nil,
    }

    setmetatable(instance, self)
    return instance
end

function FrameController:SetFadeOnly(value)
    self.fadeOnly = value
    return self
end

function FrameController:SetConditional(value)
    self.conditional = value
    return self
end

function FrameController:FadeTo(alpha, duration)
    -- Buff frame anti-flicker logic
    local isBuffFrame = (self.name == "BuffFrame" or self.name == "TemporaryEnchantFrame")

    if isBuffFrame then
        -- If fading IN and a fade OUT is requested, defer the OUT
        local fadedAlpha = Config:Get("fadedAlpha")
        if alpha == fadedAlpha and self.animating and self.targetAlpha == 1 then
            self.deferFadeOut = true
            self.deferReason = "deferred_buff_fadeout"
            return
        end

        -- If fading OUT and a fade IN is requested, defer the IN
        if alpha == 1 and self.animating and self.targetAlpha == fadedAlpha then
            self.deferFadeIn = true
            self.deferReason = "deferred_buff_fadein"
            return
        end
    end

    -- Don't force show conditional frames
    if alpha > 0 and self.conditional and not self.frame:IsShown() then
        return
    end

    -- Skip if already at target AND not animating
    if not self.animating and math.abs(self.currentAlpha - alpha) < 0.01 then
        return
    end

    -- Smooth interruption: if animating to opposite direction, start from current position
    local newTarget = Utils.Clamp(alpha, 0, 1)
