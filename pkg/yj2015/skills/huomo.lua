local huomo = fk.CreateSkill {
  name = "huomo"
}

Fk:loadTranslationTable{
  ['huomo'] = '活墨',
  ['#huomo'] = '活墨：将一张黑色非基本牌置于牌堆顶，视为使用一张基本牌',
  [':huomo'] = '当你需要使用基本牌时（你本回合使用过的基本牌除外），你可以将一张黑色非基本牌置于牌堆顶，视为使用此基本牌。',
  ['$huomo1'] = '笔墨写春秋，挥毫退万敌！',
  ['$huomo2'] = '妙笔在手，研墨在心。',
}

huomo:addEffect('viewas', {
  pattern = ".|.|.|.|.|basic",
  prompt = "#" .. huomo.name,
  interaction = function(self)
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(self, huomo.name, all_names, nil, self.player:getTableMark(huomo.name))
    if #names == 0 then return end
    return U.CardNameBox {choices = names, all_names = all_names}
  end,
  card_filter = function (self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type ~= Card.TypeBasic and card.color == Card.Black
  end,
  before_use = function (self, player, use)
    local room = player.room
    local put = use.card:getMark(huomo.name)
    if put ~= 0 and table.contains(player:getCardIds("he"), put) then
      room:moveCards({
        ids = {put},
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = huomo.name,
        proposer = player.id,
        moveVisible = true,
      })
    end
  end,
  view_as = function(self, player, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:setMark(huomo.name, cards[1])
    card.skillName = huomo.name
    return card
  end,
  enabled_at_play = function(self, player)
    return not player:isNude()
  end,
  enabled_at_response = function(self, player, response)
    return not response and not player:isNude()
  end,

  on_acquire = function (self, player, is_start)
    if not is_start then
      local room = player.room
      local names = {}
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use.from == player.id and use.card.type == Card.TypeBasic then
          table.insertIfNeed(names, use.card.trueName)
        end
      end, Player.HistoryTurn)
      room:setPlayerMark(player, huomo.name .. "-turn", names)
    end
  end,
})

huomo:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
  return target == player and player:hasSkill(huomo.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
  player.room:addTableMark(player, huomo.name .. "-turn", data.card.trueName)
  end,
})

return huomo