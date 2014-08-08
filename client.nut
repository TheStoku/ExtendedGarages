/* ############################################################## */
/* #			Extended Garages v1.0 R3 by Stoku				# */
/* #					Have fun!								# */
/* ############################################################## */

gPromptWindow <- null;
gPromptButton1 <- null;
gPromptButton2 <- null;

local iGarageID = 0;

local KEY_ACCEPT = 'Y';
local KEY_CANCEL = 'N';

pLocalPlayer <- FindLocalPlayer();

function onScriptLoad()
{
	local GUI_WINDOW_ALPHA 			= 200;							// Window alpha channel
	local GUI_ELEMENT_ALPHA 		= 50;							// Elements alpha channel
	local GUI_TITLE_BAR 			= false;						// Enable/disable window titlebars
	local GUI_TEXT_COLOR 			= Colour( 150, 150, 150 );		// Label/editbox text color
	local GUI_WINDOW_COLOR 			= Colour( 43, 43, 55 );			// Window color
	local GUI_BUTTON_COLOR 			= Colour( 65, 81, 71 );			// Button color
	local GUI_BUTTON_TEXT_COLOR 	= Colour( 216, 157, 0 );		// Button text color
	local GUI_HEALTHBAR_COLOR 		= Colour( 185, 100, 50 );		// Health bar color
	local GUI_ARMORBAR_COLOR 		= Colour( 121, 137, 93 );		// Armor bar color
	
	local promptWindow = [ (ScreenWidth/2)-250, (ScreenHeight/2), 500, 35, "Are you sure want to respray your car for 1000$?" ];	// X pos, Y pos, X Size, Y Size, Text
	local promptWindowButton1 = [ 5, 5, 240, 25, "Yes" ];											// X pos, Y pos, X Size, Y Size, Text
	local promptWindowButton2 = [ 250, 5, 240, 25, "No" ];											// X pos, Y pos, X Size, Y Size, Text
	
	gPromptWindow = GUIWindow( VectorScreen( promptWindow[0], promptWindow[1] ), ScreenSize( promptWindow[2], promptWindow[3] ), promptWindow[4] );
	if ( GUI_WINDOW_COLOR ) gPromptWindow.Colour = GUI_WINDOW_COLOR;
	gPromptWindow.Titlebar = true;
	gPromptWindow.Moveable = true;
	gPromptWindow.Alpha = GUI_WINDOW_ALPHA;
	gPromptWindow.Visible = false;
	
	/* Yes */
	gPromptButton1 = GUIButton( VectorScreen( promptWindowButton1[0], promptWindowButton1[1] ), ScreenSize( promptWindowButton1[2], promptWindowButton1[3] ), promptWindowButton1[4] );
	if ( GUI_BUTTON_COLOR ) gPromptButton1.Colour = GUI_BUTTON_COLOR;
	gPromptButton1.FontTags = TAG_BOLD;
	gPromptButton1.SetCallbackFunc( Prompt_Handle1 );
	gPromptButton1.TextColour = GUI_BUTTON_TEXT_COLOR;
	gPromptButton1.Alpha = GUI_ELEMENT_ALPHA;
	gPromptButton1.Flags = FLAG_SHADOW;
	gPromptButton1.Visible = true;
	
	/* No */
	gPromptButton2 = GUIButton( VectorScreen( promptWindowButton2[0], promptWindowButton2[1] ), ScreenSize( promptWindowButton2[2], promptWindowButton2[3] ), promptWindowButton2[4] );
	if ( GUI_BUTTON_COLOR ) gPromptButton2.Colour = GUI_BUTTON_COLOR;
	gPromptButton2.FontTags = TAG_BOLD;
	gPromptButton2.SetCallbackFunc( Prompt_Handle2 );
	gPromptButton2.TextColour = GUI_BUTTON_TEXT_COLOR;
	gPromptButton2.Alpha = GUI_ELEMENT_ALPHA;
	gPromptButton2.Flags = FLAG_SHADOW;
	gPromptButton2.Visible = true;
	
	AddGUILayer( gPromptWindow );
	gPromptWindow.AddChild( gPromptButton1 );
	gPromptWindow.AddChild( gPromptButton2 );
	
	ShowMouseCursor( true );
}

function Prompt_Handle1()
{
	CallServerFunc( "extended_garages/server.nut", "EVENT_Prompt_Yes", pLocalPlayer, iGarageID );
	
	ClosePromptWindow();
}

function Prompt_Handle2()
{
	CallServerFunc( "extended_garages/server.nut", "EVENT_Prompt_No", pLocalPlayer, iGarageID );
	
	ClosePromptWindow();
}

function ShowPromptWindow( szText, iGarage )
{
	BindKey( KEY_ACCEPT, BINDTYPE_DOWN, "Prompt_Handle1" );
	BindKey( KEY_CANCEL, BINDTYPE_DOWN, "Prompt_Handle2" );
	
	iGarageID = iGarage;
	
	gPromptWindow.TitleText = szText;
	
	gPromptWindow.Visible = true;
	ShowMouseCursor( true );
}

function ClosePromptWindow()
{
	UnBindKey( KEY_ACCEPT, BINDTYPE_DOWN, "Prompt_Handle1" );
	UnBindKey( KEY_CANCEL, BINDTYPE_DOWN, "Prompt_Handle2" );
	
	ShowMouseCursor( false );
	gPromptWindow.Visible = false;
}