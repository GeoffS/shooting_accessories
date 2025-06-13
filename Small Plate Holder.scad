include <../OpenSCAD_Lib/MakeInclude.scad>

module itemModule()
{
	
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
