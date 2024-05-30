
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
        
        load "data/4jnc_cleaned.pdb", protein
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
 
        load "data/4jnc_cleaned.pdb_points.pdb.gz", points
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
select surf_pocket1, protein and id [1144,1145,1146,1147,2143,1471,1456,1464,1122,1107,1175,1176,1830,1863,1864,1858,1859,1861,1862,1890,1898,1016,1017,1019,1020,1029,1032,1889,1895,1935,1028,1073,1071,1074,1075,1098,1099,1097,1036,1059,1900,1033,1037,2089,2106,2107,2116,1166,2108,1460,1165,1461,1462,1463,1519,785,2315,2316,2317,2318,2319,2320,2329,222,2332,236,1374,2091,2095,2098,1429,1430,2077,1442,1447,1407,2311,1389,2327,1370,1364,1403,1426,794,994,820,998,1000,1001,814,816,797,799,818,860,861,580,859,792,793,795,796,798,225,1828,1835,1837,1829,1816,1893,227] 
set surface_color,  pcol1, surf_pocket1 
set_color pcol2 = [0.702,0.278,0.533]
select surf_pocket2, protein and id [263,19,20,17,260,484,1692,490,1729,486,1691] 
set surface_color,  pcol2, surf_pocket2 
   
        
        deselect
        
        orient
        