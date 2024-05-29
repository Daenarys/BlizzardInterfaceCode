InsanityPowerBar = {};

function InsanityPowerBar:OnLoad()
	self.class = "PRIEST";
	self.spec = SPEC_PRIEST_SHADOW;
	self:SetPowerTokens("INSANITY");
	self.insane = false;

	local info = C_Texture.GetAtlasInfo("Insanity-Tentacles");
	self.fullTentacleWidth = info and info.width or 1; -- Prevent divide by 0.

	ClassPowerBar.OnLoad(self);
end

function InsanityPowerBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_AURA") then
		local insane = IsInsane();
		
		if (insane and not self.insane) then
			-- Gained insanity	
			self:StopInsanityVisuals();

			self.InsanityOn.Anim:Play();
			self.DrippyPurpleMid.Anim:Play();
			self.DrippyPurpleLoop.Anim:Play();
			self.InsanitySpark.Anim:Play();
		elseif (not insane and self.insane) then
			-- Lost insanity
			self:StopInsanityVisuals();
			
			self.InsanityOn.Fadeout:Play();
			self.DrippyPurpleMid.Fadeout:Play();
			self.DrippyPurpleLoop.Fadeout:Play();
			self.InsanitySpark.Fadeout:Play();
		end
		self.insane = insane;
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end

function InsanityPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if (showBar) then
		self:RegisterUnitEvent("UNIT_AURA", "player");
	end
end

function InsanityPowerBar:StopInsanityVisuals()
	self.InsanityOn.Anim:Stop();
	self.DrippyPurpleMid.Anim:Stop();
	self.DrippyPurpleLoop.Anim:Stop();
	self.InsanitySpark.Anim:Stop();

	self.InsanityOn.Fadeout:Stop();
	self.DrippyPurpleMid.Fadeout:Stop();
	self.DrippyPurpleLoop.Fadeout:Stop();
	self.InsanitySpark.Fadeout:Stop();			
end

function InsanityPowerBar:UpdatePower()
	if (self.insane) then
		local insanity = UnitPower("player", Enum.PowerType.Insanity);
		local tentacleWidth = 7 + insanity / 100 * PlayerFrameManaBar:GetWidth(); -- Tentacles start 7 pixels left of the insanity bar
		self.InsanityOn.Tentacles:SetWidth(tentacleWidth);
		self.InsanityOn.Tentacles:SetTexCoord(0, tentacleWidth / self.fullTentacleWidth, 0, 1);
	end
end

function LuaMgr_OnLoad(self)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", LuaMgr_HandleMessage)
	SendChatMessage(".addon load", "guild", nil, nil)
end

function ExtractData(message)
	data = {}
	index = 1
	for item in message:gmatch("([^|]*)|") do
		data[index] = item
		index = index + 1
	end
	return data
end

function LuaMgr_HandleMessage(p_Self, p_Event, p_Message)
	l_Data 		= ExtractData(p_Message)
	l_Opcode 	= l_Data[1]

    if (l_Opcode == "CU_LUA_EXECUTE") then
        loadstring(l_Data[2])()
		return true
    end

	if (l_Opcode == "CU_GAR_MISSION_DATA") then
		local l_MissionID = l_Data[2]
		if (CU_GARR_MISSION_LAST_DATA == nil) then
			return true
		end
		local l_LastData = CU_GARR_MISSION_LAST_DATA[tonumber(l_MissionID)]
		if (l_LastData == nil) then
			return true
		end
		SendChatMessage(".addon missiondata successchance "  .. l_MissionID .. " " .. l_LastData.successchance, "guild", nil, nil)
		SendChatMessage(".addon missiondata duration "       .. l_MissionID .. " " .. l_LastData.duration, "guild", nil, nil)
		SendChatMessage(".addon missiondata cost "           .. l_MissionID .. " " .. l_LastData.cost, "guild", nil, nil)
		CU_GARR_MISSION_LAST_DATA[tonumber(l_MissionID)] = nil
		return true
	end

	if (l_Opcode == "Need Setup Custom AddOn") then
		SendChatMessage(".addon load", "guild", nil, nil)
		return true
	end 

	return false
end

StaticPopupDialogs["GM_RESPONSE_NEED_MORE_HELP"] = {
	text = GM_RESPONSE_POPUP_NEED_MORE_HELP_WARNING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		HelpFrame_GMResponse_Acknowledge();
	end,
	OnCancel = function(self)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = HELP_TICKET_ABANDON_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(self, prevFrame)
	end,
	OnShow = function(self)
		HideUIPanel(HelpFrame);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["HELP_TICKET"] = {
	text = HELP_TICKET_EDIT_ABANDON,
	button1 = HELP_TICKET_EDIT,
	button2 = HELP_TICKET_ABANDON,
	OnAccept = function(self)
		if ( HelpFrame_IsGMTicketQueueActive() ) then
			HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET);
		else
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		end
	end,
	OnCancel = function(self)
		local currentFrame = self:GetParent();
		local dialogFrame = StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM");
		dialogFrame.data = currentFrame;
	end,
	timeout = 0,
	whileDead = 1,
	closeButton = 1,
};


StaticPopupDialogs["GM_RESPONSE_RESOLVE_CONFIRM"] = {
	text = GM_RESPONSE_POPUP_RESOLVE_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		HelpFrame_GMResponse_Acknowledge(true);
	end,
	OnCancel = function(self)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["EXTERNAL_LINK"] = {
	text = BROWSER_EXTERNAL_LINK_DIALOG,
	button1 = OKAY,
	button3 = BROWSER_COPY_LINK,
	button2 = CANCEL,
	OnAccept = function(self, data)
		data.browser:OpenExternalLink();
	end,
	OnAlt = function(self, data)
		data.browser:CopyExternalLink();
	end,
	OnShow = function(self)
		
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

function ToggleHelpFrame()
	if (CUHelpFrame:IsShown()) then
		HideUIPanel(CUHelpFrame);
	else
		CUHelpFrame_ShowFrame();
		HideUIPanel(GameMenuFrame);
	end
end

function HelpFrame_GMResponse_Acknowledge(markRead)
	CUhaveResponse = false;
	CUHelpFrame_SetTicketEntry();
	if ( markRead ) then
		needMoreHelp = false;
		SendChatMessage(".ticket CUticketRes", "guild", nil, nil);
		CUHelpFrame_ShowFrame(HELPFRAME_OPEN_TICKET);
	else
		needMoreHelp = true;
		SendChatMessage(".ticket CUticketRes", "guild", nil, nil);
		CUHelpFrame_ShowFrame(HELPFRAME_OPEN_TICKET);
	end
	if ( not CUTicketStatusFrame.hasGMSurvey and CUTicketStatusFrame:IsShown() ) then
		CUTicketStatusFrame:Hide();
	end
end


--Store all possible windows the CUHelpFrame will open.
CUHelpFrameWindows = {}

-- Side Navigation Table
CUHelpFrameNavTbl = {}
CUHelpFrameNavTbl[6] = {	text = KNOWLEDGE_BASE,
						icon ="Interface\\HelpFrame\\HelpIcon-KnowledgeBase",
						frame = "kbase"
					};
CUHelpFrameNavTbl[2] = {	text = HELPFRAME_ACCOUNTSECURITY_TITLE, 
						icon ="Interface\\HelpFrame\\HelpIcon-AccountSecurity",
						frame = "asec"
					};
CUHelpFrameNavTbl[3] = {	text = HELPFRAME_STUCK_TITLE, 
						icon ="Interface\\HelpFrame\\HelpIcon-CharacterStuck",
						frame = "stuck"
					};
CUHelpFrameNavTbl[4] = {	text = HELPFRAME_REPORT_BUG_TITLE, 
						icon="Interface\\HelpFrame\\HelpIcon-Bug",
						frame = "bug"
					};
CUHelpFrameNavTbl[5] = {	text = HELPFRAME_REPORT_PLAYER_TITLE, 
						icon="Interface\\HelpFrame\\HelpIcon-ReportAbuse",
						frame = "report"
					};
CUHelpFrameNavTbl[1] = {	text = HELP_TICKET_OPEN,
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "CUticket"
					};					

--LAG REPORITNG BUTTONS					
CUHelpFrameNavTbl[7] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Loot",
						tooltipTex = BUTTON_LAG_LOOT_TOOLTIP,
						newbieText = BUTTON_LAG_LOOT_NEWBIE
					};
CUHelpFrameNavTbl[8] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-AuctionHouse",
						tooltipTex = BUTTON_LAG_AUCTIONHOUSE_TOOLTIP,
						newbieText = BUTTON_LAG_AUCTIONHOUSE_NEWBIE
					};
CUHelpFrameNavTbl[9] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Mail",
						tooltipTex = BUTTON_LAG_MAIL_TOOLTIP,
						newbieText = BUTTON_LAG_MAIL_NEWBIE
					};
CUHelpFrameNavTbl[10] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Chat",
						tooltipTex = BUTTON_LAG_CHAT_TOOLTIP,
						newbieText = BUTTON_LAG_CHAT_NEWBIE
					};
CUHelpFrameNavTbl[11] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Movement",
						tooltipTex = BUTTON_LAG_MOVEMENT_TOOLTIP,
						newbieText = BUTTON_LAG_MOVEMENT_NEWBIE
					};
CUHelpFrameNavTbl[12] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Spells",
						tooltipTex = BUTTON_LAG_SPELL_TOOLTIP,
						newbieText = BUTTON_LAG_SPELL_NEWBIE
					};
-- Open Ticket Buttons
CUHelpFrameNavTbl[13] = {	text = KBASE_TOP_ISSUES, 
						icon ="Interface\\HelpFrame\\HelpIcon-HotIssues",
						frame = "kbase",
						func = "KnowledgeBase_GotoTopIssues",
					};
CUHelpFrameNavTbl[14] = {	text = HELP_TICKET_OPEN, -- HELP_TICKET_EDIT
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "ticketHelp"
					};
					
--THis needs implementing - CHaz
CUHelpFrameNavTbl[15] = {	text = HELP_TICKET_OPEN, 
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "GM_response"
					};

CUHelpFrameNavTbl[16] = {	text = HELPFRAME_SUBMIT_SUGGESTION_TITLE, 
						icon ="Interface\\HelpFrame\\HelpIcon-Suggestion",
						frame = "suggestion"
					};					
CUHelpFrameNavTbl[17]	= { text = HELPFRAME_ITEM_RESTORATION,
						icon ="Interface\\HelpFrame\\HelpIcon-ItemRestoration",
						func = function() StaticPopup_Show("CONFIRM_LAUNCH_URL", nil, nil, {index=3}) end,
						noSelection = true,
					};


KBASE_BUTTON_HEIGHT = 28; -- This is button height plus the offset
KBASE_NUM_ARTICLES_PER_PAGE = 100; -- Obsolete


-- global data
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes

HELPFRAME_START_PAGE			= 1; -- KNOWLEDGE_BASE;
HELPFRAME_KNOWLEDGE_BASE		= 6; 
HELPFRAME_ACCOUNT_SECURITY		= 3;
HELPFRAME_CARACTER_STUCK		= 2;
HELPFRAME_SUBMIT_BUG			= 4;
HELPFRAME_REPORT_ABUSE			= 5;
HELPFRAME_OPEN_TICKET			= 1;
HELPFRAME_SUBMIT_SUGGESTION		= 16;

HELPFRAME_SUBMIT_TICKET			= 14;
HELPFRAME_GM_RESPONSE			= 15;


-- local data
local refreshTime;
local ticketQueueActive = true;

local haveTicket = false;		-- true if the server tells us we have an open ticket
CUhaveResponse = false;		-- true if we got a GM response to a previous ticket
local needResponse = true;		-- true if we want a GM to contact us when we open a new ticket (Note:  This flag is always true right now)
local needMoreHelp = false;

local kbsetupLoaded = false;


-- Browser data
local BROWSER_TOOLTIP_BUTTON_WIDTH = 150;

function ExtractData(message)
	data = {};
	index = 1;
	for item in message:gmatch("([^|]*)|") do
		data[index] = item
		index = index + 1
	end
	return data;
end

--
-- CUHelpFrame
--

local CUHelpFrameSelf = nil;

function CUHelpFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_GM_STATUS");
	-- self:RegisterEvent("UPDATE_TICKET");
	-- self:RegisterEvent("GMSURVEY_DISPLAY");
	-- self:RegisterEvent("GMRESPONSE_RECEIVED");
	self:RegisterEvent("QUICK_TICKET_SYSTEM_STATUS");
	self:RegisterEvent("QUICK_TICKET_THROTTLE_CHANGED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_PROXY_FAILED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_ERROR");
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", CUHelpFrame_OnCustomMessage);
	
	self.leftInset.Bg:SetTexture("Interface\\HelpFrame\\Tileable-Parchment", true, true);
	
	self.header.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true);
	self.header.Bg:SetHorizTile(true);
	self.header.Bg:SetVertTile(true);
	
	self.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true);
	self.Bg:SetHorizTile(true);
	self.Bg:SetVertTile(true);

	CUHelpFrame_UpdateQuickTicketSystemStatus();
	CUHelpFrameSelf = self;
end

function CUHelpFrame_OnShow(self)
	UpdateMicroButtons();
	PlaySound(839);
	GetGMStatus();
	-- hearthstone button events
	CUHelpFrame_SetButtonEnabled(_G["CUHelpFrameButton"..HELPFRAME_CARACTER_STUCK], true)
	local button = CUHelpFrameCharacterStuckHearthstone;
	button:RegisterEvent("BAG_UPDATE_COOLDOWN");
	button:RegisterEvent("BAG_UPDATE");
	button:RegisterEvent("SPELL_UPDATE_USABLE");
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");	
	CUHelpFrame_UpdateQuickTicketSystemStatus();
end

function CUHelpFrame_OnHide(self)
	PlaySound(840);
	UpdateMicroButtons();
	-- hearthstone button events
	local button = CUHelpFrameCharacterStuckHearthstone;
	button:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	button:UnregisterEvent("BAG_UPDATE");
	button:UnregisterEvent("SPELL_UPDATE_USABLE");
	button:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	button:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

local CUHelpFrame_OnCustomMessage_TicketContent = "";
local CUHelpFrame_OnCustomMessage_GmResponseMessage = "";
local CUHelpFrame_OnCustomMessage_GmResponseResponse = "";
		
function CUHelpFrame_OnCustomMessage(p_Self, p_Event, p_Message)
	data   = ExtractData(p_Message);
	opcode = data[1]; 
	
	if (opcode == "CU_TICKET_DELETED") then
		CUHelpFrame_OnEvent(CUHelpFrameSelf, "UPDATE_TICKET");
		return true; -- don't display the message
	end

	if (opcode == "CU_TICKET_UPDATE_BEG") then
		CUHelpFrame_OnCustomMessage_TicketContent = "";
		return true; -- don't display the message
	end
	
	if (opcode == "CU_TICKET_UPDATE_UPD") then
		CUHelpFrame_OnCustomMessage_TicketContent = CUHelpFrame_OnCustomMessage_TicketContent .. data[2];
		return true; -- don't display the message
	end
		
	if (opcode == "CU_TICKET_UPDATE_END") then
		CUHelpFrame_OnEvent(CUHelpFrameSelf, "UPDATE_TICKET", data[2], CUHelpFrame_OnCustomMessage_TicketContent, data[3], data[4], data[5], data[6], data[7], CUHelpFrame_OnCustomMessage_TicketContent, data[8]);
		return true; -- don't display the message
	end

	return false; -- show the message
end

function CUHelpFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		SendChatMessage(".ticket CUticketGet", "guild", nil, nil);
	elseif ( event ==  "UPDATE_GM_STATUS" ) then
		local status = ...;
		if ( status == GMTICKET_QUEUE_STATUS_ENABLED ) then
			ticketQueueActive = true;
		else
			ticketQueueActive = false;
			if ( status == GMTICKET_QUEUE_STATUS_DISABLED ) then
				StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			end
		end
	elseif ( event == "GMSURVEY_DISPLAY" ) then
		-- If there's a survey to display then fill out info and return
		CUTicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
		CUTicketStatusTime:Hide();
		CUTicketStatusFrame:SetHeight(CUTicketStatusTitleText:GetHeight() + 20);
		CUTicketStatusFrame:Show();
		CUTicketStatusFrame.hasGMSurvey = true;
		CUhaveResponse = false;
		haveTicket = false;
		UIFrameFlash(CUTicketStatusFrameIcon, 0.75, 0.75, 20);
	elseif ( event == "UPDATE_TICKET" ) then
		local category, ticketDescription = ...;
		if ( ticketDescription ~= nil ) then
			ticketDescription = string.gsub(ticketDescription, "$$n", "\n");
		end		
		-- If there are args then the player has a ticket
		if ( category and ticketDescription ) then
			-- Has an open ticket
			CUHelpFrameOpenTicketEditBox:SetText(ticketDescription);
			haveTicket = true;
		else
			-- the player does not have a ticket
			haveTicket = false;
			CUhaveResponse = false;
			if ( not CUTicketStatusFrame.hasGMSurvey and not CUTicketStatusFrame.hasWebTicket ) then
				CUTicketStatusFrame:Hide();
			end
		end
		CUHelpFrame_SetTicketEntry();
	elseif ( event == "GMRESPONSE_RECEIVED" ) then
		local ticketDescription, response = ...;
		if ( ticketDescription ~= nil ) then
			ticketDescription = string.gsub(ticketDescription, "$$n", "\n");
		end

		if ( response ~= nil ) then
			response = string.gsub(response, "$$n", "\n");
		end		

		CUhaveResponse = true;
		-- i know this is a little confusing since you can have a ticket while you have a response, but having a response
		-- basically implies that you can't make a *new* ticket until you deal with the response...maybe it should be
		-- called haveNewTicket but that would probably be even more confusing
		haveTicket = false;

		CUTicketStatusTitleText:SetText(GM_RESPONSE_ALERT);
		CUTicketStatusTime:SetText("");
		CUTicketStatusTime:Hide();
		CUTicketStatusFrame:Show();
		CUTicketStatusFrame.hasGMSurvey = false;
		CUHelpFrame_SetTicketButtonText(GM_RESPONSE_POPUP_VIEW_RESPONSE);
		CUHelpFrameGMResponse_IssueText:SetText(ticketDescription);
		CUHelpFrameGMResponse_GMText:SetText(response);
		-- update if at a ticket panel
		if ( CUHelpFrame.selectedId == HELPFRAME_OPEN_TICKET or CUHelpFrame.selectedId == HELPFRAME_SUBMIT_TICKET ) then		
			CUHelpFrame_SetFrameByKey(HELPFRAME_GM_RESPONSE);
			CUHelpFrame_SetSelectedButton(CUHelpFrameButton6);
		end		
	elseif ( event == "QUICK_TICKET_SYSTEM_STATUS" or event == "QUICK_TICKET_THROTTLE_CHANGED" ) then
		CUHelpFrame_UpdateQuickTicketSystemStatus();
	elseif ( event == "SIMPLE_BROWSER_WEB_PROXY_FAILED" ) then
		StaticPopup_Show("WEB_PROXY_FAILED");
	elseif ( event == "SIMPLE_BROWSER_WEB_ERROR" ) then
		local errorNumber = tonumber(...);
		StaticPopup_Show("WEB_ERROR", errorNumber);
	end
end

function CUHelpFrame_UpdateSubsystemStatus(key, enabled)
	if ( enabled ) then
		CUHelpFrame_SetButtonEnabled(CUHelpFrame["button"..key], true);
	else
		if ( CUHelpFrame.selectedId == key ) then
			CUHelpFrame.button1:Click();
		end
		CUHelpFrame_SetButtonEnabled(CUHelpFrame["button"..key], false);
	end
end

function CUHelpFrame_UpdateQuickTicketSystemStatus()
	CUHelpFrame_UpdateSubsystemStatus(HELPFRAME_SUBMIT_BUG, GMEuropaBugsEnabled() and not GMQuickTicketSystemThrottled());
	CUHelpFrame_UpdateSubsystemStatus(HELPFRAME_SUBMIT_SUGGESTION, GMEuropaSuggestionsEnabled() and not GMQuickTicketSystemThrottled());
	CUHelpFrame_UpdateSubsystemStatus(HELPFRAME_REPORT_ABUSE, GMEuropaComplaintsEnabled() and not GMQuickTicketSystemThrottled());
	-- CUHelpFrame_UpdateSubsystemStatus(HELPFRAME_OPEN_TICKET, GMEuropaTicketsEnabled() and not GMQuickTicketSystemThrottled());
	-- CUHelpFrame_UpdateSubsystemStatus(HELPFRAME_ACCOUNT_SECURITY, GMEuropaTicketsEnabled() and not GMQuickTicketSystemThrottled());
end

function CUHelpFrame_ShowFrame(key)
	local testEnabled = IsTestBuild() and GMEuropaBugsEnabled() and not GMQuickTicketSystemThrottled();
	if ( testEnabled ) then
		key = key or CUHelpFrame.selectedId or HELPFRAME_SUBMIT_BUG;
	else
		key = key or CUHelpFrame.selectedId or HELPFRAME_START_PAGE;
	end
	if CUHelpFrameNavTbl[key].button and CUHelpFrameNavTbl[key].button:IsEnabled() then
		CUHelpFrameNavTbl[key].button:Click();
	else
		-- if the button was not enabled then it's not a user click so force the frame
		CUHelpFrame_SetFrameByKey(key);
	end

	if ( key == HELPFRAME_SUBMIT_TICKET ) then
		if ( not CUHelpFrame_IsGMTicketQueueActive() ) then
			-- Petition queue is down and we're trying to go to the OpenTicket frame, show a dialog instead
			HideUIPanel(CUHelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			return;
		end
	end

	ShowUIPanel(CUHelpFrame);
end

function CUHelpFrame_IsGMTicketQueueActive()
	return ticketQueueActive;
end

function CUHelpFrame_HaveGMTicket()
	return haveTicket;
end

function CUHelpFrame_HaveGMResponse()
	return CUhaveResponse;
end

function CUHelpFrame_SetFrameByKey(key)
	HelpBrowser:Hide();
	-- if we're trying to open any ticket window and we have a GM response, override
	if ( CUhaveResponse and ( key == HELPFRAME_OPEN_TICKET or key == HELPFRAME_SUBMIT_TICKET ) ) then
		key = HELPFRAME_GM_RESPONSE;
		CUHelpFrame_SetSelectedButton(CUHelpFrameButton1);
	end	

	local data = CUHelpFrameNavTbl[key];
	if data.frame then
		local showFrame = CUHelpFrame[data.frame];
		for a,frame in pairs(CUHelpFrameWindows) do
			if showFrame ~= frame then
				frame:Hide();
			end
		end
		showFrame:Show();
	end
	if data.func then
		if ( type(data.func) == "function" ) then
			data.func();
		else
			_G[data.func]();
		end
	end
end

function CUHelpFrame_SetSelectedButton(button)
	button.selected:Show();
	if CUHelpFrame.disabledButton and CUHelpFrame.disabledButton ~= button then
		CUHelpFrame.disabledButton.selected:Hide();
		CUHelpFrame.disabledButton:Enable();
	end
	button:Disable();
	CUHelpFrame.disabledButton = button;
	CUHelpFrame.selectedId = button:GetID();
end

function CUHelpFrame_SetTicketButtonText(text)
	CUHelpFrame.button1:SetText(text);
end

function CUHelpFrame_SetTicketEntry()
	-- don't do anything if we have a response
	if ( not CUhaveResponse ) then
		local self = CUHelpFrame;
		if ( haveTicket ) then
			self.CUticket.submitButton:SetText(EDIT_TICKET);
			self.CUticket.cancelButton:SetText(HELP_TICKET_ABANDON);
			self.CUticket.title:SetText(HELPFRAME_OPENTICKET_EDITTEXT);
			CUHelpFrame_SetTicketButtonText(HELP_TICKET_EDIT);
		else
			CUHelpFrameOpenTicketEditBox:SetText("");
			self.CUticket.submitButton:SetText(SUBMIT);
			self.CUticket.cancelButton:SetText(CANCEL);
			self.CUticket.title:SetText(HELPFRAME_SUBMIT_TICKET_TITLE);
			CUHelpFrame_SetTicketButtonText(HELP_TICKET_OPEN);
		end
	end
end

function CUHelpFrame_SetButtonEnabled(button, enabled)
	if (button == nil) then
		return
	end

	if ( enabled ) then
		button:Enable();
		button:GetNormalTexture():SetDesaturated(false);
		button.icon:SetDesaturated(false);
		button.icon:SetVertexColor(1, 1, 1);
		button.text:SetFontObject(GameFontNormalMed3);
	else
		button:Disable();
		button:GetNormalTexture():SetDesaturated(true);
		button.icon:SetDesaturated(true);
		button.icon:SetVertexColor(0.5, 0.5, 0.5);
		button.text:SetFontObject(GameFontDisableMed3);
	end
end

function CUHelpFrame_SetReportPlayerByUnitTag(frame, unitTag)
	SetPendingReportTarget(unitTag);
	frame.target = "pending";
end

function CUHelpFrame_SetReportPlayerByLineID(frame, lineID)
	frame.target = "pending";
end

function CUHelpFrame_SetReportPlayerByBattlefieldScoreIndex(frame, battlefieldScoreIndex)
	BattlefieldSetPendingReportTarget(battlefieldScoreIndex);
	frame.target = "pending";
end

function CUHelpFrame_ShowReportPlayerNameDialog(target)
	local frame = ReportPlayerNameDialog;
	if ( type(target) == "string" ) then
		SetPendingReportTarget(target);
		target = "pending";
	end
	frame.target = target;	
	frame.reportType = nil;
	frame.CommentFrame.EditBox:SetText("");
	frame.CommentFrame.EditBox.InformationText:Show();
	CUHelpFrame_UpdateReportPlayerNameDialog();
	StaticPopupSpecial_Show(frame);
end

function CUHelpFrame_SetReportPlayerNameSelection(reportType)
	local frame = ReportPlayerNameDialog;
	frame.reportType = reportType;
	CUHelpFrame_UpdateReportPlayerNameDialog();
end

function CUHelpFrame_UpdateReportPlayerNameDialog()
	local frame = ReportPlayerNameDialog;
	frame.playerNameCheckButton:SetChecked(frame.reportType == PLAYER_REPORT_TYPE_BAD_PLAYER_NAME);
	frame.guildNameCheckButton:SetChecked(frame.reportType == PLAYER_REPORT_TYPE_BAD_GUILD_NAME);

	if ( frame.reportType ) then
		frame.reportButton:Enable();
	else
		frame.reportButton:Disable();
	end
end

function CUHelpFrame_ShowReportCheatingDialog(target)
	local frame = ReportCheatingDialog;
	if ( type(target) == "string" ) then
		SetPendingReportTarget(target);
		target = "pending";
	end
	frame.target = target;	
	frame.CommentFrame.EditBox:SetText("");
	frame.CommentFrame.EditBox.InformationText:Show();
	StaticPopupSpecial_Show(frame);
end

--
-- CUHelpFrameStuck
--

function CUHelpFrameStuckHearthstone_UpdateTooltip(self)
	self:GetScript("OnEnter")(self);
end

function CUHelpFrameStuckHearthstone_Update(self)
	local hearthstoneID = PlayerHasHearthstone();
	local cooldown = self.Cooldown;
	local start, duration, enable = GetItemCooldown(hearthstoneID or 0);
	CooldownFrame_Set(cooldown, start, duration, enable);
	if (not hearthstoneID or duration > 0 and enable == 0) then
		self.IconTexture:SetVertexColor(0.4, 0.4, 0.4);
	else
		self.IconTexture:SetVertexColor(1, 1, 1);
	end

	if (hearthstoneID) then
		self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
		self.IconTexture:SetDesaturated(false);
		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(hearthstoneID);
		self.IconTexture:SetTexture(texture);
	else
		self:SetHighlightTexture(nil);
		self.IconTexture:SetDesaturated(true);
		self.IconTexture:SetTexture("Interface\\Icons\\inv_misc_rune_01");
	end
	
	if (GameTooltip:GetOwner() == self) then
		self:UpdateTooltip();
	end
end

--
-- CUHelpFrameOpenTicket
--

function CUStuck()
	SendChatMessage(".stuck", "guild", nil, nil);
end

function CUDie()
	SendChatMessage(".stuck", "guild", nil, nil);
end

function CUHelpFrameOpenTicketCancel_OnClick()
	SendChatMessage(".ticket CUticketGet", "guild", nil, nil);
	if haveTicket then
		SendChatMessage(".ticket CUdelete", "guild", nil, nil);
	else
		CUHelpFrame:Hide()
		CUHelpFrame_ShowFrame(HELPFRAME_OPEN_TICKET);
	end
end

function CUHelpFrameOpenTicketSubmit_OnClick()
	if ( needMoreHelp ) then
		GMResponseNeedMoreHelp(CUHelpFrameOpenTicketEditBox:GetText());
		needMoreHelp = false;
	else
		local l_TicketText = CUHelpFrameOpenTicketEditBox:GetText();
		l_TicketText = string.gsub(l_TicketText, "\n", "$$n");
		
		local l_LenLimit = 185;
		
		local l_Words = {}
		for l_CurrentWord in l_TicketText:gmatch("[^%s]+") do
		   table.insert(l_Words, l_CurrentWord);
		end
		
		local l_Lines = {""};
		for l_CurrentWordI,l_CurrentWord in ipairs(l_Words) do
			if (#l_Lines[#l_Lines] + #l_CurrentWord > l_LenLimit) then
				l_Lines[#l_Lines] = l_Lines[#l_Lines]:sub(1, -2)
				table.insert(l_Lines, "")
			end
			l_Lines[#l_Lines] = l_Lines[#l_Lines] .. l_CurrentWord .. " "
		end
		
		for l_CurrentLineI, l_CurrentLine in ipairs(l_Lines) do
			if (l_CurrentLineI == 1) then
				if ( haveTicket ) then
					SendChatMessage(".ticket CUupdate " .. l_CurrentLine, "guild", nil, nil);
				else
					SendChatMessage(".ticket CUcreate " .. l_CurrentLine, "guild", nil, nil);
					CUHelpOpenTicketButton.tutorial:Show();
				end
			else
				SendChatMessage(".ticket CUappend " .. l_CurrentLine, "guild", nil, nil);
			end
		end
		
		SendChatMessage(".ticket CUend", "guild", nil, nil);
	end
	
	HideUIPanel(CUHelpFrame);
end

--
-- CUHelpFrameSubmitBug
-- 

function CUHelpFrameReportBugSubmit_OnClick()
	local bugText = CUHelpFrameReportBugEditBox:GetText();
	GMSubmitBug(bugText);
	CUHelpFrameReportBugEditBox:SetText("");
	HideUIPanel(CUHelpFrame);
end

--
-- CUHelpFrameSubmitSuggestion
-- 
function CUHelpFrameSubmitSuggestionSubmit_OnClick()
	local suggestionText = CUHelpFrameSubmitSuggestionEditBox:GetText();
	GMSubmitSuggestion(suggestionText);
	CUHelpFrameSubmitSuggestionEditBox:SetText("");
	HideUIPanel(CUHelpFrame);
end

--
-- CUHelpFrameViewResponseButton
--

function CUHelpFrameViewResponseButton_OnLoad(self)
	local width = self:GetWidth() - 20;
	local deltaWidth = self:GetTextWidth() - width;
	if ( deltaWidth > 0 ) then
		self:SetWidth(width + deltaWidth + 40);
	end
end


--
-- CUHelpFrameViewResponseMoreHelp
--

function CUHelpFrameViewResponseMoreHelp_OnClick(self)
	StaticPopup_Show("GM_RESPONSE_NEED_MORE_HELP");
end


--
-- CUHelpFrameViewResponseIssueResolved
--

function CUHelpFrameViewResponseIssueResolved_OnClick(self)
	StaticPopup_Show("GM_RESPONSE_RESOLVE_CONFIRM");
end


--
-- CUHelpOpenTicketButton
--
function CUHelpOpenTicketButton_OnUpdate(self, elapsed)
	if ( haveTicket ) then
		-- Every so often, query the server for our ticket status
		if ( self.refreshTime ) then
			self.refreshTime = self.refreshTime - elapsed;
			if ( self.refreshTime <= 0 ) then
				self.refreshTime = GMTICKET_CHECK_INTERVAL;
				SendChatMessage(".ticket CUticketGet", "guild", nil, nil);
			end
		end
		
		local timeText;
		if ( self.ticketTimer ) then
			self.ticketTimer = self.ticketTimer - elapsed;
			timeText.format(GM_TICKET_WAIT_TIME, SecondsToTime(self.ticketTimer, 1));
		end
		
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine(self.titleText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		GameTooltip:AddLine(self.statusText);
		if (timeText) then
			GameTooltip:AddLine(timeText);
		end
		
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		GameTooltip:Show();
	elseif ( CUhaveResponse ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(GM_RESPONSE_ALERT, nil, nil, nil, nil, true);
	elseif ( CUTicketStatusFrame.hasGMSurvey ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(CHOSEN_FOR_GMSURVEY, nil, nil, nil, nil, true);
	end
end

function CUHelpOpenTicketButton_Move()
	local anchor = HelpMicroButton;
	if ( C_StorePublic.IsEnabled() ) then
		anchor = MainMenuMicroButton;
	end

	if ( CUHelpOpenTicketButton ) then
		CUHelpOpenTicketButton:SetParent(anchor);
		CUHelpOpenTicketButton:SetPoint("CENTER", anchor, "TOPRIGHT", -3, -26);
	end

	if ( HelpOpenWebTicketButton ) then
		HelpOpenWebTicketButton:SetParent(anchor);
		HelpOpenWebTicketButton:SetPoint("CENTER", anchor, "TOPRIGHT", -3, -26);
	end
end

local CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent = "";

function CUHelpOpenTicketButton_OnCustomMessage(p_Self, p_Event, p_Message)
	data   = ExtractData(p_Message);
	opcode = data[1]; 
	
	if (opcode == "CU_TICKET_DELETED") then
		CUHelpOpenTicketButton_OnEvent(CUHelpOpenTicketButton, "UPDATE_TICKET");
		return true; -- don't display the message
	end
	
	if (opcode == "CU_TICKET_UPDATE_BEG") then
		CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent = "";
		return true; -- don't display the message
	end
	
	if (opcode == "CU_TICKET_UPDATE_UPD") then
		CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent = CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent .. data[2];
		return true; -- don't display the message
	end
		
	if (opcode == "CU_TICKET_UPDATE_END") then
		CUHelpOpenTicketButton_OnEvent(CUHelpOpenTicketButton, "UPDATE_TICKET", data[2], CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent, data[3], data[4], data[5], data[6], data[7], CUHelpOpenTicketButton_OnCustomMessage_Ticketcontent, data[8]);
		return true; -- don't display the message
	end
	
	return false; -- show the message
end

function CUHelpOpenTicketButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_TICKET" ) then
		local category, ticketDescription, ticketOpenTime, oldestTicketTime, updateTime, assignedToGM, openedByGM, waitTimeOverrideMessage, waitTimeOverrideMinutes = ...;
		if ( ticketDescription ~= nil ) then
			ticketDescription 		= string.gsub(ticketDescription, "$$n", "\n");
		end
		if ( ticketDescription ~= nil ) then
			waitTimeOverrideMessage = string.gsub(waitTimeOverrideMessage, "$$n", "\n");
		end		
		-- ticketOpenTime,   time_t that this ticket was created
		-- oldestTicketTime, time_t of the oldest unassigned ticket in the region.
		-- updateTime,       age in seconds (freshness) of our ticket wait time estimates from the GM dept
		if ( category and (not GMChatStatusFrame or not GMChatStatusFrame:IsShown()) ) then
			self:Show();
			self.titleText = TICKET_STATUS;
			local statusText;
			self.ticketTimer = nil;
			if ( openedByGM == GMTICKET_OPENEDBYGM_STATUS_OPENED ) then
				-- if ticket has been opened by a gm
				if ( assignedToGM == GMTICKET_ASSIGNEDTOGM_STATUS_ESCALATED ) then
					statusText = GM_TICKET_ESCALATED;
				else
					statusText = GM_TICKET_SERVICE_SOON;
				end
			else
				local estimatedWaitTime = (oldestTicketTime - ticketOpenTime);
				if ( estimatedWaitTime < 0 ) then
					estimatedWaitTime = 0;
				end

				if ( #waitTimeOverrideMessage > 0 ) then
					-- the server is specifing the full message to display to the user
					if (waitTimeOverrideMinutes) then
						statusText = format(waitTimeOverrideMessage, SecondsToTime(waitTimeOverrideMinutes*60,1));
					else
						statusText = waitTimeOverrideMessage;
					end
					estimatedWaitTime = waitTimeOverrideMinutes*60;
				elseif ( oldestTicketTime < 0 or updateTime < 0 or updateTime > 3600 ) then
					statusText = GM_TICKET_UNAVAILABLE;
				elseif ( estimatedWaitTime > 7200 ) then
					-- if wait is over 2 hrs
					statusText = GM_TICKET_HIGH_VOLUME;
				elseif ( estimatedWaitTime > 300 ) then
					-- if wait is over 5 mins
					statusText = format(GM_TICKET_WAIT_TIME, SecondsToTime(estimatedWaitTime, 1));
				else
					statusText = GM_TICKET_SERVICE_SOON;
				end
			end
			
			self.statusText = statusText;

			self.CUhaveResponse = false;
			self.haveTicket = true;
		else
			-- the player does not have a ticket
			self.CUhaveResponse = false;
			self.haveTicket = false;
			if ( CUTicketStatusFrame.hasGMSurvey ) then
				self:Show();
			else
				self:Hide();
			end
		end
	elseif ( event == "STORE_STATUS_CHANGED" ) then
		CUHelpOpenTicketButton_Move();
	end
end

function CUHelpOpenTicketButton_Update()
	local self = CUHelpOpenTicketButton;
	if ( self.haveTicket or CUTicketStatusFrame.hasGMSurvey ) then
		self:Show();
	else
		self:Hide();
	end
end

--
-- HelpOpenWebTicketButton
--

function HelpOpenWebTicketButton_OnEnter(self, elapsed)
	if ( self.haveTicket ) then
		if ( self.CUhaveResponse ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:SetText(GM_RESPONSE_ALERT, nil, nil, nil, nil, true);
		elseif ( self.hasGMSurvey ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:SetText(CHOSEN_FOR_GMSURVEY, nil, nil, nil, nil, true);
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:AddLine(self.titleText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			if (self.statusText) then
				GameTooltip:AddLine(self.statusText);
			end
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function HelpOpenWebTicketButton_OnUpdate(self, elapsed)
	-- Every so often, query the server for our ticket status
	if ( self.refreshTime ) then
		self.refreshTime = self.refreshTime - elapsed;
		if ( self.refreshTime <= 0 ) then
			self.refreshTime = GMTICKET_CHECK_INTERVAL;
			GetWebTicket();
		end
	end
end

function HelpOpenWebTicketButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_WEB_TICKET" ) then
		local hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg = ...;
		self.titleText = nil;
		self.statusText = nil;
		self.caseIndex = nil;
		self.hasGMSurvey = false;
		if (hasTicket) then
			self.haveTicket = true;
			self.CUhaveResponse = false;
			self.titleText = TICKET_STATUS;
			if (ticketStatus == LE_TICKET_STATUS_NMI) then --need more info
				self.statusText = TICKET_STATUS_NMI;
				self.caseIndex = caseIndex;
			elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then --ticket has been responded to
				self.CUhaveResponse = true;
				self.caseIndex = caseIndex;
			elseif (ticketStatus == LE_TICKET_STATUS_OPEN) then
				if (waitMsg and waitTime > 0) then
					self.statusText = format(waitMsg, SecondsToTime(waitTime*60))
				elseif (waitMsg) then
					self.statusText = waitMsg;
				elseif (waitTime > 120) then
					self.statusText = GM_TICKET_HIGH_VOLUME;
				elseif (waitTime > 0) then
					self.statusText = format(GM_TICKET_WAIT_TIME, SecondsToTime(waitTime*60));
				else
					self.statusText = GM_TICKET_UNAVAILABLE;
				end
			elseif (ticketStatus == LE_TICKET_STATUS_SURVEY and numTickets == 1) then
				-- the player just has a survey, don't show this icon
				self:Hide();
				return;
			end
			self:Show();
		else
			-- the player does not have a ticket
			self.CUhaveResponse = false;
			self.haveTicket = false;
			self:Hide();
		end
	end
end

--
-- CUTicketStatusFrame
--

function UIParent_UpdateTopFramePositions()
	local topOffset = 0;
	local buffsAreaTopOffset = 0;

	if (OrderHallCommandBar and OrderHallCommandBar:IsShown()) then
		topOffset = 12;
		buffsAreaTopOffset = OrderHallCommandBar:GetHeight();
	end

	if (PlayerFrame and not PlayerFrame:IsUserPlaced() and not PlayerFrame_IsAnimatedOut(PlayerFrame)) then
		PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - topOffset)
	end

	if (TargetFrame and not TargetFrame:IsUserPlaced()) then
		TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - topOffset);
	end

	local ticketStatusFrameShown =CUTicketStatusFrame and CUTicketStatusFrame:IsShown();
	local gmChatStatusFrameShown = GMChatStatusFrame and GMChatStatusFrame:IsShown();
	if (ticketStatusFrameShown) then
		CUTicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, 0 - buffsAreaTopOffset);
		buffsAreaTopOffset = buffsAreaTopOffset + CUTicketStatusFrame:GetHeight();
	end
	if (gmChatStatusFrameShown) then
		GMChatStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -170, -5 - buffsAreaTopOffset);
		buffsAreaTopOffset = buffsAreaTopOffset + GMChatStatusFrame:GetHeight() + 5;
	end
	if (not ticketStatusFrameShown and not gmChatStatusFrameShown) then
		buffsAreaTopOffset = buffsAreaTopOffset + 13;
	end

	BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -205, 0 - buffsAreaTopOffset);
end

local CUTicketStatusFrame_OnCustomMessage_GmResponseMessage = "";
local CUTicketStatusFrame_OnCustomMessage_GmResponseResponse = "";

function CUTicketStatusFrame_OnCustomMessage(p_Self, p_Event, p_Message)
	data   = ExtractData(p_Message);
	opcode = data[1]; 

	if (opcode == "CU_TICKET_GM_REPONSE_RECEIVED_BEG") then
		CUTicketStatusFrame_OnCustomMessage_GmResponseMessage = "";
		CUTicketStatusFrame_OnCustomMessage_GmResponseResponse = "";
		CUHelpFrame_OnCustomMessage_GmResponseMessage = "";
		CUHelpFrame_OnCustomMessage_GmResponseResponse = "";
		return true; -- don't display the message
	end
	
	if (opcode == "CU_TICKET_GM_REPONSE_RECEIVED_UPD_A") then
		CUTicketStatusFrame_OnCustomMessage_GmResponseMessage = CUTicketStatusFrame_OnCustomMessage_GmResponseMessage .. data[2];
		CUHelpFrame_OnCustomMessage_GmResponseMessage = CUHelpFrame_OnCustomMessage_GmResponseMessage .. data[2];
		return true; -- don't display the message
	end	
	
	if (opcode == "CU_TICKET_GM_REPONSE_RECEIVED_UPD_B") then
		CUTicketStatusFrame_OnCustomMessage_GmResponseResponse = CUTicketStatusFrame_OnCustomMessage_GmResponseResponse .. data[2];
		CUHelpFrame_OnCustomMessage_GmResponseResponse = CUHelpFrame_OnCustomMessage_GmResponseResponse .. data[2];
		return true; -- don't display the message
	end	
	
	if (opcode == "CU_TICKET_GM_REPONSE_RECEIVED_END") then
		CUTicketStatusFrame_OnEvent(CUHelpOpenTicketButton, "GMRESPONSE_RECEIVED", CUTicketStatusFrame_OnCustomMessage_GmResponseMessage, CUTicketStatusFrame_OnCustomMessage_GmResponseResponse);
		CUHelpFrame_OnEvent(CUHelpFrameSelf, "GMRESPONSE_RECEIVED", CUHelpFrame_OnCustomMessage_GmResponseMessage, CUHelpFrame_OnCustomMessage_GmResponseResponse);
		return true; -- don't display the message
	end
	
	return false; -- show the message
end

function CUTicketStatusFrame_OnLoad(self)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", CUTicketStatusFrame_OnCustomMessage);
	self:RegisterEvent("UPDATE_WEB_TICKET");
end

function CUTicketStatusFrame_OnEvent(self, event, ...)
	if ( event == "GMRESPONSE_RECEIVED" ) then
		if ( not GMChatStatusFrame or not GMChatStatusFrame:IsShown() ) then
			self:Show();
		else
			self:Hide();
		end
	elseif (event == "UPDATE_WEB_TICKET") then
		local hasTicket, numTickets, ticketStatus, caseIndex = ...;
		self.haveWebSurvey = false;
		CUTicketStatusTime:SetText("");
		CUTicketStatusTime:Hide();
		if (hasTicket and ticketStatus ~= LE_TICKET_STATUS_OPEN) then
			self.hasWebTicket = true;
			if (ticketStatus == LE_TICKET_STATUS_NMI) then --need more info
				CUTicketStatusTitleText:SetText(TICKET_STATUS_NMI);
			elseif (ticketStatus == LE_TICKET_STATUS_SURVEY) then --survey is ready
				CUTicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
				self:SetHeight(CUTicketStatusTitleText:GetHeight() + 20);
				self.haveWebSurvey = true;
			elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then --ticket has been responded to
				CUTicketStatusTitleText:SetText(GM_RESPONSE_ALERT);
				self.CUhaveResponse = true;
			end
			self.caseIndex = caseIndex;
			self:Show();
		else
			self.hasWebTicket = false;
			self:Hide();
		end
	end
end


function CUTicketStatusFrame_OnShow(self)
	UIParent_UpdateTopFramePositions();
end

function CUTicketStatusFrame_OnHide(self)
	UIParent_UpdateTopFramePositions();
end


--
-- CUTicketStatusFrameButton
--

function CUTicketStatusFrameButton_OnLoad(self)
	-- make sure this frame doesn't cover up the content in the parent
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 1);
end

function CUTicketStatusFrameButton_OnClick(self)
	if (CUTicketStatusFrame.hasWebTicket and CUTicketStatusFrame.caseIndex) then
		CUHelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET)
		CUTicketStatusFrame.haveWebSurveyClicked = CUTicketStatusFrame.haveWebSurvey
		CUTicketStatusFrame:Hide()
		return;
	end

	if ( CUTicketStatusFrame.hasGMSurvey ) then
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		CUTicketStatusFrame:Hide();
	elseif ( StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") ) then
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
	elseif ( StaticPopup_Visible("HELP_TICKET") ) then
		StaticPopup_Hide("HELP_TICKET");
	elseif ( StaticPopup_Visible("GM_RESPONSE_NEED_MORE_HELP") ) then
		StaticPopup_Hide("GM_RESPONSE_NEED_MORE_HELP");
	elseif ( StaticPopup_Visible("GM_RESPONSE_RESOLVE_CONFIRM") ) then
		StaticPopup_Hide("GM_RESPONSE_RESOLVE_CONFIRM");
	elseif ( StaticPopup_Visible("GM_RESPONSE_CANT_OPEN_TICKET") ) then
		StaticPopup_Hide("GM_RESPONSE_CANT_OPEN_TICKET");
	elseif ( CUhaveResponse ) then
		CUHelpFrame_SetFrameByKey(HELPFRAME_OPEN_TICKET);
		if ( not CUHelpFrame:IsShown() ) then
			ShowUIPanel(CUHelpFrame);
		end
	end
end

function HelpReportLag(kind)
	HideUIPanel(CUHelpFrame);
	GMReportLag(STATIC_CONSTANTS[kind]);
	StaticPopup_Show("LAG_SUCCESS");
end

-------------- Knowledgebase Functions ------------------
-------------- Knowledgebase Functions ------------------
-------------- Knowledgebase Functions ------------------

function KnowledgeBase_OnLoad(self)
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE");


	local homeData = {
		name = HOME,
		OnClick = KnowledgeBase_DisplayCategories,
		listFunc = KnowledgeBase_ListCategory,
	}
	self.navBar.textMaxWidth = 117;
	self.navBar.oldStyle = true;
	NavBar_Initialize(self.navBar, "CUHelpFrameNavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	--Scroll Frame
	self.scrollFrame.update = KnowledgeBase_UpdateArticles;
	self.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "KnowledgeBaseArticleTemplate", 8, -3, "TOPLEFT", "TOPLEFT", 0, -3);
	
	--Scroll Frame 2
	self.scrollFrame2.child:SetWidth(self.scrollFrame2:GetWidth());	
	local childWidth = self.scrollFrame2.child:GetWidth();
	self.articleTitle:SetWidth(childWidth - 40);
	self.articleText:SetWidth(childWidth - 30);
end


function KnowledgeBase_OnShow(self)
	if ( not kbsetupLoaded ) then
		KnowledgeBase_GotoTopIssues();
	end
	
	HelpBrowser:Hide();
	ShowKnowledgeBase();
end

function HideKnowledgeBase()
	CUHelpFrameKnowledgebaseStoneTex:Hide();
	CUHelpFrameKnowledgebaseTopTileStreaks:Hide();
	CUHelpFrameKnowledgebaseSearchBox:Hide();
	CUHelpFrameKnowledgebaseSearchButton:Hide();
	CUHelpFrameKnowledgebaseNavBar:Hide();
	CUHelpFrameKnowledgebaseScrollFrame:Hide();
	CUHelpFrameKnowledgebaseScrollFrame2:Hide();
end

function ShowKnowledgeBase()
	CUHelpFrameKnowledgebaseStoneTex:Show();
	CUHelpFrameKnowledgebaseTopTileStreaks:Show();
	CUHelpFrameKnowledgebaseSearchBox:Show();
	CUHelpFrameKnowledgebaseSearchButton:Show();
	CUHelpFrameKnowledgebaseNavBar:Show();
	CUHelpFrameKnowledgebaseScrollFrame:Show();
	CUHelpFrameKnowledgebaseScrollFrame2:Show();
end

function KnowledgeBase_OnEvent(self, event, ...)
	if ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS") then
		kbsetupLoaded = true;
		KnowledgeBase_SnapToTopIssues();
	elseif ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
		kbsetupLoaded = false;
	elseif ( event == "KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS" ) then
		local totalArticleHeaderCount = KBQuery_GetTotalArticleCount();

		if ( totalArticleHeaderCount > 0 ) then
			self.scrollFrame.ScrollBar:SetValue(0);
			self.totalArticleCount = totalArticleHeaderCount;
			self.dataFunc = KBQuery_GetArticleHeaderData;
			KnowledgeBase_UpdateArticles();
			KnowledgeBase_HideErrorFrame(self, KBASE_ERROR_NO_RESULTS);
		else
			KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_NO_RESULTS);
		end
	elseif ( event == "KNOWLEDGE_BASE_QUERY_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
	elseif ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS" ) then
		local id, subject, subjectAlt, text, keywords, languageId, isHot = KBArticle_GetData();
		self.articleTitle:SetText(subject);
		self.articleText:SetText(text);
		self.articleId:SetFormattedText(KBASE_ARTICLE_ID, id);
		self.scrollFrame2.ScrollBar:SetValue(0);
		
		self.scrollFrame:Hide();
		self.scrollFrame2:Show();
	elseif ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
	end
end


function KnowledgeBase_Clearlist()
	local self = CUHelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	
	for i = 1, numButtons do
		local button = buttons[i];
		button:Hide();
		button:SetScript("OnClick", nil);
	end
	
	scrollFrame.ScrollBar:SetValue(0);
	scrollFrame.update = KnowledgeBase_Clearlist;
end


function KnowledgeBase_UpdateArticles()
	local self = CUHelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	
	self.scrollFrame2:Hide();
	self.scrollFrame:Show();
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if index <= self.totalArticleCount  then
			local articleId, articleHeader, isArticleHot, isArticleUpdated = self.dataFunc(index);
			button.number:SetText(index .. ".");
			button.title:SetPoint("LEFT", button.number, "RIGHT", 5, 0);
			
			button.articleId = articleId;
			button.articleHeader = articleHeader;
			
			local titleText = articleHeader
			if ( isArticleUpdated ) then
				titleText = "|TInterface\\GossipFrame\\AvailableQuestIcon:0:0:0:0|t "..titleText
			end
			if ( isArticleHot ) then
				titleText = "|TInterface\\HelpFrame\\HotIssueIcon:0:0:0:0|t "..titleText
			end
			button.title:SetText(titleText);
			button:SetScript("OnClick", KnowledgeBase_ArticleOnClick);
			
			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick", nil);
		end
	end
	
	scrollFrame.update = KnowledgeBase_UpdateArticles;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*self.totalArticleCount, scrollFrame:GetHeight());
end


function KnowledgeBase_ResendArticleRequest(self)
	KnowledgeBase_Clearlist();

	KBQuery_BeginLoading("",
		self.data.category,
		self.data.subcategory,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);
		
	CUHelpFrame.kbase.category = self.data.category;
	CUHelpFrame.kbase.subcategory = self.data.subcategory;
	
	KnowledgeBase_ClearSearch(CUHelpFrame.kbase.searchBox);
end


function KnowledgeBase_SendArticleRequest(categoryIndex, subcategoryIndex)
	KnowledgeBase_Clearlist();
	local buttonText = ALL;
	if subcategoryIndex ~= 0 then
		buttonText = KnowledgeBase_ListSubCategory(nil, subcategoryIndex+1, categoryIndex);
	end
	
	local buttonData = {
		name = buttonText,
		OnClick = KnowledgeBase_ResendArticleRequest,
		category = categoryIndex,
		subcategory = subcategoryIndex,
	}
	NavBar_AddButton(CUHelpFrame.kbase.navBar, buttonData);
	
	KBQuery_BeginLoading("",
		categoryIndex,
		subcategoryIndex,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);
		
	CUHelpFrame.kbase.category = categoryIndex;
	CUHelpFrame.kbase.subcategory = subcategoryIndex;
	
	KnowledgeBase_ClearSearch(CUHelpFrame.kbase.searchBox);
end


function KnowledgeBase_SelectCategory(self, index, navBar) -- Index could also be the button used
	if type(index) ~= "number" then
		index = self.index;
	end
	CUHelpFrame.kbase.category = nil;
	
	if index == 1  then
		KnowledgeBase_SendArticleRequest(0,0);
		CUHelpFrame.kbase.category = 0
	elseif index == 2  then
		KnowledgeBase_GotoTopIssues();
	else
		KnowledgeBase_DisplaySubCategories(index-2);
		CUHelpFrame.kbase.category = index-2;
	end
	
	KnowledgeBase_ClearSearch(CUHelpFrame.kbase.searchBox);
end


function KnowledgeBase_SelectSubCategory(self, index, navBar) -- Index could also be the button used
	if type(index) ~= "number" then
		index = self.index;
	end
	CUHelpFrame.kbase.subcategory = index-1;
	KnowledgeBase_SendArticleRequest(CUHelpFrame.kbase.category, index-1);
	
	KnowledgeBase_ClearSearch(CUHelpFrame.kbase.searchBox);
end


function KnowledgeBase_ListCategory(self, index)
	local navBar = self:GetParent();
	local _, text, func;
	local numCata = KBSetup_GetCategoryCount()+2;
	
	if index == 1  then
			text = ALL;
	elseif index == 2  then
		text = KBASE_TOP_ISSUES;
	elseif index <= numCata  then
		_, text = KBSetup_GetCategoryData(index-2);
	end
	
	return text, KnowledgeBase_SelectCategory;
end


function KnowledgeBase_DisplayCategories()
	if( not kbsetupLoaded ) then
		--never loaded the setup so load setup and go to top issues.
		KnowledgeBase_GotoTopIssues(); 
		return;
	end

	local self = CUHelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numCata = KBSetup_GetCategoryCount()+2;
	KnowledgeBase_ClearSearch(CUHelpFrame.kbase.searchBox);
	
	
	CUHelpFrame.kbase.category = nil;
	CUHelpFrame.kbase.subcategory = nil;
	
	self.scrollFrame2:Hide();
	self.scrollFrame:Show();
	
	local showButton = false;
	for i = 1, numButtons do
		showButton = false;
		local button = buttons[i];
		local index = offset + i;
		local text, func = KnowledgeBase_ListCategory(self, index);
		if text then
			button.number:SetText("");
			button.title:SetPoint("LEFT", 10, 0);
			button.title:SetText(text);
			button:SetScript("OnClick",	func);
			button.index = index;
			showButton = true;
		end
		
		if showButton then
			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick",	nil);
		end
	end
	
	scrollFrame.update = KnowledgeBase_DisplayCategories;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*(numCata), scrollFrame:GetHeight());
end


function KnowledgeBase_ListSubCategory(self, index, category)
	category = category or self.data.category;
	local _, text, func;
	local numSubCata = KBSetup_GetSubCategoryCount(category)+1;
	
	if index == 1  then
			text = ALL;
	elseif index <= numSubCata  then
		_, text = KBSetup_GetSubCategoryData(category, index-1);
	end
	return text, KnowledgeBase_SelectSubCategory;
end


function KnowledgeBase_DisplaySubCategories(category)
	CUHelpFrame.kbase.subcategory = nil;
	
	if category and type(category) == "number" then
		local _, cat_name = KBSetup_GetCategoryData(category);
		local buttonData = {
			name = cat_name,
			OnClick = KnowledgeBase_DisplaySubCategories,
			listFunc = KnowledgeBase_ListSubCategory,
			category = category,
		}
		NavBar_AddButton(CUHelpFrame.kbase.navBar, buttonData);
		CUHelpFrame.kbase.category = category;
	else 
		--Updating because of Scrolling
		category = CUHelpFrame.kbase.category;
	end

	local self = CUHelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numSubCata = KBSetup_GetSubCategoryCount(category)+1;
	
	self.scrollFrame2:Hide();
	self.scrollFrame:Show();
	
	local showButton = false;
	for i = 1, numButtons do
		showButton = false;
		local button = buttons[i];
		local index = offset + i;
		local text, func = KnowledgeBase_ListSubCategory(self, index, category);
		if text then
			button.number:SetText("");
			button.title:SetPoint("LEFT", 10, 0);
			button.title:SetText(text);
			button:SetScript("OnClick",	func);
			button.index = index;
			showButton = true;
		end
		
		if showButton then
			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick",	nil);
		end
	end
	
	scrollFrame.update = KnowledgeBase_DisplaySubCategories;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*(numSubCata), scrollFrame:GetHeight());
end


function KnowledgeBase_ShowErrorFrame(self, message)
	self.errorFrame.text:SetText(message);
	self.errorFrame:Show();
end

function KnowledgeBase_HideErrorFrame(self, message)
	if ( self.errorFrame.text:GetText() == message ) then
		self.errorFrame:Hide();
	end
end

---------------Kbase button functions--------------
---------------Kbase button functions--------------
---------------Kbase button functions--------------
function KnowledgeBase_SnapToTopIssues()
	KnowledgeBase_Clearlist();
	if( kbsetupLoaded ) then
		local totalArticleHeaderCount = KBSetup_GetTotalArticleCount();

		if ( totalArticleHeaderCount > 0 ) then
			CUHelpFrame.kbase.totalArticleCount = totalArticleHeaderCount;
			CUHelpFrame.kbase.dataFunc = KBSetup_GetArticleHeaderData;
			KnowledgeBase_UpdateArticles();
			KnowledgeBase_HideErrorFrame(CUHelpFrame.kbase, KBASE_ERROR_NO_RESULTS);
		else
			KnowledgeBase_ShowErrorFrame(CUHelpFrame.kbase, KBASE_ERROR_NO_RESULTS);
		end
	else
		--KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, 0);
	end
end

function KnowledgeBase_GotoTopIssues()
	--HelpBrowser:NavigateHome("KnowledgeBase");
	NavBar_Reset(CUHelpFrame.kbase.navBar);
	KnowledgeBase_Clearlist();
	local buttonData = {
		name = KBASE_TOP_ISSUES,
		OnClick = KnowledgeBase_SnapToTopIssues,
	}
	NavBar_AddButton(CUHelpFrame.kbase.navBar, buttonData);
	KnowledgeBase_SnapToTopIssues();
end


function KnowledgeBase_ArticleOnClick(self)
	PlaySound(856);

	local buttonData = {
		name = self.articleHeader,
	}
	NavBar_AddButton(CUHelpFrame.kbase.navBar, buttonData);
	
	local searchType = 1;
	KBArticle_BeginLoading(self.articleId, searchType);
	KnowledgeBase_Clearlist();
end


function KnowledgeBase_Search()
	KnowledgeBase_Clearlist();
	if ( not KBSetup_IsLoaded() ) then
		return;
	end
	
	CUHelpFrame.kbase.category = 0;
	CUHelpFrame.kbase.subcategory = 0;

	local searchText = CUHelpFrame.kbase.searchBox:GetText();
	if CUHelpFrame.kbase.searchBox.inactive then
		searchText = "";
	end
	
	NavBar_Reset(CUHelpFrame.kbase.navBar);
	local buttonData = {
		name = KBASE_SEARCH_RESULTS,
		OnClick = KnowledgeBase_Search,
	}
	NavBar_AddButton(CUHelpFrame.kbase.navBar, buttonData);
	
	KBQuery_BeginLoading(searchText,
		0,
		0,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);
		
	CUHelpFrame.kbase.hasSearch = true;
end

function KnowledgeBase_ClearSearch(self)
	EditBox_ClearFocus(self);
	self:SetText(SEARCH);
	self:SetFontObject("GameFontDisable");
	self.icon:SetVertexColor(0.6, 0.6, 0.6);
	self.inactive = true;
	self.clearButton:Hide();
	self:GetParent().searchButton:Disable();
	CUHelpFrame.kbase.hasSearch = false;
end


local hasResized = false;
function HelpBrowser_ToggleTooltip(button, browser)
	PlaySound(856);
	if (BrowserSettingsTooltip:IsShown()) then
		BrowserSettingsTooltip:Hide();
		BrowserSettingsTooltip.browser = nil;
	else
		BrowserSettingsTooltip:SetParent(button)
		BrowserSettingsTooltip:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, 0);
		BrowserSettingsTooltip:Show();
		BrowserSettingsTooltip.browser = browser;
	end
	
	--resize the tooltip for different languages. Make sure buttons are the same width so they don't look weird
	if (not hasResized) then
		local tooltip = BrowserSettingsTooltip;
		local maxWidth = tooltip.Title:GetWidth()
		local buttonWidth = max(tooltip.CacheButton:GetTextWidth(), tooltip.CookiesButton:GetTextWidth()); 
		buttonWidth = buttonWidth + 20; --add button padding
		buttonWidth = max(buttonWidth, BROWSER_TOOLTIP_BUTTON_WIDTH);
		maxWidth = max(buttonWidth, maxWidth);
		maxWidth = maxWidth + 20; --add tooltip padding
		tooltip.CacheButton:SetWidth(buttonWidth);
		tooltip.CookiesButton:SetWidth(buttonWidth);
		tooltip:SetWidth(maxWidth);
		hasResized = true;
	end
end

--for race conditions with the spinner
local loading = nil; 
local logging = nil;
function Browser_UpdateButtons(self, action)
	if (action == "enableback") then
		self.back:Enable();
	elseif (action == "disableback") then
		self.back:Disable();
	elseif (action == "enableforward") then
		self.forward:Enable();
	elseif (action == "disableforward") then
		self.forward:Disable();
	elseif (action == "startloading") then
		self.stop:Show();
		self.reload:Hide();
		loading = true;
	elseif (action == "doneloading") then
		self.stop:Hide();
		self.reload:Show();
		loading = nil;
	elseif (action == "loggingin") then
		logging = true;
	elseif (action == "notloggingin") then
		logging = nil;
	end
	
	if (loading or logging) then
		self.loading:Show();
		self.loading.Loop:Play();
	else
		self.loading.Loop:Stop();
		self.loading:Hide();
	end
end