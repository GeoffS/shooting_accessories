include <../OpenSCAD_Lib/MakeInclude.scad>

brassOD = 5.75;
brassRimOD = 6.9;
cartridgeLen = 26;

troughWallX = 3;
troughCornerDia = 2*troughWallX;
troughX = brassRimOD + 2*troughWallX + 2;
troughY = 40;
troughZ = cartridgeLen + 2;

module itemModule()
{
	difference()
    {
        // Trough exterior:
        translate([0, troughY/2, 0]) 
            hull() 
                doubleX() doubleY() 
                    translate([troughX/2-troughCornerDia/2, troughY/2-troughCornerDia/2, 0]) 
                        cylinder(d=troughCornerDia, h=troughZ);

        // Cartridge slot:
        translate([0,0,-10]) hull()
        {
            tcy([0, -10, 0], d=brassOD, h=100);
            tcy([0, 100, 0], d=brassOD, h=100);
        }

        // // Rim recess:
        // translate([0, troughY/2, 0]) 
        //     hull() 
        //         doubleX() doubleY() 
        //             translate([troughX/2-troughCornerDia/2, troughY/2-troughCornerDia/2, 0]) 
        //                 cylinder(d=troughCornerDia, h=troughZ);
    }
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
