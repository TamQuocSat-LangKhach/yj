local zhiyan = fk.CreateSkill {
  name = "zhiyan"
}

Fk:loadTranslationTable{
  ['zhiyan'] = '直言',
  ['#zhiyan-choose'] = '直言：你可以令一名角色摸一张牌并展示之，若为装备牌其使用之并回复1点体力',
  [':zhiyan'] = '结束阶段开始时，你可以令一名角色摸一张牌并展示之，若此牌为装备牌，其使用此牌并回复1点体力。',
  ['$zhiyan1'] = '志节分明，折而不屈！',
  ['$zhiyan2'] = '直言劝谏，不惧祸否！',
}

zhiyan:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiyan.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getAlivePlayers(), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#zhiyan-choose",
      skill_name = zhiyan.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local id = to:drawCards(1, zhiyan.name)[1]
    if room:getCardOwner(id) ~= to or room:getCardArea(id) ~= Card.PlayerHand then return end
    local card = Fk:getCardById(id)
    to:showCards(card)
    if to.dead then return end
    room:delay(1000)  --防止天机图卡手牌
    if card.type == Card.TypeEquip and not to:prohibitUse(card) and not to:isProhibited(to, card) then
      room:useCard({
        from = to.id,
        tos = {{to.id}},
        card = card,
      })
      if to:isWounded() and not to.dead then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = zhiyan.name
        })
      end
    end
  end,
})

return zhiyan