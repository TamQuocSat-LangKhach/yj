local pojun = fk.CreateSkill {
  name = "pojun"
}

Fk:loadTranslationTable{
  ['pojun'] = '破军',
  [':pojun'] = '当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌（X为其体力值，至多为5），然后其翻面。',
  ['$pojun1'] = '大军在此！汝等休想前进一步！',
  ['$pojun2'] = '敬请，养精蓄锐！',
}

pojun:addEffect(fk.Damage, {
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(pojun.name) and data.card and data.card.trueName == "slash"
      and not data.to.dead and player.room.logic:damageByCardEffect()
  end,
  on_use = function(skill, event, target, player, data)
    local to = data.to
    to:drawCards(math.min(to.hp, 5))
    if to.dead then return end
    to:turnOver()
  end
})

return pojun