-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华雄 - 耀武技能
-- 锁定技，当你受到【杀】造成的伤害时，若此【杀】：为红色，伤害来源选择回复1点体力或摸一张牌；不为红色，则你摸一张牌。

local yaowu = fk.CreateSkill {
  name = "yaowu",
}

Fk:loadTranslationTable {
  ["yaowu"] = "耀武",
  [":yaowu"] = "锁定技，当你受到【杀】造成的伤害时，若此【杀】：为红色，伤害来源选择回复1点体力或摸一张牌；不为红色，则你摸一张牌。",

  ["yaowu_recover"] = "回复1点体力",
  ["yaowu_draw"] = "摸一张牌",

  ["$yaowu1"] = "耀武扬威，谁敢争锋！",
  ["$yaowu2"] = "西凉华雄，天下无双！",
}

yaowu:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yaowu.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    
    if card.color == Card.Red then
      -- 红色杀：伤害来源选择回复或摸牌
      if data.from then
        local choice = room:askToChoice(data.from, {
          choices = {"yaowu_recover", "yaowu_draw"},
          skill_name = yaowu.name,
          prompt = "选择一项",
          detailed = false,
        })
        
        if choice == "yaowu_recover" then
          room:recover{
            who = data.from,
            num = 1,
            recoverBy = data.from,
            skillName = yaowu.name,
          }
        else
          data.from:drawCards(1, yaowu.name)
        end
      end
    else
      -- 非红色杀：你摸一张牌
      player:drawCards(1, yaowu.name)
    end
  end,
})

return yaowu
