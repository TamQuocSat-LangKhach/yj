local lihuo = fk.CreateSkill {
  name = "lihuo"
}

Fk:loadTranslationTable{
  ['lihuo'] = '疬火',
  ['#lihuo-trans'] = '疬火：可以将%arg改为火【杀】，若造成伤害，结算后你失去1点体力',
  ['#lihuo-choose'] = '疬火：你可以为此%arg增加一个目标',
  [':lihuo'] = '当你使用普通【杀】时，你可以将此【杀】改为火【杀】，然后此【杀】结算结束后，若此【杀】造成过伤害，你失去1点体力；你使用火【杀】可以多选择一个目标。',
  ['$lihuo1'] = '将士们，引火对敌！',
  ['$lihuo2'] = '和我同归于尽吧！'
}

lihuo:addEffect(fk.AfterCardUseDeclared, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.name == "slash"
  end,
  on_cost = function(skill, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#lihuo-trans:::"..data.card:toLogString()
    })
  end,
  on_use = function(skill, event, target, player, data)
    local card = Fk:cloneCard("fire__slash", data.card.suit, data.card.number)
    for k, v in pairs(data.card) do
      if card[k] == nil then
        card[k] = v
      end
    end
    if data.card:isVirtual() then
      card.subcards = data.card.subcards
    else
      card.id = data.card.id
    end
    card.skillNames = data.card.skillNames
    data.card = card
    data.extra_data = data.extra_data or {}
    data.extra_data.lihuo = data.extra_data.lihuo or {}
    table.insert(data.extra_data.lihuo, player.id)
  end,
})

lihuo:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.name == "fire__slash" and #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(skill, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getUseExtraTargets(data),
      min_num = 1,
      max_num = 1,
      prompt = "#lihuo-choose:::"..data.card:toLogString(),
      skill_name = skill.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(skill, tos)
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local tos = event:getCostData(skill)
    player.room:sendLog{
      type = "#AddTargetsBySkill",
      from = player.id,
      to = tos,
      arg = skill.name,
      arg2 = data.card:toLogString()
    }
    table.insert(data.tos, tos)
  end,
})

lihuo:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
    return not player.dead and data.damageDealt and data.extra_data and data.extra_data.lihuo and
      table.contains(data.extra_data.lihuo, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(skill, event, target, player, data)
    player.room:loseHp(player, 1, skill.name)
  end,
})

return lihuo