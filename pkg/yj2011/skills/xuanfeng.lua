```lua
local xuanfeng = fk.CreateSkill {
  name = "xuanfeng"
}

Fk:loadTranslationTable{
  ['xuanfeng'] = '旋风',
  ['#xuanfeng-choose'] = '旋风：你可以依次弃置一至两名角色的共计两张牌',
  [':xuanfeng'] = '当你失去装备区里的牌后，或弃牌阶段结束时，若你于此阶段内弃置过你的至少两张手牌，你可以依次弃置至多两名其他角色共计两张牌。',
  ['$xuanfeng1'] = '伤敌于千里之外！',
  ['$xuanfeng2'] = '索命于须臾之间！',
}

xuanfeng:addEffect(fk.AfterCardsMove, {
  can_trigger = function(skill, event, target, player, data)
  if player:hasSkill(xuanfeng.name) then
    for _, move in ipairs(data) do
    if move.from == player.id then
      for _, info in ipairs(move.moveInfo) do
      if info.fromArea == Card.PlayerEquip then
        return not table.every(player.room.alive_players, function (p)
        return p == player or p:isNude()
        end)
      end
      end
    end
    end
  end
  end,
  on_cost = function(skill, event, target, player, data)
  local room = player.room
  local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
  if #targets == 0 then return false end
  local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#xuanfeng-choose",
    skill_name = xuanfeng.name,
    cancelable = true,
    no_indicate = true
  })
  if #tos > 0 then
    event:setCostData(skill, { tos = Util.IdMapper(tos) })
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(event:getCostData(skill).tos[1])
  local card = room:askToChooseCard(player, {
    target = to,
    flag = "he",
    skill_name = xuanfeng.name
  })
  room:throwCard({card}, xuanfeng.name, to, player)
  if player.dead then return false end
  local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
  if #targets > 0 then
    local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#xuanfeng-choose",
    skill_name = xuanfeng.name,
    cancelable = true
    })
    if #tos > 0 then
    to = room:getPlayerById(tos[1])
    card = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = xuanfeng.name
    })
    room:throwCard({card}, xuanfeng.name, to, player)
    end
  end
  end,
})

xuanfeng:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(skill, event, target, player, data)
  if target == player and player.phase == Player.Discard and not table.every(player.room.alive_players, function (p)
    return p == player or p:isNude()
  end) then
    local x = 0
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
    for _, move in ipairs(e.data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard" then
      x = x + #move.moveInfo
      if x > 1 then return true end
      end
    end
    return false
    end, Player.HistoryTurn)
    return x > 1
  end
  end,
  on_cost = function(skill, event, target, player, data)
  local room = player.room
  local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
  if #targets == 0 then return false end
  local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#xuanfeng-choose",
    skill_name = xuanfeng.name,
    cancelable = true,
    no_indicate = true
  })
  if #tos > 0 then
    event:setCostData(skill, { tos = Util.IdMapper(tos) })
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(event:getCostData(skill).tos[1])
  local card = room:askToChooseCard(player, {
    target = to,
    flag = "he",
    skill_name = xuanfeng.name
  })
  room:throwCard({card}, xuanfeng.name, to, player)
  if player.dead then return false end
  local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
  if #targets > 0 then
    local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#xuanfeng-choose",
    skill_name = xuanfeng.name,
    cancelable = true
    })
    if #tos > 0 then
    to = room:getPlayerById(tos[1])
    card = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = xuanfeng.name
    })
    room:throwCard({card}, xuanfeng.name, to, player)
    end
  end
  end,
})

return xuanfeng
```