local xuanhuo = fk.CreateSkill {
  name = "xuanhuo"
}

Fk:loadTranslationTable{
  ['xuanhuo'] = '眩惑',
  ['#xuanhuo-target'] = '眩惑：你可以放弃摸牌，令另一名角色摸两张牌并使用【杀】',
  ['#xuanhuo-choose'] = '眩惑：选择令 %dest 使用【杀】的目标',
  ['#xuanhuo-slash'] = '眩惑：你需对 %dest 使用【杀】，否则 %src 获得你两张牌',
  [':xuanhuo'] = '摸牌阶段，你可以放弃摸牌，改为令另一名角色摸两张牌，然后令其对其攻击范围内你指定的一名角色使用一张【杀】，若该角色未如此做，你获得其两张牌。',
  ['$xuanhuo1'] = '收人钱财，替人消灾。',
  ['$xuanhuo2'] = '哼，叫你十倍奉还！',
}

xuanhuo:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(xuanhuo.name) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#xuanhuo-target",
      skill_name = xuanhuo.name
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    to:drawCards(2, xuanhuo.name)
    if player.dead or to.dead then return end
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return target:inMyAttackRange(p) 
    end), Util.IdMapper)
    if #targets == 0 then
      if to:isNude() then return end
      local cards = room:askToChooseCards(player, {
        min_num = math.min(2, #to:getCardIds("he")),
        max_num = 2,
        target = to,
        flag = "he",
        skill_name = xuanhuo.name
      })
      room:obtainCard(player, cards, false, fk.ReasonPrey)
    else
      local tos = player.room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#xuanhuo-choose::"..to.id,
        skill_name = xuanhuo.name,
        cancelable = false
      })
      local victim = #tos > 0 and tos[1] or table.random(targets)
      
      room:doIndicate(to.id, {victim})
      local use = room:askToUseCard(to, {
        pattern = "slash",
        prompt = "#xuanhuo-slash:"..player.id..":"..victim,
        cancelable = true,
        extra_data = {must_targets = {victim}}
      })
      
      if use then
        room:useCard(use)
      else
        if to:isNude() then return end
        local cards = room:askToChooseCards(player, {
          min_num = math.min(2, #to:getCardIds("he")),
          max_num = 2,
          target = to,
          flag = "he",
          skill_name = xuanhuo.name
        })
        room:obtainCard(player, cards, false, fk.ReasonPrey)
      end
    end
    return true
  end,
})

return xuanhuo