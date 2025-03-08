local zhenlie = fk.CreateSkill {
  name = "zhenlie"
}

Fk:loadTranslationTable{
  ['zhenlie'] = '贞烈',
  [':zhenlie'] = '当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可以失去1点体力使此牌对你无效，然后你弃置其一张牌。',
  ['$zhenlie1'] = '虽是妇人，亦当奋身一搏！',
  ['$zhenlie2'] = '为雪前耻，不惜吾身！',
}

zhenlie:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhenlie.name) and data.from ~= player.id and
      (data.card:isCommonTrick() or data.card.trueName == "slash")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, zhenlie.name)
    if player.dead then return end
    table.insertIfNeed(data.nullifiedTargets, player.id)
    local to = room:getPlayerById(data.from)
    if to.dead or to:isNude() then return end
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = zhenlie.name
    })
    room:throwCard({id}, zhenlie.name, to, player)
  end,
})

return zhenlie