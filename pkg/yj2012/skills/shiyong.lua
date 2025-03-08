```lua
local shiyong = fk.CreateSkill {
  name = "shiyong"
}

Fk:loadTranslationTable{
  ['shiyong'] = '恃勇',
  [':shiyong'] = '锁定技，每当你受到一次红色【杀】或【酒】【杀】造成的伤害后，你减1点体力上限。',
  ['$shiyong1'] = '好大一股酒气啊！',
  ['$shiyong2'] = '好大一股杀气啊！',
}

shiyong:addEffect(fk.Damaged, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(shiyong.name) and data.card and data.card.trueName == "slash" then
    if data.card.color == Card.Red then
      return true
    end
    local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      return use.extra_data and use.extra_data.drankBuff
    end
    end
  end,
  on_use = function(skill, event, target, player, data)
    local audio = 0
    if target == player and player:hasSkill(shiyong.name) and data.card and data.card.trueName == "slash" then
    if data.card.color == Card.Red then
      audio = 2
    end
    local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      if use.extra_data and use.extra_data.drankBuff then
      if audio == 2 then
        audio = -1
      else
        audio = 1
      end
      end
    end
    end
    player.room:notifySkillInvoked(player, shiyong.name, "negative")
    player:broadcastSkillInvoke(shiyong.name, audio)
    player.room:changeMaxHp(player, -1)
  end,
})

return shiyong
```