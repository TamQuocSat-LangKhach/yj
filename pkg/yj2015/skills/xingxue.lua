local xingxue = fk.CreateSkill {
  name = "xingxue"
}

Fk:loadTranslationTable{
  ['xingxue'] = '兴学',
  ['#xingxue-choose'] = '兴学：你可以令至多%arg名角色依次摸一张牌并将一张牌置于牌堆顶',
  ['#xingxue-card'] = '兴学：选择一张牌置于牌堆顶',
  [':xingxue'] = '结束阶段，你可以令X名角色依次摸一张牌并将一张牌置于牌堆顶（X为你的体力值）。',
  ['$xingxue1'] = '汝等都是国之栋梁。',
  ['$xingxue2'] = '文修武备，才是兴国之道。',
}

xingxue:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingxue) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local n = player:hasSkill(yanzhu, true) and player.hp or player.maxHp
    local tos = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room.alive_players, Util.IdMapper),
      min_num = 1,
      max_num = n,
      prompt = "#xingxue-choose:::"..n,
      skill_name = xingxue.name,
    })
    if #tos > 0 then
      event:setCostData(self, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(event:getCostData(self))
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local to = room:getPlayerById(id)
      if not to.dead then
        to:drawCards(1, xingxue.name)
        if not (to.dead or to:isNude()) then
          local card = room:askToCards(to, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            pattern = ".",
            prompt = "#xingxue-card",
            skill_name = xingxue.name,
          })
          room:moveCards({
            ids = card,
            from = id,
            toArea = Card.DrawPile,
            moveReason = fk.ReasonJustMove,
            skillName = xingxue.name,
          })
        end
      end
    end
  end,
})

return xingxue