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
    if self.animating and newTarget ~= self.targetAlpha then
        -- Interrupting animation - start from current position for smooth transition
        self.startAlpha = self.currentAlpha
    else
        self.startAlpha = self.currentAlpha
    end

    self.targetAlpha = newTarget
    self.duration = math.max(0.05, duration or Config:Get("fadeTime"))
    self.elapsed = 0
    self.animating = true

    -- Prepare for fade-in
    if alpha > self.currentAlpha then
        self.frame:Show()
        self.frame:SetAlpha(self.currentAlpha)
    end
end

function FrameController:Update(dt)
    if not self.animating then return end

    self.elapsed = self.elapsed + dt
    local progress = math.min(1, self.elapsed / self.duration)

    -- Linear interpolation from start to target
    self.currentAlpha = self.startAlpha + (self.targetAlpha - self.startAlpha) * progress
    self.frame:SetAlpha(self.currentAlpha)

    -- Animation complete
    if progress >= 1 then
        self.animating = false
        self.currentAlpha = self.targetAlpha
        self.frame:SetAlpha(self.targetAlpha)

        local isBuffFrame = (self.name == "BuffFrame" or self.name == "TemporaryEnchantFrame")
        local fadedAlpha = Config:Get("fadedAlpha") or 0

        -- Execute deferred fade-out after fade-in completes (buff frames only)
        if self.targetAlpha == 1 and self.deferFadeOut and isBuffFrame then
            self.deferFadeOut = false
            self.deferReason = nil
            self:FadeTo(fadedAlpha, Config:Get("fadeTime"))
            return
        end

        -- Execute deferred fade-in after fade-out completes (buff frames only)
        if self.targetAlpha == fadedAlpha and self.deferFadeIn and isBuffFrame then
            self.deferFadeIn = false
            self.deferReason = nil
            -- Show at faded alpha then fade in
            self.frame:Show()
            self.frame:SetAlpha(fadedAlpha)
            self:FadeTo(1, Config:Get("fadeTime"))
            return
        end

        -- Hide frame at end of fade-out for performance (unless fadeOnly)
        if self.targetAlpha <= 0.01 and not self.fadeOnly then
            self.frame:Hide()
        end
    end
end

function FrameController:Show(priority)
    local duration = priority and 0.8 or Config:Get("fadeTime")
    self:FadeTo(1, duration)
    self.visible = true
end

function FrameController:Hide()
    local fadedAlpha = Config:Get("fadedAlpha") or 0
    self:FadeTo(fadedAlpha, Config:Get("fadeTime"))
    self.visible = false
end

-- Export to ZenHUD namespace
ZenHUD.FrameController = FrameController
