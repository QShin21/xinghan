-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夏侯惇 - 刚烈技能
-- 当你受到1点伤害后，你可以进行判定，若结果为：
-- 红色，你对伤害来源造成1点伤害；
-- 黑色，你弃置伤害来源的一张牌。

local ganglie = fk.CreateSkill {
  name = "xh__ganglie",
}

Fk:loadTranslationTable {
  ["xh__ganglie"] = "刚烈",
  [":xh__ganglie"] = "当你受到1点伤害后，你可以进行判定，若结果为：红色，你对伤害来源造成1点伤害；黑色，你弃置伤害来源的一张牌。",

  ["#xh__ganglie-invoke"] = "刚烈：你可以进行判定",
  ["#xh__ganglie-judge"] = "刚烈判定",

  ["$xh__ganglie1"] = "以彼之道，还施彼身！",
  ["$xh__ganglie2"] = "鼠辈，竟敢伤我！",
}

ganglie:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ganglie.name) and data.damage > 0 and
      data.from and not data.from.dead and data.from ~= player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#xh__ganglie-invoke"
    return room:askToSkillInvoke(player, {
      skill_name = ganglie.name,
      prompt = prompt,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from

    -- 进行判定
    local judge = {
      who = player,
      reason = ganglie.name,
      pattern = ".",
    }
    room:judge(judge)

    if from.dead then return end

    local card = Fk:getCardById(judge.card.id)

    if card.color == Card.Red then
      -- 红色：对伤害来源造成1点伤害
      room:damage{
        from = player,
        to = from,
        damage = 1,
        skillName = ganglie.name,
      }
    else
      -- 黑色：弃置伤害来源的一张牌
      if not from:isNude() then
        local id = room:askToChooseCard(player, {
          target = from,
          flag = "he",
          skill_name = ganglie.name,
        })
        room:throwCard(id, ganglie.name, from, player)
      end
    end
  end,
})

return ganglie
