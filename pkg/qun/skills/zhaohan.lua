-- SPDX-License-Identifier: GPL-3.0-or-later
-- 杨彪 - 昭汉技能
-- 锁定技，准备阶段，若牌堆未洗过牌，则你回复1点体力，否则你失去1点体力。

local zhaohan = fk.CreateSkill {
  name = "xh__zhaohan",
}

Fk:loadTranslationTable {
  ["xh__zhaohan"] = "昭汉",
  [":xh__zhaohan"] = "锁定技，准备阶段，若牌堆未洗过牌，则你回复1点体力，否则你失去1点体力。",

  ["$xh__zhaohan1"] = "昭汉之心，天地可鉴！",
  ["$xh__zhaohan2"] = "汉室倾颓，吾心甚忧！",
}

zhaohan:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__zhaohan.name) and
      player.phase == Player.Start
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 检查牌堆是否洗过牌（简化处理：检查是否有洗牌标记）
    local shuffled = room:getBanner("draw_pile_shuffled")
    
    if not shuffled then
      -- 未洗过牌：回复1点体力
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xh__zhaohan.name,
      }
    else
      -- 洗过牌：失去1点体力
      room:loseHp(player, 1, xh__zhaohan.name)
    end
  end,
})

return zhaohan
