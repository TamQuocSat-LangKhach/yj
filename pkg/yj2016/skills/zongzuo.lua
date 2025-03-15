```lua
local zongzuo = fk.CreateSkill {
  name = "zongzuo"
}

Fk:loadTranslationTable{
  ['zongzuo'] = '宗祚',
  [':zongzuo'] = '锁定技，游戏开始时，你加X点体力上限和体力（X为全场势力数）；当每个势力的最后一名角色死亡后，你减1点体力上限。',
  ['$zongzuo1'] = '尽死生之力，保大厦不倾。',
  ['$zongzuo2'] = '乾坤倒，黎民苦，高祖后，岂任之？',
}

zongzuo:addEffect(fk.GameStart, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(zongzuo) and (event == fk.GameStart or
      (event == fk.Deathed and table.every(player.room:getAlivePlayers(), function(p) return p.kingdom ~= target.kingdom end)))
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.GameStart then
      player:broadcastSkillInvoke(zongzuo.name)
      room:notifySkillInvoked(player, zongzuo.name, "defensive")
      local kingdoms = {}
      for _, p in ipairs(player.room:getAlivePlayers()) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      room:changeMaxHp(player, #kingdoms)
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = zongzuo.name,
      }
    else
      room:notifySkillInvoked(player, zongzuo.name, "negative")
      room:changeMaxHp(player, -1)
    end
  end,
})

zongzuo:addEffect(fk.Deathed, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(zongzuo) and (event == fk.GameStart or
      (event == fk.Death and table.every(player.room:getAlivePlayers(), function(p) return p.kingdom ~= target.kingdom end)))
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.GameStart then
      player:broadcastSkillInvoke(zongzuo.name)
      room:notifySkillInvoked(player, zongzuo.name, "defensive")
      local kingdoms = {}
      for _, p in ipairs(player.room:getAlivePlayers()) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      room:changeMaxHp(player, #kingdoms)
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = zongzuo.name,
      }
    else
      room:notifySkillInvoked(player, zongzuo.name, "negative")
      room:changeMaxHp(player, -1)
    end
  end,
})

return zongzuo
```