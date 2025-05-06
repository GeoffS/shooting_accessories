include <../OpenSCAD_Lib/MakeInclude.scad>

baseBottomOD = 170;
baseTopOD = 40;
baseCylinderZ = 10;
baseConeZ = 100;


baseZ = baseConeZ + baseCylinderZ;

module itemModule()
{
	difference()
	{
		baseExterior();
	}
}

module baseExterior()
{
	cylinder(d=baseBottomOD, h=baseCylinderZ+nothing);
	translate([0,0,baseCylinderZ]) cylinder(d1=baseBottomOD, d2=baseTopOD, h=baseConeZ);
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
