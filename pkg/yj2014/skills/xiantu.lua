```lua
local xiantu = fk.CreateSkill {
  name = "xiantu"
}

Fk:loadTranslationTable{
  ['xiantu'] = '献图',
  ['#xiantu-invoke'] = '献图：你可以摸两张牌并交给 %dest 两张牌',
  ['#xiantu-give'] = '献图：选择交给 %dest 的两张牌',
  [':xiantu'] = '其他角色的出牌阶段开始时，你可以摸两张牌，然后交给其两张牌，然后此阶段结束时，若其于此回合内未杀死过角色，则你失去1点体力。',
  ['$xiantu1'] = '将军莫虑，且看此图。',
  ['$xiantu2'] = '我已诚心相献，君何踌躇不前？',
}

xiantu:addEffect(fk.EventPhaseStart, {
  mute = true,
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(xiantu.name) and target.phase == Player.Play and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = xiantu.name, prompt = "#xiantu-invoke::" .. target.id })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(xiantu.name, 1)
    room:notifySkillInvoked(player, xiantu.name)
    room:doIndicate(player.id, {target.id})
    room:setPlayerMark(player, "xiantu-phase", 1)
    player:drawCards(2, xiantu.name)
    if player:isNude() then return end
    local cards
    if #player:getCardIds{Player.Hand, Player.Equip} <= 2 then
      cards = player:getCardIds{Player.Hand, Player.Equip}
    else
      cards = room:askToCards(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = xiantu.name,
        cancelable = false,
        prompt = "#xiantu-give::" .. target.id
      })
    end
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, xiantu.name, nil, false, player.id)
  end,
})

xiantu:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player and target.phase == Player.Play and player:getMark("xiantu-phase") > 0 then
      return #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function(e)
        local death = e.data[1]
        return death.damage and death.damage.from == target
      end, Player.HistoryPhase) == 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiantu", 2)
    room:notifySkillInvoked(player, "xiantu", "negative")
    room:loseHp(player, 1, xiantu.name)
  end,
})

return xiantu
```