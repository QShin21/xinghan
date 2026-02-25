-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 励战武将包
local extension = Package:new("xinhan_lizhan")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/lizhan/skills")

Fk:loadTranslationTable {
  ["xinhan_lizhan"] = "星汉灿烂·励战",
}



-- 曹操，男，魏，4勾玉
General:new(extension, "xh__caocao", "wei", 4):addSkills { "xh__shuzhi" }
Fk:loadTranslationTable {
  ["xh__caocao"] = "曹操",
  ["#xh__caocao"] = "魏武帝",
  ["illustrator:xh__caocao"] = "KayaK",
  ["~xh__caocao"] = "孤……不甘心……",
}

-- 曹仁，男，魏，4勾玉
General:new(extension, "xhsp__caoren", "wei", 4):addSkills { "xh__weikui", "xh__lizhan" }
Fk:loadTranslationTable {
  ["xhsp__caoren"] = "曹仁",
  ["#xhsp__caoren"] = "大将军",
  ["illustrator:xhsp__caoren"] = "KayaK",
  ["~xhsp__caoren"] = "实在是守不住了……",
}

-- 曹昂，男，魏，4勾玉
General:new(extension, "xh__caoang", "wei", 4):addSkills { "kangkai" }
Fk:loadTranslationTable {
  ["xh__caoang"] = "曹昂",
  ["#xh__caoang"] = "丰愍王",
  ["illustrator:xh__caoang"] = "KayaK",
  ["~xh__caoang"] = "父亲……快走……",
}

-- 王朗，男，魏，3勾玉
General:new(extension, "xh__wanglang", "wei", 3):addSkills { "gushe", "jici" }
Fk:loadTranslationTable {
  ["xh__wanglang"] = "王朗",
  ["#xh__wanglang"] = "凤鸣",
  ["illustrator:xh__wanglang"] = "KayaK",
  ["~xh__wanglang"] = "诸葛村夫……",
}

-- 华歆，男，魏，3勾玉
General:new(extension, "xh__huaxin", "wei", 3):addSkills { "wanggui", "xibing" }
Fk:loadTranslationTable {
  ["xh__huaxin"] = "华歆",
  ["#xh__huaxin"] = "一龙",
  ["illustrator:xh__huaxin"] = "KayaK",
  ["~xh__huaxin"] = "管宁……",
}

-- 关羽(魏)，男，魏，4勾玉
General:new(extension, "xhsp__guanyu", "wei", 4):addSkills { "xh__wusheng", "xh__danqi" }
Fk:loadTranslationTable {
  ["xhsp__guanyu"] = "关羽",
  ["#xhsp__guanyu"] = "武圣",
  ["illustrator:xhsp__guanyu"] = "KayaK",
  ["~xhsp__guanyu"] = "什么？此地竟有……",
}

-- 荀攸，男，魏，3勾玉
General:new(extension, "xh__xunyou", "wei", 3):addSkills { "qice", "ty_ex__zhiyu" }
Fk:loadTranslationTable {
  ["xh__xunyou"] = "荀攸",
  ["#xh__xunyou"] = "谋主",
  ["illustrator:xh__xunyou"] = "KayaK",
  ["~xh__xunyou"] = "主公……",
}

-- 典韦，男，魏，4勾玉
General:new(extension, "xh__dianwei", "wei", 4):addSkills { "qiangxi", "ninge" }
Fk:loadTranslationTable {
  ["xh__dianwei"] = "典韦",
  ["#xh__dianwei"] = "古之恶来",
  ["illustrator:xh__dianwei"] = "KayaK",
  ["~xh__dianwei"] = "主公……快走……",
}



-- 以下为吴国武将


-- 孙坚sp，男，吴，4/5勾玉
General:new(extension, "xhsp__sunjian", "wu", 4, 5):addSkills { "xh__hulie" }
Fk:loadTranslationTable {
  ["xhsp__sunjian"] = "孙坚",
  ["#xhsp__sunjian"] = "江东猛虎",
  ["illustrator:xhsp__sunjian"] = "KayaK",
  ["~xhsp__sunjian"] = "有埋伏……呃……",
}

-- 孙策(吴)，男，吴，4勾玉
General:new(extension, "xh__sunce", "wu", 4):addSkills { "xh__jiang", "xh__hunzi" }
Fk:loadTranslationTable {
  ["xh__sunce"] = "孙策",
  ["#xh__sunce"] = "江东小霸王",
  ["illustrator:xh__sunce"] = "KayaK",
  ["~xh__sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

-- 周瑜，男，吴，3勾玉
General:new(extension, "xh__zhouyu", "wu", 3):addSkills { "xh__yingzi", "xh__fanjian" }
Fk:loadTranslationTable {
  ["xh__zhouyu"] = "周瑜",
  ["#xh__zhouyu"] = "大都督",
  ["illustrator:xh__zhouyu"] = "KayaK",
  ["~xh__zhouyu"] = "既生瑜，何生亮……",
}

-- 庞统，男，吴，3勾玉
General:new(extension, "xh__pangtong", "wu", 3):addSkills { "xh__guolun", "xh__zhanji" }
Fk:loadTranslationTable {
  ["xh__pangtong"] = "庞统",
  ["#xh__pangtong"] = "凤雏",
  ["illustrator:xh__pangtong"] = "KayaK",
  ["~xh__pangtong"] = "落凤坡……",
}


return extension
