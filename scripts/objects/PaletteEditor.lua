---@class PaletteEditor : Object
local PaletteEditor, super = Class(Object)


--- In-editor names of palettes. Please try to keep these continuous.
PaletteEditor.PALETTE_NAMES = {
    [-1] = {{0.3,0.3,0.3,1}, "(Unused)"},
    [0] = {COLORS.gray, "Default"},

    -- DLC YELLOW
    [0x01] = "Steamworks",
    [0x02] = "Lower Snowdin",
    [0x03] = "Dunes Caves",

    -- 
    [0x10] = nil
}

setmetatable(PaletteEditor.PALETTE_NAMES, {__index = function (t, k)
    return rawget(t, -1)
end})

function PaletteEditor:init(actor)
    super.init(self)
    self:setParallax(0)
    self.shader = Assets.newShader("palette")
    ---@type Color[]
    self.base_pal = {}
    ---@type Color[][]
    self.palettes = {}
    self.selected_palette = 0
    self.backgrounds = Assets.getFrames("backgrounds/bg")
    self:setActor(actor)
    self.state_manager = StateManager("", self, true)
    self.main = PaletteEditorMain(self)
    self.picker = PaletteEditorColorPicker(self)
    self.state_manager:addState("MAIN", self.main)
    self.state_manager:addState("PICKER", self.picker)
end

function PaletteEditor:onAdd(parent)
    super.onAdd(self,parent)
    self:setState("MAIN")
end

function PaletteEditor:setState(state, ...)
    self.state_manager:setState(state, ...)
end

function PaletteEditor:pushState(state, ...)
    self.state_manager:pushState(state, ...)
end

function PaletteEditor:popState()
    self.state_manager:popState()
end

local function hexToRgb(hex, value)
    return {tonumber(string.sub(hex, 2, 3), 16)/255, tonumber(string.sub(hex, 4, 5), 16)/255, tonumber(string.sub(hex, 6, 7), 16)/255, value or 1}
end

---@param actor Actor|string
function PaletteEditor:setActor(actor)
    if type(actor) == "string" then actor = Registry.createActor(actor) end
    if self.actorsprite then self.actorsprite:remove() end
    ---@cast actor Actor
    self.base_pal = {}
    self.palettes = {}
    self.selected_palette = 0
    self.actor = actor
    self.spritedata = Assets.getTextureData(self.actor:getSpritePath() .. "/" .. self.actor:getDefault() .. "/down_1")
    self.sprite = love.graphics.newImage(self.spritedata)
    local pal_img = Assets.getTextureData(self.actor:getSpritePath() .. "/palette")
    if pal_img then
        for x = 1, pal_img:getWidth() do
            local r,g,b,a
            r,g,b,a = pal_img:getPixel(x - 1, 0)
            table.insert(self.base_pal, {r,g,b,a})
            for y=1, pal_img:getHeight() - 1 do
                self.palettes[y] = self.palettes[y] or {}
                r,g,b,a = pal_img:getPixel(x - 1, y)
                self.palettes[y][x] = {r,g,b,a}
            end
        end
    else
        local all_colors = {}
        for x = 0, self.spritedata:getWidth()-1 do
            for y = 0, self.spritedata:getHeight()-1 do
                if select(4, self.spritedata:getPixel(x, y)) > 0 then
                    all_colors[Utils.rgbToHex({self.spritedata:getPixel(x, y)})] = true
                end
            end
        end
        for key, value in pairs(all_colors) do
            if value then table.insert(self.base_pal, hexToRgb(key)) end
        end
        self:duplicatePalette(0)
    end
    self.actorsprite = actor:createSprite()
    self:addChild(self.actorsprite)
    self.actorsprite:addFX(ShaderFX(self.shader))
    self.actorsprite:setOrigin(0.5)
    self.actorsprite:setScale(4)
    self.actorsprite:setPosition((SCREEN_WIDTH/2),((SCREEN_HEIGHT-100)/2))
end

function PaletteEditor:onStateChange(old,new)
    if new == "PICKER" then
        self.actorsprite:slideTo((SCREEN_WIDTH/4),((SCREEN_HEIGHT-100)/2), 0.3, "out-quad")
    elseif new == "MAIN" then
        self.actorsprite:slideTo((SCREEN_WIDTH/2),((SCREEN_HEIGHT-100)/2), 0.3, "out-quad")
    end
end

function PaletteEditor:save()
    self:saveAs(Mod.info.path.."/assets/sprites/"..self.actor:getSpritePath().."/palette.png")
end

function PaletteEditor:saveAs(path)
    do
        local splitpath = Utils.split(path, "/")
        table.remove(splitpath)
        love.filesystem.createDirectory(table.concat(splitpath, "/"))
    end
    local canvas = love.graphics.newCanvas(#self.base_pal, #self.palettes+1)
    Draw.pushCanvas(canvas)
    for x = 1, #self.base_pal do
        for y = 0, #self.palettes do
            Draw.setColor((self:getPalette(y))[x])
            love.graphics.points(x-1,y+1)
        end
    end
    Draw.popCanvas()
    canvas:newImageData():encode("png", path)
end

function PaletteEditor:getPalette(id)
    return (self.palettes[id] or self.base_pal)
end

function PaletteEditor:update()
    self.state_manager:update()
    super.update(self)
end

function PaletteEditor:duplicatePalette(id)
    self:mixPalettes(id,id)
end

function PaletteEditor:mixPalettes(a,b)
    local pal_a = self:getPalette(a)
    local pal_b = self:getPalette(b)
    local new_pal = {}
    for i = 1, #pal_a do
        local col_a = Utils.copy(pal_a[i])
        local col_b = Utils.copy(pal_b[i])
        new_pal[i] = Utils.lerp(col_a, col_b, 0.5)
    end
    table.insert(self.palettes, a+1, new_pal)
end

function PaletteEditor:onKeyPressed(key, is_repeat)
    self.state_manager:call("keypressed", key, is_repeat)
end

function PaletteEditor:onKeyReleased(key)
    -- Check input for the current state
    self.state_manager:call("keyreleased", key)
end

function PaletteEditor:draw()
    if self.backgrounds and self.backgrounds[self.selected_palette] then
        Draw.draw(self.backgrounds[self.selected_palette])
    end
    self.state_manager:draw()
    if not self.actor then return end
    self.shader:send("base_palette", unpack(self.base_pal))
    self.shader:send("live_palette", unpack(self:getPalette(self.selected_palette)))
    super.draw(self)
end

return PaletteEditor