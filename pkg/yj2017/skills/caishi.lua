local caishi = fk.CreateSkill {
  name = "caishi"
}

Fk:loadTranslationTable{
  ['caishi'] = '才识',
  ['#caishi1'] = '手牌上限+1，本回合不能对其他角色用牌',
  ['#caishi2'] = '回复1点体力，本回合不能对自己用牌',
  ['#caishi_prohibit'] = '才识',
  [':caishi'] = '摸牌阶段开始时，你可以选择一项：1.手牌上限+1，然后本回合你的牌不能对其他角色使用；2.回复1点体力，然后本回合你的牌不能对自己使用。',
  ['$caishi1'] = '清识难尚，至德可师。',
  ['$caishi2'] = '知书达礼，博古通今。',
}

caishi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(caishi.name) and player == target and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local choices = {"#caishi1","cancel"}
    if player:isWounded() then table.insert(choices,2, "#caishi2") end
    local choice = target.room:askToChoice(target, {
      choices = choices,
      skill_name = caishi.name
    })
    if choice ~= "cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choice = event:getCostData(self)
    if choice == "#caishi1" then
      room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)
      room:addPlayerMark(player, "caishi_other-turn")
    else
      room:recover({ who = player, num = 1, skillName = caishi.name })
      room:addPlayerMark(player, "caishi_self-turn")
    end
  end,
})

local caishi_prohibit = fk.CreateSkill {
  name = "#caishi_prohibit"
}

caishi_prohibit:addEffect("prohibit", {
  is_prohibited = function(self, from, to)
    return (from:getMark("caishi_other-turn") > 0 and from ~= to) or (from:getMark("caishi_self-turn") > 0 and from == to)
  end,
})

return caishi, caishi_prohibit