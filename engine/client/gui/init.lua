--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: GUI interface
--
--==========================================================================--

require( "engine.client.gui.scheme" )

local love    = love
local math    = math
local require = require
local _G      = _G

module( "gui" )

require( "engine.client.gui.autoloader" )
require( "engine.client.gui.handlers" )

function invalidateTree()
	_rootPanel:invalidateLayout()
	_rootPanel:invalidateFramebuffer()
	_viewportFramebuffer = nil
	_blurFramebuffer     = nil
end

function preDrawWorld()
	_rootPanel:preDrawWorld()
end

function scale( n )
	return math.round( n * ( love.graphics.getHeight() / 1080 ) )
end

function setFocusedPanel( panel, focus )
	if ( _focusedPanel ) then
		_focusedPanel.focus = nil

		if ( _focusedPanel.onLostFocus ) then
			_focusedPanel:onLostFocus()
		end

		if ( _focusedPanel ) then
			_focusedPanel:invalidate()
		end
	end

	if ( focus ) then
		_focusedPanel = panel
		if ( panel and panel.canFocus ) then
			panel.focus = focus

			if ( _focusedPanel.onFocus ) then
				_focusedPanel:onFocus()
			end

			panel:invalidate()
		end
	else
		_focusedPanel = nil
		if ( panel ) then
			panel.focus = nil
			panel:invalidate()
		end
	end
end
