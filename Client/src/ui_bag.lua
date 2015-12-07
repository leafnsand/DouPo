UIBag={}
local scrollView =nil 
local listItem = nil 
local btnItem =nil 
local bagFlag = nil
local sellFlag = nil  -- 出售标志位
local expandNum  = nil
local ExpandPrice = nil

local function compareThing(value1,value2)
--  if DictThing[tostring(value1.int["3"])].isUse == 0 and DictThing[tostring(value2.int["3"])].isUse ~= 0 then
  if DictThing[tostring(value1.int["3"])].indexOrder >  DictThing[tostring(value2.int["3"])].indexOrder then
    return true
  else
    return false
  end 
end

local function compare(value1,value2)
    return value1.int["8"] > value2.int["8"]
end
local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.bagExpand then
    UIManager.showToast("扩充成功")
  end
  UIManager.flushWidget(UITeamInfo)
  UIManager.flushWidget(UIBag)
end

local function ExpandCallBack()
    if ExpandPrice <= net.InstPlayer.int["5"] then
        if bagFlag == 1 then
            utils.sendExpandData(StaticBag_Type.item,netCallbackFunc)
        elseif bagFlag ==2 then 
            utils.sendExpandData(StaticBag_Type.core,netCallbackFunc)
        end
    else
         UIManager.showToast("元宝不够！")
    end
end

local function setScrollViewItem(flag,_Item, _obj)
    local image_frame_gem = _Item:getChildByName("image_frame_gem")
    local image_price = _Item:getChildByName("image_price")
    local price_text = image_price:getChildByName("text_price")
    local image = image_frame_gem:getChildByName("image_gem")
    local num = _Item:getChildByName("text_number")
    local name = _Item:getChildByName("text_gem_name")
    local description = ccui.Helper:seekNodeByName(_Item,"text_gem_describe")
    local btn_lineup = _Item:getChildByName("btn_lineup")
    local btn_change = _Item:getChildByName("btn_change")
    btn_lineup:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    local tableFieldId = _obj.int["3"]
    local name_text=DictThing[tostring(tableFieldId)].name
    local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
    local smallImage= DictUI[tostring(smallUiId)].fileName
    local description_text =DictThing[tostring(tableFieldId)].description
    local num_text = _obj.int["5"]
    if tableFieldId == StaticThing.goldBox then
      num_text = num_text + _obj.int["4"]
    end
    local price = DictThing[tostring(tableFieldId)].sellCopper
    price_text:setString(string.format("×%d",price))
    if sellFlag then
        image_price:setVisible(true)
    else
        image_price:setVisible(false)
    end
    local qualityId = utils.addBorderImage(StaticTableType.DictThing,tableFieldId,image_frame_gem)
    utils.changeNameColor(name,qualityId)
    name:setString(name_text)
    num:setString(string.format("数量：%d",num_text))
    image:loadTexture("image/" .. smallImage)
    if description_text ~= nil then 
      description:setString(description_text)
    end
    local function btnUseFunc(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local _dictThingId = _obj.int["3"]
            if _dictThingId == StaticThing.goldBox
                    or _dictThingId == StaticThing.silverBox
                    or _dictThingId == StaticThing.copperBox
                    or _dictThingId == StaticThing.goldKey
                    or _dictThingId == StaticThing.silverKey
                    or _dictThingId == StaticThing.copperKey
                    or (StaticThing.lihezuixiazhi <= _dictThingId and _dictThingId <= StaticThing.lihezuidazhi) then
                UIBoxUse.setData(_obj)
                UIManager.pushScene("ui_box_use")
            else
                -----背包使用-----------
                UISellProp.setData(_obj,"UIBagUse")
                UIManager.pushScene("ui_sell_prop")
            end
        end
    end
    local function btnSellFunc(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
              UISellProp.setData(_obj,UIBag)
              UIManager.pushScene("ui_sell_prop")
        end
    end
    if flag == 1 then --道具
        btn_change:setVisible(false)
        if sellFlag then 
            btn_lineup:setVisible(true)
            btn_lineup:setTitleText("出售")
            btn_lineup:addTouchEventListener(btnSellFunc)
        else
            if tonumber(DictThing[tostring(tableFieldId)].isUse) == 0 then 
                btn_lineup:setVisible(false)
            else
                btn_lineup:setVisible(true)
                btn_lineup:setTitleText("使用")
            end
            btn_lineup:addTouchEventListener(btnUseFunc)
        end
    elseif flag == 2 then  -- 魔核
        local function btnEvent(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                sender:retain()
                if sender == btn_change then 
                  UIGemSwitch.setData(_obj,UIBag)
                  UIManager.pushScene("ui_gem_switch")
                elseif sender == btn_lineup then 
                  UIGemUpGrade.setData(_obj,UIBag)
                  UIManager.pushScene("ui_gem_upgrade")
                end
                cc.release(sender)
            end
        end
        btn_change:addTouchEventListener(btnEvent)
        if sellFlag then
             btn_lineup:setVisible(true)
             btn_change:setVisible(false)
             btn_lineup:setTitleText("出售")  
             btn_lineup:addTouchEventListener(btnSellFunc)
        else
             btn_lineup:setVisible(true)
             btn_change:setVisible(true)
             btn_lineup:setTitleText("升级")
             btn_lineup:addTouchEventListener(btnEvent)
        end
    end
end

local function selectedBtnChange(flag) 
    local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget,"btn_prop")
    local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget,"btn_gem")
    if flag == 1 then 
        btn_gem:loadTextureNormal("ui/yh_btn01.png")
        btn_gem:getChildByName("text_gem"):setTextColor(cc.c4b(255,255,255,255))
        btn_prop:loadTextureNormal("ui/yh_btn02.png")
        btn_prop:getChildByName("text_prop"):setTextColor(cc.c4b(51,25,4,255))
    elseif  flag ==  2 then
        btn_prop:loadTextureNormal("ui/yh_btn01.png")
        btn_prop:getChildByName("text_prop"):setTextColor(cc.c4b(255,255,255,255))
        btn_gem:loadTextureNormal("ui/yh_btn02.png")
        btn_gem:getChildByName("text_gem"):setTextColor(cc.c4b(51,25,4,255))
    end
end

function UIBag.init()
    local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_prop") --道具按钮
    local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_gem") -- 魔核按钮
    local btn_expansion = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_expansion") -- 扩充按钮
    local btn_sell = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_sell") -- 出售按钮
    btn_prop:setPressedActionEnabled(true)
    btn_gem:setPressedActionEnabled(true)
    btn_expansion:setPressedActionEnabled(true)
    btn_sell:setPressedActionEnabled(true)

    local function btnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_prop then 
              if bagFlag == 1 then
                  return
              end
              bagFlag = 1
              UIBag.setup()
            elseif sender == btn_gem then 
              if bagFlag == 2 then 
                  return
              end
              bagFlag = 2
              UIBag.setup()
            elseif sender == btn_expansion then 
              local hint=""
              if expandNum == nil then 
                expandNum = 0
              end
              ExpandPrice = DictSysConfig[tostring(StaticSysConfig.expandInitGold)].value + expandNum*DictSysConfig[tostring(StaticSysConfig.bagExpandGoldGrow)].value
              if bagFlag ==1 then 
                  hint= "购买5个道具背包上限，需要花费" .. ExpandPrice .. "个元宝"
              else
                  hint = "购买5个魔核背包上限，需要花费" .. ExpandPrice .. "个元宝"
              end
              utils.PromptDialog(ExpandCallBack,hint)
            elseif sender == btn_sell then 
              if sellFlag == false then 
                btn_prop:setVisible(false)
                btn_gem:setVisible(false)
                btn_expansion:setVisible(false)
                btn_sell:loadTextureNormal("ui/fh_btn.png")
                btn_sell:loadTexturePressed("ui/fh_btn.png")
                btn_sell:setScaleX(0.9)
                btn_sell:setScaleY(0.8)
                sellFlag =true
              else
                sellFlag =false
                btn_prop:setVisible(true)
                btn_gem:setVisible(true)
                btn_expansion:setVisible(true)
                btn_sell:setScale(1)
                btn_sell:loadTextureNormal("ui/chushou_btn.png")
                btn_sell:loadTexturePressed("ui/chushou_btn.png")
              end
              UIBag.setup()
            end
        end
    end
    btn_prop:addTouchEventListener(btnEvent)
    btn_gem:addTouchEventListener(btnEvent)
    btn_expansion:addTouchEventListener(btnEvent)
    btn_sell:addTouchEventListener(btnEvent)
    scrollView = ccui.Helper:seekNodeByName(UIBag.Widget, "view_list_gem") --  滚动层
    listItem = scrollView:getChildByName("image_base_gem"):clone()
    btnItem = scrollView:getChildByName("btn_buy"):clone()
end

function UIBag.setup()
    if sellFlag == nil then 
      sellFlag =false
      local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_prop") --道具按钮
      local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_gem") -- 魔核按钮
      local btn_expansion = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_expansion") -- 扩充按钮
      local btn_sell = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_sell") -- 出售按钮
      btn_prop:setVisible(true)
      btn_gem:setVisible(true)
      btn_expansion:setVisible(true)
      btn_sell:setScale(1)
      btn_sell:loadTextureNormal("ui/chushou_btn.png")
      btn_sell:loadTexturePressed("ui/chushou_btn.png")
    end
    local grid = 0
    if listItem:getReferenceCount() == 1 then 
        listItem:retain()
    end
    if btnItem:getReferenceCount() == 1 then 
        btnItem:retain()
    end
    if net.InstPlayerBagExpand then 
        for key,obj in pairs(net.InstPlayerBagExpand) do
            if obj.int["3"] == StaticBag_Type.item and bagFlag == 1 then 
                grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                expandNum = obj.int["6"]
            end
            if obj.int["3"] == StaticBag_Type.core and bagFlag == 2 then
                grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                expandNum = obj.int["6"]
            end
        end
    end
    if bagFlag == 1 and grid == 0 then 
        grid = DictBagType[tostring(StaticBag_Type.item)].bagUpLimit
    elseif bagFlag == 2 and grid == 0 then 
        grid = DictBagType[tostring(StaticBag_Type.core)].bagUpLimit
    end
    local text_ceiling =  ccui.Helper:seekNodeByName(UIBag.Widget, "text_ceiling")
    scrollView:removeAllChildren()
    local BagThing={}
    if net.InstPlayerThing then 
        if bagFlag == 1 then 
           for key, obj in pairs(net.InstPlayerThing) do
              if obj.int and obj.int["7"] == StaticBag_Type.item and obj.int["3"] ~= StaticThing.soulSource and obj.int["3"] ~= StaticThing.washRock then 
                  table.insert(BagThing,obj)
              end
           end
           utils.quickSort(BagThing,compareThing)
        elseif bagFlag == 2 then 
           for key, obj in pairs(net.InstPlayerThing) do
              if obj.int and obj.int["7"] == StaticBag_Type.core then 
                  table.insert(BagThing,obj)
              end
           end
           utils.quickSort(BagThing,compare)
        end
    end
    selectedBtnChange(bagFlag)
    if BagThing then
        utils.updateView(UIBag,scrollView,listItem,BagThing,setScrollViewItem,bagFlag,btnItem)
   end
   text_ceiling:setString(string.format("背包上限%d/%d",#BagThing,grid))
end
function UIBag.reset()
    bagFlag = 1
end
function UIBag.free()
    scrollView:removeAllChildren()
    sellFlag = nil
    ExpandPrice = nil
    expandNum = nil
    bagFlag = nil
end