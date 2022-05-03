---------------------------------------
--    POLI Top-Down Weapon System    --
-- More info in WeaponHandler Script --
---------------------------------------
--			  Version 4.0            --
-- 		Date Created : 1/5/2021      --
---------------------------------------

local module = {
	weaponName  = "Name";
	weaponType  = "Type"; -- Normal, Shotgun, Energy
	fireType    = "FullAuto"; -- FullAuto or SemiAuto
	damage      = 50;
	fireRate    = 0.11;
	coolDown    = 1; -- Only applicable when weaponType is SemiAuto.
	maxAmmo     = 35;
	penetration = true;
	penValue    = 5; -- Only applicable when penetration = true.
	numShots    = 5; -- Only applicable when weaponType is Shotgun.
	bulletSpeed = 175;
	spread      = 1;
	reloadTime  = 3;
	DEBUG       = false;
}
return module
