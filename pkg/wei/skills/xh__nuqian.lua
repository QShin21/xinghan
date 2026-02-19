-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关羽(魏) - 怒斩技能
-- 锁定技，你使用锦囊牌转化的【杀】无次数限制；
-- 你使用装备牌转化的【杀】造成的伤害+1。

local nuqian = fk.CreateSkill {
  name = "xh__nuqian",
}

Fk:loadTranslationTable {
  ["xh__nuqian"] = "怒斩",
  [":xh__nuqian"] = "锁定技，你使用锦囊牌转化的【杀】无次数限制；"..
    "你使用装备牌转化的【杀】造成的伤害+1。",

  ["$xh__nuqian1"] = "怒斩敌首，威震华夏！",
  ["$xh__nuqian2"] = "青龙偃月，所向披靡！",
}

-- 锦囊牌转化的杀无次数限制
nuqian:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if not player:hasSkill(nuqian.name) then return 0 end
    if skill.trueName ~= "slash_skill" then return 0 end

    -- 检查是否为锦囊牌转化
    if card and card:isVirtual() then
      for _, subcard in ipairs(card.subcards) do
        if Fk:getCardById(subcard).type == Card.TypeTrick then
          return 999
        end
      end
    end

    return 0
  end,
})

-- 装备牌转化的杀伤害+1
nuqian:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(nuqian.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end

    -- 检查是否为装备牌转化
    if data.card:isVirtual() then
      for _, subcard in ipairs(data.card.subcards) do
        if Fk:getCardById(subcard).type == Card.TypeEquip then
          return true
        end
      end
    end

    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return nuqian
