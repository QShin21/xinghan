-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙权 - 制衡技能
-- 出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，
-- 若你以此法弃置了所有手牌且对手上阵武将数大于你，则你多摸一张牌。

local zhiheng = fk.CreateSkill {
  name = "xh__zhiheng",
}

Fk:loadTranslationTable {
  ["xh__zhiheng"] = "制衡",
  [":xh__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌，" ..
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
  max_phase_use_time = 1,

  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,

  can_use = function(self, player)
    return player.phase == Player.Play and not player:isNude()
  end,

  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, zhiheng.name, "draw")
    player:broadcastSkillInvoke(zhiheng.name)

    -- 先记录发动前的手牌，用来判断是否“弃置了所有手牌”
    local hand_before = player:getCardIds("h")

    -- 直接询问弃牌：该函数默认会把选择的牌弃掉（除非 skipDiscard = true）
    local discard_ids = room:askToDiscard(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      pattern = ".",
      skill_name = zhiheng.name,
      prompt = "#xh__zhiheng-use",
      cancelable = false,
    })

    local discard_num = #discard_ids
    if discard_num == 0 or player.dead then
      return
    end

    -- 判断是否弃置了所有手牌：只要求手牌全在 discard_ids 中，装备弃不弃都无所谓
    local discarded_all_hand = (#hand_before > 0)
    for _, id in ipairs(hand_before) do
      if not table.contains(discard_ids, id) then
        discarded_all_hand = false
        break
      end
    end

    -- 计算“上阵武将数”：这里用存活友方人数 vs 存活敌方人数近似
    local my_side_cnt = #player:getFriends(true, false)
    local enemy_side_cnt = #player:getEnemies(false)

    local draw_num = discard_num
    if discarded_all_hand and enemy_side_cnt > my_side_cnt then
      draw_num = draw_num + 1
    end

    player:drawCards(draw_num, zhiheng.name)
  end,
})

return zhiheng