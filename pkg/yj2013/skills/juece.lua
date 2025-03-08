local juece = fk.CreateSkill {
  name = "juece"
}

Fk:loadTranslationTable{
  ['juece'] = '绝策',
  ['#juece-choose'] = '绝策：你可以对一名没有手牌的其他角色造成1点伤害',
  [':juece'] = '结束阶段，你可以对一名没有手牌的其他角色造成1点伤害。',
  ['$juece1'] = '哼！你走投无路了。',
  ['$juece2'] = '无用之人，死！',
}

juece:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(juece.name) and player.phase == Player.Finish and
      #table.filter(player.room:getOtherPlayers(player), function(p) return p:isKongcheng() end) > 0
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local kongcheng_players = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p:isKongcheng()
    end), Util.IdMapper)

    local to = room:askToChoosePlayers(player, {
      targets = kongcheng_players,
      min_num = 1,
      max_num = 1,
      prompt = "#juece-choose",
      skill_name = juece.name,
      cancelable = true
    })

    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local cost_data = event:getCostData(self)
    player.room:damage{
      from = player,
      to = player.room:getPlayerById(cost_data),
      damage = 1,
      skillName = juece.name,
    }
  end,
})

return juece