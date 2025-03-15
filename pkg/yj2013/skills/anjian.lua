```lua
local anjian = fk.CreateSkill {
  name = "anjian"
}

Fk:loadTranslationTable{
  ['anjian'] = '暗箭',
  [':anjian'] = '锁定技，当你使用的【杀】对目标角色造成伤害时，若你不在其攻击范围内，则此【杀】伤害+1。',
  ['$anjian1'] = '击其懈怠，攻其不备！',
  ['$anjian2'] = '哼，你满身都是破绽！',
}

anjian:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(anjian.name) and data.card and data.card.trueName == "slash" and
      not data.to:inMyAttackRange(player) and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return anjian
```