--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region Layer class
--
--============================================================================--

class( "regionlayer" )

function regionlayer:regionlayer( layerData )
	self.data = layerData
end

if ( _CLIENT ) then
	function regionlayer:createSpriteBatch()
		local tileset = self:getTileset()
		if ( not tileset ) then
			return
		end

		local image = tileset:getImage()
		local count = self:getWidth() * self:getHeight()
		self.spritebatch = graphics.newSpriteBatch( image:getDrawable(), count )
	end

	function regionlayer:draw()
		if ( self:getType() ~= "tilelayer" ) then
			return
		end

		local spritebatch = self:getSpriteBatch()
		if ( not spritebatch ) then
			return
		end

		graphics.push()
			graphics.translate( self:getX(), self:getY() )
			graphics.setOpacity( self:getOpacity() )
			graphics.setColor( color.white )
			graphics.draw( spritebatch )
		graphics.pop()
	end
end

mutator( regionlayer, "data" )

function regionlayer:getHighestTileGid()
	local highestTileGid = -1
	for xy, gid in ipairs( self:getData() ) do
		if ( gid >= highestTileGid ) then
			highestTileGid = gid
		end
	end
	return highestTileGid
end

mutator( regionlayer, "name" )
mutator( regionlayer, "opacity" )
mutator( regionlayer, "properties" )
mutator( regionlayer, "region" )

if ( _CLIENT ) then
	accessor( regionlayer, "spriteBatch", "spritebatch" )
end

mutator( regionlayer, "tileset" )
mutator( regionlayer, "type" )
mutator( regionlayer, "width" )
mutator( regionlayer, "height" )
mutator( regionlayer, "x" )
mutator( regionlayer, "y" )

if ( _CLIENT ) then
	function regionlayer:initializeTiles()
		self:createSpriteBatch()

		local spritebatch = self:getSpriteBatch()
		if ( not spritebatch ) then
			return
		end

		local tileset  = self:getTileset()
		local tileW    = tileset:getTileWidth()
		local tileH    = tileset:getTileHeight()
		local image    = tileset:getImage()
		local imgW     = image:getWidth()
		local imgH     = image:getHeight()
		local quad     = graphics.newQuad( 0, 0, tileW, tileH, imgW, imgH )
		local id       = 0
		local tileX    = 0
		local tileY    = 0
		local firstgid = tileset:getFirstGid()
		local floor    = math.floor
		local x        = 0
		local y        = 0
		local width    = self:getWidth()
		local height   = self:getHeight()
		for xy, gid in ipairs( self:getData() ) do
			if ( gid ~= 0 ) then
				id    = gid - firstgid
				tileX =      ( id * tileW % imgW )
				tileY = floor( id * tileW / imgW ) * tileH
				quad:setViewport( tileX, tileY, tileW, tileH )

				x =      ( ( xy - 1 ) % width ) * tileW
				y = floor( ( xy - 1 ) / width ) * tileH
				spritebatch:add( quad, self:getX() + x, self:getY() + y )
			end
		end
	end
end

function regionlayer:isVisible()
	return self.visible
end

function regionlayer:parse()
	if ( not self.data ) then
		return
	end

	local data = self.data
	self:setType( data[ "type" ] )
	self:setName( data[ "name" ] )
	self:setX( data[ "x" ] )
	self:setY( data[ "y" ] )
	self:setWidth( data[ "width" ] )
	self:setHeight( data[ "height" ] )
	self:setVisible( data[ "visible" ] )
	self:setOpacity( data[ "opacity" ] )
	self:setProperties( table.copy( data[ "properties" ] ) )

	local type = self:getType()
	if ( type == "tilelayer" ) then
		self:setData( table.copy( data[ "data" ] ) )
	elseif ( type == "objectgroup" ) then
		if ( not self:isVisible() ) then
			return
		end

		if ( _SERVER ) then
			require( "engine.shared.entities" )
			local region   = self:getRegion()
			local entities = entities.initialize( region, data[ "objects" ] )
			for _, entity in ipairs( entities ) do
				region:addEntity( entity )
			end
		end
	end

	-- self.data = nil
end

function regionlayer:setTileset( tileset )
	self.tileset = tileset

	if ( _CLIENT ) then
		if ( self:getType() == "tilelayer" ) then
			self:initializeTiles()
		end
	end
end

function regionlayer:setVisible( visible )
	self.visible = visible
end

function regionlayer:__tostring()
	return "regionlayer: \"" .. self:getName() .. "\""
end
