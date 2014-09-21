#define GUI_GRID_X	(0)
#define GUI_GRID_Y	(0)
#define GUI_GRID_W	(0.03125)
#define GUI_GRID_H	(0.05)

#define COLOR_MENU_BG { 0, 0, 0, 0.7 }

class MFInsuranceDialog
{
	idd = 1000;
	movingEnable = 0;
	class controlsBackground { 
		class MFInsuranceDialog_Window: RscText
		{
			colorBackground[] = COLOR_MENU_BG;
			text = "";
			idc = 1800;
			x = 0.293783 * safezoneW + safezoneX;
			y = 0.225091 * safezoneH + safezoneY;
			w = 0.413868 * safezoneW;
			h = 0.552792 * safezoneH;	
		};
	};
	class objects { 
		// define controls here
	};
	class controls {
		class MFInsuranceDialog_MenuTitle: RscStructuredText
		{
			idc = 1100;
			text = "Vehicle Insurance Menu | MF-Insurance";
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 0.0736115 * GUI_GRID_H + GUI_GRID_Y;
			w = 32.0417 * GUI_GRID_W;
			h = 0.92639 * GUI_GRID_H;
		};
		class MFInsuranceDialog_VehicleList: RscListbox
		{
			idc = 1500;
			x = 0.306678 * safezoneW + safezoneX;
			y = 0.307564 * safezoneH + safezoneY;
			w = 0.14177 * safezoneW;
			h = 0.398618 * safezoneH;
		};
		class MFInsuranceDialog_Button_Close: RscShortcutButton
		{
			idc = 1700;
			text = "Close";
			x = 0.5 * GUI_GRID_W + GUI_GRID_X;
			y = 18 * GUI_GRID_H + GUI_GRID_Y;
			w = 4.72141 * GUI_GRID_W;
			h = 2.18403 * GUI_GRID_H;
			onButtonClick = "((ctrlParent (_this select 0)) closeDisplay 9000);";
			class Attributes
			{
				align = "left";
			};
		};
		class MFInsuranceDialog_FilterComboBox: RscCombo
		{
			idc = 2100;
			x = 1 * GUI_GRID_W + GUI_GRID_X;
			y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 11.1259 * GUI_GRID_W;
			h = 0.895841 * GUI_GRID_H;
			tooltip = "Filter vehicle list by type.";
		};
		class MFInsuranceDialog_VehiclePicture: RscPicture
		{
			idc = 1200;
			text = "";
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 18 * GUI_GRID_W;
			h = 9.5 * GUI_GRID_H;
			style = 2096;
		};
		class MFInsuranceDialog_VehicleInfoPane: RscFrame
		{
			idc = 1801;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 13 * GUI_GRID_H + GUI_GRID_Y;
			w = 13 * GUI_GRID_W;
			h = 6.5 * GUI_GRID_H;
		};
		class MFInsuranceDialog_VehicleInfoPane_PaymentDueDate: RscText
		{
			idc = 1000;
			text = "Payment Due: DD/MM/YYYY";
			x = 0.46778 * safezoneW + safezoneX;
			y = 0.719927 * safezoneH + safezoneY;
			w = 0.213193 * safezoneW;
			h = 0.0218399 * safezoneH;
		};
		class MFInsuranceDialog_VehicleInfoPane_Status: RscText
		{
			idc = 1001;
			text = "";
			type = CT_STRUCTURED_TEXT;
			style = ST_LEFT;
			size = 0.03921;
			x = 0.46778 * safezoneW + safezoneX;
			y = 0.596218 * safezoneH + safezoneY;
			w = 0.213193 * safezoneW;
			h = 0.0218399 * safezoneH;
		};
		class MFInsuranceDialog_VehicleInfoPane_InsuranceCost: RscText
		{
			idc = 1002;
			text = "";
			x = 0.46778 * safezoneW + safezoneX;
			y = 0.623709 * safezoneH + safezoneY;
			w = 0.213193 * safezoneW;
			h = 0.0218399 * safezoneH;
		};
		class MFInsuranceDialog_VehicleInfoPane_PaymentFrequency: RscText
		{
			idc = 1003;
			text = "";
			x = 0.46778 * safezoneW + safezoneX;
			y = 0.6512 * safezoneH + safezoneY;
			w = 0.213193 * safezoneW;
			h = 0.0218399 * safezoneH;
		};
		class MFInsuranceDialog_VehicleInfoPane_Balance: RscText
		{
			idc = 1004;
			text = "";
			type = CT_STRUCTURED_TEXT;
			style = ST_LEFT;
			size = 0.03921;
			x = 0.46778 * safezoneW + safezoneX;
			y = 0.692436 * safezoneH + safezoneY;
			w = 0.213193 * safezoneW;
			h = 0.0218399 * safezoneH;
		};
		class MFInsuranceDialog_Button_Remove: RscShortcutButton
		{
			idc = 1702;
			text = "Remove";
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.13847 * GUI_GRID_W;
			h = 2.18403 * GUI_GRID_H;
			class Attributes
			{
				align = "left";
			};
		};
		class MFInsuranceDialog_Button_Recover: RscShortcutButton
		{
			idc = 1703;
			text = "Recover";
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.13847 * GUI_GRID_W;
			h = 2.18403 * GUI_GRID_H;
			class Attributes
			{
				align = "left";
			};
		};
		class MFInsuranceDialog_Button_Pay: RscShortcutButton
		{
			idc = 1701;
			text = "Pay";
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 18 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.13847 * GUI_GRID_W;
			h = 2.18403 * GUI_GRID_H;
			class Attributes
			{
				align = "left";
			};
		};
		class MFInsuranceDialog_Button_Insure: RscShortcutButton
		{
			idc = 1704;
			text = "Insure";
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 18 * GUI_GRID_H + GUI_GRID_Y;
			w = 5.13847 * GUI_GRID_W;
			h = 2.18403 * GUI_GRID_H;
			tooltip = "Insure this vehicle.";
			class Attributes
			{
				align = "left";
			};
		};
		class MFInsuranceDialog_VehicleTitle: RscText
		{
			idc = 1005;
			text = "";
			x = 0.461336 * safezoneW + safezoneX;
			y = 0.266327 * safezoneH + safezoneY;
			w = 0.232524 * safezoneW;
			h = 0.0224318 * safezoneH;
		};
	};
};