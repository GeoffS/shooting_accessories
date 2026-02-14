include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

origLen = 37.42;
remove = 2.31;

boltHoleDia = 5;
nutRoundRecessDia = 11.5;
nutHexRecessDia = nutRoundRecessDia;

finalLen = origLen - remove;
echo(str("finalLen = ", finalLen));

heatsinkNutsRecessZ = 13.4;
nylocNutZ = 6.2;

nutsRecessZ = heatsinkNutsRecessZ + nylocNutZ + 2;
echo(str("nutsRecessZ = ", nutsRecessZ));

module itemModule()
{
	difference() 
    {
        simpleChamferedCylinder(d=17, h=finalLen, cz=2);

        tcy([0,0,-10], d=boltHoleDia, h=200);
        tcy([0,0,-100+nutsRecessZ], d=nutHexRecessDia, h=100, $fn=6);

        for (a = [0, 60, 120, 180, 240, 300]) 
        {
            rotate([0,0,a]) translate([nutHexRecessDia/2, 0, -100+nutsRecessZ]) cylinder(d=2, h=100);
        }
    }
}

module clip(d=0)
{
	tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	rotate([180,0,0]) itemModule();
}
