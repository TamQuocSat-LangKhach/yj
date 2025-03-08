local jingce = fk.CreateSkill {
  name = "jingce"
}

Fk:loadTranslationTable{
  ['jingce'] = '精策',
  [':jingce'] = '出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。',
  ['$jingce1'] = '方策精详，有备无患。',
  ['$jingce2'] = '精兵据敌，策守如山。',
}

jingce:addEffect(fk.EventPhaseEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jingce.name) and player.phase == Player.Play and #player.room.logic:getEventsOfScope(GameEvent.UseCard, 998, function(e)
      local use = e.data[1]
      return use.from == player.id
    end, Player.HistoryTurn) >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, jingce.name)
  end,
})

return jingce