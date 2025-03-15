local xingshuai = fk.CreateSkill {
  name = "xingshuai$"
}

Fk:loadTranslationTable{
  ['#xingshuai-invoke'] = '兴衰：你可以令%dest回复1点体力，结算后你受到1点伤害',
}

xingshuai:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingshuai) and player:usedSkillTimes(xingshuai.name, Player.HistoryGame) == 0 and
      not table.every(player.room:getOtherPlayers(player), function(p) return p.kingdom ~= "wei" end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "wei" and room:askToSkillInvoke(p, {
        skill_name = xingshuai.name,
        prompt = "#xingshuai-invoke::"..player.id
      }) then
        table.insert(targets, p)
      end
    end
    if #targets > 0 then
      for _, p in ipairs(targets) do
        if player.dead or not player:isWounded() then break end
        room:recover{
          who = player,
          num = 1,
          recoverBy = p,
          skillName = xingshuai.name
        }
      end
    end
    if not player.dying then
      for _, p in ipairs(targets) do
        room:damage{
          to = p,
          damage = 1,
          skillName = xingshuai.name,
        }
      end
    end
  end,
})

return xingshuai