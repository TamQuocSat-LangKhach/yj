```lua
local juexiang = fk.CreateSkill{
  name = "juexiang"
}

Fk:loadTranslationTable{
  ['juexiang'] = '绝响',
  ['#juexiang-choose'] = '绝响：你可以令一名其他角色随机获得“激弦”/“烈弦”/“柔弦”/“和弦”中一个',
  ['jixiann'] = '激弦',
  ['liexian'] = '烈弦',
  ['rouxian'] = '柔弦',
  ['hexian'] = '和弦',
  ['@@juexiang'] = '绝响',
  ['#juexiang_prohibit'] = '绝响',
  [':juexiang'] = '当你死亡时，你可以令一名其他角色随机获得〖激弦〗、〖烈弦〗、〖柔弦〗、〖和弦〗中的一个技能，然后直到其下回合开始前，该角色不能成为除其以外的角色使用♣牌的目标。',
  ['$juexiang1'] = '此曲不能绝矣！',
  ['$juexiang2'] = '一曲琴音，为我送别。',
}

juexiang:addEffect(fk.Death, {
  global = false,
  can_trigger = function(self, event, target, player, data)
  return player:hasSkill(juexiang,false,true) and target == player
  end,
  on_cost = function(self, event, target, player, data)
  local room = player.room
  local tos = room:askToChoosePlayers(player, {
    targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
    min_num = 1,
    max_num = 1,
    prompt = "#juexiang-choose",
    skill_name = juexiang.name,
    cancelable = true,
    no_indicate = true
  })
  if #tos > 0 then
    event:setCostData(self, {tos = tos})
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(event:getCostData(self).tos[1])
  local skills = table.filter({"jixiann","liexian","rouxian","hexian"}, function (s) return not to:hasSkill(s,true) end)
  if #skills > 0 then
    room:handleAddLoseSkills(to, table.random(skills), nil)
  end
  room:setPlayerMark(to, "@@juexiang", 1)
  end,
})

juexiang:addEffect(fk.TurnStart, {
  global = false,
  can_refresh = function (self, event, target, player, data)
  return target == player and player:getMark("@@juexiang") > 0
  end,
  on_refresh = function (self, event, target, player, data)
  player.room:setPlayerMark(player, "@@juexiang", 0)
  end,
})

juexiang:addEffect('prohibit', {
  is_prohibited = function(self, from, to, card)
  if card and card.suit == Card.Club then
    return to:getMark("@@juexiang") > 0 and from ~= to
  end
  end,
})

return juexiang
```