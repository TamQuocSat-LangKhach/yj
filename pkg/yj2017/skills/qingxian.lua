```lua
local qingxian = fk.CreateSkill {
  name = "qingxian"
}

Fk:loadTranslationTable{
  ['qingxian'] = '清弦',
  ['#qingxian-invoke'] = '清弦：你可以令 %src 失去体力并使用装备牌/回复体力并弃装备牌',
  ['#qingxian-choose'] = '清弦：选择一名其他角色，令其失去体力并使用装备牌/回复体力并弃装备牌',
  ['qingxian_losehp'] = '失去1点体力并随机使用牌堆一张装备牌',
  ['qingxian_recover'] = '回复1点体力并弃置一张装备牌',
  [':qingxian'] = '当你受到伤害/回复体力后，你可以选一项令伤害来源/一名其他角色执行：1.失去1点体力并随机使用牌堆一张装备牌；2.回复1点体力并弃置一张装备牌。若其使用或弃置的牌的花色为♣，你回复1点体力。',
  ['$qingxian1'] = '抚琴拨弦，悠然自得。',
  ['$qingxian2'] = '寄情于琴，合于天地。',
}

qingxian:addEffect({ fk.Damaged, fk.HpRecover }, {
  global = false,
  can_trigger = function(self, event, target, player, data)
  if player:hasSkill(qingxian.name) and target == player then
    if event == fk.Damaged then
    return data.from and not data.from.dead
    else
    return true
    end
  end
  end,
  on_cost = function (self, event, target, player, data)
  local room = player.room
  if event == fk.Damaged then
    if room:askToSkillInvoke(player, { skill_name = qingxian.name, prompt = "#qingxian-invoke:"..data.from.id }) then
    event:setCostData(self, {tos = {data.from.id}})
    return true
    end
  else
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#qingxian-choose",
      skill_name = qingxian.name
    })
    if #tos > 0 then
    event:setCostData(self, {tos = tos})
    return true
    end
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  local cost_data = event:getCostData(self)
  local to = room:getPlayerById(cost_data.tos[1])
  local choice = room:askToChoice(player, {
    choices = {"qingxian_losehp", "qingxian_recover"},
    skill_name = qingxian.name
  })
  local card = doQingxian(room, to, player, choice, qingxian.name)
  if card and card.suit == Card.Club and player:isWounded() and not player.dead then
    room:recover({ who = player, num = 1, recoverBy = player, skillName = qingxian.name })
  end
  end,
})

return qingxian
```