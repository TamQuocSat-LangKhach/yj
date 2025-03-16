local yuce = fk.CreateSkill {
  name = "yuce"
}

Fk:loadTranslationTable{
  ['yuce'] = '御策',
  ['#yuce-invoke'] = '御策：你可以展示一张手牌，伤害来源需弃置一张类别不同的手牌，否则你回复1点体力',
  ['#yuce-discard'] = '御策：你需弃置一张非%arg手牌，否则 %src 回复1点体力',
  [':yuce'] = '每当你受到一次伤害后，你可以展示一张手牌，令伤害来源弃置一张类别不同的手牌，否则你回复1点体力。',
  ['$yuce1'] = '御敌之策，成竹于胸。',
  ['$yuce2'] = '以缓制急，不战屈兵。',
}

yuce:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuce.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yuce.name,
      cancelable = true,
      prompt = "#yuce-invoke"
    })
    if #card > 0 then
      event:setCostData(self, card[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local c = event:getCostData(self)
    player:showCards({c})
    if player.dead then return end
    if not data.from or data.from.dead or data.from:isKongcheng() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = yuce.name
      }
    else
      local types = {"basic", "trick", "equip"}
      table.removeOne(types, Fk:getCardById(c):getTypeString())
      if #room:askToDiscard(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = yuce.name,
        cancelable = true,
        pattern = ".|.|.|hand|.|"..table.concat(types, ","),
        prompt = "#yuce-discard:"..player.id..":"..Fk:getCardById(c):getTypeString()
      }) == 0 then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = yuce.name
        }
      end
    end
  end,
})

return yuce