-- SPDX-License-Identifier: GPL-3.0-or-later
-- 庞统 - 展骥技能
-- 锁定技，当你于出牌阶段内因摸牌且并非因发动此技能而得到牌时，你摸一张牌。

local zhanji = fk.CreateSkill {
  name = "xh__zhanji",
}

Fk:loadTranslationTable {
  ["xh__zhanji"] = "展骥",
  [":xh__zhanji"] = "锁定技，当你于出牌阶段内因摸牌且并非因发动此技能而得到牌时，你摸一张牌。",

  ["$xh__zhanji1"] = "展骥千里，志在四方！",
  ["$xh__zhanji2"] = "骥足展露，必成大器！",
}

zhanji:addEffect(fk.AfterDrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__zhanji.name) and
      player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, xh__zhanji.name)
  end,
})

return zhanji
