local guizao = fk.CreateSkill {
  name = "guizao"
}

Fk:loadTranslationTable{
  ['guizao'] = '瑰藻',
  [':guizao'] = '弃牌阶段结束时，若你本阶段弃置过至少两张牌且花色均不相同，你可以回复1点体力或摸一张牌。',
  ['$guizao1'] = '这都是陛下的恩泽呀。',
  ['$guizao2'] = '陛下盛宠，臣万莫敢忘。',
}

guizao:addEffect(fk.EventPhaseEnd, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(guizao.name) and player.phase == Player.Discard then
    local yes, suits = true, {}
    player.room.logic:getEventsOfScope(GameEvent.MoveCards, 999, function(e)
      for _, move in ipairs(e.data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
        local card = Fk:getCardById(info.cardId)
        if not table.contains(suits, card.suit) then
          table.insertIfNeed(suits, card.suit)
        elseif card.suit ~= Card.NoSuit then
          yes = false
          return
        end
        end
      end
      end
    end, Player.HistoryPhase)
    return yes and #suits > 1
    end
  end,
  on_cost = function(self, event, target, player)
    local choices = {"Cancel", "draw1"}
    if player:isWounded() then
    table.insert(choices, "recover")
    end
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = guizao.name,
    })
    if choice ~= "Cancel" then
    event:setCostData(self, choice)
    return true
    end
  end,
  on_use = function(self, event, target, player)
    local cost_data = event:getCostData(self)
    if cost_data == "draw1" then
    player:drawCards(1, guizao.name)
    else
    player.room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = guizao.name
    })
    end
  end,
})

return guizao