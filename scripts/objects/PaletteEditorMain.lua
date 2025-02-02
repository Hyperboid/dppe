---@class PaletteEditorMain : StateClass
local PaletteEditorMain, super = Class(StateClass)

function PaletteEditorMain:init(editor)
    super.init(self)
    ---@type PaletteEditor
    self.editor = editor
    self.select_x = 1
end

function PaletteEditorMain:registerEvents(master)
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("keypressed", self.onKeyPressed)

    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function PaletteEditorMain:onEnter()
    
end

function PaletteEditorMain:onKeyPressed(key)
    if Input.is("down", key) then
        if Input.down("cancel") then
        else
            self.editor.selected_palette = ((self.editor.selected_palette + 1) % (#self.editor.palettes+1))
            Assets.playSound("ui_move")
        end
    elseif Input.is("up", key) then
        if Input.down("cancel") then
        else
            self.editor.selected_palette = ((self.editor.selected_palette - 1) % (#self.editor.palettes+1))
            Assets.playSound("ui_move")
        end
    elseif Input.is("left", key) then
        self.select_x = (((self.select_x-2) % #self.editor.base_pal) + 1)
        Assets.playSound("ui_move")
    elseif Input.is("right", key) then
        self.select_x = (((self.select_x) % #self.editor.base_pal) + 1)
        Assets.playSound("ui_move")
    elseif Input.is("confirm", key) then
        if self.editor.selected_palette == 0 then
            Assets.playSound("ui_cant_select")
        else
            Assets.playSound("ui_select")
            self.editor.picker.pal_id = self.editor.selected_palette
            self.editor.picker.col_id = self.select_x
            self.editor:pushState("PICKER", self.editor:getPalette(self.editor.selected_palette)[self.select_x])
        end
    elseif Input.is("menu", key) then
        if Input.down("cancel") then
            if self.editor.selected_palette == 0 then
                Assets.stopAndPlaySound("ui_cant_select")
            else
                table.remove(self.editor.palettes, self.editor.selected_palette)
                self.editor.selected_palette = self.editor.selected_palette - 1
                Assets.playSound("ui_move")
            end
        else
            self.editor:duplicatePalette(self.editor.selected_palette)
        end
    end
end

function PaletteEditorMain:draw()
    local canvas = Draw.pushCanvas(SCREEN_WIDTH, 100)
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", 0,0, SCREEN_WIDTH, 100)
    love.graphics.translate(0, 20)
    love.graphics.translate(0, 23 * -self.editor.selected_palette)
    local all_palletes = Utils.merge({self.editor.base_pal},self.editor.palettes)
    for pal_id, pal in ipairs(all_palletes) do
        for col_id, col in ipairs(pal) do
            Draw.setColor(unpack(col))
            love.graphics.rectangle("fill", (col_id*23), (pal_id*23), 20,20)
            if self.select_x == col_id and (self.editor.selected_palette+1) == pal_id then
                Draw.setColor(COLORS.yellow)
                love.graphics.rectangle("line", (col_id*23)-1, (pal_id*23)-1, 23,23)
            end
        end
    end
    Draw.popCanvas()
    Draw.setColor(COLORS.white)
    Draw.draw(canvas, 0, SCREEN_HEIGHT - 100)
end

return PaletteEditorMain