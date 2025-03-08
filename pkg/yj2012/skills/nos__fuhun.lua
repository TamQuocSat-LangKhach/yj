```lua
local nos__fuhun = fk.CreateSkill {
  name = "nos__fuhun"
}

Fk:loadTranslationTable{
  ['nos__fuhun'] = '父魂',
  [':nos__fuhun'] = '摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的两张牌并获得之，若亮出的牌颜色不同，你获得技能〖武圣〗、〖咆哮〗，直到回合结束。',
  ['$nos__fuhun1'] = '不血父仇，誓不罢休！',
  ['$nos__fuhun2'] = '承父遗志，横扫叛贼！',
}

nos__fuhun:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(nos__fuhun.name) and player.phase == Player.Draw
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(2)
    room:moveCards({
    ids = ids,
    toArea = Card.Processing,
    moveReason = fk.ReasonJustMove,
    skillName = nos__fuhun.name,
    proposer = player.id,
    })
    room:delay(1000)
    room:obtainCard(player.id, ids, true, fk.ReasonJustMove)
    if Fk:getCardById(ids[1]).color ~= Fk:getCardById(ids[2]).color then
    local skills = {}
    for _, skill_name in ipairs({"wusheng", "paoxiao"}) do
      if not player:hasSkill(skill_name, true) then
      table.insert(skills, skill_name)
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
      end)
    end
    end
    return true
  end,
})

return nos__fuhun
```