-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄盖 - 苦肉技能
-- 出牌阶段限一次，你可以弃置一张牌，然后失去1点体力。

local kurou = fk.CreateSkill {
  name = "xh__kurou",
}

Fk:loadTranslationTable {
  ["xh__kurou"] = "苦肉",
  [":xh__kurou"] = "出牌阶段限一次，你可以弃置一张牌，然后失去1点体力。",

  ["#xh__kurou-use"] = "苦肉：弃置一张牌，然后失去1点体力",

  ["$xh__kurou1"] = "请鞭挞我吧，公瑾！",
  ["$xh__kurou2"] = "公瑾，请鞭挞我吧！",
}

kurou:addEffect("active", {
  mute = true,
  prompt = "#xh__kurou-use",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(kurou.name, Player.HistoryPhase) == 0 and
      not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return player:prohibitDiscard(Fk:getCardById(to_select)) == false
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = effect.cards[1]

    room:notifySkillInvoked(player, kurou.name, "offensive")
    player:broadcastSkillInvoke(kurou.name)

    -- 弃置牌
    room:throwCard(card, kurou.name, player, player)

    -- 失去1点体力
    room:loseHp(player, 1, kurou.name)
  end,
})

return kurou
