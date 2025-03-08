```lua
local yizhong = fk.CreateSkill {
  name = "yizhong"
}

Fk:loadTranslationTable{
  ['yizhong'] = '毅重',
  [':yizhong'] = '锁定技，当你没有装备防具时，黑色的【杀】对你无效。',
  ['$yizhong1'] = '不先为备，何以待敌？',
  ['$yizhong2'] = '稳重行军，百战不殆！',
}

yizhong:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(yizhong.name) and data.card.trueName == "slash" and player.id == data.to and
      data.card.color == Card.Black and player:getEquipment(Card.SubtypeArmor) == nil
  end,
  on_use = Util.TrueFunc,
})

return yizhong
```