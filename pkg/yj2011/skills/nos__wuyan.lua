```lua
local nos__wuyan = fk.CreateSkill {
  name = "nos__wuyan"
}

Fk:loadTranslationTable{
  ['nos__wuyan'] = '无言',
  [':nos__wuyan'] = '锁定技，你使用的非延时类锦囊对其他角色无效；其他角色使用的非延时类锦囊对你无效。',
  ['$nos__wuyan1'] = '嘘，言多必失啊。',
  ['$nos__wuyan2'] = '唉，一切尽在不言中。',
}

nos__wuyan:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    if player:hasSkill(nos__wuyan.name) and data.card:isCommonTrick() and data.card.name ~= "nullification" then
      if player.id == data.from then
        return player.id ~= data.to
      end
      if player.id == data.to then
        return player.id ~= data.from
      end
    end
  end,
  on_use = Util.TrueFunc,
})

return nos__wuyan
```