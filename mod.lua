function Mod:init()
    assert(Kristal.Mods.getMod("dlc_yellow"))
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Game.editor = Game.world:openMenu(PaletteEditor("kris_lw"))
end

---@alias Color {[1]:number,[2]:number,[3]:number,[4]:number?}