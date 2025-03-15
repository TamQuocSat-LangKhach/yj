```lua
local benxi = fk.CreateSkill {
  name = "benxi"
}

Fk:loadTranslationTable{
  ['benxi'] = '奔袭',
  ['@benxi-turn'] = '奔袭',
  ['#benxi-choose'] = '奔袭：你可以多指定一个目标',
  [':benxi'] = '锁定技，当你于回合内使用牌时，本回合你计算与其他角色的距离-1；你的回合内，若你与所有其他角色的距离均为1，则你无视其他角色的防具且你使用【杀】可以多指定一个目标。',
  ['$benxi1'] = '奔战万里，袭关斩将。',
  ['$benxi2'] = '袭敌千里，溃敌百步！',
}

benxi:addEffect(fk.CardUsing, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(benxi) and player.room.current == player
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      player.room:addPlayerMark(player, "@benxi-turn", 1)
    end
  end,
})

benxi:addEffect(fk.AfterCardTargetDeclared, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(benxi) and player.room.current == player and 
         (data.card and data.card.trueName == "slash" and
        table.every(player.room.alive_players, function(p) return player:distanceTo(p) < 2 end) and
        #player.room:getUseExtraTargets(data, false) > 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getUseExtraTargets(data, false)
    if #targets == 0 then return false end
    targets = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#benxi-choose",
      skill_name = benxi.name,
      cancelable = true,
    })
    if #targets > 0 then
      table.insert(data.tos, targets)
    end
  end,
})

local benxi_armorInvalidity = fk.CreateSkill {
  name = "benxi_invalidity"
}

benxi_armorInvalidity:addEffect('invalidity', {
  invalidity_func = function(self, player, skill_to_check)
    if skill_to_check.attached_equip and Fk:cloneCard(skill_toCheck.attached_equip).sub_type == Card.SubtypeArmor then
      -- 无视防具（规则集版）！
      if RoomInstance then
        local skill_owner = RoomInstance.current
        if not (skill_owner:hasSkill(benxi) and table.every(RoomInstance.alive_players, function(p)
          return skill_owner:distanceTo(p) < 2
        end)) then return false end

        local logic = RoomInstance.logic
        local event = logic:getCurrentEvent()
        repeat
          if event.event == GameEvent.SkillEffect then
            if not event.data[3].cardSkill then
              return event.data[2] == skill_owner
            end
          elseif event.event == GameEvent.Damage then
            local damage = event.data[1]
            return damage.to == player and damage.from == skill_owner
          elseif event.event == GameEvent.UseCard then
            local use = event.data[1]
            return use.from == skill_owner.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
          end
          event = event.parent
        until event == nil
      end
    end
  end,
})

local benxi_distance = fk.CreateSkill {
  name = "benxi_distance"
}

benxi_distance:addEffect('distance', {
  correct_func = function(self, from, to)
    return -from:getMark("@benxi-turn")
  end,
})

return benxi
```