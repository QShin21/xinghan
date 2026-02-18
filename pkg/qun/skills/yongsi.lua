-- SPDX-License-Identifier: GPL-3.0-or-later
-- 袁术 - 庸肆技能
-- 锁定技，摸牌阶段，你多摸X张牌；弃牌阶段开始时，你弃置一张牌（X为场上势力数）。

local yongsi = fk.CreateSkill {
  name = "yongsi",
}

Fk:loadTranslationTable {
  ["yongsi"] = "庸肆",
  [":yongsi"] = "锁定技，摸牌阶段，你多摸X张牌；弃牌阶段开始时，你弃置一张牌（X为场上势力数）。",

  ["#yongsi-discard"] = "庸肆：弃置一张牌",

  ["$yongsi1"] = "庸肆之志，天下归心！",
  ["$yongsi2"] = "四世三公，何人能比！",
}

-- 多摸牌
yongsi:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 计算场上势力数
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end

    local x = #kingdoms
    data.num = data.num + x
  end,
})

-- 弃牌阶段弃置一张牌
yongsi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name) and
      player.phase == Player.Discard and not player:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local id = room:askToChooseCard(player, {
      target = player,
      flag = "he",
      skill_name = yongsi.name,
    })
    room:throwCard(id, yongsi.name, player, player)
  end,
})

return yongsi
