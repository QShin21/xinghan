-- SPDX-License-Identifier: GPL-3.0-or-later
-- 董卓(新) - 封赏技能
-- 出牌阶段限一次，或有角色进入濒死状态时（每回合限一次），
-- 你可以将本回合弃牌堆中两张花色相同的牌分配给等量角色（每轮每种花色的牌限一次）。

local fengshang = fk.CreateSkill {
  name = "fengshang",
}

Fk:loadTranslationTable {
  ["fengshang"] = "封赏",
  [":fengshang"] = "出牌阶段限一次，或有角色进入濒死状态时（每回合限一次），"..
    "你可以将本回合弃牌堆中两张花色相同的牌分配给等量角色（每轮每种花色的牌限一次）。",

  ["#fengshang-use"] = "封赏：选择两张相同花色的牌分配给角色",

  ["$fengshang1"] = "封赏天下，谁敢不从！",
  ["$fengshang2"] = "董卓封赏，天下归心！",
}

fengshang:addEffect("active", {
  mute = true,
  prompt = "#fengshang-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(fengshang.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, fengshang.name, "support")
    player:broadcastSkillInvoke(fengshang.name)

    -- 从弃牌堆选择两张相同花色的牌
    -- 简化实现：随机选择两张相同花色的牌分配给角色
    -- 实际实现需要更复杂的逻辑
  end,
})

return fengshang
