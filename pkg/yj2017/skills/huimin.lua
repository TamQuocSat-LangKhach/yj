local huimin = fk.CreateSkill {
  name = "huimin"
}

Fk:loadTranslationTable{
  ['huimin'] = '惠民',
  ['#huimin-invoke'] = '惠民：摸%arg张牌，再展示等量手牌，令手牌数小于体力值的角色获得',
  ['#huimin-show'] = '惠民：请展示%arg张手牌，从你指定的角色开始，手牌数小于体力值的角色依次获得其中一张',
  ['#huimin-choose'] = '惠民：指定第一个选牌的角色',
  [':huimin'] = '结束阶段开始时，你可以摸X张牌（X为手牌数小于体力值的角色数），然后展示等量的手牌，从你指定的一名角色开始，这些角色依次获得其中一张。',
  ['$huimin1'] = '悬壶济世，施医救民。',
  ['$huimin2'] = '心系百姓，惠布山阳。',
}

huimin:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huimin.name) and player.phase == Player.Finish and
         table.find(player.room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    return room:askToSkillInvoke(player, {
      skill_name = huimin.name,
      prompt = "#huimin-invoke:::" .. n
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    player:drawCards(#players, huimin.name)
    if player:isKongcheng() then return false end
    local cards = room:askToDiscard(player, {
      min_num = #players,
      max_num = #players,
      include_equip = false,
      skill_name = huimin.name,
      cancelable = false,
      pattern = ".",
      prompt = "#huimin-show:::" .. #players
    })
    player:showCards(cards)
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(players, Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#huimin-choose",
      skill_name = huimin.name
    })
    local temp = room:getPlayerById(tos[1])
    table.forEach(room.players, function(p) room:fillAG(p, cards) end)
    while #cards > 0 and #players > 0 do
      if table.contains(players, temp) then
        table.removeOne(players, temp)
        local chosen = room:askToAG(temp, {
          id_list = cards,
          cancelable = false,
          skill_name = huimin.name
        })
        room:takeAG(temp, chosen, room.players)
        room:obtainCard(temp, chosen, true, fk.ReasonPrey)
        table.removeOne(cards, chosen)
        cards = table.filter(cards, function(id) return room:getCardOwner(id) == player and room:getCardArea(id) == Card.PlayerHand end)
      end
      temp = temp.next
    end
    table.forEach(room.players, function(p) room:closeAG(p) end)
  end,
})

return huimin