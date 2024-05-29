
        from pymol import cmd,stored
        
        set depth_cue, 1
        set fog_start, 0.4
        
        set_color b_col, [36,36,85]
        set_color t_col, [10,10,10]
        set bg_rgb_bottom, b_col
        set bg_rgb_top, t_col      
        set bg_gradient
        
        set  spec_power  =  200
        set  spec_refl   =  0
        
        load "data/7cam_cleaned.pdb", protein
        create ligands, protein and organic
        select xlig, protein and organic
        delete xlig
        
        hide everything, all
        
        color white, elem c
        color bluewhite, protein
        #show_as cartoon, protein
        show surface, protein
        #set transparency, 0.15
        
        show sticks, ligands
        set stick_color, magenta
        
        
        
        
        # SAS points
 
        load "data/7cam_cleaned.pdb_points.pdb.gz", points
        hide nonbonded, points
        show nb_spheres, points
        set sphere_scale, 0.2, points
        cmd.spectrum("b", "green_red", selection="points", minimum=0, maximum=0.7)
        
        
        stored.list=[]
        cmd.iterate("(resn STP)","stored.list.append(resi)")    # read info about residues STP
        lastSTP=stored.list[-1] # get the index of the last residue
        hide lines, resn STP
        
        cmd.select("rest", "resn STP and resi 0")
        
        for my_index in range(1,int(lastSTP)+1): cmd.select("pocket"+str(my_index), "resn STP and resi "+str(my_index))
        for my_index in range(1,int(lastSTP)+1): cmd.show("spheres","pocket"+str(my_index))
        for my_index in range(1,int(lastSTP)+1): cmd.set("sphere_scale","0.4","pocket"+str(my_index))
        for my_index in range(1,int(lastSTP)+1): cmd.set("sphere_transparency","0.1","pocket"+str(my_index))
        
        
        
        set_color pcol1 = [0.361,0.576,0.902]
select surf_pocket1, protein and id [3139,3140,3142,4166,3131,3134,3146,3148,3154,3144,3145,3147,3851,4548,3829,4557,3843,3844,4163,4214,4215,4216,4238,4237,4239,3315,3316,3312] 
set surface_color,  pcol1, surf_pocket1 
set_color pcol2 = [0.278,0.310,0.702]
select surf_pocket2, protein and id [3395,3397,3396,3413,3573,3412,3559,2602,2604,2605,2663,3757,3398,3399,2476,2471,2472,2638,2662,2473,2599,3567,3574,3578,3579,3577] 
set surface_color,  pcol2, surf_pocket2 
set_color pcol3 = [0.498,0.361,0.902]
select surf_pocket3, protein and id [1925,1537,2242,2243,1529,1530,1900,1923,1924,1892,1902,820,1510,1517,1901,1849,1850,1851,1853,1889,1890,832,841,831,817,824,825,826,829,819,821,1002,2248,1514,1515,1516,2234,2235] 
set surface_color,  pcol3, surf_pocket3 
set_color pcol4 = [0.525,0.278,0.702]
select surf_pocket4, protein and id [4521,4522,4523,4508,4515,3821,4502,4143,3816,4142,4130,2332,4513,4514,3360,4529,4530,4531,4532,3358,3808,3804,3805,3806,3810,3811,3812,6,9,2333,2334,4484,4485,4479,2307,4497,4495,2163,2165,2167,2171] 
set surface_color,  pcol4, surf_pocket4 
set_color pcol5 = [0.851,0.361,0.902]
select surf_pocket5, protein and id [1245,1260,1258,1263,1099,1441,1444,1079,1259,290,173,285,288,349,350,1440,1082,162,170,156,158,159,310,315,316] 
set surface_color,  pcol5, surf_pocket5 
set_color pcol6 = [0.702,0.278,0.600]
select surf_pocket6, protein and id [2291,2295,2302,3369,3370,3366,3364,1623,1624,2228,1,2161,2158,2160,1625,1597,3363] 
set surface_color,  pcol6, surf_pocket6 
set_color pcol7 = [0.902,0.361,0.596]
select surf_pocket7, protein and id [1137,1139,2249,2250,2251,2252,2253,2254,2248,1154,1153,1155,1138,845,842,847,811,839,840,841,792,2261,2235,2236,1136,1143,1193] 
set surface_color,  pcol7, surf_pocket7 
set_color pcol8 = [0.702,0.278,0.325]
select surf_pocket8, protein and id [3450,3451,3453,3280,3452,4575,3155,2345,2348,2353,2354,2355,2357,2338,2346,2356,2358,932,936,4608,4610,2342,4609,4597,4598,4563,4565,4567,3457,3468,3469] 
set surface_color,  pcol8, surf_pocket8 
set_color pcol9 = [0.902,0.478,0.361]
select surf_pocket9, protein and id [2199,2201,2200,2197,2198,1567,2170,2171,2183,2225,2227,2160,2216,2218,18,20,2323,2321,2320,12,16,4477,4478,4479,2307,4471,4484,4485] 
set surface_color,  pcol9, surf_pocket9 
set_color pcol10 = [0.702,0.510,0.278]
select surf_pocket10, protein and id [2341,2342,901,902,4603,4606,1053,1054,1055,1058,1059,1068,1072,4604,4605,2312,1063,4594,2318] 
set surface_color,  pcol10, surf_pocket10 
set_color pcol11 = [0.902,0.831,0.361]
select surf_pocket11, protein and id [110,204,206,714,100,527,524,525,526,81,88,89,90,729,730,722] 
set surface_color,  pcol11, surf_pocket11 
   
        
        deselect
        
        orient
        