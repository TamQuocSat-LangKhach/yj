```lua
local fuzhu = fk.CreateSkill {
  name = "fuzhu"
}

Fk:loadTranslationTable{
  ['fuzhu'] = '伏诛',
  ['#fuzhu-invoke'] = '伏诛：你可以对 %dest 使用牌堆中所有【杀】！',
  [':fuzhu'] = '一名男性角色结束阶段，若牌堆剩余牌数不大于你体力值的十倍，你可以依次对其使用牌堆中所有的【杀】（不能超过游戏人数），然后洗牌。',
  ['$fuzhu1'] = '我连做梦都在等这一天呢。',
  ['$fuzhu2'] = '既然来了，就别想走了。',
}

fuzhu:addEffect(fk.EventPhaseStart, {
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(skill.name) and target ~= player and target.phase == Player.Finish
      and (target:isMale())
      and #player.room.draw_pile <= 10 * player.hp
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#fuzhu-invoke::" .. target.id
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local n = 0
    repeat
      n = n + 1
      local no_slash = true
      local slash
      for i = #room.draw_pile, 1, -1 do
        slash = Fk:getCardById(room.draw_pile[i])
        if slash.trueName == "slash" and player:canUseTo(slash, target, { bypass_times = true, bypass_distances = true }) then
          no_slash = false
          room:useCard({
            from = player.id,
            tos = {{target.id}},
            card = slash,
            extraUse = true,
          })
          break
        end
      end
      if no_slash then break end
    until (n >= #room.players or player.dead or target.dead or #room.draw_pile > 10 * player.hp)
    room:shuffleDrawPile()
  end,
})

return fuzhu
```