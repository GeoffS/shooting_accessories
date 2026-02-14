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
// nylocExtendsPastEndZ = 0.5;

// nylocRecessZ = nylocNutZ - nylocExtendsPastEndZ;

nutsRecessZ = heatsinkNutsRecessZ + nylocNutZ + 0.5;
echo(str("nutsRecessZ = ", nutsRecessZ));

module itemModule()
{
	difference() 
    {
        simpleChamferedCylinder(d=20, h=finalLen, cz=2);

        tcy([0,0,-10], d=boltHoleDia, h=200);
        tcy([0,0,-100+nutsRecessZ], d=nutHexRecessDia, h=100, $fn=6);
        // tcy([0,0,nylocRecessZ-nothing], d=nutRoundRecessDia, h=roundRecessZ);
        // hull()
        // {
        //     tcy([0,0,nylocRecessZ-nothing], d=nutRoundRecessDia, h=0.1);
        //     tcy([0,0,nylocRecessZ-1], d=nutHexRecessDia, h=0.1, $fn=6);
        // }
        // tcy([0,0,-100+nylocRecessZ-1+nothing], d=nutHexRecessDia, h=100, $fn=6);
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
