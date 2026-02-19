-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭图 - 诿解技能
-- 其他角色的回合限一次，当你需要使用或打出基本牌时，
-- 你可弃置与你距离为1的其他角色一张手牌，若此牌与你需要使用或打出的牌名相同，
-- 你视为使用或打出此牌。

local weijie = fk.CreateSkill {
  name = "xh__weijie",
}

Fk:loadTranslationTable {
  ["xh__weijie"] = "诿解",
  [":xh__weijie"] = "其他角色的回合限一次，当你需要使用或打出基本牌时，"..
    "你可弃置与你距离为1的其他角色一张手牌，若此牌与你需要使用或打出的牌名相同，"..
    "你视为使用或打出此牌。",

  ["#xh__weijie-use"] = "诿解：选择一名距离为1的角色",

  ["$xh__weijie1"] = "诿解之计，借刀杀人！",
  ["$xh__weijie2"] = "郭图诿解，天下无双！",
}

weijie:addEffect("viewas", {
  mute = true,
  pattern = "slash,jink,peach,analeptic",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return nil end
    
    -- 检查是否可以使用
    if player:usedSkillTimes(weijie.name, Player.HistoryTurn) > 0 then return nil end
    
    -- 找出距离为1的角色
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and player:distanceTo(p) == 1 and not p:isKongcheng()
    end)
    
    if #targets == 0 then return nil end
    
    -- 简化实现：需要更复杂的逻辑来处理
    return nil
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(weijie.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:usedSkillTimes(weijie.name, Player.HistoryTurn) == 0
  end,
})

return weijie
