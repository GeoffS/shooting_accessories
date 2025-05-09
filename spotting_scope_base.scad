include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

layerHeight = 0.2;

baseBottomOD = 240;
baseTopOD = 40;
baseCylinderZ = 10;
baseConeZ = 100;
baseZ = 160;

boltRecessDia = 12.9;
boltHeadRecessTopZ = baseZ - 14;
boltHeadRecessZ = 5;
boltHeadRecessBotZ = boltHeadRecessTopZ - boltHeadRecessZ;

boltHeadAccessDia = boltRecessDia + 5;
boltHeadAccessTaperZ = 5;

module itemModule()
{
	difference()
	{
		baseExterior();

		baseInterior();

		// Screw hole:
		tcy([0,0,-1], d=0.25 * 25.4 + 1, h=300);

		// Bolt head recess:
		tcy([0,0,boltHeadRecessBotZ], d=boltRecessDia, h=boltHeadRecessZ, $fn=6);

		// Taper to bolt-head recess:
		hull()
		{
			tcy([0,0,boltHeadRecessBotZ], d=boltRecessDia, h=nothing, $fn=6);
			tcy([0,0,boltHeadRecessBotZ-boltHeadRecessZ-boltHeadAccessTaperZ-100], d=boltHeadAccessDia, h=100);
		}
	}

	// Sacrificial layer at bottom of bolt-head access recess:
	// MAGIC NUMBER: 76/170, 91/200
	// sacrificialLayerZ = 30/170 * baseBottomOD;
	sacrificialLayerZ = baseBottomOD/2 - 9;
	echo(str("sacrificialLayerZ = ", sacrificialLayerZ));
	tcy([0,0,sacrificialLayerZ], d=20, h=layerHeight);
}

module baseExterior()
{
	// Cone base:
	cylinder(d=baseBottomOD, h=baseCylinderZ+nothing);
	translate([0,0,baseCylinderZ]) cylinder(d1=baseBottomOD, d2=0, h=baseBottomOD/2);

	// Post:
	baseTopCZ = 6;
	simpleChamferedCylinder(d=baseTopOD+baseTopCZ, h=baseZ, cz=baseTopCZ/2);
}

module baseInterior()
{
	baseBottomID = baseBottomOD - 20;
	cylZ = 10;
	baseeInnerConeZ = baseBottomID/2;
	tcy([0,0,-1+nothing], d=baseBottomID, h=cylZ+1);
	translate([0,0,cylZ]) cylinder(d1=baseBottomID, d2=0, h=baseeInnerConeZ);
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
