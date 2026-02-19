-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 肃军技能
-- 出牌阶段限一次，当你使用一张牌时，若你手牌中基本牌与非基本牌数量相等，你可以摸两张牌。

local sujun = fk.CreateSkill {
  name = "xh__sujun",
}

Fk:loadTranslationTable{
  ["xh__sujun"] = "肃军",
  [":xh__sujun"] = "出牌阶段限一次，当你使用一张牌时，若你手牌中基本牌与非基本牌数量相等，你可以摸两张牌。",

  ["$xh__sujun1"] = "将为军魂，需以身作则。",
  ["$xh__sujun2"] = "整肃三军，可育虎贲。",
}

sujun:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sujun.name) and
      player.phase == Player.Play and
      player:usedSkillTimes(sujun.name, Player.HistoryPhase) == 0 and
      2 * #table.filter(player:getCardIds("h"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end) == player:getHandcardNum()
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, sujun.name)
  end,
})

return sujun
