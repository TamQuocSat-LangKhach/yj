local shenduan = fk.CreateSkill {
  name = "shenduan"
}

Fk:loadTranslationTable{
  ['shenduan'] = '慎断',
  ['shenduan_active'] = '慎断',
  ['#shenduan-use'] = '慎断：你可以将这些牌当【兵粮寸断】使用',
  [':shenduan'] = '当你的黑色基本牌因弃置进入弃牌堆时，你可以将此牌当无距离限制的【兵粮寸断】使用。',
  ['$shenduan1'] = '良机虽去，尚可截资断源！',
  ['$shenduan2'] = '行军须慎，谋断当绝！'
}

shenduan:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skill.name) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and player.room:getCardArea(info.cardId) == Card.DiscardPile then
              local card = Fk:getCardById(info.cardId)
              if card.type == Card.TypeBasic and card.color == Card.Black then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and player.room:getCardArea(info.cardId) == Card.DiscardPile then
            local card = Fk:getCardById(info.cardId)
            if card.type == Card.TypeBasic and card.color == Card.Black then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
    end
    for i = 1, #ids, 1 do
      if not player:hasSkill(skill.name) then break end
      local cards = table.filter(ids, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
      if #cards == 0 then break end
      skill.cancel_cost = false
      skill:doCost(event, nil, player, cards)
      if skill.cancel_cost then
        skill.cancel_cost = false
        break
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, shenduan.name, data)
    local _, dat = room:askToUseRealCard(player, {
      pattern = data,
      skill_name = "shenduan_active",
      prompt = "#shenduan-use",
      cancelable = true,
      expand_pile = data
    }, { bypass_distances = true })
    if dat then
      event:setCostData(skill, dat)
      return true
    else
      skill.cancel_cost = true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("supply_shortage", event:getCostData(skill).cards, player, room:getPlayerById(event:getCostData(skill).targets[1]), shenduan.name)
  end,
})

return shenduan