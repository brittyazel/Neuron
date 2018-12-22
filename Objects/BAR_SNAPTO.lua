--Neuron , a World of Warcraft® user interface addon.
--SnapTo code is a modified version of FlyPaper by Tuller


local BAR = Neuron.BAR

local function frameIsDependentOnFrame(frame, otherFrame)

	if (frame and otherFrame) then

		if (frame == otherFrame) then return true end

		local points = frame:GetNumPoints()

		for i=1,points do
			local parent = select(2, frame:GetPoint(i))
			if (frameIsDependentOnFrame(parent, otherFrame)) then return true end
		end
	end
end

local function canAttach(frame, otherFrame)

	if not(frame and otherFrame) then
		return
	elseif (frame:GetNumPoints() == 0 or otherFrame:GetNumPoints() == 0) then
		return
	elseif (frame:GetWidth() == 0 or frame:GetHeight() == 0 or otherFrame:GetWidth() == 0 or otherFrame:GetHeight() == 0) then
		return
	elseif (frameIsDependentOnFrame(otherFrame, frame)) then
		return
	end

	return true
end


--[[ Attachment Functions ]]--

local function attachToTop(frame, otherFrame, distLeft, distRight, distCenter, offset)

	frame:ClearAllPoints()

	if (distLeft < distCenter and distLeft < distRight) then

		frame:SetPoint("BOTTOMLEFT", otherFrame, "TOPLEFT", 0, offset); return "TL"

	elseif (distRight < distCenter and distRight < distLeft) then

		frame:SetPoint("BOTTOMRIGHT", otherFrame, "TOPRIGHT", 0, offset); return "TR"
	else
		frame:SetPoint("BOTTOM", otherFrame, "TOP", 0, offset); return "TC"
	end
end

local function attachToBottom(frame, otherFrame, distLeft, distRight, distCenter, offset)

	frame:ClearAllPoints()

	if (distLeft < distCenter and distLeft < distRight) then

		frame:SetPoint("TOPLEFT", otherFrame, "BOTTOMLEFT", 0, -offset); return "BL"

	elseif (distRight < distCenter and distRight < distLeft) then

		frame:SetPoint("TOPRIGHT", otherFrame, "BOTTOMRIGHT", 0, -offset); return "BR"

	else
		frame:SetPoint("TOP", otherFrame, "BOTTOM", 0, -offset); return "BC"
	end
end

local function attachToLeft(frame, otherFrame, distTop, distBottom, distCenter, offset)

	frame:ClearAllPoints()

	if (distBottom < distTop and distBottom < distCenter) then

		frame:SetPoint("BOTTOMRIGHT", otherFrame, "BOTTOMLEFT", -offset, 0); return "LB"

	elseif (distTop < distBottom and distTop < distCenter) then

		frame:SetPoint("TOPRIGHT", otherFrame, "TOPLEFT", -offset, 0); return "LT"

	else
		frame:SetPoint("RIGHT", otherFrame, "LEFT", -offset, 0); return "LC"
	end
end

local function attachToRight(frame, otherFrame, distTop, distBottom, distCenter, offset)

	frame:ClearAllPoints()

	if (distBottom < distTop and distBottom < distCenter) then

		frame:SetPoint("BOTTOMLEFT", otherFrame, "BOTTOMRIGHT", offset, 0); return "RB"

	elseif (distTop < distBottom and distTop < distCenter) then

		frame:SetPoint("TOPLEFT", otherFrame, "TOPRIGHT", offset, 0); return "RT"

	else
		frame:SetPoint("LEFT", otherFrame, "RIGHT", offset, 0); return "RC"
	end
end

local function attachToCenter(frame, otherFrame)

	frame:ClearAllPoints()

	frame:SetPoint("CENTER", otherFrame, "CENTER", 0, 0); return "CT"
end


--[[ Usable Functions ]]--


function BAR:StickToEdge()

	local point, x, y= self:GetPosition()
	local changed
	local w, h, rTol = self:GetWidth()/2, self:GetHeight()/2, Neuron.SNAPTO_TOLLERANCE

	local function calcX(opt)
		if (opt == 1) then if (x <= w+rTol) then x = w; changed = true end
		elseif (opt == 2) then if (x >= -(w+rTol)) then x = -(w); changed = true end
		elseif (opt == 3) then if (math.abs(x) <= rTol) then x = 0; changed = true end
		end
	end

	local function calcY(opt)
		if (opt == 1) then if (y <= h+rTol) then y = h; changed = true end
		elseif (opt == 2) then if (y >= -(h+rTol)) then y = -(h); changed = true end
		elseif (opt == 3) then if (math.abs(y) <= rTol) then y = 0; changed = true end
		end
	end

	if (point == "CENTER") then calcX(3); calcY(3) end

	if (point:find("LEFT")) then calcX(1); calcY(3) end

	if (point:find("RIGHT")) then	calcX(2); calcY(3) end

	if (not changed and point:find("BOTTOM")) then calcX(3); calcY(1) end

	if (not changed and point:find("TOP")) then calcX(3); calcY(2) end

	if (changed) then
		self.data.point = point; self.data.x = x; self.data.y = y
		self:SetPosition()
	end
end

function BAR:Stick(oFrame, tolerance, xOff, yOff)

	xOff, yOff = xOff or 0, yOff or 0

	if (not canAttach(self, oFrame)) then return end

	local left, right, top, bottom = self:GetLeft(), self:GetRight(), self:GetTop(), self:GetBottom()
	local centerX, centerY = self:GetCenter()

	if (left and right and top and bottom and centerX) then

		local oScale = oFrame:GetScale()

		left = left/oScale; right = right/oScale; top = top/oScale; bottom = bottom/oScale

		centerX = centerX/oScale; centerY = centerY/oScale

	else return end


	local oLeft, oRight, oTop, oBottom = oFrame:GetLeft(), oFrame:GetRight(), oFrame:GetTop(), oFrame:GetBottom()
	local oCenterX, oCenterY = oFrame:GetCenter()

	if (oLeft and oRight and oTop and oBottom and oCenterX) then

		local scale = self:GetScale()

		oLeft = oLeft/scale; oRight = oRight/scale; oTop = oTop/scale; oBottom = oBottom/scale

		oCenterX = oCenterX/scale; oCenterY = oCenterY/scale

	else return end

	if ((oLeft - tolerance <= left and oRight + tolerance >= right) or (left - tolerance <= oLeft and right + tolerance >= oRight)) then

		local distCenter, distLeft, distRight = math.abs(oCenterX - centerX), math.abs(oLeft - left), math.abs(right - oRight)

		if (math.abs(oTop - bottom) <= tolerance) then
			return attachToTop(self, oFrame, distLeft, distRight, distCenter, yOff)
		elseif math.abs(oBottom - top) <= tolerance then
			return attachToBottom(self, oFrame, distLeft, distRight, distCenter, yOff)
		end
	end

	if ((oTop + tolerance >= top and oBottom - tolerance <= bottom) or (top + tolerance >= oTop and bottom - tolerance <= oBottom)) then

		local distCenter, distTop, distBottom = math.abs(oCenterY - centerY), math.abs(oTop - top), math.abs(oBottom - bottom)

		if (math.abs(oLeft - right) <= tolerance) then
			return attachToLeft(self, oFrame, distTop, distBottom, distCenter, xOff)
		end

		if (math.abs(oRight - left) <= tolerance) then
			return attachToRight(self, oFrame, distTop, distBottom, distCenter, xOff)
		end
	end

	if (oCenterX > centerX - tolerance/2 and oCenterX < centerX + tolerance/2 and oCenterY > centerY - tolerance/2 and oCenterY < centerY + tolerance/2) then
		return attachToCenter(self, oFrame)
	end
end

function BAR:StickToPoint(oFrame, point, xOff, yOff)

	xOff, yOff = xOff or 0, yOff or 0

	if (not (point and canAttach(self, oFrame))) then return end

	self:ClearAllPoints()

	if (point == "TL") then
		self:SetPoint("BOTTOMLEFT", oFrame, "TOPLEFT", 0, yOff); return point
	elseif (point == "TC") then
		self:SetPoint("BOTTOM", oFrame, "TOP", 0, yOff); return point
	elseif (point == "TR") then
		self:SetPoint("BOTTOMRIGHT", oFrame, "TOPRIGHT", 0, yOff);	return point
	end

	if (point == "BL") then
		self:SetPoint("TOPLEFT", oFrame, "BOTTOMLEFT", 0, -yOff); return point
	elseif (point == "BC") then
		self:SetPoint("TOP", oFrame, "BOTTOM", 0, -yOff); return point
	elseif (point == "BR") then
		self:SetPoint("TOPRIGHT", oFrame, "BOTTOMRIGHT", 0, -yOff); return point
	end

	if (point == "LB") then
		self:SetPoint("BOTTOMRIGHT", oFrame, "BOTTOMLEFT", -xOff, 0); return point
	elseif (point == "LC") then
		self:SetPoint("RIGHT", oFrame, "LEFT", -xOff, 0); return point
	elseif (point == "LT") then
		self:SetPoint("TOPRIGHT", oFrame, "TOPLEFT", -xOff, 0); return point
	end

	if (point == "RB") then
		self:SetPoint("BOTTOMLEFT", oFrame, "BOTTOMRIGHT", xOff, 0); return point
	elseif (point == "RC") then
		self:SetPoint("LEFT", oFrame, "RIGHT", xOff, 0); return point
	elseif (point == "RT") then
		self:SetPoint("TOPLEFT", oFrame, "TOPRIGHT", xOff, 0); return point
	end

	if (point == "CT") then
		self:SetPoint("CENTER", oFrame, "CENTER", 0, 0); return point
	end
end
