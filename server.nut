/* ############################################################## */
/* #			Extended Garages v1.0 R2 by Stoku				# */
/* #					Have fun!								# */
/* ############################################################## */

local szScriptDir = "Scripts/extended_garages/";

function onScriptLoad()
{
	Garages <- {};
	Garages_out <- {};
	UnArmedVehicles <- {};
	ArmedVehicles <- {};
	
	RegisterRemoteFunc( "EVENT_Prompt_Yes" );
	RegisterRemoteFunc( "EVENT_Prompt_No" );
	
	LoadModule( "lu_ini" );
	
	LoadGarages();
}

function LoadGarages()
{	
	if ( ReadIniBool( szScriptDir + "config.ini", "PORTLAND_PAYNSPRAY_GARAGE", "enabled" ) ) AddGarage( "PORTLAND_PAYNSPRAY_GARAGE", PORTLAND_PAYNSPRAY_GARAGE );
	if ( ReadIniBool( szScriptDir + "config.ini", "STAUNTON_PAYNSPRAY_GARAGE", "enabled" ) ) AddGarage( "STAUNTON_PAYNSPRAY_GARAGE", STAUNTON_PAYNSPRAY_GARAGE );
	if ( ReadIniBool( szScriptDir + "config.ini", "SSV_PAYNSPRAY_GARAGE", "enabled" ) ) AddGarage( "SSV_PAYNSPRAY_GARAGE", SSV_PAYNSPRAY_GARAGE );
	
	if ( ReadIniBool( szScriptDir + "config.ini", "PORTLAND_BOMBSHOP_GARAGE", "enabled" ) ) AddGarage( "PORTLAND_BOMBSHOP_GARAGE", PORTLAND_BOMBSHOP_GARAGE );
	if ( ReadIniBool( szScriptDir + "config.ini", "STAUNTON_BOMSHOP_GARAGE", "enabled" ) ) AddGarage( "STAUNTON_BOMSHOP_GARAGE", STAUNTON_BOMSHOP_GARAGE );
	if ( ReadIniBool( szScriptDir + "config.ini", "SSV_BOMBSHOP_GARAGE", "enabled" ) ) AddGarage( "SSV_BOMBSHOP_GARAGE", SSV_BOMBSHOP_GARAGE );
}

function AddGarage( szGarage, iGarage )
{
	local x = ReadIniFloat( szScriptDir + "config.ini", szGarage, "x" );
	local y = ReadIniFloat( szScriptDir + "config.ini", szGarage, "y" );
	local z = ReadIniFloat( szScriptDir + "config.ini", szGarage, "z" );
	
	local x_out = ReadIniFloat( szScriptDir + "config.ini", szGarage, "x_out" );
	local y_out = ReadIniFloat( szScriptDir + "config.ini", szGarage, "y_out" );
	local z_out = ReadIniFloat( szScriptDir + "config.ini", szGarage, "z_out" );
	
	// Bombshop
	if (( iGarage ==  3 ) || ( iGarage ==  9 ) || ( iGarage ==  22 ))
	{	
		CreateBlip( BLIP_8BALL, x, y, z );
		local pSphere = CreateSphere( Vector( x, y, z ), 4.0 );
		local pSphere_out = CreateSphere( Vector( x_out, y_out, z_out ), 4.0 );
		
		Garages.rawset( pSphere.ID, iGarage );
		Garages_out.rawset( pSphere_out.ID, iGarage );
	}
	
	// Pay'n'spray
	if (( iGarage ==  4 ) || ( iGarage ==  10 ) || ( iGarage ==  21 ))
	{	
		CreateBlip( BLIP_PNS, x, y, z );
		local pSphere = CreateSphere( Vector( x, y, z ), 4.0 );
		local pSphere_out = CreateSphere( Vector( x_out, y_out, z_out ), 4.0 );
		
		Garages.rawset( pSphere.ID, iGarage );
		Garages_out.rawset( pSphere_out.ID, iGarage );
	}
	
	print( szGarage + " " + iGarage );
}

function onPlayerEnterSphere( pPlayer, pSphere )
{
	pPlayer.Cash = 4000;
	if ( !pPlayer.Vehicle || pPlayer.VehicleSeat ) return 0;
	
	if ( Garages_out.rawin( pSphere.ID ) ) OpenGarage( Garages_out.rawget( pSphere.ID ) );
	if ( Garages.rawin( pSphere.ID ) )
	{
		local iGarage = Garages.rawget( pSphere.ID );
		local iCost = ReadIniInteger( szScriptDir + "config.ini", GetGarageFromID( iGarage ), "cost" );
	
		if ( pPlayer.Cash < iCost )
		{
			MessagePlayer( "You have not enough money. Cost - " + iCost + "$.", pPlayer, Colour( 255, 0, 0 ) );
			OpenGarage( iGarage );
			return 0;
		}
		
		pPlayer.Frozen = true;
		CloseGarage( iGarage );
			
		// Bombshop
		if (( iGarage ==  3 ) || ( iGarage ==  9 ) || ( iGarage ==  22 )) CallClientFunc( pPlayer, "extended_garages/client.nut", "ShowPromptWindow", "Do you want to arm your vehicle for " + iCost + "$?", iGarage );
		
		// Pay'n'spray	
		if (( iGarage ==  4 ) || ( iGarage ==  10 ) || ( iGarage ==  21 )) CallClientFunc( pPlayer, "extended_garages/client.nut", "ShowPromptWindow", "Do you want to respray your vehicle for " + iCost + "$?", iGarage );
	}
	
	return 1;
}

function onPlayerExitSphere( pPlayer, pSphere )
{
	if ( !pPlayer.Vehicle || pPlayer.VehicleSeat ) return 0;
	if ( Garages_out.rawin( pSphere.ID ) ) CloseGarage( Garages_out.rawget( pSphere.ID ) );
	
	return 1;
}

function EVENT_Prompt_Yes( pPlayer, iGarage )
{
	local iCost = ReadIniInteger( szScriptDir + "config.ini", GetGarageFromID( iGarage ), "cost" );
	local pVehicle = pPlayer.Vehicle;
	
	pPlayer.Cash -= iCost;
	pPlayer.Frozen = false;
	OpenGarage( iGarage );
	
	// Pay'n'spray	
	if (( iGarage ==  4 ) || ( iGarage ==  10 ) || ( iGarage ==  21 )) pVehicle.Fix();
	
	// Bombshop
	if (( iGarage ==  3 ) || ( iGarage ==  9 ) || ( iGarage ==  22 ))
	{
		SmallMessage( pPlayer, "Now use detonator to arm the bomb.", 2000, 1 );
		
		UnArmedVehicles.rawset( pPlayer.ID, pVehicle.ID );
		pPlayer.SetWeapon( 12, 1 );
	}
	
	return 1;
}

function EVENT_Prompt_No( pPlayer, iGarage )
{
	pPlayer.Frozen = false;
	OpenGarage( iGarage );
	
	return 1;
}

function GetGarageFromID( iGarage )
{
	switch( iGarage )
	{
		case PORTLAND_PAYNSPRAY_GARAGE:
			return "PORTLAND_PAYNSPRAY_GARAGE";
		case STAUNTON_PAYNSPRAY_GARAGE:
			return "STAUNTON_PAYNSPRAY_GARAGE";
		case SSV_PAYNSPRAY_GARAGE:
			return "SSV_PAYNSPRAY_GARAGE";
			
		case PORTLAND_BOMBSHOP_GARAGE:
			return "PORTLAND_BOMBSHOP_GARAGE";
		case STAUNTON_BOMSHOP_GARAGE:
			return "STAUNTON_BOMSHOP_GARAGE";
		case SSV_BOMBSHOP_GARAGE:
			return "SSV_BOMBSHOP_GARAGE";
	}
}

function onPlayerUseDetonator( pPlayer )
{	
	local bUnArmedVehicle = UnArmedVehicles.rawin( pPlayer.ID );
	
	if ( bUnArmedVehicle )
	{
		local iVehicle = UnArmedVehicles.rawget( pPlayer.ID );
		
		ArmedVehicles.rawset( iVehicle, pPlayer.ID );
		UnArmedVehicles.rawdelete( pPlayer.ID );
		
		SmallMessage( pPlayer, "Bomb has been armed.", 2000, 1 );
	}
}

function onPlayerEnteredVehicle( pPlayer, pVehicle, iSeat )
{
	local bArmedVehicle = ArmedVehicles.rawin( pVehicle.ID );
	
	if ( bArmedVehicle )
	{
		local iPlayerID = ArmedVehicles.rawget( pVehicle.ID );
		
		
		ArmedVehicles.rawdelete( pVehicle.ID );
		pVehicle.Explode( FindPlayer( iPlayerID ));
	}
}