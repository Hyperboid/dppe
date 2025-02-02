---@class PaletteEditorColorPicker : StateClass
local PaletteEditorColorPicker, super = Class(StateClass)

function PaletteEditorColorPicker:init(editor)
    super.init(self)
    ---@type PaletteEditor
    self.editor = editor
    self.color_ref = nil
end

function PaletteEditorColorPicker:registerEvents(master)
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("keypressed", self.onKeyPressed)

    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function PaletteEditorColorPicker:onEnter(_, color_ref)
    self.color_ref = color_ref
end

function PaletteEditorColorPicker:onKeyPressed(key)
    if Input.is("cancel", key) then
        self.editor:popState()
        Assets.playSound("ui_cancel_small")
    end
end

function PaletteEditorColorPicker:update()
    local color = self.color_ref
    if Input.down("up") then
        Kristal.Console.env.print(color)
        color[1] = .5
    end
end


function PaletteEditorColorPicker:draw()
    
end

return PaletteEditorColorPicker