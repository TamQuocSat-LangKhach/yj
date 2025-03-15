local jiaojin = fk.CreateSkill {
  name = "jiaojin"
}

Fk:loadTranslationTable{
  ['jiaojin'] = '骄矜',
  [':jiaojin'] = '每当你受到一名男性角色造成的伤害时，你可以弃置一张装备牌，令此伤害-1。',
  ['$jiaojin1'] = '就凭你，还想算计于我？',
  ['$jiaojin2'] = '是谁借给你的胆子？'
}

jiaojin:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaojin.name) and data.from and data.from:isMale() and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return #player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = jiaojin.name,
    cancelable = true,
    pattern = ".|.|.|.|.|equip",
    prompt = "#jiaojin-cost"
    }) > 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
})

return jiaojin