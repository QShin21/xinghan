-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹操 - 奸雄技能
-- 当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。

local jianxiong = fk.CreateSkill {
  name = "xh__jianxiong",
}

Fk:loadTranslationTable {
  ["xh__jianxiong"] = "奸雄",
  [":xh__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",

  ["#xh__jianxiong-invoke"] = "奸雄：获得造成伤害的牌并摸一张牌",

  ["$xh__jianxiong1"] = "宁教我负天下人，休教天下人负我！",
  ["$xh__jianxiong2"] = "吾好梦中杀人！",
}

jianxiong:addEffect(fk.Damaged, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianxiong.name) and
      data.card and not data.card:isVirtual()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jianxiong.name,
      prompt = "#xh__jianxiong-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card

    -- 获得造成伤害的牌
    if table.contains(room.discard_pile, card.id) then
      room:moveCardTo(card.id, Player.Hand, player, fk.ReasonPrey, jianxiong.name)
    end

    -- 摸一张牌
    player:drawCards(1, jianxiong.name)
  end,
})

return jianxiong
