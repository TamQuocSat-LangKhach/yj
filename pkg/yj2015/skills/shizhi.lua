local shizhi = fk.CreateSkill {
  name = "shizhi"
}

Fk:loadTranslationTable{
  ['shizhi'] = '矢志',
  [':shizhi'] = '锁定技，若你的体力值为1，你的【闪】视为【杀】。',
}

shizhi:addEffect('filter', {
  card_filter = function(self, player, to_select)
    return player:hasSkill(shizhi) and player.hp == 1 and to_select.name == "jink" and
      table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
})

shizhi:addEffect(fk.HpChanged, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(shizhi, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player:filterHandcards()
  end,
})

shizhi:addEffect(fk.MaxHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(shizhi, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player:filterHandcards()
  end,
})

return shizhi