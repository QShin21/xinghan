-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李傕 - 亦算技能
-- 出牌阶段限一次，当你使用的普通锦囊牌结算结束后，
-- 你可以失去1点体力或减1点体力上限，然后获得此牌。

local yisuan = fk.CreateSkill {
  name = "yisuan",
}

Fk:loadTranslationTable {
  ["yisuan"] = "亦算",
  [":yisuan"] = "出牌阶段限一次，当你使用的普通锦囊牌结算结束后，"..
    "你可以失去1点体力或减1点体力上限，然后获得此牌。",

  ["#yisuan-invoke"] = "亦算：是否获得此牌？",
  ["yisuan_losehp"] = "失去1点体力",
  ["yisuan_losemaxhp"] = "减1点体力上限",

  ["$yisuan1"] = "亦算之计，得失之间！",
  ["$yisuan2"] = "算无遗策，智计百出！",
}

yisuan:addEffect(fk.CardUseFinished, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yisuan.name) and
      player.phase == Player.Play and
      data.card and data.card.type == Card.TypeTrick and
      player:usedSkillTimes(yisuan.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yisuan.name,
      prompt = "#yisuan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local choice = room:askToChoice(player, {
      choices = {"yisuan_losehp", "yisuan_losemaxhp"},
      skill_name = yisuan.name,
      prompt = "选择一项代价",
      detailed = false,
    })
    
    if choice == "yisuan_losehp" then
      room:loseHp(player, 1, yisuan.name)
    else
      room:changeMaxHp(player, -1)
    end
    
    -- 获得此牌
    if data.card and table.contains(room.discard_pile, data.card.id) then
      room:moveCardTo(data.card.id, Player.Hand, player, fk.ReasonPrey, yisuan.name)
    end
  end,
})

return yisuan
