---@class PaletteEditor : Object
local PaletteEditor, super = Class(Object)

function PaletteEditor:init(actor)
    super.init(self)
    self:setParallax(0)
    self.shader = Assets.newShader("palette")
    ---@type Color[]
    self.base_pal = {}
    ---@type Color[][]
    self.palettes = {}
    self.selected_palette = 0
    self:setActor(actor)
    self.state_manager = StateManager("", self, true)
    self.main = PaletteEditorMain(self)
    self.state_manager:addState("MAIN", self.main)
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

---@param actor Actor|string
function PaletteEditor:setActor(actor)
    if type(actor) == "string" then actor = Registry.createActor(actor) end
    self.base_pal = {}
    self.palettes = {}
    self.selected_palette = 0
    ---@cast actor Actor
    self.actor = actor
    self.spritedata = Assets.getTextureData(self.actor:getSpritePath() .. "/" .. self.actor:getDefault() .. "/down_1")
    self.sprite = love.graphics.newImage(self.spritedata)
    local pal_img = Assets.getTextureData(self.actor:getSpritePath() .. "/palette")
    if pal_img then
        for x = 1, pal_img:getWidth()/2 do
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
                all_colors[Utils.rgbToHex({self.spritedata:getPixel(x, y)})] = true
            end
        end
        for key, value in pairs(all_colors) do
            if value then table.insert(self.base_pal, Utils.hexToRgb(key)) end
        end
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
            Draw.setColor((self.palettes[y] or self.base_pal)[x])
            love.graphics.points(x-1,y+1)
        end
    end
    Draw.popCanvas()
    canvas:newImageData():encode("png", path)
end

function PaletteEditor:update()
    self.state_manager:update()
    super.update(self)
end

function PaletteEditor:onKeyPressed(key, is_repeat)
    self.state_manager:call("keypressed", key, is_repeat)
end

function PaletteEditor:onKeyReleased(key)
    -- Check input for the current state
    self.state_manager:call("keyreleased", key)
end

function PaletteEditor:draw()
    self.state_manager:draw()
    if not self.actor then return end
    self.shader:send("base_palette", unpack(self.base_pal))
    self.shader:send("live_palette", unpack(self.palettes[self.selected_palette] or self.base_pal))
    love.graphics.setShader(self.shader)
    Draw.draw(self.sprite, 100, 100, 0, 4,4)
    love.graphics.setShader()
end

return PaletteEditor