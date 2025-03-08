local zongxuan = fk.CreateSkill {
  name = "zongxuan"
}

Fk:loadTranslationTable{
  ['zongxuan'] = '纵玄',
  ['zongxuanNoput'] = '不置于牌堆顶',
  [':zongxuan'] = '当你的牌因弃置而移至弃牌堆后，你可以将其中至少一张牌置于牌堆顶。',
  ['$zongxuan1'] = '依易设象，以占吉凶。',
  ['$zongxuan2'] = '世间万物，皆有定数。',
}

zongxuan:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zongxuan.name) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              if player.room:getCardArea(info.cardId) == Card.DiscardPile then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            if room:getCardArea(info.cardId) == Card.DiscardPile then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end
    if #cards > 0 then
      local top = room:askToGuanxing(player, {
        cards = cards,
        top_limit = {1, #cards},
        skill_name = zongxuan.name,
        skip = true,
        area_names = {nil, "zongxuanNoput"}
      }).top
      if #top > 0 then
        room:moveCards({
          ids = table.reverse(top),
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = zongxuan.name,
          proposer = player.id,
        })
      end
    end
  end,
})

return zongxuan