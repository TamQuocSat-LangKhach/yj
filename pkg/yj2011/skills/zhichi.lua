local zhichi = fk.CreateSkill {
  name = "zhichi"
}

Fk:loadTranslationTable{
  ['zhichi'] = '智迟',
  ['@@zhichi-turn'] = '智迟',
  [':zhichi'] = '锁定技，你的回合外，当你受到伤害后，此回合【杀】和普通锦囊牌对你无效。',
  ['$zhichi1'] = '如今之计，唯有退守，再做决断。',
  ['$zhichi2'] = '若吾，早知如此……',
}

zhichi:addEffect(fk.Damaged, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player)
    return player.phase == Player.NotActive and target == player and player:hasSkill(zhichi.name)
  end,
  on_use = function(skill, event, target, player)
    player.room:setPlayerMark(player, "@@zhichi-turn", 1)
  end,
})

zhichi:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, _, player, data)
    return player.phase == Player.NotActive and
         player.id == data.to and
         player:usedSkillTimes(zhichi.name, Player.HistoryTurn) > 0 and
         (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function() return true end,
})

return zhichi