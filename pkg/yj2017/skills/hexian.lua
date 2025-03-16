local hexian = fk.CreateSkill {
  name = "hexian"
}

Fk:loadTranslationTable{
  ['hexian'] = '和弦',
  ['#hexian-choose'] = '和弦：可以令一名其他角色回复1点体力并弃置一张装备牌',
  ['qingxian_recover'] = '回复1点体力并弃置一张装备牌',
  [':hexian'] = '当你回复体力后，你可以令一名其他角色回复1点体力并弃置一张装备牌。',
  ['$hexian'] = '悠悠琴音，人人自醉。',
}

hexian:addEffect(fk.HpRecover, {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#hexian-choose",
      skill_name = hexian.name,
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
    doQingxian(room, room:getPlayerById(event:getCostData(self).tos[1]), player, "qingxian_recover", hexian.name)
  end,
})

return hexian