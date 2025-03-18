local xiaolian = fk.CreateSkill {
  name = "tw__xiaolian",
}

Fk:loadTranslationTable{
  ["tw__xiaolian"] = "孝廉",
  [":tw__xiaolian"] = "當一名其他角色成為【殺】的唯一目標時，你可以將此【殺】轉移給你。此【殺】结算后，若你受到此【殺】的傷害，"..
  "你可以將一張牌當【絕影】置入其裝備區。",

  ["#tw__xiaolian-invoke"] = "孝廉：你可以将对 %dest 使用的%arg转移给你",
  ["#tw__xiaolian-card"] = "孝廉：你可以將一張牌當【絕影】置入 %dest 的裝備區",
}

xiaolian:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiaolian.name) and target ~= player and data.card.trueName == "slash" and
      #data.use.tos == 1 and not data.from:isProhibited(player, data.card)
    end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xiaolian.name,
      prompt = "#tw__xiaolian-invoke::"..target.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(data.to)
    data:addTarget(player)
    data.extra_data = data.extra_data or {}
    data.extra_data.tw__xiaolian = {
      from = player,
      to = target,
    }
  end,
})

xiaolian:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName == "slash" and data.extra_data and data.extra_data.tw__xiaolian and
      data.extra_data.tw__xiaolian.from == player and data.damageDealt and data.damageDealt[player] and
      not player:isNude() and not player.dead then
      local to = data.extra_data.tw__xiaolian.to
      return not to.dead and to:hasEmptyEquipSlot(Card.SubtypeDefensiveRide)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      skill_name = xiaolian.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      prompt = "#tw__xiaolian-card::"..data.extra_data.tw__xiaolian.to.id,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {data.extra_data.tw__xiaolian.to}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.extra_data.tw__xiaolian.to
    local card = Fk:getCardById(event:getCostData(self).cards[1], true)
    room:setCardMark(card, xiaolian.name, 1)
    --[[local card = Fk:cloneCard("jueying")
    card:addSubcards(self.cost_data)
    table.insertIfNeed(to.virtual_equips, card)]]
    room:moveCards({
      ids = event:getCostData(self).cards,
      from = player,
      to = to,
      toArea = Card.PlayerEquip,
      moveReason = fk.ReasonPut,
      proposer = player,
      skillName = xiaolian.name,
    })
  end,

})

xiaolian:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea ~= Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId, true):getMark(xiaolian.name) > 0 then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea ~= Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            player.room:setCardMark(Fk:getCardById(info.cardId, true), xiaolian.name, 0)
          end
        end
      end
    end
  end,
})

xiaolian:addEffect("filter", {
  card_filter = function(self, to_select, player, isJudgeEvent)
    return to_select:getMark("tw__xiaolian") > 0 and
      table.contains(player:getCardIds("e"), to_select.id)
    end,
  view_as = function(self, player, to_select)
    local card = Fk:cloneCard("jueying", to_select.suit, to_select.number)
    card.skillName = xiaolian.name
    return card
  end,
})

return xiaolian
