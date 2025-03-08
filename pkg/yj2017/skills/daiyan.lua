local daiyan = fk.CreateSkill {
  name = "daiyan"
}

Fk:loadTranslationTable{
  ['daiyan'] = '怠宴',
  ['@@daiyan-tmp'] = '上次怠宴目标',
  ['#daiyan-choose'] = '怠宴：你可以令一名其他角色摸一张<font color=>♥</font>基本牌，若为上回合选择的角色，其失去1点体力',
  [':daiyan'] = '结束阶段，你可以令一名其他角色从牌堆中获得一张<font color=>♥</font>基本牌，然后若其是上回合此技能选择的角色，其失去1点体力。',
  ['$daiyan1'] = '汝可于宫中多留几日无妨。',
  ['$daiyan2'] = '胡氏受屈，吾亦心不安。',
}

daiyan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
  return target == player and player:hasSkill(daiyan.name) and player.phase == Player.Finish
  end,
  on_trigger = function(self, event, target, player)
  local room = player.room
  if player:getMark("daiyan_record") ~= 0 then
    local to = room:getPlayerById(player:getMark("daiyan_record"))
    room:setPlayerMark(player, "daiyan_record", 0)
    if not to.dead then
    room:setPlayerMark(to, "@@daiyan-tmp", 1)
    end
  end
  self:doCost(event, target, player)
  for _, p in ipairs(room.players) do
    room:setPlayerMark(p, "@@daiyan-tmp", 0)
  end
  end,
  on_cost = function(self, event, target, player)
  local to = player.room:askToChoosePlayers(player, {
    targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
    min_num = 1,
    max_num = 1,
    prompt = "#daiyan-choose",
    skill_name = daiyan.name,
    cancelable = true
  })
  if #to > 0 then
    event:setCostData(self, to[1])
    return true
  end
  end,
  on_use = function(self, event, target, player)
  local room = player.room
  room:setPlayerMark(player, "daiyan_record", event:getCostData(self).id)
  local to = room:getPlayerById(event:getCostData(self).id)
  local card = room:getCardsFromPileByRule(".|.|heart|.|.|basic")
  if #card > 0 then
    room:moveCards({
    ids = card,
    to = to.id,
    toArea = Card.PlayerHand,
    moveReason = fk.ReasonJustMove,
    proposer = player.id,
    skillName = daiyan.name,
    moveVisible = true,
    })
  end
  if not to.dead and to:getMark("@@daiyan-tmp") > 0 then
    room:loseHp(to, 1, daiyan.name)
  end
  end,
})

return daiyan