local juguan = fk.CreateSkill{
  name = "xh__juguan",
}

Fk:loadTranslationTable{
  ["xh__juguan"] = "拒关",
  [":xh__juguan"] = "出牌阶段限一次，你可以将一张手牌当【杀】或【决斗】使用。若受到此牌伤害的角色未在你的下回合开始前对你造成过伤害，"..
  "你的下个摸牌阶段摸牌数+2。",

  ["#xh__juguan"] = "拒关：将一张手牌当【杀】或【决斗】使用",
  ["@@xh__juguan"] = "拒关",

  ["$xh__juguan1"] = "吾欲自立，举兵拒关。",
  ["$xh__juguan2"] = "自立门户，拒关不开。",
}

-- 视为使用【杀】或【决斗】不计入次数
juguan:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#xh__juguan",
  interaction = UI.CardNameBox {choices = {"slash", "duel"}},
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|^equip",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = juguan.name
    c:addSubcard(cards[1])
    return c
  end,
  after_use = function(self, player, use)
    if player.dead or not use.damageDealt then return end
    local room = player.room
    local mark = {}
    for _, p in ipairs(room.players) do
      if use.damageDealt[p] then
        table.insertIfNeed(mark, p.id)
      end
    end
    room:setPlayerMark(player, "@@xh__juguan", mark)  -- 标记谁被该牌伤害
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(juguan.name, Player.HistoryPhase) == 0
  end,
})

-- 伤害判定，处理标记，记录伤害来源
juguan:addEffect(fk.Damaged, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@xh__juguan") ~= 0 and
      data.from and table.contains(player:getMark("@@xh__juguan"), data.from.id)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removeTableMark(player, "@@xh__juguan", data.from.id)  -- 清除标记
  end,
})

-- 触发条件：当受到伤害的角色没有对你造成过伤害时，下个摸牌阶段摸牌数+2
juguan:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@xh__juguan") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xh__juguan", 0)  -- 重置标记
    player.room:addPlayerMark(player, "xh__juguan_draw", 1)  -- 准备增加摸牌数
  end,
})

-- 增加摸牌数
juguan:addEffect(fk.DrawNCards, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("xh__juguan_draw") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.n = data.n + 2 * player:getMark("xh__juguan_draw")  -- 摸牌数 +2
    player.room:setPlayerMark(player, "xh__juguan_draw", 0)  -- 清除标记
  end,
})

return juguan