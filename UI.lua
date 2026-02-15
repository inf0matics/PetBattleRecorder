local PBR = PetBattleRecorder

----------------------------------
-- CREATE WINDOW
----------------------------------

function PBR:CreateWindow()
    if self.window then return end
    local f = CreateFrame("Frame", "PBRExportWindow", UIParent, "BackdropTemplate")
    f:SetSize(400, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:Hide()

    -- Title text
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Pet Battle Recorder - Export")

    -- Close button
    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)

    local scroll = CreateFrame(
        "ScrollFrame",
        nil,
        f,
        "UIPanelScrollFrameTemplate"
    )

    scroll:SetPoint("TOPLEFT", 20, -40)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    local edit = CreateFrame("EditBox", nil, scroll)

    edit:SetMultiLine(true)
    edit:SetFontObject("ChatFontNormal")
    edit:SetWidth(550)

    scroll:SetScrollChild(edit)

    f.edit = edit

    self.window = f
end

----------------------------------
-- SHOW EXPORT
----------------------------------

function PBR:ToggleWindow()
    if not self.window then
        self:CreateWindow()
    end

    if self.window:IsShown() then
        self.window:Hide()
    else
        local text = self:GenerateExport()
        self.window.edit:SetText(text)
        self.window:Show()
    end
end

----------------------------------
-- SLASH COMMAND
----------------------------------

SLASH_PBR1 = "/pbr"

SlashCmdList["PBR"] = function()
    PBR:ToggleWindow()
end

PBR:ToggleWindow()
