```lua
local anguo = fk.CreateSkill {
  name = "anguo"
}

Fk:loadTranslationTable{
  ['anguo'] = '安国',
  ['#anguo-active'] = '发动 安国，选择一名其他角色',
  [':anguo'] = '出牌阶段限一次，你可以选择一名其他角色，令其依次执行：若其手牌数为全场最少，其摸一张牌；体力值为全场最低，回复1点体力；装备区内牌数为全场最少，随机使用牌堆中一张装备牌。然后若该角色有未执行的效果且你满足条件，你执行之。',
  ['$anguo1'] = '止干戈，休战事。',
  ['$anguo2'] = '安邦定国，臣子分内之事。',
}

anguo:addEffect('active', {
  anim_type = "support",
  prompt = "#anguo-active",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
  return player:usedSkillTimes(anguo.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local types = {"equip", "recover", "draw"}
  for i = 3, 1, -1 do
    if doAnguo(target, types[i], player) then
    table.removeOne(types, types[i])
    if target.dead then
      break
    end
    end
  end
  for i = #types, 1, -1 do
    if player.dead then break end
    doAnguo(player, types[i], player)
  end
  end,
})

return anguo
```

该技能代码并未使用任何`askForXXX`方法，因此无需进行重构。