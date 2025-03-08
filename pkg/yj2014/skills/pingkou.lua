local pingkou = fk.CreateSkill {
  name = "pingkou"
}

Fk:loadTranslationTable{
  ['pingkou'] = '平寇',
  ['#pingkou-choose'] = '平寇：你可以对至多%arg名角色各造成1点伤害',
  [':pingkou'] = '回合结束时，你可以对至多X名其他角色各造成1点伤害（X为你本回合跳过的阶段数）。',
  ['$pingkou1'] = '对敌人仁慈，就是对自己残忍。',
  ['$pingkou2'] = '反守为攻，直捣黄龙！',
}

pingkou:addEffect(fk.EventPhaseStart, {
  mute = true,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pingkou.name) and player.phase == Player.Finish and type(player.skipped_phases) == "table"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, phase in ipairs({Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish}) do
      if player.skipped_phases[phase] then
        n = n + 1
      end
    end
    local targets = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = n,
      prompt = "#pingkou-choose:::"..n,
      skill_name = pingkou.name,
      cancelable = true
    })
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      event:setCostData(self, targets)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(event:getCostData(self)) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = pingkou.name,
        }
      end
    end
  end,
})

return pingkou