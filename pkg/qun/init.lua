-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 群雄武将包
local extension = Package:new("xinhan_qun")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/qun/skills")

Fk:loadTranslationTable {
  ["xinhan_qun"] = "星汉灿烂·群",
}

-- 贾诩，男，群，3勾玉
General:new(extension, "jiaxu", "qun", 3):addSkills { "wansha", "luanwu", "weimu" }
Fk:loadTranslationTable {
  ["jiaxu"] = "贾诩",
  ["#jiaxu"] = "冷酷的毒士",
  ["illustrator:jiaxu"] = "KayaK",
  ["~jiaxu"] = "我的时辰……到了……",
}

-- 吕布，男，群，5勾玉
General:new(extension, "lvbu", "qun", 5):addSkills { "wushuang", "liyu" }
Fk:loadTranslationTable {
  ["lvbu"] = "吕布",
  ["#lvbu"] = "武的化身",
  ["illustrator:lvbu"] = "KayaK",
  ["~lvbu"] = "不可能！",
}

-- 貂蝉，女，群，3勾玉
General:new(extension, "diaochan", "qun", 3, 3, General.Female):addSkills { "biyue" }
Fk:loadTranslationTable {
  ["diaochan"] = "貂蝉",
  ["#diaochan"] = "绝世的舞姬",
  ["illustrator:diaochan"] = "KayaK",
  ["~diaochan"] = "父亲大人，对不起……",
}

-- 董卓，男，群，4勾玉
General:new(extension, "dongzhuo", "qun", 4):addSkills { "jiuchi", "hengzheng" }
Fk:loadTranslationTable {
  ["dongzhuo"] = "董卓",
  ["#dongzhuo"] = "魔王",
  ["illustrator:dongzhuo"] = "KayaK",
  ["~dongzhuo"] = "汉室……亡了……",
}

-- 袁绍，男，群，4勾玉
General:new(extension, "yuanshao", "qun", 4):addSkills { "luanji" }
Fk:loadTranslationTable {
  ["yuanshao"] = "袁绍",
  ["#yuanshao"] = "高贵的名门",
  ["illustrator:yuanshao"] = "KayaK",
  ["~yuanshao"] = "老天不公啊！",
}

-- 田丰，男，群，3勾玉
General:new(extension, "tianfeng", "qun", 3):addSkills { "sijian", "suishi" }
Fk:loadTranslationTable {
  ["tianfeng"] = "田丰",
  ["#tianfeng"] = "河北谋士",
  ["illustrator:tianfeng"] = "KayaK",
  ["~tianfeng"] = "吾命休矣……",
}

-- 马腾，男，群，4勾玉
General:new(extension, "mateng", "qun", 4):addSkills { "mashu", "xiongyi" }
Fk:loadTranslationTable {
  ["mateng"] = "马腾",
  ["#mateng"] = "西凉太守",
  ["illustrator:mateng"] = "KayaK",
  ["~mateng"] = "西凉……完了……",
}

-- 李儒，男，群，3勾玉
General:new(extension, "liru", "qun", 3):addSkills { "mieji", "juece", "fengcheng" }
Fk:loadTranslationTable {
  ["liru"] = "李儒",
  ["#liru"] = "魔士",
  ["illustrator:liru"] = "KayaK",
  ["~liru"] = "主公……",
}

-- 高顺，男，群，4勾玉
General:new(extension, "gaoshun", "qun", 4):addSkills { "xianzhen", "jinjiu" }
Fk:loadTranslationTable {
  ["gaoshun"] = "高顺",
  ["#gaoshun"] = "陷阵营主",
  ["illustrator:gaoshun"] = "KayaK",
  ["~gaoshun"] = "陷阵……败了……",
}

-- 孙策(群)，男，群，4勾玉
General:new(extension, "sunce_qun", "qun", 4):addSkills { "liantao" }
Fk:loadTranslationTable {
  ["sunce_qun"] = "孙策",
  ["#sunce_qun"] = "江东小霸王",
  ["illustrator:sunce_qun"] = "KayaK",
  ["~sunce_qun"] = "大业未成……",
}

-- 刘表，男，群，3勾玉
General:new(extension, "liubiao", "qun", 3):addSkills { "zishou", "zongshi" }
Fk:loadTranslationTable {
  ["liubiao"] = "刘表",
  ["#liubiao"] = "荆州牧",
  ["illustrator:liubiao"] = "KayaK",
  ["~liubiao"] = "荆州……",
}

-- 杨彪，男，群，3勾玉
General:new(extension, "yangbiao", "qun", 3):addSkills { "zhaohan", "rangjie" }
Fk:loadTranslationTable {
  ["yangbiao"] = "杨彪",
  ["#yangbiao"] = "汉室忠臣",
  ["illustrator:yangbiao"] = "KayaK",
  ["~yangbiao"] = "汉室……",
}

-- 张角，男，群，3勾玉
General:new(extension, "zhangjiao", "qun", 3):addSkills { "leiji", "guidao" }
Fk:loadTranslationTable {
  ["zhangjiao"] = "张角",
  ["#zhangjiao"] = "天公将军",
  ["illustrator:zhangjiao"] = "KayaK",
  ["~zhangjiao"] = "黄天……",
}

-- 于吉，男，群，3勾玉
General:new(extension, "yuji", "qun", 3):addSkills { "guhuo" }
Fk:loadTranslationTable {
  ["yuji"] = "于吉",
  ["#yuji"] = "太平道人",
  ["illustrator:yuji"] = "KayaK",
  ["~yuji"] = "蛊惑……",
}

-- 李傕，男，群，4勾玉
General:new(extension, "lijue", "qun", 4):addSkills { "langxi", "yisuan" }
Fk:loadTranslationTable {
  ["lijue"] = "李傕",
  ["#lijue"] = "狼子野心",
  ["illustrator:lijue"] = "KayaK",
  ["~lijue"] = "西凉……",
}

-- 郭汜，男，群，4勾玉
General:new(extension, "guosi", "qun", 4):addSkills { "tanbei", "sidao" }
Fk:loadTranslationTable {
  ["guosi"] = "郭汜",
  ["#guosi"] = "贪婪之徒",
  ["illustrator:guosi"] = "KayaK",
  ["~guosi"] = "西凉……",
}

-- 王允，男，群，3勾玉
General:new(extension, "wangyun", "qun", 3):addSkills { "jiexuan", "zhongliu" }
Fk:loadTranslationTable {
  ["wangyun"] = "王允",
  ["#wangyun"] = "连环计主",
  ["illustrator:wangyun"] = "KayaK",
  ["~wangyun"] = "汉室……",
}

-- 张济，男，群，4勾玉
General:new(extension, "zhangji_qun", "qun", 4):addSkills { "lueling", "tunjun" }
Fk:loadTranslationTable {
  ["zhangji_qun"] = "张济",
  ["#zhangji_qun"] = "西凉军阀",
  ["illustrator:zhangji_qun"] = "KayaK",
  ["~zhangji_qun"] = "西凉……",
}

-- 徐荣，男，群，4勾玉
General:new(extension, "xurong", "qun", 4):addSkills { "xionghuo" }
Fk:loadTranslationTable {
  ["xurong"] = "徐荣",
  ["#xurong"] = "凶镬之将",
  ["illustrator:xurong"] = "KayaK",
  ["~xurong"] = "西凉……",
}

-- 公孙瓒，男，群，4勾玉
General:new(extension, "gongsunzan", "qun", 4):addSkills { "qiaomeng", "yicong" }
Fk:loadTranslationTable {
  ["gongsunzan"] = "公孙瓒",
  ["#gongsunzan"] = "白马将军",
  ["illustrator:gongsunzan"] = "KayaK",
  ["~gongsunzan"] = "白马……",
}

-- 韩遂，男，群，4勾玉
General:new(extension, "hansui", "qun", 4):addSkills { "niluan", "xiaoxi" }
Fk:loadTranslationTable {
  ["hansui"] = "韩遂",
  ["#hansui"] = "西凉军阀",
  ["illustrator:hansui"] = "KayaK",
  ["~hansui"] = "西凉……",
}

-- 鲍信，男，群，4勾玉
General:new(extension, "baoxin", "qun", 4):addSkills { "mutao", "yimou" }
Fk:loadTranslationTable {
  ["baoxin"] = "鲍信",
  ["#baoxin"] = "义兵首领",
  ["illustrator:baoxin"] = "KayaK",
  ["~baoxin"] = "义兵……",
}

-- 孔融，男，群，3勾玉
General:new(extension, "kongrong", "qun", 3):addSkills { "mingshi", "lirang" }
Fk:loadTranslationTable {
  ["kongrong"] = "孔融",
  ["#kongrong"] = "名士",
  ["illustrator:kongrong"] = "KayaK",
  ["~kongrong"] = "名士……",
}

return extension

-- 华雄，男，群，4勾玉
General:new(extension, "huaxiong", "qun", 4):addSkills { "yaowu", "yangwei" }
Fk:loadTranslationTable {
  ["huaxiong"] = "华雄",
  ["#huaxiong"] = "西凉猛将",
  ["illustrator:huaxiong"] = "KayaK",
  ["~huaxiong"] = "西凉……",
}

-- 袁术，男，群，4勾玉
General:new(extension, "yuanshu", "qun", 4):addSkills { "yongsi" }
Fk:loadTranslationTable {
  ["yuanshu"] = "袁术",
  ["#yuanshu"] = "仲家",
  ["illustrator:yuanshu"] = "KayaK",
  ["~yuanshu"] = "仲家……",
}

-- 潘凤，男，群，4勾玉
General:new(extension, "panfeng", "qun", 4):addSkills { "kuangfu" }
Fk:loadTranslationTable {
  ["panfeng"] = "潘凤",
  ["#panfeng"] = "无双上将",
  ["illustrator:panfeng"] = "KayaK",
  ["~panfeng"] = "上将……",
}

-- 纪灵，男，群，4勾玉
General:new(extension, "jiling", "qun", 4):addSkills { "shuangren" }
Fk:loadTranslationTable {
  ["jiling"] = "纪灵",
  ["#jiling"] = "山东名将",
  ["illustrator:jiling"] = "KayaK",
  ["~jiling"] = "山东……",
}

-- 颜良文丑，男，群，4勾玉
General:new(extension, "yanliangwenchou", "qun", 4):addSkills { "shuangxiong" }
Fk:loadTranslationTable {
  ["yanliangwenchou"] = "颜良文丑",
  ["#yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:yanliangwenchou"] = "KayaK",
  ["~yanliangwenchou"] = "河北……",
}

-- 牛辅，男，群，4/5勾玉
local niufu = General:new(extension, "niufu", "qun", 4, 5)
niufu:addSkills { "xiaoxiong", "xiongrao" }
Fk:loadTranslationTable {
  ["niufu"] = "牛辅",
  ["#niufu"] = "西凉女婿",
  ["illustrator:niufu"] = "KayaK",
  ["~niufu"] = "西凉……",
}

-- 刘备(群)，男，群，4勾玉
General:new(extension, "liubei_qun", "qun", 4):addSkills { "jishan", "zhenqia" }
Fk:loadTranslationTable {
  ["liubei_qun"] = "刘备",
  ["#liubei_qun"] = "乱世枭雄",
  ["illustrator:liubei_qun"] = "KayaK",
  ["~liubei_qun"] = "乱世……",
}

-- 武安国，男，群，4勾玉
General:new(extension, "wuananguo", "qun", 4):addSkills { "liyong" }
Fk:loadTranslationTable {
  ["wuananguo"] = "武安国",
  ["#wuananguo"] = "断腕猛将",
  ["illustrator:wuananguo"] = "KayaK",
  ["~wuananguo"] = "北海……",
}

-- 杨奉，男，群，4勾玉
General:new(extension, "yangfeng", "qun", 4):addSkills { "xuetu" }
Fk:loadTranslationTable {
  ["yangfeng"] = "杨奉",
  ["#yangfeng"] = "白波军帅",
  ["illustrator:yangfeng"] = "KayaK",
  ["~yangfeng"] = "白波……",
}

-- 张燕，男，群，4勾玉
General:new(extension, "zhangyan", "qun", 4):addSkills { "suji", "langdao" }
Fk:loadTranslationTable {
  ["zhangyan"] = "张燕",
  ["#zhangyan"] = "黑山军帅",
  ["illustrator:zhangyan"] = "KayaK",
  ["~zhangyan"] = "黑山……",
}

-- 梁兴，男，群，4勾玉
General:new(extension, "liangxing", "qun", 4):addSkills { "lulve" }
Fk:loadTranslationTable {
  ["liangxing"] = "梁兴",
  ["#liangxing"] = "西凉悍将",
  ["illustrator:liangxing"] = "KayaK",
  ["~liangxing"] = "西凉……",
}

-- 黄祖，男，群，4勾玉
General:new(extension, "huangzu", "qun", 4):addSkills { "xishe" }
Fk:loadTranslationTable {
  ["huangzu"] = "黄祖",
  ["#huangzu"] = "江夏太守",
  ["illustrator:huangzu"] = "KayaK",
  ["~huangzu"] = "江夏……",
}

-- 沮授，男，群，3勾玉
General:new(extension, "jushou", "qun", 3):addSkills { "jianying", "shibei" }
Fk:loadTranslationTable {
  ["jushou"] = "沮授",
  ["#jushou"] = "河北谋士",
  ["illustrator:jushou"] = "KayaK",
  ["~jushou"] = "河北……",
}

-- 张绣，男，群，4勾玉
General:new(extension, "zhangxiu", "qun", 4):addSkills { "fudi", "congjian" }
Fk:loadTranslationTable {
  ["zhangxiu"] = "张绣",
  ["#zhangxiu"] = "宛城侯",
  ["illustrator:zhangxiu"] = "KayaK",
  ["~zhangxiu"] = "宛城……",
}

-- 刘繇，男，群，4勾玉
General:new(extension, "liuyao", "qun", 4):addSkills { "kannan" }
Fk:loadTranslationTable {
  ["liuyao"] = "刘繇",
  ["#liuyao"] = "扬州刺史",
  ["illustrator:liuyao"] = "KayaK",
  ["~liuyao"] = "扬州……",
}

-- 邹氏，女，群，3勾玉
General:new(extension, "zoushi", "qun", 3, 3, General.Female):addSkills { "huoshui", "qingcheng" }
Fk:loadTranslationTable {
  ["zoushi"] = "邹氏",
  ["#zoushi"] = "祸水红颜",
  ["illustrator:zoushi"] = "KayaK",
  ["~zoushi"] = "祸水……",
}

-- 许攸，男，群，3勾玉
General:new(extension, "xuyou", "qun", 3):addSkills { "chenglue", "shicai" }
Fk:loadTranslationTable {
  ["xuyou"] = "许攸",
  ["#xuyou"] = "恃才傲物",
  ["illustrator:xuyou"] = "KayaK",
  ["~xuyou"] = "恃才……",
}

-- 刘协，男，群，3勾玉
General:new(extension, "liuxie", "qun", 3):addSkills { "tianming", "mizhao" }
Fk:loadTranslationTable {
  ["liuxie"] = "刘协",
  ["#liuxie"] = "汉献帝",
  ["illustrator:liuxie"] = "KayaK",
  ["~liuxie"] = "汉室……",
}

-- 士燮，男，群，3勾玉
General:new(extension, "shixie", "qun", 3):addSkills { "biluan", "lixia" }
Fk:loadTranslationTable {
  ["shixie"] = "士燮",
  ["#shixie"] = "交州牧",
  ["illustrator:shixie"] = "KayaK",
  ["~shixie"] = "交州……",
}

-- 陶谦，男，群，3勾玉
General:new(extension, "taoqian", "qun", 3):addSkills { "yixiang" }
Fk:loadTranslationTable {
  ["taoqian"] = "陶谦",
  ["#taoqian"] = "徐州牧",
  ["illustrator:taoqian"] = "KayaK",
  ["~taoqian"] = "徐州……",
}

-- 张鲁，男，群，3勾玉
General:new(extension, "zhanglu", "qun", 3):addSkills { "yishe", "bushi" }
Fk:loadTranslationTable {
  ["zhanglu"] = "张鲁",
  ["#zhanglu"] = "汉中太守",
  ["illustrator:zhanglu"] = "KayaK",
  ["~zhanglu"] = "汉中……",
}
