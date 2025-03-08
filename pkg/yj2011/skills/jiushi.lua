local jiushi = fk.CreateSkill {
  name = "jiushi"
}

Fk:loadTranslationTable{
  ['jiushi'] = '酒诗',
  [':jiushi'] = '若你的武将牌正面朝上，你可以翻面视为使用一张【酒】；当你受到伤害时，若你的武将牌背面朝上，你可以在受到伤害后翻至正面。',
  ['$jiushi1'] = '置酒高殿上，亲友从我游。',
  ['$jiushi2'] = '走马行酒醴，驱车布鱼肉。',
}

jiushi:addEffect('viewas', {
  anim_type = "support",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  before_use = function(skill, player)
    player:turnOver()
  end,
  view_as = function(skill, player)
    local c = Fk:cloneCard("analeptic")
    c.skillName = jiushi.name
    return c
  end,
  enabled_at_play = function (skill, player)
    return player.faceup
  end,
  enabled_at_response = function (skill, player, response)
    return player.faceup and not response
  end,
})

jiushi:addEffect(fk.Damaged, {
  mute = true,
  main_skill = jiushi,
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(jiushi.name) and (data.extra_data or {}).jiushi_check and not player.faceup
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = "jiushi" })
  end,
  on_use = function(skill, event, target, player, data)
    player:broadcastSkillInvoke("jiushi")
    player.room:notifySkillInvoked(player, "jiushi", "defensive")
    player:turnOver()
  end,

  can_refresh = function(skill, event, target, player, data)
    return target == player and not player.faceup
  end,
  on_refresh = function(skill, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.jiushi_check = true
  end,
})

return jiushi