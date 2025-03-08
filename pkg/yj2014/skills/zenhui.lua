local zenhui = fk.CreateSkill {
  name = "zenhui"
}

Fk:loadTranslationTable{
  ['zenhui'] = '谮毁',
  ['#zenhui-choose'] = '谮毁：你可以令一名角色选择一项：交给你一张牌并成为%arg的使用者；或成为此牌的额外目标',
  ['#zenhui-give'] = '谮毁：交给 %dest 一张牌以成为此牌使用者，否则你成为此牌额外目标',
  [':zenhui'] = '出牌阶段限一次，当你使用【杀】或黑色非延时类锦囊牌指定唯一目标时，你令可以成为此牌目标的另一名其他角色选择一项：交给你一张牌并成为此牌的使用者；或成为此牌的额外目标。',
  ['$zenhui1'] = '你也休想置身事外！',
  ['$zenhui2'] = '你可别不识抬举！'
}

zenhui:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zenhui.name) and player:usedSkillTimes(zenhui.name) == 0 and
         data.tos and #data.tos == 1 and
         (data.card.trueName == "slash" or
        (data.card.color == Card.Black and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not table.contains(data.tos[1], p.id) then  --TODO: target filter
        table.insertIfNeed(targets, p.id)
      end
    end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#zenhui-choose:::"..data.card:toLogString(),
      skill_name = zenhui.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1].id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    if to:isNude() then
      table.insert(data.tos, {event:getCostData(self)})
      return
    end
    local card = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zenhui.name,
      cancelable = true,
      prompt = "#zenhui-give::"..player.id
    })
    if #card > 0 then
      room:obtainCard(player, card[1], false, fk.ReasonGive, to.id)
      data.from = to.id
      --room.logic:trigger(fk.PreCardUse, to, data)
    else
      table.insert(data.tos, {event:getCostData(self)})
    end
  end,
})

return zenhui