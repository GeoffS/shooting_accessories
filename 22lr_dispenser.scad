include <../OpenSCAD_Lib/MakeInclude.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
cartridgeLen = 26;

troughWallX = 3;
troughCornerDia = 2*troughWallX;
troughX = brassRimOD + 2*troughWallX + 2;
troughY = 40;
troughZ = cartridgeLen + 2;

baseX = troughX + 6;
baseY = troughY;
baseOffsetY = 10;
baseZ = 2;
baseCornerDia = 10;

totalZ = baseZ + troughZ;

frontZ = 4;

module itemModule()
{
	difference()
    {
        union()
        {
            // // Trough exterior:
            // translate([0, troughY/2, 0]) 
            //     hull() 
            //         doubleX() doubleY() 
            //             translate([troughX/2-troughCornerDia/2, troughY/2-troughCornerDia/2, 0]) 
            //                 cylinder(d=troughCornerDia, h=totalZ);
            hull()
            {
                dy = troughZ - frontZ + 6;
                doubleX() tcy([troughX/2-troughCornerDia/2, troughCornerDia/2, totalZ-frontZ], d=troughCornerDia, h=frontZ);
                doubleX() tcy([troughX/2-troughCornerDia/2, dy-troughCornerDia/2, 0], d=troughCornerDia, h=totalZ);
                doubleX() tcy([troughX/2-troughCornerDia/2, troughY-troughCornerDia/2, 0], d=troughCornerDia, h=totalZ);
            }
        
            // Base:
            translate([0, troughY/2, 0]) 
                hull() 
                    doubleX() doubleY() 
                        translate([baseX/2-baseCornerDia/2, baseY/2-baseCornerDia/2, 0]) 
                            cylinder(d=baseCornerDia, h=baseZ);
        }

        recessBackDY = 5;
        // Cartridge slot:
        translate([0,0,baseZ]) hull()
        {
            tcy([0, -10, 0], d=brassOD, h=100);
            tcy([0, troughY-recessBackDY, 0], d=brassOD, h=100);
        }

        // Rim recess:
        translate([0,0,totalZ-2]) hull() 
        {
            tcy([0,3,0], d=brassRimOD, h=10);
            tcy([0,troughY-recessBackDY,0], d=brassRimOD, h=10);
        }
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
