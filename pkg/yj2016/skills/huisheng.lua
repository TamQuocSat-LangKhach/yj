local huisheng = fk.CreateSkill {
  name = "huisheng"
}

Fk:loadTranslationTable{
  ['huisheng'] = '贿生',
  ['#huisheng-invoke'] = '贿生：你可选择至少一张牌令 %src 观看之',
  ['#huisheng-discard'] = '贿生：弃置%arg张牌，否则你获得%arg2并防止对%dest造成的伤害',
  [':huisheng'] = '当你受到其他角色造成的伤害时，你可以选择至少一张牌，令其观看之并选择一项：1.获得其中一张，防止此伤害，然后你不能再对其发动此技能；2.弃置等量的牌。',
  ['$huisheng1'] = '大人，这些钱够吗？',
  ['$huisheng2'] = '劳烦大人美言几句~',
}

huisheng:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huisheng.name) and not player:isNude() and data.from and data.from ~= player
    and not data.from.dead and not table.contains(player:getTableMark(huisheng.name), data.from.id)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = huisheng.name,
      cancelable = true,
      pattern = ".",
      prompt = "#huisheng-invoke:" .. data.from.id
    })
    if #cards > 0 then
    event:setCostData(self, cards)
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self)
    local n = #cards
    local get = room:askToChooseCard(data.from, {
      target = player,
      flag = { card_data = {{player.general, cards}} },
      skill_name = huisheng.name
    })
    if #room:askToDiscard(data.from, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = huisheng.name,
      cancelable = true,
      pattern = ".",
      prompt = "#huisheng-discard::" .. player.id .. ":" .. n .. ":" .. Fk:getCardById(get, true):toLogString()
    }) ~= n then
    room:addTableMark(player, huisheng.name, data.from.id)
    room:obtainCard(data.from, get, false, fk.ReasonPrey, data.from.id, huisheng.name)
    return true
    end
  end,
})

return huisheng