```lua
local funan = fk.CreateSkill {
  name = "funan"
}

Fk:loadTranslationTable{
  ['funan'] = '复难',
  ['#funan-invoke'] = '复难：你可以令 %dest 获得你使用的%arg，你获得其使用的%arg2',
  [':funan'] = '其他角色使用或打出牌响应你使用的牌时，你可以令其获得你使用的牌（其本回合不能使用或打出这张牌），然后你获得其使用或打出的牌。',
  ['$funan1'] = '礼尚往来，乃君子风范。',
  ['$funan2'] = '以子之矛，攻子之盾。',
}

funan:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(skill, event, target, player, data)
    if player:hasSkill(skill.name) and target ~= player and
       data.responseToEvent and data.responseToEvent.from == player.id then
      return data.responseToEvent.card and player.room:getCardArea(data.responseToEvent.card) == Card.Processing
    end
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#funan-invoke::" .. target.id .. ":" .. data.responseToEvent.card:toLogString() .. ":" .. data.card:toLogString()
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local card = data.responseToEvent.card
    room:obtainCard(target, card, false, fk.ReasonPrey)
    local cards = target:getTableMark("funan-turn")
    table.insertTable(cards, card:isVirtual() and card.subcards or {card.id})
    room:setPlayerMark(target, "funan-turn", cards)
    if room:getCardArea(data.card) == Card.Processing then
      room:obtainCard(player, data.card, false, fk.ReasonPrey)
    end
  end,
})

funan:addEffect(fk.CardRespondFinished, {
  anim_type = "control",
  can_trigger = function(skill, event, target, player, data)
    if player:hasSkill(skill.name) and target ~= player and
       data.responseToEvent and data.responseToEvent.from == player.id then
      return data.responseToEvent.card and player.room:getCardArea(data.responseToEvent.card) == Card.Processing
    end
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#funan-invoke::" .. target.id .. ":" .. data.responseToEvent.card:toLogString() .. ":" .. data.card:toLogString()
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local card = data.responseToEvent.card
    room:obtainCard(target, card, false, fk.ReasonPrey)
    local cards = target:getTableMark("funan-turn")
    table.insertTable(cards, card:isVirtual() and card.subcards or {card.id})
    room:setPlayerMark(target, "funan-turn", cards)
    if room:getCardArea(data.card) == Card.Processing then
      room:obtainCard(player, data.card, false, fk.ReasonPrey)
    end
  end,
})

funan:addEffect('prohibit', {
  name = "#funan_prohibit",
  prohibit_use = function(skill, player, card)
  if type(player:getMark("funan-turn")) == "table" then return table.contains(player:getMark("funan-turn"), card.id) end
  end,
  prohibit_response = function(skill, player, card)
  if type(player:getMark("funan-turn")) == "table" then return table.contains(player:getMark("funan-turn"), card.id) end
  end,
})

return funan
```