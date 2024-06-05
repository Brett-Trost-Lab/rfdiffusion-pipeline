
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
        
        load "data/4lg9_cleaned.pdb", protein
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
 
        load "data/4lg9_cleaned.pdb_points.pdb.gz", points
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
select surf_pocket1, protein and id [1843,1844,2231,2553,2555,2554,1826,2230,1842,2240,2243,2244,2247,515,188,504,819,520,176,499,1500,1501,1156,1157,1162,1172,831,833,2552,2559,2564,2567,2569,181,189,192,174,2539,2217,2218,2220,1819,2222,2540,2542,2544,162,163,491,151,164,165,166,167,168,169,489,492,494,614,616,480,1475,1476,1484,803,815,1146,1812,1477,1478,1463,1815,1817,812,806,808,2261,2262,2572,2586,2266,2592,2267,215,206,212,211] 
set surface_color,  pcol1, surf_pocket1 
set_color pcol2 = [0.329,0.278,0.702]
select surf_pocket2, protein and id [1173,1505,1519,1172,1177,1851,1499,1500,833,1178,1180,838,1506,1191,851,852,857,858,861,1527,1525] 
set surface_color,  pcol2, surf_pocket2 
set_color pcol3 = [0.698,0.361,0.902]
select surf_pocket3, protein and id [2609,2717,2718,2719,2721,2470,2472,2604,2296,2298,2300,2297,2299,2301,2389] 
set surface_color,  pcol3, surf_pocket3 
set_color pcol4 = [0.702,0.278,0.639]
select surf_pocket4, protein and id [879,880,1027,1023,556,878,538,566,574,554,847,1010,1011,1009] 
set surface_color,  pcol4, surf_pocket4 
set_color pcol5 = [0.902,0.361,0.545]
select surf_pocket5, protein and id [1536,2082,2083,2084,1523,1952,1537,1948,1949,1556,2076,2078,2079,2075] 
set surface_color,  pcol5, surf_pocket5 
set_color pcol6 = [0.702,0.353,0.278]
select surf_pocket6, protein and id [236,237,238,361,366,367,368,356,2590,369,2611,2612,2731,2596,2600] 
set surface_color,  pcol6, surf_pocket6 
set_color pcol7 = [0.902,0.729,0.361]
select surf_pocket7, protein and id [2490,2510,93,94,2518,2519,2513] 
set surface_color,  pcol7, surf_pocket7 
   
        
        deselect
        
        orient
        