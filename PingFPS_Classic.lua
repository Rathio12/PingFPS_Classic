PingFPSClassicDB = PingFPSClassicDB or {}

local defaults = {
    point = "CENTER",
    x = 0,
    y = 0,
    locked = false,
}

local function ApplyDefaults()
    for k, v in pairs(defaults) do
        if PingFPSClassicDB[k] == nil then
            PingFPSClassicDB[k] = v
        end
    end
end

local frame = CreateFrame("Frame", "PingFPSClassicFrame", UIParent)
frame:SetSize(120, 24)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 0.6)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")

frame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() and not PingFPSClassicDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, _, x, y = self:GetPoint()
    PingFPSClassicDB.point = p
    PingFPSClassicDB.x = x
    PingFPSClassicDB.y = y
end)

local elapsed = 0
frame:SetScript("OnUpdate", function(self, e)
    elapsed = elapsed + e
    if elapsed < 1 then return end
    elapsed = 0

    local _, _, home, world = GetNetStats()
    local ping = world or home or 0
    local fps = floor(GetFramerate() or 0)

    text:SetText("Ping: "..ping.." ms | FPS: "..fps)
end)

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if addon ~= "PingFPS_Classic" then return end

    ApplyDefaults()

    frame:ClearAllPoints()
    frame:SetPoint(
        PingFPSClassicDB.point,
        UIParent,
        PingFPSClassicDB.point,
        PingFPSClassicDB.x,
        PingFPSClassicDB.y
    )
end)

SLASH_PINGFPSCLASSIC1 = "/pingfps"
SlashCmdList["PINGFPSCLASSIC"] = function()
    PingFPSClassicDB.locked = not PingFPSClassicDB.locked
    print("|cff00ff00PingFPS Classic|r frame locked:", PingFPSClassicDB.locked)
end
