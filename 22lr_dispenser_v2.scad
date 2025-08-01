include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

makeOrienter = false;


centerHoleDia = brassRimOD + 1;

orienterBaseCZ = 2;
orienterExteriorWallThickness = 2*orienterBaseCZ + 2;
orienterBaseDia = centerHoleDia + 2*cartridgeLen + 2*orienterExteriorWallThickness;

orienterFunnelZ = 20;

orienterBaseZ = 3;

orienterZ = orienterBaseZ + cartridgeLen + orienterFunnelZ;

module orienter()
{
    difference() 
    {
        // Exterior:
        simpleChamferedCylinderDoubleEnded(d=orienterBaseDia, h=orienterZ, cz=orienterBaseCZ);
    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
    // tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	display() orienter();
}
else
{
	if(makeOrienter) orienter();
}
