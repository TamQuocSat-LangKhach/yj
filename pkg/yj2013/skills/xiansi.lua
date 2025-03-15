local xiansi = fk.CreateSkill {
  name = "xiansi"
}

Fk:loadTranslationTable{
  ['xiansi'] = '陷嗣',
  ['xiansi&'] = '陷嗣',
  ['liufeng_ni'] = '逆',
  ['#xiansi-choose'] = '陷嗣：你可以将至多两名其他角色各一张牌置为“逆”',
  [':xiansi'] = '回合开始阶段开始时，你可以将至多两名其他角色的各一张牌置于你的武将牌上，称为“逆”。每当其他角色需要对你使用一张【杀】时，该角色可以弃置你武将牌上的两张“逆”，视为对你使用一张【杀】。',
  ['$xiansi1'] = '袭人于不意，溃敌于无形！',
  ['$xiansi2'] = '破敌军阵，父亲定会刮目相看！',
  ['$xiansi3'] = '此乃孟达之计，非我所愿！',
  ['$xiansi4'] = '我有何罪？！',
}

xiansi:addEffect(fk.EventPhaseStart, {
  global = false,
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(xiansi.name) and player.phase == Player.Start then
      return not table.every(player.room:getOtherPlayers(player), function (p) return p:isNude() end)
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude()
    end), Util.IdMapper)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 2,
      prompt = "#xiansi-choose",
      skill_name = xiansi.name
    })
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      event:setCostData(skill, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    for _, pid in ipairs(event:getCostData(skill)) do
      if player.dead then break end
      local p = room:getPlayerById(pid)
      if not p:isNude() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "he",
          skill_name = xiansi.name
        })
        player:addToPile("liufeng_ni", id, true, xiansi.name)
      end
    end
  end,
})

return xiansi