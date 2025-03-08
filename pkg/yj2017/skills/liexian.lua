local liexian = fk.CreateSkill {
  name = "liexian"
}

Fk:loadTranslationTable{
  ['liexian'] = '烈弦',
  ['#liexian-choose'] = '烈弦：可以令一名其他角色失去1点体力并随机使用装备牌',
  ['qingxian_losehp'] = '失去1点体力并随机使用牌堆一张装备牌',
  [':liexian'] = '当你回复体力后，你可以令一名其他角色失去1点体力并随机使用牌堆一张装备牌。',
  ['$liexian'] = '一壶烈云烧，一曲人皆醉。',
}

liexian:addEffect(fk.HpRecover, {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#liexian-choose",
      skill_name = liexian.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    doQingxian(room, room:getPlayerById(event:getCostData(self).tos[1]), player, "qingxian_losehp", liexian.name)
  end,
})

return liexian