--Neuron , a World of Warcraft® user interface addon.
--SnapTo code is a modified version of FlyPaper by Tuller

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


function Neuron.NeuronBar:StickToEdge(bar)

	local DB = Neuron.db.profile

	local point, x, y= Neuron.NeuronBar:GetPosition(bar)
	local changed
	local w, h, rTol = bar:GetWidth()/2, bar:GetHeight()/2, DB.snapToTol

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
		bar.data.point = point; bar.data.x = x; bar.data.y = y
		Neuron.NeuronBar:SetPosition(bar)
	end
end

function Neuron.NeuronBar:Stick(bar, oFrame, tolerance, xOff, yOff)

	xOff, yOff = xOff or 0, yOff or 0

	if (not canAttach(bar, oFrame)) then return end

	local left, right, top, bottom = bar:GetLeft(), bar:GetRight(), bar:GetTop(), bar:GetBottom()
	local centerX, centerY = bar:GetCenter()

	if (left and right and top and bottom and centerX) then

		local oScale = oFrame:GetScale()

		left = left/oScale; right = right/oScale; top = top/oScale; bottom = bottom/oScale

		centerX = centerX/oScale; centerY = centerY/oScale

	else return end


	local oLeft, oRight, oTop, oBottom = oFrame:GetLeft(), oFrame:GetRight(), oFrame:GetTop(), oFrame:GetBottom()
	local oCenterX, oCenterY = oFrame:GetCenter()

	if (oLeft and oRight and oTop and oBottom and oCenterX) then

		local scale = bar:GetScale()

		oLeft = oLeft/scale; oRight = oRight/scale; oTop = oTop/scale; oBottom = oBottom/scale

		oCenterX = oCenterX/scale; oCenterY = oCenterY/scale

	else return end

	if ((oLeft - tolerance <= left and oRight + tolerance >= right) or (left - tolerance <= oLeft and right + tolerance >= oRight)) then

		local distCenter, distLeft, distRight = math.abs(oCenterX - centerX), math.abs(oLeft - left), math.abs(right - oRight)

		if (math.abs(oTop - bottom) <= tolerance) then
			return attachToTop(bar, oFrame, distLeft, distRight, distCenter, yOff)
		elseif math.abs(oBottom - top) <= tolerance then
			return attachToBottom(bar, oFrame, distLeft, distRight, distCenter, yOff)
		end
	end

	if ((oTop + tolerance >= top and oBottom - tolerance <= bottom) or (top + tolerance >= oTop and bottom - tolerance <= oBottom)) then

		local distCenter, distTop, distBottom = math.abs(oCenterY - centerY), math.abs(oTop - top), math.abs(oBottom - bottom)

		if (math.abs(oLeft - right) <= tolerance) then
			return attachToLeft(bar, oFrame, distTop, distBottom, distCenter, xOff)
		end

		if (math.abs(oRight - left) <= tolerance) then
			return attachToRight(bar, oFrame, distTop, distBottom, distCenter, xOff)
		end
	end

	if (oCenterX > centerX - tolerance/2 and oCenterX < centerX + tolerance/2 and oCenterY > centerY - tolerance/2 and oCenterY < centerY + tolerance/2) then
		return attachToCenter(bar, oFrame)
	end
end

function Neuron.NeuronBar:StickToPoint(bar, oFrame, point, xOff, yOff)

	xOff, yOff = xOff or 0, yOff or 0

	if (not (point and canAttach(bar, oFrame))) then return end

	bar:ClearAllPoints()

	if (point == "TL") then
		bar:SetPoint("BOTTOMLEFT", oFrame, "TOPLEFT", 0, yOff); return point
	elseif (point == "TC") then
		bar:SetPoint("BOTTOM", oFrame, "TOP", 0, yOff); return point
	elseif (point == "TR") then
		bar:SetPoint("BOTTOMRIGHT", oFrame, "TOPRIGHT", 0, yOff);	return point
	end

	if (point == "BL") then
		bar:SetPoint("TOPLEFT", oFrame, "BOTTOMLEFT", 0, -yOff); return point
	elseif (point == "BC") then
		bar:SetPoint("TOP", oFrame, "BOTTOM", 0, -yOff); return point
	elseif (point == "BR") then
		bar:SetPoint("TOPRIGHT", oFrame, "BOTTOMRIGHT", 0, -yOff); return point
	end

	if (point == "LB") then
		bar:SetPoint("BOTTOMRIGHT", oFrame, "BOTTOMLEFT", -xOff, 0); return point
	elseif (point == "LC") then
		bar:SetPoint("RIGHT", oFrame, "LEFT", -xOff, 0); return point
	elseif (point == "LT") then
		bar:SetPoint("TOPRIGHT", oFrame, "TOPLEFT", -xOff, 0); return point
	end

	if (point == "RB") then
		bar:SetPoint("BOTTOMLEFT", oFrame, "BOTTOMRIGHT", xOff, 0); return point
	elseif (point == "RC") then
		bar:SetPoint("LEFT", oFrame, "RIGHT", xOff, 0); return point
	elseif (point == "RT") then
		bar:SetPoint("TOPLEFT", oFrame, "TOPRIGHT", xOff, 0); return point
	end

	if (point == "CT") then
		bar:SetPoint("CENTER", oFrame, "CENTER", 0, 0); return point
	end
end
