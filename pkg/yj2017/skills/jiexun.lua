local jiexun = fk.CreateSkill {
  name = "jiexun"
}

Fk:loadTranslationTable{
  ['jiexun'] = '诫训',
  ['@jiexun'] = '诫训',
  ['#jiexun-choose'] = '诫训：你可以令一名其他角色摸等同于场上<font color="red">♦</font>牌数的牌，然后弃置X张牌（X为本技能发动过的次数）',
  ['funan'] = '复难',
  [':jiexun'] = '结束阶段，你可令一名其他角色摸等同于场上<font color="red">♦</font>牌数的牌，然后弃置X张牌（X为本技能发动过的次数），若其因此法弃置了所有牌，则你失去〖诫训〗，然后修改〖复难〗（删去“令其获得你使用的牌”）。',
  ['$jiexun1'] = '帝王应以社稷为重，以大观为主。',
  ['$jiexun2'] = '吾冒昧进谏，只求陛下思虑。',
}

jiexun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiexun) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n1 = 0
    for _, p in ipairs(room.alive_players) do
      n1 = n1 + #table.filter(p:getCardIds("ej"), function(id) return Fk:getCardById(id).suit == Card.Diamond end)
    end
    local n2 = player:getMark("@jiexun") + 1
    local to = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#jiexun-choose:::"..n1..":"..n2,
      skill_name = jiexun.name
    })
    if #to > 0 then
      event:setCostData(self, {to[1], n1, n2})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jiexun")
    local to = room:getPlayerById(event:getCostData(self)[1])
    local n1, n2 = event:getCostData(self)[2], event:getCostData(self)[3]
    if n1 > 0 then
      to:drawCards(n1, jiexun.name)
    end
    if to:isNude() or to.dead then return end
    local throw = room:askToDiscard(to, {
      min_num = n2,
      max_num = n2,
      include_equip = true,
      skill_name = jiexun.name,
      cancelable = false,
      pattern = ".",
      skip = true
    })
    local change = (#throw == #to:getCardIds("he"))
    room:throwCard(throw, jiexun.name, to, to)
    if change and not player.dead then
      room:handleAddLoseSkills(player, "-jiexun", nil, true, false)
      if player:hasSkill("funan", true) then
        room:handleAddLoseSkills(player, "-funan|funanEx", nil, false, true)
      end
    end
  end,
  can_refresh = function(self, event, target, player, data)
    return player == target and data == self
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jiexun", 0)
  end,
})

return jiexun