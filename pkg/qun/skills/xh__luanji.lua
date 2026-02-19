-- SPDX-License-Identifier: GPL-3.0-or-later
-- 袁绍 - 乱击技能
-- 出牌阶段限一次，你可以将两张手牌当【万箭齐发】使用，
-- 当其他角色打出【闪】响应此牌时，你摸一张牌。

local luanji = fk.CreateSkill {
  name = "xh__luanji",
}

Fk:loadTranslationTable {
  ["xh__luanji"] = "乱击",
  [":xh__luanji"] = "出牌阶段限一次，你可以将两张手牌当【万箭齐发】使用，当其他角色打出【闪】响应此牌时，你摸一张牌。",

  ["#xh__luanji-use"] = "乱击：将两张手牌当【万箭齐发】使用",
  ["@@xh__luanji_card"] = "乱击",

  ["$xh__luanji1"] = "放箭！放箭！",
  ["$xh__luanji2"] = "箭如雨下，看你们往哪里躲！",
}

luanji:addEffect("viewas", {
  mute = true,
  pattern = "savage_assault",
  card_filter = function(self, player, to_select, selected)
    if #selected >= 2 then return false end
    return player:getCardIds("h")[1] == to_select or player:getCardIds("h")[2] == to_select
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return nil end
    local card = Fk:cloneCard("savage_assault")
    card.skillName = luanji.name
    for _, id in ipairs(cards) do
      card:addSubcard(id)
    end
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(luanji.name, Player.HistoryPhase) == 0 and
      player:getHandcardNum() >= 2 and
      player:canUse(Fk:cloneCard("savage_assault"))
  end,
})

-- 使用后标记
luanji:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.skillName == luanji.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@luanji_card", data.card.id)
  end,
})

-- 其他角色打出闪响应时摸牌
luanji:addEffect(fk.CardResponding, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then return false end
    if not player:hasSkill(luanji.name) then return false end

    local card = data.card
    if not card or card.trueName ~= "jink" then return false end

    local luanji_card = player:getMark("@@luanji_card")
    return luanji_card ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, luanji.name)
  end,
})

-- 回合结束清除标记
luanji:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@luanji_card") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@luanji_card", 0)
  end,
})

return luanji
