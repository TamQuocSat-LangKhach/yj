```lua
local zhaofu = fk.CreateSkill {
  name = "zhaofu$"
}

Fk:loadTranslationTable{ }

zhaofu:addEffect("atkrange", {
  within_func = function(skill, player, from, to)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:hasSkill(zhaofu.name) and p:distanceTo(to) == 1 and from.kingdom == "wu" and from ~= p then
        return true
      end
    end
  end,
})

return zhaofu
```

这个技能代码中并没有使用任何`askForXXX`方法，所以不需要进行重构。