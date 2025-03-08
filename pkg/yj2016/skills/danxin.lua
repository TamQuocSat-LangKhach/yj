local danxin = fk.CreateSkill {
  name = "danxin"
}

Fk:loadTranslationTable{
  ['danxin'] = '殚心',
  ['updateJiaozhao'] = '修改矫诏',
  ['jiaozhaoVS'] = '矫诏',
  [':danxin'] = '当你受到伤害后，你可以摸一张牌，或修改〖矫诏〗。',
  ['$danxin1'] = '司马一族，其心可诛。',
  ['$danxin2'] = '妾身定为我大魏鞠躬尽瘁，死而后已。',
}

danxin:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "draw1"}
    if player:getMark("jiaozhao_status") > 0 and player:getMark("jiaozhao_status") < 3 then
      table.insert(choices, "updateJiaozhao")
    end
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = danxin.name
    })
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cost_data = event:getCostData(self)
    if cost_data == "draw1" then
      player:drawCards(1, danxin.name)
    else
      local room = player.room
      local n = player:getMark("jiaozhao_status")
      room:addPlayerMark(player, "jiaozhao_status", 1)
      if not player:hasSkill("jiaozhaoVS", true) then
        room:handleAddLoseSkills(player, jiaozhaoSkills[n + 1].."|-"..jiaozhaoSkills[n], nil, false, true)
      end
    end
  end,
})

return danxin