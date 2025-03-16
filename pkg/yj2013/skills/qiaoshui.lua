```lua
local qiaoshui = fk.CreateSkill {
  name = "qiaoshui"
}

Fk:loadTranslationTable{
  ['qiaoshui'] = '巧说',
  ['#qiaoshui-invoke'] = '巧说：你可以拼点，若赢，下一张基本牌或锦囊牌可以增加/减少一个目标',
  ['@@qiaoshui-turn'] = '巧说 赢',
  ['@@qiaoshui_lose-turn'] = '巧说 没赢',
  ['#qiaoshui_delay'] = '巧说',
  ['#qiaoshui-choose'] = '巧说：你可以为%arg增加/减少一个目标',
  [':qiaoshui'] = '出牌阶段开始时，你可以与一名其他角色拼点，若你赢，你使用的下一张基本牌或非延时类锦囊牌可以额外指定任意一名其他角色为目标或减少指定一个目标；若你没赢，你不能使用锦囊牌直到回合结束。',
  ['$qiaoshui1'] = '合则两利，斗则两伤。',
  ['$qiaoshui2'] = '君且安坐，听我一言。',
}

-- 主技能
qiaoshui:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiaoshui) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return player:canPindian(p) 
    end), Util.IdMapper)
    
    if #targets == 0 then return false end
    
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = qiaoshui.name,
      prompt = "#qiaoshui-invoke",
      cancelable = true
    })
    
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    local to = room:getPlayerById(cost_data.tos[1])
    local pindian = player:pindian({to}, qiaoshui.name)
    
    if pindian.results[to.id].winner == player then
      room:addPlayerMark(player, "@@qiaoshui-turn", 1)
    else
      room:addPlayerMark(player, "@@qiaoshui_lose-turn", 1)
    end
  end,
})

-- 延迟技能
qiaoshui:addEffect(fk.AfterCardTargetDeclared, {
  name = "#qiaoshui_delay",
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@qiaoshui-turn") > 0 and
         data.card.type ~= Card.TypeEquip and data.card.sub_type ~= Card.SubtypeDelayedTrick
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@qiaoshui-turn", 0)
    
    local targets = room:getUseExtraTargets(data)
    table.insertTableIfNeed(targets, TargetGroup:getRealTargets(data.tos))
    
    if #targets == 0 then return false end
    
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = qiaoshui.name,
      prompt = "#qiaoshui-choose:::"..data.card:toLogString(),
      cancelable = true
    })
    
    if #tos > 0 then
      local to = tos[1]
      
      if TargetGroup:includeRealTargets(data.tos, to) then
        TargetGroup:removeTarget(data.tos, to)
      else
        table.insert(data.tos, {to})
      end
    end
  end,
})

-- 禁用技能
qiaoshui:addEffect('prohibit', {
  name = "#qiaoshui_prohibit",
  prohibit_use = function(self, player, card)
    return player:hasSkill(qiaoshui, true) and player:getMark("@@qiaoshui_lose-turn") > 0 and card.type == Card.TypeTrick
  end,
})

return qiaoshui
```