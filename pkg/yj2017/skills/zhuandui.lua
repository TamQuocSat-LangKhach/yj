local zhuandui = fk.CreateSkill {
  name = "zhuandui"
}

Fk:loadTranslationTable{
  ['zhuandui'] = '专对',
  ['zhuandui1-invoke'] = '专对：你可以与 %dest 点，若赢，其不能响应此%arg',
  ['zhuandui2-invoke'] = '专对：你可以与 %dest 拼点，若赢，此%arg对你无效',
  [':zhuandui'] = '当你使用【杀】指定目标后，你可以与目标拼点：若你赢，其不能响应此【杀】。当你成为【杀】的目标后，你可以与使用者拼点：若你赢，此【杀】对你无效。',
  ['$zhuandui1'] = '黄口小儿，也敢来班门弄斧？',
  ['$zhuandui2'] = '你已无话可说了吧！',
}

zhuandui:addEffect(fk.TargetSpecified, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(zhuandui.name) and data.card.trueName == "slash" and not player:isKongcheng() then
    return data.to ~= player.id and player:canPindian(player.room:getPlayerById(data.to))
    end
  end,
  on_cost = function(skill, event, target, player, data)
    local prompt = "zhuandui1-invoke::"..data.to..":"..data.card:toLogString()
    return player.room:askToSkillInvoke(player, {
    skill_name = zhuandui.name,
    prompt = prompt
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(zhuandui.name)
    room:notifySkillInvoked(player, zhuandui.name, "offensive")
    room:doIndicate(player.id, {data.to})
    local pindian = player:pindian({room:getPlayerById(data.to)}, zhuandui.name)
    if pindian.results[data.to].winner == player then
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
    end
  end,
})

zhuandui:addEffect(fk.TargetConfirmed, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(zhuandui.name) and data.card.trueName == "slash" and not player:isKongcheng() then
    return data.from ~= player.id and player:canPindian(player.room:getPlayerById(data.from))
    end
  end,
  on_cost = function(skill, event, target, player, data)
    local prompt = "zhuandui2-invoke::"..data.from..":"..data.card:toLogString()
    return player.room:askToSkillInvoke(player, {
    skill_name = zhuandui.name,
    prompt = prompt
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(zhuandui.name)
    room:notifySkillInvoked(player, zhuandui.name, "defensive")
    room:doIndicate(player.id, {data.from})
    local pindian = player:pindian({room:getPlayerById(data.from)}, zhuandui.name)
    if pindian.results[data.from].winner == player then
    table.insertIfNeed(data.nullifiedTargets, player.id)
    end
  end,
})

return zhuandui