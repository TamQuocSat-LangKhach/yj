local funanEx = fk.CreateSkill {
  name = "funanEx"
}

Fk:loadTranslationTable{
  ['funanEx'] = '复难',
  ['#funanEx-invoke'] = '复难：你可以获得 %dest 使用的%arg',
  ['funan'] = '复难',
  [':funanEx'] = '其他角色使用或打出牌响应你使用的牌时，你可以获得其使用或打出的牌。',
}

funanEx:addEffect(fk.CardUseFinished, {
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(skill, event, target, player, data)
    if player:hasSkill(skill.name) and target ~= player and
      data.responseToEvent and data.responseToEvent.from == player.id then
      if (event == fk.CardUseFinished and data.toCard) or event == fk.CardRespondFinished then
        return player.room:getCardArea(data.card) == Card.Processing
      end
    end
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#funanEx-invoke::"..target.id..":"..data.card:toLogString()
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("funan")
    room:notifySkillInvoked(player, "funan", "drawcard")
    room:obtainCard(player, data.card, false, fk.ReasonPrey)
  end,
})

return funanEx