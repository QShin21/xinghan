-- SPDX-License-Identifier: GPL-3.0-or-later
-- 高干 - 拒关技能
-- 出牌阶段限一次，你可将一张手牌当不计入次数的【杀】或【决斗】使用。
-- 直到你下回合开始前，若以此法受到伤害的角色未对你造成过伤害，你的下个摸牌阶段摸牌数+2。

local juguan = fk.CreateSkill {
  name = "xh__juguan",
}

Fk:loadTranslationTable {
  ["xh__juguan"] = "拒关",
  [":xh__juguan"] = "出牌阶段限一次，你可将一张手牌当不计入次数的【杀】或【决斗】使用。"..
    "直到你下回合开始前，若以此法受到伤害的角色未对你造成过伤害，你的下个摸牌阶段摸牌数+2。",

  ["#xh__juguan-use"] = "拒关：选择一张手牌",
  ["juguan_slash"] = "当杀使用",
  ["juguan_duel"] = "当决斗使用",
  ["@@xh__juguan_bonus"] = "拒关奖励",

  ["$xh__juguan1"] = "拒关之险，谁敢闯关！",
  ["$xh__juguan2"] = "高干拒关，天下无双！",
}

juguan:addEffect("viewas", {
  mute = true,
  pattern = "slash,duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("h"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"juguan_slash", "juguan_duel"},
      skill_name = xh__juguan.name,
      prompt = "选择当什么牌使用",
      detailed = false,
    })
    
    local card_name = choice == "juguan_slash" and "slash" or "duel"
    local card = Fk:cloneCard(card_name)
    card.skillName = xh__juguan.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(xh__juguan.name, Player.HistoryPhase) == 0
  end,
})

-- 摸牌阶段摸牌数+2
juguan:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@juguan_bonus") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.num = data.num + 2
    player.room:setPlayerMark(player, "@@juguan_bonus", 0)
  end,
})

return juguan
