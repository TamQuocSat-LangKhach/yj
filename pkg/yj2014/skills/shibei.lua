```lua
local shibei = fk.CreateSkill {
  name = "shibei"
}

Fk:loadTranslationTable{
  ['shibei'] = '矢北',
  [':shibei'] = '锁定技，每当你受到伤害后，若此伤害是你本回合第一次受到的伤害，你回复1点体力；否则你失去1点体力。',
  ['$shibei1'] = '矢志于北，尽忠于国！',
  ['$shibei2'] = '命系袁氏，一心向北。',
}

shibei:addEffect(fk.Damaged, {
  mute = true,
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.isVirtualDMG then return end -- 虚拟伤害别管了
    local firstDamage = room.logic:getActualDamageEvents(1, function(e) return e.data[1].to == player end)[1]
    if firstDamage and firstDamage.data[1] == data then
      player:broadcastSkillInvoke(shibei.name, 1)
      room:notifySkillInvoked(player, shibei.name)
      if player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          skillName = shibei.name
        }
      end
    else
      player:broadcastSkillInvoke(shibei.name, 2)
      room:notifySkillInvoked(player, shibei.name, "negative")
      room:loseHp(player, 1, shibei.name)
    end
  end,
})

return shibei
```