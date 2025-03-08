```lua
local fuhun = fk.CreateSkill {
  name = "fuhun"
}

Fk:loadTranslationTable{
  ['fuhun'] = '父魂',
  ['#fuhun_delay'] = '父魂',
  [':fuhun'] = '你可以将两张手牌当【杀】使用或打出；当你于出牌阶段内以此法造成伤害后，本回合获得〖武圣〗和〖咆哮〗。',
  ['$fuhun1'] = '光复汉室，重任在肩！',
  ['$fuhun2'] = '将门虎子，承我父志！',
}

-- ViewAsSkill 效果
fuhun:addEffect('viewas', {
  name = "fuhun",
  pattern = "slash",
  card_filter = function(skill, player, to_select, selected)
    return #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(skill, player, cards)
    if #cards ~= 2 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = fuhun.name
    c:addSubcards(cards)
    return c
  end,
})

-- TriggerSkill 效果
fuhun:addEffect(fk.Damage, {
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(fuhun.name) and target == player and data.card and table.contains(data.card.skillNames, fuhun.name) and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_trigger = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("fuhun")
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
  end,
})

return fuhun
```