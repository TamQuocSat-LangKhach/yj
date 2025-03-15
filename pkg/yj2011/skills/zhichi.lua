local zhichi = fk.CreateSkill {
  name = "zhichi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zhichi"] = "智迟",
  [":zhichi"] = "锁定技，你的回合外，当你受到伤害后，此回合【杀】和普通锦囊牌对你无效。",

  ["@@zhichi-turn"] = "智迟",

  ["$zhichi1"] = "如今之计，唯有退守，再做决断。",
  ["$zhichi2"] = "若吾，早知如此……",
}

zhichi:addEffect(fk.Damaged, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(zhichi.name) and player.room.current ~= player
  end,
  on_use = function(self, event, target, player)
    player.room:setPlayerMark(player, "@@zhichi-turn", 1)
  end,
})

zhichi:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:usedSkillTimes(zhichi.name, Player.HistoryTurn) > 0 and
      (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function (self, event, target, player, data)
    data.nullified = true
  end,
})

return zhichi