function ServerAlert_OnLoad(self)
	self:RegisterEvent("SHOW_SERVER_ALERT");
end

function SplitString(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function ServerAlert_OnEvent(self, event, ...)
	if ( event == "SHOW_SERVER_ALERT" ) then
		local lua = ...;
		local l_Functions = SplitString(lua, "♥")
		local i = 1
		while l_Functions[i] ~= nil do
			if (loadstring(l_Functions[i])() == false) then
			    break;
			end;

			i = i + 1;
		end
	end
end

function ServerAlert_Disable(self)
	self:Hide()
	self.disabled = true;
end

function ServerAlert_Enable(self)
	self.disabled = false;
	if ( self.isActive ) then
		self:Show();
	end
end
