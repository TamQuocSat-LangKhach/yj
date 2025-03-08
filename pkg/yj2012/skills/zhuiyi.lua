local zhuiyi = fk.CreateSkill {
  name = "zhuiyi"
}

Fk:loadTranslationTable{
  ['zhuiyi'] = '追忆',
  ['#zhuiyi-choose'] = '追忆：你可以令一名角色摸三张牌并回复1点体力',
  [':zhuiyi'] = '你死亡时，可以令一名其他角色（杀死你的角色除外）摸三张牌并回复1点体力。',
  ['$zhuiyi1'] = '终其永怀，恋心殷殷。',
  ['$zhuiyi2'] = '妾心所系，如月之恒。',
}

zhuiyi:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuiyi.name, false, true)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room.alive_players, Util.IdMapper)
    if data.damage and data.damage.from then
      table.removeOne(targets, data.damage.from.id)
    end
    local p = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#zhuiyi-choose",
      skill_name = zhuiyi.name,
      cancelable = true,
    })
    if #p > 0 then
      event:setCostData(self, p[1].id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    to:drawCards(3, zhuiyi.name)
    if to:isWounded() and not to.dead then
      room:recover{
        who = to,
        num = 1,
        recoverBy = player,
        skillName = zhuiyi.name
      }
    end
  end,
})

return zhuiyi