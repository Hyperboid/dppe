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
    self.channel_selected = 1
end

function PaletteEditorColorPicker:onKeyPressed(key)
    if Input.is("cancel", key) then
        self.editor:popState()
        Assets.playSound("ui_cancel_small")
    elseif Input.is("down", key) then
        self.channel_selected = (self.channel_selected % 3)+1
        Assets.stopAndPlaySound("ui_move")
    elseif Input.is("up", key) then
        Assets.stopAndPlaySound("ui_move")
        self.channel_selected = ((self.channel_selected-2) % 3)+1
    end
end

function PaletteEditorColorPicker:update()
    local color = self.color_ref
    local incdec = DT*.3
    if Input.down("right") then
        color[self.channel_selected] = Utils.clamp(color[self.channel_selected]+incdec, 0,1)
    elseif Input.down("left") then
        color[self.channel_selected] = Utils.clamp(color[self.channel_selected]-incdec, 0,1)
    end
end

function PaletteEditorColorPicker:draw()
    love.graphics.push()
    love.graphics.setColor(self.color_ref)
    love.graphics.translate(0,SCREEN_HEIGHT-100)
    love.graphics.rectangle("fill", 0,0,SCREEN_WIDTH,100)
    local w = SCREEN_WIDTH
    love.graphics.translate(0,-20)
    Draw.setColor({0.5,0,0})
    if self.channel_selected == 1 then Draw.setColor({1,0,0}) end
    love.graphics.setLineWidth(8)
    love.graphics.line(0,0,self.color_ref[1]*w,0)
    Draw.setColor(COLORS.green)
    if self.channel_selected == 2 then Draw.setColor(COLORS.lime) end
    love.graphics.line(0,8,self.color_ref[2]*w,8)
    Draw.setColor({0,0,0.5})
    if self.channel_selected == 3 then Draw.setColor({0,0,1}) end
    love.graphics.line(0,16,self.color_ref[3]*w,16)
    love.graphics.pop()
end

return PaletteEditorColorPicker