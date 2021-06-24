  

**Summary**
-----------

### Background on study

The effect of grasshoppers on soil nematode and microarthropod (mite)
communities were assessed through a short-term field study.
Specifically,12-50 x 100 cm plots covered with fine metal mesh cages
were set up in the shortgrasss steppe of northern Colorado for roughly
4.5 weeks. Half of the cages were intact to exclude grasshoppers (i.e.,
exclosures), while the remaing six cages had holes cut in them to allow
grasshopper feeding (i.e., caged controls or grasshopper plots). Soils
were sampled prior to cage installation for initial numbers of nematodes
and microarthropods (as well as soil moisture). Cages were monitored
weekly for grasshopper activity. The same sampling was repeated at
experiment termination as well as clipping all aboveground plant matter
in plots for shoot biomass and soil sampling for root biomass. The
latter involved sampling to 20 cm depth in bare soil and plant-covered
areas in plots and assessing root biomass by location and depth (0-10
and 10-20 cm). Samples were collected in the field, transported to the
laboratory, and processed appropriately.

### Description of raw data

The following describe the raw data collected and units of measure:

-   Grasshoppers
    -   Number of grasshoppers counted per plot for each date
-   Aboveground plant biomass (measures for each plot)
    -   Mass of plant + bag + washers (g)
    -   Mass of bag + washers (g)
    -   Mass of plants directly measured (g) (note: some plots had
        directly measured biomass)
    -   Mass of functional groups (g)
        -   Other grasses (g) (i.e., grasses other than fescue)
        -   Forbs (g)
        -   Shrubs (g)
-   Belowground plant biomass
    -   Crucible number
    -   Crucible mass (g)
    -   Crucible + plant (g)
    -   Crucible + ash (g)
-   Soil (for start and end of experiment)
    -   Soil can \#
    -   Soil for microbial extraction (g)
    -   Soil for nematode extraction (g)
    -   Empty can + lid (g)
    -   Soil for moisture determination (g)
    -   Soil can + lid + dried soil (g)
    -   Mite sample soil + bag (g)
    -   Mite sample bag only (g)
-   Soil nematodes (for each plot at start and end of experiment)
    -   Numbers of each feeding group (in a 200-nematode subsample)
        -   Bacterial feeders (BF)
        -   Fungal feeders (FF)
        -   Plant parasites (PP)
        -   Omnivores (OM)
        -   Predators (PR)
        -   Unknowns (UNK)
    -   Total nematodes (TOTAL)
-   Soil microarthropods (or each plot at start and end of experiment)
    -   Numbers of different groups
        -   Fungal-feeding mites (FF)
        -   Predatory mites (PR)
        -   Springtails (SPR)
        -   Other arthropods (ARTH)
    -   Total arthropods (TOTAL)

### Summary of tidying process

This data project outlines the steps involved in preprocessing the raw
data (described above) for statistical analyses primarily using
tidyverse and tidyverse-adjacent R packages. The data tidying was
separated into three parts/groups: 1) grasshopper, 2) plant biomass, and
3) soil and soil animal data. In general, the following steps were
completed for each part: 1) R packages loaded, 2) data importation, 3)
data checking (e.g., dimensions, column classes, n’s, range of values),
4) data cleaning (e.g., eliminating columns, renaming columns), 5)
missing data assessment, 6) reclassifying variables (e.g., changing
variable classes, deriving a variable of interest from two or more
pieces of raw data), and 7) writing (saving) tidied data.

**Grasshopper tidying**
-----------------------

The relevant packages was loaded into R. The function read\_xlsx() from
the readxl package was used to import the data from an Excel file to R.

    #load packages
    library(here)
    library(readxl)
    library(janitor)
    library(lubridate)
    library(tidyr)
    library(visdat)
    library(skimr)
    library(readr)

    #data import
    gh<-read_xlsx(here("data","raw_data","field_expt_gh.xlsx"),col_names=TRUE)
    head(gh) #dates got mangled during read-in

  

The data cleaning focused on column names as these did not transfer well
from Excel. Names only in lowercase and without spaces was the approach
for this dataset as well as the whole project. This is easily done with
clean\_names() in the janitor package. The dates were also changed by
creating a vector and using base R.

    #clean_names
    gh<-clean_names(gh)
    #create date vector
    dates<-c("2014-09-13","2014-09-19","2014-09-26","2014-10-03","2014-10-10",
             "2014-10-16","2014-10-21")
    #replace date headers with it
    names(gh)[3:9]<-dates

  

Grasshopper data were reshaped from wide to long format using
pivot\_longer() in tidyr, and three variables were re-classified.

    #convert to wide format
    gh<-gh %>% pivot_longer(cols=3:9,names_to="date",values_to="number")
    #reclassify variables
    gh$trmt<-as.factor(gh$trmt)
    gh$date<-ymd(gh$date)
    gh$number<-as.integer(gh$number)

    tidy_gh<-gh

The tibble was renamed to tidy\_gh following these initial cleaning
steps.  

The data were checked by assessing numbers of rows and columns and
levels of the factor trmt and previewing parts of the data for any
irregularities.

    nrow(tidy_gh); ncol(tidy_gh) #check # of rows/cols; 84=12 (plots) * 7 (dates)

    ## [1] 84

    ## [1] 4

    str(tidy_gh) #check classes of variables; they check out

    ## tibble [84 × 4] (S3: tbl_df/tbl/data.frame)
    ##  $ plot  : num [1:84] 1 1 1 1 1 1 1 2 2 2 ...
    ##  $ trmt  : Factor w/ 2 levels "Ex","Gh": 2 2 2 2 2 2 2 1 1 1 ...
    ##  $ date  : Date[1:84], format: "2014-09-13" "2014-09-19" ...
    ##  $ number: int [1:84] 1 0 2 0 0 0 1 0 1 1 ...

    levels(tidy_gh$trmt) #check factor levels; they check out

    ## [1] "Ex" "Gh"

    head(tidy_gh,n=10); tail(tidy_gh,n=10) #check top/bottom of tibble

    ## # A tibble: 10 x 4
    ##     plot trmt  date       number
    ##    <dbl> <fct> <date>      <int>
    ##  1     1 Gh    2014-09-13      1
    ##  2     1 Gh    2014-09-19      0
    ##  3     1 Gh    2014-09-26      2
    ##  4     1 Gh    2014-10-03      0
    ##  5     1 Gh    2014-10-10      0
    ##  6     1 Gh    2014-10-16      0
    ##  7     1 Gh    2014-10-21      1
    ##  8     2 Ex    2014-09-13      0
    ##  9     2 Ex    2014-09-19      1
    ## 10     2 Ex    2014-09-26      1

    ## # A tibble: 10 x 4
    ##     plot trmt  date       number
    ##    <dbl> <fct> <date>      <int>
    ##  1    11 Gh    2014-10-10      0
    ##  2    11 Gh    2014-10-16      0
    ##  3    11 Gh    2014-10-21      2
    ##  4    12 Ex    2014-09-13      0
    ##  5    12 Ex    2014-09-19      0
    ##  6    12 Ex    2014-09-26      0
    ##  7    12 Ex    2014-10-03      1
    ##  8    12 Ex    2014-10-10      0
    ##  9    12 Ex    2014-10-16      0
    ## 10    12 Ex    2014-10-21      0

No issues were found.  

Missing data were assessed visually using vis\_dat(0) from the visdat
package.

    vis_dat(tidy_gh)

![](grasshopper_soil_animal_report_files/figure-markdown_strict/gh%20missing%20data-1.png)

No missing data were detected, and variable classes were correct.  

Grasshopper data were checked once again.

    #check n's (using prior knowledge)
    range(tidy_gh$date) #2014-09-13 to 2014-10-21, which are correct range of dates

    ## [1] "2014-09-13" "2014-10-21"

    range(tidy_gh$number) #0-2, which is correct

    ## [1] 0 2

The date and grasshopper count ranges were correct and reasonable,
respectively.  

The tidied grasshopper data were saved as a .csv.

    write_csv(tidy_gh,here("data","tidy_data","tidy_gh_data.csv"))

  

**Plant biomass tidying**
-------------------------

The packages need for working with these data were loaded and the data
for aboveground plant biomass, aboveground plant biomass by functional
group, and belowground plant biomass were read into R. Note that there
are duplicate packages loaded across this project as each part would be
considered a separate R script.

    #load packages
    library(here)
    library(readxl)
    library(tidyr)
    library(dplyr)
    library(janitor)
    library(forcats)
    library(purrr)
    library(visdat)
    library(skimr)
    library(readr)

    #data import
    ag_plant<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                        sheet="Aboveground-total")

    ag_plant_groups<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                               sheet="Aboveground-functional groups")

    bg_plant<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                        sheet="Belowground-new")

  

### Aboveground plant biomass

Preliminary data checking, similar to the grasshopper data, was run on
both tibbles.

    #preliminary data checking
    dim(ag_plant) #check 34 x 5, which seems correct

    ## [1] 34  5

    str(ag_plant) #check classes of variables; need to change some eventually

    ## tibble [34 × 5] (S3: tbl_df/tbl/data.frame)
    ##  $ Plot #                                   : num [1:34] 1 NA NA NA 2 NA NA NA 3 NA ...
    ##  $ Bag #                                    : num [1:34] 1 2 3 4 1 2 3 4 1 2 ...
    ##  $ Mass of biomass + bag + washers (if nec.): num [1:34] NA 32.4 32.8 19.7 36.4 ...
    ##  $ Mass of bag + washers (if nec.)          : num [1:34] NA 6.79 6.99 6.96 6.87 6.81 6.66 6.89 6.86 6.7 ...
    ##  $ Measured biomass (g)                     : num [1:34] 19.7 NA NA NA NA ...

    head(ag_plant,n=10); tail(ag_plant,n=10) #preview data--need to fill; other NAs expected

    ## # A tibble: 10 x 5
    ##    `Plot #` `Bag #` `Mass of biomass + ba… `Mass of bag + was… `Measured biomas…
    ##       <dbl>   <dbl>                  <dbl>               <dbl>             <dbl>
    ##  1        1       1                   NA                 NA                 19.7
    ##  2       NA       2                   32.4                6.79              NA  
    ##  3       NA       3                   32.8                6.99              NA  
    ##  4       NA       4                   19.7                6.96              NA  
    ##  5        2       1                   36.4                6.87              NA  
    ##  6       NA       2                   22.0                6.81              NA  
    ##  7       NA       3                   22.6                6.66              NA  
    ##  8       NA       4                   27.3                6.89              NA  
    ##  9        3       1                   36.2                6.86              NA  
    ## 10       NA       2                   25.9                6.7               NA

    ## # A tibble: 10 x 5
    ##    `Plot #` `Bag #` `Mass of biomass + ba… `Mass of bag + was… `Measured biomas…
    ##       <dbl>   <dbl>                  <dbl>               <dbl>             <dbl>
    ##  1        8       1                   58.3                33.3              NA  
    ##  2       NA       2                   68.1                34.1              NA  
    ##  3        9       1                   53.1                26.2              NA  
    ##  4       NA       2                   63.9                29.2              NA  
    ##  5       10       1                   61.0                28.5              32.4
    ##  6       NA       2                   65.2                33.3              32.0
    ##  7       11       1                   86.6                48.7              37.9
    ##  8       NA       2                   62.6                31.7              30.8
    ##  9       12       1                   58.6                33.0              25.6
    ## 10       NA       2                   61.7                36.0              25.7

    dim(ag_plant_groups) #12 x 4; 12 plots and 4 variables

    ## [1] 12  4

    str(ag_plant_groups) #check classes of variables; need to change plot # eventually

    ## tibble [12 × 4] (S3: tbl_df/tbl/data.frame)
    ##  $ Plot #          : num [1:12] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ Other grasses(g): num [1:12] 4.55 6.47 3.74 4.46 3.05 2.36 5.78 1.99 4.26 2.77 ...
    ##  $ Forbs (g)       : num [1:12] 0 0.154 1.288 0 1.761 ...
    ##  $ Shrubs (g)      : num [1:12] 0 0 0 0 0 0 0 0.12 0 0 ...

    ag_plant_groups #data look fine

    ## # A tibble: 12 x 4
    ##    `Plot #` `Other grasses(g)` `Forbs (g)` `Shrubs (g)`
    ##       <dbl>              <dbl>       <dbl>        <dbl>
    ##  1        1               4.55       0             0   
    ##  2        2               6.47       0.154         0   
    ##  3        3               3.74       1.29          0   
    ##  4        4               4.46       0             0   
    ##  5        5               3.05       1.76          0   
    ##  6        6               2.36       0.126         0   
    ##  7        7               5.78       0.296         0   
    ##  8        8               1.99       0.338         0.12
    ##  9        9               4.26       0             0   
    ## 10       10               2.77       0.208         0   
    ## 11       11               5.77       0.302         0   
    ## 12       12               4.28       0             0

Some variable classes needed to be changed. Plot values were missing for
some rows, and missing data were detected.  

The column names for the aboveground plant biomass tibble were cleaned
by manually renaming them, while clean\_names() was run on the
functional group tibble. The missing plot values were addressed using
fill() from the tidyr package.

    #create character vector of col names
    ag_plant_names<-c("plot","bag","biomass_bag_washers_g","bag_washers_g","measured_biomass_g")
    names(ag_plant)<-ag_plant_names #append to tibble

    ag_plant_groups<-clean_names(ag_plant_groups)

    #fill in empty cells
    ag_plant<-fill(ag_plant,plot)

  

Aboveground plant biomass was calculated for some plots using mutate(),
and an algorithm to select this measure or directly measured biomass was
run on the data. Variables were reclassified, and plant biomass was
determined for each plot.

    #rename, compute, eliminate, and reclassify variables
    #compute 'calculated' biomass from subtraction
    ag_plant<-ag_plant %>%
      mutate(calc_biomass_g=biomass_bag_washers_g-bag_washers_g) #calculate biomass
    ag_plant$calc_biomass_g[29:34]<-NA #replace values with NA where biomass directly measured
    #create algorithm where ag_biomass is based on directly measured or computed biomass
    ag_plant<-ag_plant %>%
      mutate(ag_biomass_g=ifelse(!is.na(measured_biomass_g),measured_biomass_g,calc_biomass_g))
    #reclassify variables
    ag_plant[1:2]<-map(ag_plant[1:2],as.integer) #convert plot and bag cols to integers
    #sum by plot
    ag_plant_by_plot<-ag_plant %>%
      group_by(plot) %>%
      summarize(tot_ag_biomass_g=sum(ag_biomass_g)) %>%
      ungroup() %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) #add treatment col

    #rename and reclassify cols 
    ag_plant_by_plot$trmt<-as.factor(ag_plant_by_plot$trmt)
    names(ag_plant_groups)[1]<-"plot"
    ag_plant_groups$plot<-as.integer(ag_plant_groups$plot)

  

The two tibbles–aboveground plant biomass and functional group
biomass–were joined by plot, fescue biomass column created, and some
columns renamed. Plant biomass was converted to biomass density (g/m^2)
by dividing biomass by the area of remaining soil surface in each plot
(i.e., 0.5 m^2 plot - area removed by soil sampling).

    #join ag plant tibbles, create fescue biomass col, and convert biomass to g/m2
    ag_plant_biomass<-inner_join(ag_plant_by_plot,ag_plant_groups,by="plot") %>%
      mutate(fescue_biomass=tot_ag_biomass_g-(other_grasses_g+forbs_g+shrubs_g)) %>% #create fescue col
      select(plot,trmt,fescue_biomass,other_grasses_g,forbs_g,shrubs_g,tot_ag_biomass_g) %>% #reorder using select
      mutate(across(fescue_biomass:tot_ag_biomass_g,~.x/0.49487)) #convert to biomass per m^2

    #rename cols
    ag_plant_dens_names<-c("fescue_biomass_g_m2","oth_grasses_g_m2","forbs_g_m2",
                           "shrubs_g_m2","tot_ag_plant_g_m2")
    names(ag_plant_biomass)[3:7]<-ag_plant_dens_names

  

### Belowground plant biomass

As done with grasshopper and aboveground plant biomass data, root
biomass data were visually inspected and checked for numbers of rows and
columns and types of variables. The column names were cleaned using
clean\_names().

    #preliminary data check
    dim(bg_plant) #check 45 x 7: indicates some missing rows (as a multiple of 12 expected)

    ## [1] 45  7

    str(bg_plant) #check classes of variables; some need to change some eventually

    ## tibble [45 × 7] (S3: tbl_df/tbl/data.frame)
    ##  $ Plot #              : num [1:45] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ Location            : chr [1:45] "B" "B" "B" "B" ...
    ##  $ Depth (cm)          : chr [1:45] "0-10" "0-10" "0-10" "0-10" ...
    ##  $ Crucible #          : chr [1:45] "653" "B4" "B6" "B5" ...
    ##  $ Crucible (g)        : num [1:45] 44.9 56.6 50.1 55.7 55 ...
    ##  $ Crucible + plant (g): num [1:45] 53.6 65.2 55.9 62.8 59.7 ...
    ##  $ Crucible + ash (g)  : num [1:45] 50.9 63.3 54.5 61.4 58.4 ...

    head(bg_plant,n=10); tail(bg_plant,n=10) #seems like plots 1 & 2 for location P are missing

    ## # A tibble: 10 x 7
    ##    `Plot #` Location `Depth (cm)` `Crucible #` `Crucible (g)` `Crucible + pla…
    ##       <dbl> <chr>    <chr>        <chr>                 <dbl>            <dbl>
    ##  1        1 B        0-10         653                    44.9             53.6
    ##  2        2 B        0-10         B4                     56.6             65.2
    ##  3        3 B        0-10         B6                     50.1             55.9
    ##  4        4 B        0-10         B5                     55.7             62.8
    ##  5        5 B        0-10         B8                     55.0             59.7
    ##  6        6 B        0-10         2                      55.8             57.5
    ##  7        7 B        0-10         90                     48.7             54.8
    ##  8        8 B        0-10         615                    44.7             49.3
    ##  9        9 B        0-10         642                    43.6             45.7
    ## 10       10 B        0-10         B7                     54.4             58.3
    ## # … with 1 more variable: `Crucible + ash (g)` <dbl>

    ## # A tibble: 10 x 7
    ##    `Plot #` Location `Depth (cm)` `Crucible #` `Crucible (g)` `Crucible + pla…
    ##       <dbl> <chr>    <chr>        <chr>                 <dbl>            <dbl>
    ##  1       12 P        0-10         600                    54.4             56.6
    ##  2        3 P        10-20        605                    46.0             47.3
    ##  3        4 P        10-20        602                    50.4             52.3
    ##  4        5 P        10-20        612                    47.6             48.8
    ##  5        6 P        10-20        B10                    56.0             56.7
    ##  6        7 P        10-20        90                     48.7             49.4
    ##  7        8 P        10-20        91                     47.4             48.8
    ##  8        9 P        10-20        338                    17.6             18.2
    ##  9       10 P        10-20        92                     45.3             47.1
    ## 10       12 P        10-20        93                     46.6             49.2
    ## # … with 1 more variable: `Crucible + ash (g)` <dbl>

    #clean and view names
    bg_plant<-clean_names(bg_plant)

Some variables have inappropriate classes, and missing data were
detected.  

Root biomass for each location (i.e., bare (B) or plant-covered (P)) and
depth (i.e., 0-10, 10-20 cm) were computed and converted to density by
scaling up the area of the soil core to 1 m^2. Exclosure treatment was
added to each row, and three rows which had missing data were added as
well.

    #compute root biomass and root biomass density
    bg_plant_biomass<-bg_plant %>% 
      rename(plot=plot_number) %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>% #assign trmts
      mutate(root_g_m2=(crucible_plant_g-crucible_ash_g)*315.764039) %>% #calculate root biomass & convert to g/m^2
      select(plot,trmt,location,depth_cm,root_g_m2) %>%
      add_row(plot=c(1,1,2),trmt=c("Gh","Gh","Ex"),location=c("B","P","P"), #add NAs
              depth_cm=c("10-20","10-20","10-20"),root_g_m2=rep(NA,3)) %>%
      arrange(plot,location,depth_cm) #sort data
    bg_plant_biomass

    ## # A tibble: 48 x 5
    ##     plot trmt  location depth_cm root_g_m2
    ##    <dbl> <chr> <chr>    <chr>        <dbl>
    ##  1     1 Gh    B        0-10          831.
    ##  2     1 Gh    B        10-20          NA 
    ##  3     1 Gh    P        0-10          366.
    ##  4     1 Gh    P        10-20          NA 
    ##  5     2 Ex    B        0-10          579.
    ##  6     2 Ex    B        10-20         205.
    ##  7     2 Ex    P        0-10          362.
    ##  8     2 Ex    P        10-20          NA 
    ##  9     3 Gh    B        0-10          457.
    ## 10     3 Gh    B        10-20         140.
    ## # … with 38 more rows

The tibble now has 48 rows (instead of 45 rows), which is correct
because there are 12 plots x 2 locations x 2 depths.  

Select variables were reclassified and the depth\_cm factor levels
renamed.

    #reclassify variables
    bg_plant_biomass$plot<-as.integer(bg_plant_biomass$plot)
    bg_plant_biomass[2:4]<-map(bg_plant_biomass[2:4],as.factor)
    bg_plant_biomass$depth_cm<-fct_recode(bg_plant_biomass$depth_cm,`10`="0-10",`20`="10-20") 
    #recode depth levels to make it easier 

  

### Shoot:root biomass calculation and tidying

The ratio of shoot biomass to root biomass (known as shoot:root) was
calculated using aboveground biomass density and the density of root
biomass using 0-20 cm depth. This process included summing root biomass
density across location and depth and dividing by two (to account for
two soil cores per plot). Shoot:root was computed.

    #sum and avg root biomass for each plot 
    tot_root_biomass<-bg_plant_biomass %>%
      group_by(plot,trmt) %>%
      summarize(tot_root_g_m2=sum(root_g_m2/2)) #take average value based on bare and plant locations

    #compute s:r data
    s_r_data<-bind_cols(ag_plant_biomass[c(1,2,7)],tot_root_biomass[3]) %>%
      mutate(s_r=tot_ag_plant_g_m2/tot_root_g_m2)

  
  
  

Missing data for the three tibbles (i.e., aboveground biomass,
belowground biomass, shoot:root) were assessed visually, and the tibbles
were checked for any irregularities in their values.

    #missing data assessment
    vis_dat(ag_plant_biomass) #0 NAs

![](grasshopper_soil_animal_report_files/figure-markdown_strict/plant%20missing%20data,%20data%20check,%20save%20data-1.png)

    vis_dat(bg_plant_biomass) #3 NAs; expected

![](grasshopper_soil_animal_report_files/figure-markdown_strict/plant%20missing%20data,%20data%20check,%20save%20data-2.png)

    vis_dat(s_r_data) #2 cols with a few values each

![](grasshopper_soil_animal_report_files/figure-markdown_strict/plant%20missing%20data,%20data%20check,%20save%20data-3.png)

    #missing data expected

    #checking data for irregularities
    dim(ag_plant_biomass); dim(bg_plant_biomass); dim(s_r_data) #all seem fine

    ## [1] 12  7

    ## [1] 48  5

    ## [1] 12  5

    str(ag_plant_biomass); str(bg_plant_biomass); str(s_r_data) #all cols coded correctly

    ## tibble [12 × 7] (S3: tbl_df/tbl/data.frame)
    ##  $ plot               : int [1:12] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ trmt               : Factor w/ 2 levels "Ex","Gh": 2 1 2 1 2 1 1 2 2 1 ...
    ##  $ fescue_biomass_g_m2: num [1:12] 160 150 193 138 140 ...
    ##  $ oth_grasses_g_m2   : num [1:12] 9.19 13.07 7.56 9.01 6.16 ...
    ##  $ forbs_g_m2         : num [1:12] 0 0.311 2.603 0 3.559 ...
    ##  $ shrubs_g_m2        : num [1:12] 0 0 0 0 0 ...
    ##  $ tot_ag_plant_g_m2  : num [1:12] 169 164 203 147 150 ...

    ## tibble [48 × 5] (S3: tbl_df/tbl/data.frame)
    ##  $ plot     : int [1:48] 1 1 1 1 2 2 2 2 3 3 ...
    ##  $ trmt     : Factor w/ 2 levels "Ex","Gh": 2 2 2 2 1 1 1 1 2 2 ...
    ##  $ location : Factor w/ 2 levels "B","P": 1 1 2 2 1 1 2 2 1 1 ...
    ##  $ depth_cm : Factor w/ 2 levels "10","20": 1 2 1 2 1 2 1 2 1 2 ...
    ##  $ root_g_m2: num [1:48] 831 NA 366 NA 579 ...

    ## tibble [12 × 5] (S3: tbl_df/tbl/data.frame)
    ##  $ plot             : int [1:12] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ trmt             : Factor w/ 2 levels "Ex","Gh": 2 1 2 1 2 1 1 2 2 1 ...
    ##  $ tot_ag_plant_g_m2: num [1:12] 169 164 203 147 150 ...
    ##  $ tot_root_g_m2    : num [1:12] NA NA 647 585 623 ...
    ##  $ s_r              : num [1:12] NA NA 0.315 0.252 0.24 ...

    ag_plant_biomass

    ## # A tibble: 12 x 7
    ##     plot trmt  fescue_biomass_… oth_grasses_g_m2 forbs_g_m2 shrubs_g_m2
    ##    <int> <fct>            <dbl>            <dbl>      <dbl>       <dbl>
    ##  1     1 Gh               160.              9.19      0           0    
    ##  2     2 Ex               150.             13.1       0.311       0    
    ##  3     3 Gh               193.              7.56      2.60        0    
    ##  4     4 Ex               138.              9.01      0           0    
    ##  5     5 Gh               140.              6.16      3.56        0    
    ##  6     6 Ex               108.              4.77      0.255       0    
    ##  7     7 Ex               163.             11.7       0.598       0    
    ##  8     8 Gh               114.              4.02      0.683       0.242
    ##  9     9 Gh               116.              8.61      0           0    
    ## 10    10 Ex               124.              5.60      0.420       0    
    ## 11    11 Gh               127.             11.7       0.610       0    
    ## 12    12 Ex                95.0             8.65      0           0    
    ## # … with 1 more variable: tot_ag_plant_g_m2 <dbl>

    s_r_data

    ## # A tibble: 12 x 5
    ##     plot trmt  tot_ag_plant_g_m2 tot_root_g_m2    s_r
    ##    <int> <fct>             <dbl>         <dbl>  <dbl>
    ##  1     1 Gh                 169.           NA  NA    
    ##  2     2 Ex                 164.           NA  NA    
    ##  3     3 Gh                 203.          647.  0.315
    ##  4     4 Ex                 147.          585.  0.252
    ##  5     5 Gh                 150.          623.  0.240
    ##  6     6 Ex                 113.          436.  0.259
    ##  7     7 Ex                 175.          668.  0.262
    ##  8     8 Gh                 119.          370.  0.322
    ##  9     9 Gh                 124.          597.  0.209
    ## 10    10 Ex                 130.          544.  0.239
    ## 11    11 Gh                 139.          419.  0.331
    ## 12    12 Ex                 104.          489.  0.212

    head(bg_plant_biomass,n=10); tail(bg_plant_biomass,n=10) #look as expected

    ## # A tibble: 10 x 5
    ##     plot trmt  location depth_cm root_g_m2
    ##    <int> <fct> <fct>    <fct>        <dbl>
    ##  1     1 Gh    B        10            831.
    ##  2     1 Gh    B        20             NA 
    ##  3     1 Gh    P        10            366.
    ##  4     1 Gh    P        20             NA 
    ##  5     2 Ex    B        10            579.
    ##  6     2 Ex    B        20            205.
    ##  7     2 Ex    P        10            362.
    ##  8     2 Ex    P        20             NA 
    ##  9     3 Gh    B        10            457.
    ## 10     3 Gh    B        20            140.

    ## # A tibble: 10 x 5
    ##     plot trmt  location depth_cm root_g_m2
    ##    <int> <fct> <fct>    <fct>        <dbl>
    ##  1    10 Ex    P        10           260. 
    ##  2    10 Ex    P        20           176. 
    ##  3    11 Gh    B        10           477. 
    ##  4    11 Gh    B        20           174. 
    ##  5    11 Gh    P        10            93.5
    ##  6    11 Gh    P        20            94.8
    ##  7    12 Ex    B        10           451. 
    ##  8    12 Ex    B        20           121. 
    ##  9    12 Ex    P        10           211. 
    ## 10    12 Ex    P        20           195.

    range(ag_plant_biomass$tot_ag_plant_g_m2) 

    ## [1] 103.6030 203.4272

    range(bg_plant_biomass$root_g_m2,na.rm=TRUE) 

    ## [1]  41.83874 830.64888

    range(s_r_data$s_r,na.rm=TRUE)

    ## [1] 0.2086481 0.3311935

    #all look fine

The missing data were as expected. All columns were coded correctly, and
data values seemed reasonable.  

The tibbles were saved as .csv files.

    #export tibbles as a .csv
    write_csv(ag_plant_biomass,here("data","tidy_data","ag_plant_biomass.csv"))
    write_csv(bg_plant_biomass,here("data","tidy_data","bg_plant_biomass.csv"))
    write_csv(s_r_data,here("data","tidy_data","s_r_data.csv"))

  

**Soil and soil animal tidying**
--------------------------------

Relevant packages and raw data were read into R. These datasets included
initial and final soil, nematode, and microarthropod (mite) data.

    #load packages
    library(here)
    library(readxl)
    library(tibble)
    library(janitor)
    library(dplyr)
    library(purrr)
    library(visdat)
    library(skimr)
    library(readr)

    #import data
    initial_soil<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                            skip=1,col_names=TRUE,sheet="Raw Soil-Initial")
    final_soil<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                          skip=1,col_names=TRUE,sheet="Raw Soil-Final")
    initial_nema<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                            skip=3,n_max=12,col_names=TRUE,sheet="Nematodes")
    final_nema<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                          skip=21,n_max=12,col_names=TRUE,sheet="Nematodes")
    initial_mite<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                            skip=3,n_max=12,col_names=TRUE, sheet="Mites")
    final_mite<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                          skip=21,n_max=12,col_names=TRUE,sheet="Mites")

  

Soil data were visualized in their entirety for a data check. Tibbles
were combined, and a harvest column added.

    #preliminary data checking
    initial_soil #12 x 9; looks reasonable; a couple cols need to be reclassified

    ## # A tibble: 12 x 9
    ##     Plot `Soil can  #` `Soil for micro… `Soil for nemat… `Empty can  + l…
    ##    <dbl>         <dbl>            <dbl>            <dbl>            <dbl>
    ##  1     1           201             5.05             50.4             46.5
    ##  2     2           221             5.07             50.0             45.7
    ##  3     3           117             4.96             50.8             46.7
    ##  4     4           173             5.01             50.2             46.2
    ##  5     5           207             4.99             50.1             46.0
    ##  6     6            21             5.03             50.0             46.1
    ##  7     7             6             5.02             50.0             46.6
    ##  8     8           162             4.98             50.4             45.7
    ##  9     9           213             5.01             49.6             46.0
    ## 10    10            90             5.01             50.1             46.1
    ## 11    11            68             5.04             50.1             46.2
    ## 12    12            15             5.05             49.8             46.4
    ## # … with 4 more variables: `Soil for moisture determination (g)` <dbl>, `Soil
    ## #   can + lid + dried soil (g)` <dbl>, `Mite sample soil + bag (g)` <dbl>,
    ## #   `Mite sample bag only (g)` <dbl>

    final_soil #same as above

    ## # A tibble: 12 x 9
    ##     Plot `Soil can  #` `Soil for micro… `Soil for nemat… `Empty can  + l…
    ##    <dbl>         <dbl>            <dbl>            <dbl>            <dbl>
    ##  1     1           219             5.07             50.5             45.8
    ##  2     2           215             4.89             50.2             46.2
    ##  3     3           112             4.94             50.6             45.9
    ##  4     4           169             4.95             50.2             46.2
    ##  5     5            91             5                50.2             46.2
    ##  6     6           124             5.07             50.2             45.9
    ##  7     7           105             5.05             49.9             45.8
    ##  8     8            72             5.04             50.3             45.9
    ##  9     9           101             5.09             49.9             46.0
    ## 10    10           206             4.93             50.1             46.1
    ## 11    11            46             5.08             50.1             46.3
    ## 12    12            56             5.05             49.9             45.8
    ## # … with 4 more variables: `Soil for moisture determination (g)` <dbl>, `Soil
    ## #   can + lid + dried soil (g)` <dbl>, `Mite sample soil + bag (g)` <dbl>,
    ## #   `Mite sample bag only (g)` <dbl>

    #add harvest variable and combine tibbles
    initial_soil<-initial_soil %>%
      add_column(harvest=rep("I",12),.after="Plot")
    final_soil<-final_soil %>%
      add_column(harvest=rep("F",12),.after="Plot")
    soil<-bind_rows(initial_soil,final_soil)

  

Soil data column names were cleaned and soil variables (i.e., soil
dryness (as a proportion), dry soil (kg) of nematode and mite samples,
soil moisture (%)) were computed. Grasshopper exlosure treatment
variable was added.

    #clean column names
    soil<-clean_names(soil)

    #compute soil variables of interest based on raw data, append trmt variable
    soil_vars<-soil %>%
      mutate(soil_dryness_prop=(soil_can_lid_dried_soil_g-empty_can_lid_g)/soil_for_moisture_determination_g) %>%
      mutate(nema_dry_soil_kg=(soil_for_nematode_extraction_g*soil_dryness_prop)/1000) %>%
      mutate(mite_dry_soil_kg=((mite_sample_soil_bag_g-mite_sample_bag_only_g)*soil_dryness_prop)/1000) %>%
      mutate(soil_moisture_per=(1-soil_dryness_prop)*100) %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
      select(plot,trmt,harvest,soil_moisture_per,nema_dry_soil_kg,mite_dry_soil_kg)

  

Select soil variables were reclassified.

    #reclassify variables
    soil_vars$plot<-as.integer(soil_vars$plot)
    soil_vars[2:3]<-map(soil_vars[2:3],as.factor)

  

Nematode data were checked by visual inspection.

    #preliminary data check
    initial_nema #12 x 8; need to reclassify vars

    ## # A tibble: 12 x 8
    ##     Plot    BF    FF    PP    OM    PR   UNK TOTAL
    ##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    ##  1     1    99    39    29    18     1    14  1179
    ##  2     2    72    76    20    18     0    14   994
    ##  3     3    64    59    34    29     1    13  1849
    ##  4     4    55    70    33    24     2    16  1946
    ##  5     5    84    61    15    29     1    10   790
    ##  6     6   110    49    23     7     0    11  1804
    ##  7     7   124    47     9     6     1    13  1316
    ##  8     8    72    70    34    10     0    14  1375
    ##  9     9    83    82    20     5     1     9  1290
    ## 10    10    84    57    32    14     1    12  1073
    ## 11    11    96    55    19    21     1     8   922
    ## 12    12   100    71     9    11     0     9  1186

    final_nema #same as directly above

    ## # A tibble: 12 x 8
    ##     Plot    BF    FF    PP    OM    PR   UNK TOTAL
    ##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    ##  1     1    96    33    36    21     0    14   403
    ##  2     2    78    60    15    38     0     9   558
    ##  3     3    78    34    26    50     0    12   325
    ##  4     4    52    54    21    64     1     8   441
    ##  5     5   110    51     9    21     2     7   412
    ##  6     6    60    25    41    65     0     9   508
    ##  7     7   106    51    18    15     1     9   500
    ##  8     8    82    20    30    61     0     7   374
    ##  9     9    74    66    17    21     6    16   312
    ## 10    10    50    66    45    24     0    15   328
    ## 11    11    96    41    24    27     2    10   426
    ## 12    12    91    45    22    26     1    15   516

This check indicated that some variables need to be reclassified.  

Nematode datasets were combined into a single tibble with a harvest
column added. Columns with low counts (i.e., predators, unknowns) were
removed, and column names were cleaned.

    #add harvest variable, combine tibbles, and remove cols with low counts
    initial_nema<-initial_nema %>%
      add_column(harvest=rep("I",12),.after="Plot")
    final_nema<-final_nema %>%
      add_column(harvest=rep("F",12),.after="Plot")
    nema<-bind_rows(initial_nema,final_nema)
    nema<-nema[,c(1:6,9)]

    #clean column names
    nema<-clean_names(nema)

  

Nematode counts by feeding group were converted to densities (number/kg
dry soil). An exclosure treatment column was added, and the ratio of
bacterial- to fungal-feeding nematodes was computed for each plot and
harvest.

    #compute nema density variables of interest based on nema counts and dry soil data, append trmt variable
    nema_dens<-nema %>%
      add_column(soil_vars[4:5],.after="harvest") %>%
      mutate(total_nema=total/nema_dry_soil_kg) %>%
      mutate(across(.cols=5:8,~((.x/200)*total_nema))) %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
      mutate(bf_ff=bf/ff) %>%
      select(plot,trmt,harvest,soil_moisture_per,bf,ff,pp,om,bf_ff,total_nema)

  

A separate tibble consisting of proportions of nematode feeding groups
was created by converting the original counts by feeding group to
proportions and selecting only variables of interest.

    #compute nema proportions
    nema_prop <- nema %>% 
      mutate(across(.cols=3:6,~((.x/200)))) %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
      select(plot,trmt,harvest,bf,ff,pp,om)

  

Select variables in both the nematode density and proportion tibbles
were reclassified.

    #reclassify variables
    #densities
    nema_dens$plot<-as.integer(nema_dens$plot)
    nema_dens[2:3]<-map(nema_dens[2:3],as.factor)

    #proportions
    nema_prop$plot<-as.integer(nema_prop$plot)
    nema_prop[2:3]<-map(nema_prop[2:3],as.factor)

  

Similar to the nematode data, the mite data were visually inspected as a
preliminary data check.

    #preliminary data check
    initial_mite #12 x 8; last two cols irrelevant; need to reclassify vars

    ## # A tibble: 12 x 8
    ##     Plot    FF    PR   SPR  ARTH TOTAL ...7  `# FF Picked`
    ##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <lgl>         <dbl>
    ##  1     1   320    29     0     5   354 NA              336
    ##  2     2    77    21     0    13   111 NA               56
    ##  3     3   173    27     0     2   202 NA              176
    ##  4     4   114    32     1    46   193 NA              104
    ##  5     5   109    23     0    12   144 NA              120
    ##  6     6    84     7     0     4    95 NA               67
    ##  7     7   174     9     0     5   188 NA              165
    ##  8     8   104    28     2     2   136 NA               95
    ##  9     9   305    34     0    11   350 NA              297
    ## 10    10   130    32     0     5   167 NA              118
    ## 11    11   129    40     3    17   189 NA              117
    ## 12    12   119    42     0     2   163 NA              108

    final_mite #same as directly above

    ## # A tibble: 12 x 8
    ##     Plot    FF    PR   SPR  ARTH TOTAL ...7  `# FF Picked`
    ##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <lgl>         <dbl>
    ##  1     1   172     7     7    17   203 NA              166
    ##  2     2   220    34     2     3   259 NA              237
    ##  3     3   268    57     0    19   344 NA              251
    ##  4     4   122    27     0    30   179 NA              142
    ##  5     5   268    54     2     4   328 NA              263
    ##  6     6   215    17     2     5   239 NA              205
    ##  7     7  1410    24     1     7  1442 NA             1265
    ##  8     8   227    12     4    11   254 NA              214
    ##  9     9   101    55     4    41   201 NA              109
    ## 10    10   227    13     0    11   251 NA              231
    ## 11    11   194    17     2    12   225 NA              170
    ## 12    12   200    12     1     7   220 NA              191

  

The initial and final datasets of the mite datasets were combined.
Harvest period was added as a column, and column names were cleaned.

    #remove irrelevant cols and cols with low counts, add harvest variable, and combine tibbles
    initial_mite<-initial_mite[,-c(4:5,7:8)]
    final_mite<-final_mite[,-c(4:5,7:8)]
    initial_mite<-initial_mite %>%
      add_column(harvest=rep("I",12),.after="Plot")
    final_mite<-final_mite %>%
      add_column(harvest=rep("F",12),.after="Plot")
    mite<-bind_rows(initial_mite,final_mite)

    #clean column names
    mite<-clean_names(mite)

  

Microarthropod counts were converted to densities (number per dry kg
soil), and exclosure treatment was added as a column.

    #compute mite variables of interest based on mite counts and dry soil data, append trmt variable
    mite_dens<-mite %>%
      rename(ff_mite=ff) %>%
      rename(pr_mite=pr) %>%
      rename(total_marth=total) %>%
      add_column(soil_vars[6],.after="harvest") %>%
      mutate(across(.cols=c("ff_mite","pr_mite","total_marth"),~.x/mite_dry_soil_kg)) %>%
      mutate(total_mite=ff_mite+pr_mite) %>%
      mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
      select(plot,trmt,harvest,ff_mite,pr_mite,total_mite,total_marth) 

  

Select microarthropod variables were reclassified.

    #reclassify variables
    mite_dens$plot<-as.integer(mite_dens$plot)

  

All soil data (i.e., nematode densities, nematode proportions, mite
densities) were assessed visually for missingness and checked for
irregularities.

    #missing data assessment
    vis_dat(nema_dens) 

![](grasshopper_soil_animal_report_files/figure-markdown_strict/soil%20missing%20data%20and%20check-1.png)

    vis_dat(nema_prop)

![](grasshopper_soil_animal_report_files/figure-markdown_strict/soil%20missing%20data%20and%20check-2.png)

    vis_dat(mite_dens) 

![](grasshopper_soil_animal_report_files/figure-markdown_strict/soil%20missing%20data%20and%20check-3.png)

    #no missing data

    #checking data for irregularities
    dim(nema_dens); dim(nema_prop); dim(mite_dens) #all seem fine

    ## [1] 24 10

    ## [1] 24  7

    ## [1] 24  7

    str(nema_dens); str(nema_prop); str(mite_dens) #all cols coded correctly

    ## tibble [24 × 10] (S3: tbl_df/tbl/data.frame)
    ##  $ plot             : int [1:24] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ trmt             : Factor w/ 2 levels "Ex","Gh": 2 1 2 1 2 1 1 2 2 1 ...
    ##  $ harvest          : Factor w/ 2 levels "F","I": 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ soil_moisture_per: num [1:24] 4 4.98 5.48 3.7 4.31 ...
    ##  $ bf               : num [1:24] 12064 7530 12335 11075 6925 ...
    ##  $ ff               : num [1:24] 4752 7949 11371 14095 5029 ...
    ##  $ pp               : num [1:24] 3534 2092 6553 6645 1237 ...
    ##  $ om               : num [1:24] 2193 1883 5589 4833 2391 ...
    ##  $ bf_ff            : num [1:24] 2.538 0.947 1.085 0.786 1.377 ...
    ##  $ total_nema       : num [1:24] 24371 20918 38547 40272 16489 ...

    ## tibble [24 × 7] (S3: tbl_df/tbl/data.frame)
    ##  $ plot   : int [1:24] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ trmt   : Factor w/ 2 levels "Ex","Gh": 2 1 2 1 2 1 1 2 2 1 ...
    ##  $ harvest: Factor w/ 2 levels "F","I": 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ bf     : num [1:24] 0.495 0.36 0.32 0.275 0.42 0.55 0.62 0.36 0.415 0.42 ...
    ##  $ ff     : num [1:24] 0.195 0.38 0.295 0.35 0.305 0.245 0.235 0.35 0.41 0.285 ...
    ##  $ pp     : num [1:24] 0.145 0.1 0.17 0.165 0.075 0.115 0.045 0.17 0.1 0.16 ...
    ##  $ om     : num [1:24] 0.09 0.09 0.145 0.12 0.145 0.035 0.03 0.05 0.025 0.07 ...

    ## tibble [24 × 7] (S3: tbl_df/tbl/data.frame)
    ##  $ plot       : int [1:24] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ trmt       : chr [1:24] "Gh" "Ex" "Gh" "Ex" ...
    ##  $ harvest    : chr [1:24] "I" "I" "I" "I" ...
    ##  $ ff_mite    : num [1:24] 965 445 866 367 418 ...
    ##  $ pr_mite    : num [1:24] 87.5 121.5 135.1 102.9 88.3 ...
    ##  $ total_mite : num [1:24] 1053 567 1001 470 507 ...
    ##  $ total_marth: num [1:24] 1068 642 1011 621 553 ...

    head(nema_dens); tail(nema_dens) #look as expected

    ## # A tibble: 6 x 10
    ##    plot trmt  harvest soil_moisture_p…     bf     ff    pp    om bf_ff
    ##   <int> <fct> <fct>              <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
    ## 1     1 Gh    I                   4.00 12064.  4752. 3534. 2193. 2.54 
    ## 2     2 Ex    I                   4.98  7530.  7949. 2092. 1883. 0.947
    ## 3     3 Gh    I                   5.48 12335. 11371. 6553. 5589. 1.08 
    ## 4     4 Ex    I                   3.70 11075. 14095. 6645. 4833. 0.786
    ## 5     5 Gh    I                   4.31  6925.  5029. 1237. 2391. 1.38 
    ## 6     6 Ex    I                   3.91 20668.  9207. 4321. 1315. 2.24 
    ## # … with 1 more variable: total_nema <dbl>

    ## # A tibble: 6 x 10
    ##    plot trmt  harvest soil_moisture_per    bf    ff    pp    om bf_ff total_nema
    ##   <int> <fct> <fct>               <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>      <dbl>
    ## 1     7 Ex    F                    7.69 5752. 2767.  977.  814. 2.08      10853.
    ## 2     8 Gh    F                    8.98 3347.  816. 1224. 2490. 4.1        8163.
    ## 3     9 Gh    F                    6.84 2483. 2215.  570.  705. 1.12       6712.
    ## 4    10 Ex    F                    8.08 1780. 2350. 1602.  855. 0.758      7121.
    ## 5    11 Gh    F                    7.73 4421. 1888. 1105. 1243. 2.34       9210.
    ## 6    12 Ex    F                    7.01 5062. 2503. 1224. 1446. 2.02      11124.

    head(nema_prop); tail(nema_prop) #look as expected

    ## # A tibble: 6 x 7
    ##    plot trmt  harvest    bf    ff    pp    om
    ##   <int> <fct> <fct>   <dbl> <dbl> <dbl> <dbl>
    ## 1     1 Gh    I       0.495 0.195 0.145 0.09 
    ## 2     2 Ex    I       0.36  0.38  0.1   0.09 
    ## 3     3 Gh    I       0.32  0.295 0.17  0.145
    ## 4     4 Ex    I       0.275 0.35  0.165 0.12 
    ## 5     5 Gh    I       0.42  0.305 0.075 0.145
    ## 6     6 Ex    I       0.55  0.245 0.115 0.035

    ## # A tibble: 6 x 7
    ##    plot trmt  harvest    bf    ff    pp    om
    ##   <int> <fct> <fct>   <dbl> <dbl> <dbl> <dbl>
    ## 1     7 Ex    F       0.53  0.255 0.09  0.075
    ## 2     8 Gh    F       0.41  0.1   0.15  0.305
    ## 3     9 Gh    F       0.37  0.33  0.085 0.105
    ## 4    10 Ex    F       0.25  0.33  0.225 0.12 
    ## 5    11 Gh    F       0.48  0.205 0.12  0.135
    ## 6    12 Ex    F       0.455 0.225 0.11  0.13

    head(mite_dens); tail(mite_dens) #look as expected

    ## # A tibble: 6 x 7
    ##    plot trmt  harvest ff_mite pr_mite total_mite total_marth
    ##   <int> <chr> <chr>     <dbl>   <dbl>      <dbl>       <dbl>
    ## 1     1 Gh    I          965.    87.5      1053.       1068.
    ## 2     2 Ex    I          445.   121.        567.        642.
    ## 3     3 Gh    I          866.   135.       1001.       1011.
    ## 4     4 Ex    I          367.   103.        470.        621.
    ## 5     5 Gh    I          418.    88.3       507.        553.
    ## 6     6 Ex    I          235.    19.6       255.        266.

    ## # A tibble: 6 x 7
    ##    plot trmt  harvest ff_mite pr_mite total_mite total_marth
    ##   <int> <chr> <chr>     <dbl>   <dbl>      <dbl>       <dbl>
    ## 1     7 Ex    F         3857.    65.7      3923.       3945.
    ## 2     8 Gh    F          663.    35.0       698.        742.
    ## 3     9 Gh    F          240.   131.        371.        477.
    ## 4    10 Ex    F          684.    39.2       723.        756.
    ## 5    11 Gh    F          561.    49.2       610.        651.
    ## 6    12 Ex    F          557.    33.4       590.        612.

    map(nema_dens[4:10],range)

    ## $soil_moisture_per
    ## [1]  3.573718 10.580838
    ## 
    ## $bf
    ## [1]  1780.329 20667.904
    ## 
    ## $ff
    ## [1]   816.2903 14095.3659
    ## 
    ## $pp
    ## [1]  403.3967 6644.9582
    ## 
    ## $om
    ## [1]  673.7558 5589.3032
    ## 
    ## $bf_ff
    ## [1] 0.7575758 4.1000000
    ## 
    ## $total_nema
    ## [1]  6711.584 40272.474

    map(nema_prop[4:7],range)

    ## $bf
    ## [1] 0.25 0.62
    ## 
    ## $ff
    ## [1] 0.10 0.41
    ## 
    ## $pp
    ## [1] 0.045 0.225
    ## 
    ## $om
    ## [1] 0.025 0.325

    map(mite_dens[4:7],range)

    ## $ff_mite
    ## [1]  235.2086 3857.3627
    ## 
    ## $pr_mite
    ## [1]  19.60071 180.55950
    ## 
    ## $total_mite
    ## [1]  254.8093 3923.0199
    ## 
    ## $total_marth
    ## [1]  266.0097 3944.9056

    #no irregularities detected

No missing data or irregularities detected.  

The three tibbles (i.e., nematode densities, nematode proportions, mite
densities) were saved as separate .csv files.

    #export tibbles as a .csv
    write_csv(nema_dens,here("data","tidy_data","nema_densities.csv"))
    write_csv(nema_prop,here("data","tidy_data","nema_proportions.csv"))
    write_csv(mite_dens,here("data","tidy_data","mite_densities.csv"))

  
  

**Conclusion**
--------------

The data cleaning, wrangling, processing steps shown above yielded the
following files: 1) tidy\_gh\_data.csv, 2) ag\_plant\_biomass.csv, 3)
bg\_plant\_biomass.csv, 4) s\_r\_data.csv, 5) nema\_densities.csv, 6)
nema\_proportions\_csv, and 7) mite\_densities. These files are in a
tidy format, have correct column classes, and no excessive missingness
(beyond what was expected from raw files). These datasets could be
easily read into R using read\_csv() from the readr package. The data
are in the appropriate format for exploration (e.g., visualization,
summary statistics) and/or statistical analysis because columns are
properly coded and tibbles are tidy (i.e., one variable per column, one
observation per row, and one table per type of data). The plot variable,
which exists in all tibbles, enables one to analyze data from multiple
tibbles using join statements.
