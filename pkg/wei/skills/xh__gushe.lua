-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王朗 - 鼓舌技能
-- 出牌阶段限一次，你可以与对手拼点，没赢的角色选择一项：
-- 1. 弃置一张牌；2. 令你摸一张牌。

local gushe = fk.CreateSkill {
  name = "xh__gushe",
}

Fk:loadTranslationTable {
  ["xh__gushe"] = "鼓舌",
  [":xh__gushe"] = "出牌阶段限一次，你可以与对手拼点，没赢的角色选择一项："..
    "1. 弃置一张牌；2. 令你摸一张牌。",

  ["#xh__gushe-choose"] = "鼓舌：选择一名角色进行拼点",
  ["#xh__gushe-choice"] = "鼓舌：请选择一项",
  ["gushe_discard"] = "弃置一张牌",
  ["gushe_draw"] = "令对方摸一张牌",

  ["$xh__gushe1"] = "鼓舌如簧，巧言令色！",
  ["$xh__gushe2"] = "三寸不烂之舌，可敌百万雄师！",
}

gushe:addEffect("active", {
  mute = true,
  prompt = "#xh__gushe-choose",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(gushe.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return player:prohibitDiscard(Fk:getCardById(to_select)) == false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if #selected_cards == 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, gushe.name, "control", {target})
    player:broadcastSkillInvoke(gushe.name)

    -- 拼点
    local pindian = room:pindian({player, target}, gushe.name)

    local loser
    if pindian.results[player].winner then
      loser = target
    else
      loser = player
    end

    if loser.dead then return end

    local choices = {"gushe_discard", "gushe_draw"}

    if loser:isNude() then
      table.removeOne(choices, "gushe_discard")
    end

    local choice = room:askToChoice(loser, {
      choices = choices,
      skill_name = gushe.name,
      prompt = "#xh__gushe-choice",
      detailed = false,
    })

    if choice == "gushe_discard" then
      local id = room:askToChooseCard(loser, {
        target = loser,
        flag = "he",
        skill_name = gushe.name,
      })
      room:throwCard(id, gushe.name, loser, loser)
    else
      -- 令对方摸一张牌
      local drawer = (loser == player) and target or player
      if not drawer.dead then
        drawer:drawCards(1, gushe.name)
      end
    end
  end,
})

return gushe
