```lua
local wuyan = fk.CreateSkill {
  name = "wuyan"
}

Fk:loadTranslationTable{
  ['wuyan'] = '无言',
  [':wuyan'] = '锁定技，你防止你造成或受到的任何锦囊牌的伤害。',
  ['$wuyan1'] = '吾，誓不为汉贼献一策！',
  ['$wuyan2'] = '汝有良策，何必问我！',
}

wuyan:addEffect({fk.DamageCaused, fk.DamageInflicted}, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuyan.name) and data.card and data.card.type == Card.TypeTrick
  end,
  on_use = Util.TrueFunc,
})

return wuyan
```

这个技能代码中并没有使用任何`askForXXX`方法，因此不需要进行重构。