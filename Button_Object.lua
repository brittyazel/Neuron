--Neuron, a World of Warcraft® user interface addon.



---@class BUTTON : CheckButton
local BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BUTTON = BUTTON



---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@param frameType string @ Type of frame to create
---@param frameTemplate @ Template used for our new frame
---@param objMetaTable @ Metatable object to be assigned as the template for our new button
---@return BUTTON @ A newly created BUTTON object
function BUTTON:new(name, frameType, frameTemplate, objMetaTable)

	local object = CreateFrame(frameType, name, UIParent, frameTemplate)

	setmetatable(object, objMetaTable)

	return object
end

function BUTTON:SetData(bar)
	--empty--
end

function BUTTON:LoadData(spec,state)
	--empty--
end

function BUTTON:SetObjectVisibility(show)
	--empty--
end

function BUTTON:SetAux()
	--empty--
end

function BUTTON:LoadAux()
	--empty--
end

function BUTTON:SetDefaults(config, keys)
	--empty--
end

function BUTTON:GetDefaults()
	--empty--
end

function BUTTON:SetType(save, kill, init)
	--empty--
end

function BUTTON:SetSkinned(flyout)
	--empty--
end

function BUTTON:GetSkinned()
	--empty--
end