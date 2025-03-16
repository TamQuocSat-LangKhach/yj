local qinqing = fk.CreateSkill {
  name = "qinqing"
}

Fk:loadTranslationTable{
  ['qinqing'] = '寝情',
  ['#qinqing-choose'] = '寝情：选择任意名攻击范围内含有主公的角色',
  [':qinqing'] = '结束阶段，你可以选择任意名攻击范围内含有主公的角色，然后你弃置这些角色的一张牌（无牌则不弃），并令这些角色依次摸一张牌。若如此做，你摸X张牌（X为这些角色中手牌数大于主公的角色数）。',
  ['$qinqing1'] = '陛下勿忧，大将军危言耸听。',
  ['$qinqing2'] = '陛下，莫让他人知晓此事！',
}

qinqing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player.phase == Player.Finish and player:hasSkill(qinqing.name) then
      local lord = player.room:getLord()  --暂不考虑主公身份被变掉且没有主公的情况，以及多个主公的情况（3v3）
      if not lord then
        lord = player.room:getPlayerBySeat(1)
      end
      return lord and not lord.dead and table.find(player.room.alive_players, function(p) return p:inMyAttackRange(lord) end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local lord = room:getLord()
    if not lord then
      lord = room:getPlayerBySeat(1)
    end
    local targets = table.filter(room.alive_players, function(p) return p:inMyAttackRange(lord) end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 999,
      prompt = "#qinqing-choose",
      skill_name = qinqing.name
    })
    if #tos > 0 then
      event:setCostData(qinqing, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.map(event:getCostData(qinqing), Util.Id2PlayerMapper)
    for _, p in ipairs(tos) do
      if not p:isNude() then
        local cid = room:askToChooseCard(player, {
          target = p,
          flag = "he",
          skill_name = qinqing.name
        })
        room:throwCard({cid}, qinqing.name, p, player)
      end
      if not p.dead then
        p:drawCards(1, qinqing.name)
      end
    end
    local lord = room:getLord()
    if not lord then
      lord = room:getPlayerBySeat(1)
    end
    if not lord or lord.dead then return end
    local n = #table.filter(tos, function(p) return p:getHandcardNum() > lord:getHandcardNum() end)
    if not player.dead and n > 0 then
      player:drawCards(n, qinqing.name)
    end
  end,
})

return qinqing