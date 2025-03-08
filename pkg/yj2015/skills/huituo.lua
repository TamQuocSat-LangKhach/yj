local huituo = fk.CreateSkill {
  name = "huituo"
}

Fk:loadTranslationTable{
  ['huituo'] = '恢拓',
  ['#huituo-choose'] = '恢拓：你可以令一名角色判定，若为红色，其回复1点体力；黑色，其摸X张牌',
  [':huituo'] = '当你受到伤害后，你可以令一名角色进行判定，若结果为：红色，其回复1点体力；黑色，其摸X张牌（X为伤害值）。',
  ['$huituo1'] = '大展宏图，就在今日！',
  ['$huituo2'] = '富我大魏，扬我国威！',
}

huituo:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
    targets = table.map(room:getAlivePlayers(), Util.IdMapper),
    min_num = 1,
    max_num = 1,
    prompt = "#huituo-choose",
    skill_name = huituo.name,
    cancelable = true
    })
    if #to > 0 then
    event:setCostData(self, to[1])
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local judge = {
    who = to,
    reason = huituo.name,
    pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Red then
    if to:isWounded() then
      room:recover({
      who = to,
      num = 1,
      recoverBy = player,
      skillName = huituo.name
      })
    end
    elseif judge.card.color == Card.Black then
    to:drawCards(data.damage, huituo.name)
    end
  end,
})

return huituo