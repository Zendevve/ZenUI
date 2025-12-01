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
