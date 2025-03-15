
local zhaofu = fk.CreateSkill {
  name = "zhaofu$"
}

Fk:loadTranslationTable{ }

zhaofu:addEffect("atkrange", {
  within_func = function(self, player, from, to)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:hasSkill(zhaofu.name) and p:distanceTo(to) == 1 and from.kingdom == "wu" and from ~= p then
        return true
      end
    end
  end,
})

return zhaofu
