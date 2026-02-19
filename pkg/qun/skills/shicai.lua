-- SPDX-License-Identifier: GPL-3.0-or-later
-- 许攸 - 恃才技能
-- 锁定技，当你受到伤害后，若此伤害值：为1，则你摸两张牌；大于1，则你弃置所有的手牌。

local shicai = fk.CreateSkill {
  name = "xh__shicai",
}

Fk:loadTranslationTable {
  ["xh__shicai"] = "恃才",
  [":xh__shicai"] = "锁定技，当你受到伤害后，若此伤害值：为1，则你摸两张牌；大于1，则你弃置所有的手牌。",

  ["$xh__shicai1"] = "恃才傲物，天下无双！",
  ["$xh__shicai2"] = "许攸恃才，无人能及！",
}

shicai:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__shicai.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    if data.damage == 1 then
      player:drawCards(2, xh__shicai.name)
    else
      local handcards = player:getCardIds("h")
      if #handcards > 0 then
        room:throwCard(handcards, xh__shicai.name, player, player)
      end
    end
  end,
})

return shicai
