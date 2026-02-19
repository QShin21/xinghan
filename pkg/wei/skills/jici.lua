-- SPDX-License-Identifier: GPL-3.0-or-later
-- 王朗 - 激词技能
-- 当你发动"鼓舌"拼点的牌亮出后，若点数小于X，你可令点数+X；
-- 若点数等于X，你可以令你本回合发动"鼓舌"的次数上限+1。（X为你的手牌数量）

local jici = fk.CreateSkill {
  name = "jici",
}

Fk:loadTranslationTable {
  ["jici"] = "激词",
  [":jici"] = "当你发动\"鼓舌\"拼点的牌亮出后，若点数小于X，你可令点数+X；"..
    "若点数等于X，你可以令你本回合发动\"鼓舌\"的次数上限+1。（X为你的手牌数量）",

  ["#jici-invoke"] = "激词：是否发动效果？",
  ["@@jici_extra"] = "激词",

  ["$jici1"] = "激词慷慨，言辞犀利！",
  ["$jici2"] = "词锋如剑，直指人心！",
}

jici:addEffect(fk.PindianCardsDisplayed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(jici.name) then return false end
    if not data.pindianData or data.pindianData.reason ~= "gushe" then return false end

    -- 检查是否是玩家的拼点牌
    local fromCard = data.pindianData.fromCard
    if not fromCard then return false end

    local who = data.pindianData.from
    if who ~= player then return false end

    local x = player:getHandcardNum()
    local number = fromCard.number

    return number < x or number == x
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jici.name,
      prompt = "#jici-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:getHandcardNum()
    local fromCard = data.pindianData.fromCard
    local number = fromCard.number

    if number < x then
      -- 点数+X
      data.pindianData.fromCard.number = number + x
    elseif number == x then
      -- 发动次数+1
      room:addPlayerMark(player, "@@jici_extra", 1)
    end
  end,
})

-- 增加发动次数
jici:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    return player:getMark("@@jici_extra")
  end,
})

-- 回合结束清除标记
jici:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@jici_extra") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jici_extra", 0)
  end,
})

return jici
