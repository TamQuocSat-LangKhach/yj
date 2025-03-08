```lua
local qianju = fk.CreateSkill {
  name = "qianju"
}

Fk:loadTranslationTable{
  ['qianju'] = '千驹',
  [':qianju'] = '锁定技，你计算与其他角色的距离-X。（X为你已损失的体力值）',
}

qianju:addEffect('distance', {
  correct_func = function(skill, from, to)
  if from:hasSkill(qianju.name) then
    return -from:getLostHp()
  end
  end,
})

return qianju
```

在这个技能代码中，没有使用到任何 `askForXXX` 方法，因此不需要进行重构。所有内容保持不变。