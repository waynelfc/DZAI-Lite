/*
	buildRifleArrays
	
	Description: Builds arrays of weapons from data found in CfgBuildingLoot. These arrays will determine the weapons assigned to AI units generated by DZAI. A list of exceptions can be passed to this script to remove specified weapon classnames.
	
	Last updated: 2:09 PM 6/13/2013
*/

private ["_bldgClasses","_weapons","_lootItem","_DZAI_bannedWeapons","_unwantedWeapons","_lootList","_cfgBuildingLoot","_lootListCheck"];

diag_log "Building DZAI weapon arrays using CfgBuildingLoot data.";

_bldgClasses = _this select 0;			//Building types to extract weapon classnames
_unwantedWeapons = _this select 1;		//User-specified weapon banlist.

_aiWeaponBanList = ["Crossbow_DZ","Crossbow","MeleeBaseBallBat","MeleeMachete"];

//Add user-specified banned weapons to DZAI weapon banlist.
if ((count _unwantedWeapons) > 0) then {
	for "_i" from 0 to ((count _unwantedWeapons) - 1) do {
		_aiWeaponBanList set [(count _aiWeaponBanList),(_unwantedWeapons select _i)];
	};
};
//diag_log format ["DEBUG :: List of weapons to be removed from DZAI classname tables: %1",_aiWeaponBanList];

//Compatibility with Namalsk's selectable loot table feature.
_cfgBuildingLoot = "";
if (isNil "dayzNam_buildingLoot") then {
	_cfgBuildingLoot = "cfgBuildingLoot";
} else {
	_cfgBuildingLoot = dayzNam_buildingLoot;
	(_bldgClasses select 3) set [((_bldgClasses select 3) find "HeliCrash"),"HeliCrashNamalsk"];
};

//diag_log format ["DEBUG :: _cfgBuildingLoot: %1",_cfgBuildingLoot];

//Fix for CfgBuildingLoot structure change in DayZ 1.7.7
_lootListCheck = isArray (configFile >> _cfgBuildingLoot >> "Default" >> "lootType");
//diag_log format ["DEBUG :: _lootListCheck: %1",_lootListCheck];
_lootList = "";
if (_lootListCheck) then {
	_lootList = "lootType";
} else {
	_lootList = "itemType";
};

//Declare weapon arrays
DZAI_Rifles0 = [];
DZAI_Rifles1 = [];
DZAI_Rifles2 = [];
DZAI_Rifles3 = [];

//Build the weapon arrays.
for "_i" from 0 to (count _bldgClasses - 1) do {					//_i = weapongrade
	for "_j" from 0 to (count (_bldgClasses select _i) - 1) do {	//If each weapongrade has more than 1 building class, investigate them all
		private["_bldgLoot"];
		_bldgLoot = [] + getArray (configFile >> "cfgBuildingLoot" >> ((_bldgClasses select _i) select _j) >> _lootList);
		for "_k" from 0 to (count _bldgLoot - 1) do {				
			_lootItem = _bldgLoot select _k;
			if ((_lootItem select 1) == "weapon") then {			//Build an array of "weapons", then categorize them as rifles or pistols, then sort them into the correct weapon grade.
				private ["_weaponItem","_weaponMags"];
				_weaponItem = _lootItem select 0;
				_weaponMags = count (getArray (configFile >> "cfgWeapons" >> _weaponItem >> "magazines"));
				if (_weaponMags > 0) then {							//Consider an item as a "weapon" if it has at least one magazine type.
					if !(_weaponItem in _unwantedWeapons) then {
						if ((getNumber (configFile >> "CfgWeapons" >> _weaponItem >> "type")) == 1) then {
							call compile format ["DZAI_Rifles%1 set [(count DZAI_Rifles%1),'%2'];",_i,_weaponItem];
						};
					};
				};
			};
		};
	};
};

//In case the mod has no HeliCrash loot tables...
if ((count DZAI_Rifles3) == 0) then {
	diag_log "DZAI_Rifles3 is empty. Populating with entries from DZAI_Rifles2.";
	DZAI_Rifles3 = [] + DZAI_Rifles2;
};

if (DZAI_debugLevel > 0) then {
	//Display finished weapon arrays
	diag_log format ["Contents of DZAI_Rifles0: %1",DZAI_Rifles0];
	diag_log format ["Contents of DZAI_Rifles1: %1",DZAI_Rifles1];
	diag_log format ["Contents of DZAI_Rifles2: %1",DZAI_Rifles2];
	diag_log format ["Contents of DZAI_Rifles3: %1",DZAI_Rifles3];
};

DZAI_weaponsInitialized = true;
