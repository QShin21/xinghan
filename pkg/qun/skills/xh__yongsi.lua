-- SPDX-License-Identifier: GPL-3.0-or-later
-- 袁术 - 庸肆技能
-- 锁定技，摸牌阶段，你多摸X张牌；弃牌阶段开始时，你弃置一张牌（X为场上势力数）。

local yongsi = fk.CreateSkill {
  name = "xh__yongsi",
}

Fk:loadTranslationTable {
  ["xh__yongsi"] = "庸肆",
  [":xh__yongsi"] = "锁定技，摸牌阶段，你多摸X张牌；弃牌阶段开始时，你弃置一张牌（X为场上势力数）。",

  ["$xh__yongsi1"] = "庸肆之志，称霸天下！",
  ["$xh__yongsi2"] = "袁术称帝，天下归心！",
}

-- 多摸牌
yongsi:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__yongsi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 计算势力数
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      kingdoms[p.kingdom] = true
    end
    local x = table.size(kingdoms)
    
    data.num = data.num + x
  end,
})

-- 弃牌阶段弃置一张牌
yongsi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__yongsi.name) and
      player.phase == Player.Discard and not player:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xh__yongsi.name,
      pattern = ".",
      prompt = "选择一张牌弃置",
      cancelable = false,
    })
    
    room:throwCard(id, xh__yongsi.name, player, player)
  end,
})

return yongsi
