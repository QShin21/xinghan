-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 魏国武将包
local extension = Package:new("xinhan_wei")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/wei/skills")

Fk:loadTranslationTable {
  ["xinhan_wei"] = "星汉灿烂·魏",
}

-- 曹洪，男，魏，4勾玉
General:new(extension, "xh__caohong", "wei", 4):addSkills { "xh__yuanhu" }
Fk:loadTranslationTable {
  ["xh__caohong"] = "曹洪",
  ["#xh__caohong"] = "忠烈护主",
  ["illustrator:xh__caohong"] = "KayaK",
  ["~xh__caohong"] = "将军走好！",
}

-- 曹仁，男，魏，4勾玉
General:new(extension, "xh__caoren", "wei", 4):addSkills { "xh__sujun", "xh__lifeng" }
Fk:loadTranslationTable {
  ["xh__caoren"] = "曹仁",
  ["#xh__caoren"] = "大将军",
  ["illustrator:xh__caoren"] = "KayaK",
  ["~xh__caoren"] = "实在是守不住了……",
}

-- 曹仁(新)，男，魏，4勾玉
General:new(extension, "new__caoren", "wei", 4):addSkills { "xh__weikui", "xh__lizhan" }
Fk:loadTranslationTable {
  ["new__caoren"] = "曹仁",
  ["#new__caoren"] = "大将军",
  ["illustrator:new__caoren"] = "KayaK",
  ["~new__caoren"] = "实在是守不住了……",
}

-- 夏侯惇，男，魏，4勾玉
General:new(extension, "xh__xiahoudun", "wei", 4):addSkills { "xh__ganglie", "xh__qingjian" }
Fk:loadTranslationTable {
  ["xh__xiahoudun"] = "夏侯惇",
  ["#xh__xiahoudun"] = "独眼的罗刹",
  ["illustrator:xh__xiahoudun"] = "KayaK",
  ["~xh__xiahoudun"] = "独目残躯，不惧生死。",
}

-- 许褚，男，魏，4勾玉
General:new(extension, "xh__xuchu", "wei", 4):addSkills { "xh__luoyi" }
Fk:loadTranslationTable {
  ["xh__xuchu"] = "许褚",
  ["#xh__xuchu"] = "虎痴",
  ["illustrator:xh__xuchu"] = "KayaK",
  ["~xh__xuchu"] = "冷……好冷……",
}

-- 张辽，男，魏，4勾玉
General:new(extension, "xh__zhangliao", "wei", 4):addSkills { "xh__tuxi" }
Fk:loadTranslationTable {
  ["xh__zhangliao"] = "张辽",
  ["#xh__zhangliao"] = "前将军",
  ["illustrator:xh__zhangliao"] = "KayaK",
  ["~xh__zhangliao"] = "真的没想到……",
}

-- 荀彧，男，魏，3勾玉
General:new(extension, "xh__xunyu", "wei", 3):addSkills { "xh__quhu", "xh__jieming" }
Fk:loadTranslationTable {
  ["xh__xunyu"] = "荀彧",
  ["#xh__xunyu"] = "王佐之才",
  ["illustrator:xh__xunyu"] = "KayaK",
  ["~xh__xunyu"] = "主公，臣去矣……",
}

-- 郭嘉，男，魏，3勾玉
General:new(extension, "xh__guojia", "wei", 3):addSkills { "mou__tiandu", "xh__yiji" }
Fk:loadTranslationTable {
  ["xh__guojia"] = "郭嘉",
  ["#xh__guojia"] = "早终的先知",
  ["illustrator:xh__guojia"] = "KayaK",
  ["~xh__guojia"] = "咳……咳……",
}

-- 乐进，男，魏，4勾玉
General:new(extension, "xh__lejin", "wei", 4):addSkills { "xh__xiaoguo" }
Fk:loadTranslationTable {
  ["xh__lejin"] = "乐进",
  ["#xh__lejin"] = "奋强突固",
  ["illustrator:xh__lejin"] = "KayaK",
  ["~xh__lejin"] = "力竭……",
}

-- 于禁，男，魏，4勾玉
General:new(extension, "xh__yujin", "wei", 4):addSkills { "xh__zhenjun" }
Fk:loadTranslationTable {
  ["xh__yujin"] = "于禁",
  ["#xh__yujin"] = "弗克其终",
  ["illustrator:xh__yujin"] = "KayaK",
  ["~xh__yujin"] = "将军走好！",
}

-- 李典，男，魏，3勾玉
General:new(extension, "xh__lidian", "wei", 3):addSkills { "xh__xunxun", "xh__wangxi" }
Fk:loadTranslationTable {
  ["xh__lidian"] = "李典",
  ["#xh__lidian"] = "深明大义",
  ["illustrator:xh__lidian"] = "KayaK",
  ["~xh__lidian"] = "报国无门……",
}

-- 曹操，男，魏，4勾玉
General:new(extension, "xh__caocao", "wei", 4):addSkills { "xh__shuzhi" }
Fk:loadTranslationTable {
  ["xh__caocao"] = "曹操",
  ["#xh__caocao"] = "魏武帝",
  ["illustrator:xh__caocao"] = "KayaK",
  ["~xh__caocao"] = "孤……不甘心……",
}

-- 曹昂，男，魏，4勾玉
General:new(extension, "xh__caoang", "wei", 4):addSkills { "xh__kangkai" }
Fk:loadTranslationTable {
  ["xh__caoang"] = "曹昂",
  ["#xh__caoang"] = "丰愍王",
  ["illustrator:xh__caoang"] = "KayaK",
  ["~xh__caoang"] = "父亲……快走……",
}

-- 王朗，男，魏，3勾玉
General:new(extension, "xh__wanglang", "wei", 3):addSkills { "xh__gushe", "xh__jici" }
Fk:loadTranslationTable {
  ["xh__wanglang"] = "王朗",
  ["#xh__wanglang"] = "凤鸣",
  ["illustrator:xh__wanglang"] = "KayaK",
  ["~xh__wanglang"] = "诸葛村夫……",
}

-- 华歆，男，魏，3勾玉
General:new(extension, "xh__huaxin", "wei", 3):addSkills { "xh__wanggui", "xh__xibing" }
Fk:loadTranslationTable {
  ["xh__huaxin"] = "华歆",
  ["#xh__huaxin"] = "一龙",
  ["illustrator:xh__huaxin"] = "KayaK",
  ["~xh__huaxin"] = "管宁……",
}

-- 关羽(魏)，男，魏，4勾玉
General:new(extension, "xh__guanyu_wei", "wei", 4):addSkills { "xh__wusheng", "xh__danqi" }
Fk:loadTranslationTable {
  ["xh__guanyu_wei"] = "关羽",
  ["#xh__guanyu_wei"] = "武圣",
  ["illustrator:xh__guanyu_wei"] = "KayaK",
  ["~xh__guanyu_wei"] = "什么？此地竟有……",
}

-- 荀攸，男，魏，3勾玉
General:new(extension, "xh__xunyou", "wei", 3):addSkills { "xh__qice", "xh__zhiyu" }
Fk:loadTranslationTable {
  ["xh__xunyou"] = "荀攸",
  ["#xh__xunyou"] = "谋主",
  ["illustrator:xh__xunyou"] = "KayaK",
  ["~xh__xunyou"] = "主公……",
}

-- 典韦，男，魏，4勾玉
General:new(extension, "xh__dianwei", "wei", 4):addSkills { "xh__qiangxi", "xh__ninge" }
Fk:loadTranslationTable {
  ["xh__dianwei"] = "典韦",
  ["#xh__dianwei"] = "古之恶来",
  ["illustrator:xh__dianwei"] = "KayaK",
  ["~xh__dianwei"] = "主公……快走……",
}

return extension
