-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙权 - 制衡技能
-- 出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，
-- 若你以此法弃置了所有手牌且对手上阵武将数大于你，则你多摸一张牌。

local zhiheng = fk.CreateSkill {
  name = "xh__zhiheng",
}

Fk:loadTranslationTable {
  ["xh__zhiheng"] = "制衡",
  [":xh__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，"..
    "若你以此法弃置了所有手牌且对手上阵武将数大于你，则你多摸一张牌。",

  ["#xh__zhiheng-use"] = "制衡：弃置任意张牌，然后摸等量的牌",

  ["$xh__zhiheng1"] = "制衡天下，运筹帷幄！",
  ["$xh__zhiheng2"] = "权衡利弊，决胜千里！",
}

zhiheng:addEffect("active", {
  mute = true,
  prompt = "#xh__zhiheng-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhiheng.name, Player.HistoryPhase) == 0 and
      not player:isNude()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, zhiheng.name, "draw")
    player:broadcastSkillInvoke(zhiheng.name)

    local handcards = player:getCardIds("h")
    local equipcards = player:getCardIds("e")
    local allcards = table.simpleClone(handcards)
    table.insertTable(allcards, equipcards)

    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = #allcards,
      include_equip = true,
      skill_name = zhiheng.name,
      pattern = ".",
      prompt = "#xh__zhiheng-use",
      cancelable = false,
    })

    local discard_num = #cards
    local all_hand = #cards == #handcards + #equipcards

    room:throwCard(cards, zhiheng.name, player, player)

    -- 计算摸牌数
    local draw_num = discard_num
    if all_hand then
      draw_num = draw_num + 1
    end

    player:drawCards(draw_num, zhiheng.name)
  end,
})

return zhiheng
