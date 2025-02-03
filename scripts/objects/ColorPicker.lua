---@class ColorPicker : Object
local ColorPicker, super = Class(Object)

local COLOR_SQUARE_X_OFFSET = 100
local COLOR_SQUARE_Y_OFFSET = 100
local HUE_X_OFFSET = 400
local HUE_Y_OFFSET = 100


local function rgbToHsv(r, g, b, a)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then s = 0 else s = d / max end

    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
        h = (g - b) / d
        if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end
  
    return h, s, v, a
end

function ColorPicker:init(color,x,y)
    super.init(self,x,y,256+32+4,256)
    self.color_square_canvas = love.graphics.newCanvas(256, 256)

    self.hue_canvas = love.graphics.newCanvas(32, 256)

    self.hue, self.saturation, self.value = rgbToHsv(unpack(color))

    self.resolution = (1/64)
    self.on_edit = function() end
    self:createColorSquareCanvas()
    self:createHueCanvas()
end

function ColorPicker:createColorSquareCanvas()
    Draw.pushCanvas(self.color_square_canvas)
        love.graphics.push()
        love.graphics.clear(COLORS.black)
        for saturation = 0, 1, self.resolution do
            for value = 0, 1, self.resolution do
                Draw.setColor(Utils.hsvToRgb(self.hue, saturation, value))
                Draw.rectangle("fill", saturation*256, value*256, (self.resolution*256), (self.resolution*256))
            end
        end
        love.graphics.pop()
    Draw.popCanvas()

end

function ColorPicker:createHueCanvas()
    Draw.pushCanvas(self.hue_canvas)
    love.graphics.clear()
    for hue = 0, 1, self.resolution do
        print(hue / self.resolution)
        Draw.setColor(Utils.hsvToRgb(hue, self.saturation, self.value))
        love.graphics.rectangle("fill", 0, hue*256, 32, self.resolution*256)
    end
    Draw.popCanvas()
end


function ColorPicker:update()
    if Input.mouseDown() then
        local mx, my = self:getFullTransform():inverseTransformPoint(Input.getMousePosition())
        local mstartx, mstarty = self:getFullTransform():inverseTransformPoint(select(2, Input.mouseDown()))
        local rect = self:getDebugRectangle() or { 0, 0, self.width, self.height+4 }
        if mstartx >= rect[1] and mstartx < rect[1] + rect[3] and mstarty >= rect[2] and mstarty < rect[2] + rect[4] then
            if mx >= (self.width - 32) then
                self.hue = Utils.clamp(my / self.height, 0,1)
            elseif mx <= self.height then
                self.saturation = Utils.clamp(mx / self.height, 0,1)
                self.value = Utils.clamp(my / self.height, 0,1)
            end
            self:on_edit()
        end
        self:createColorSquareCanvas()
        self:createHueCanvas()
    end
end

function ColorPicker:draw()
    Draw.draw(self.color_square_canvas)
    Draw.draw(self.hue_canvas, self.width - 32,0)
    Draw.setColor(COLORS.white)
    love.graphics.setLineWidth(2)
    love.graphics.ellipse("line", self.saturation*256, self.value*256, 4,4)
end

return ColorPicker