# BinSq
Gridded dot map technique for tackling visual clutter in discrete geographic data.

![Standard dot map vs BinSq](https://41.media.tumblr.com/b5b2ce9e0e6beecc8005b1db1138c3d2/tumblr_o69npgOlsG1rgerafo2_r1_1280.png)

![Standard dot map](https://67.media.tumblr.com/768f9e03aa0d5802292deacdfb83365b/tumblr_o69npgOlsG1rgerafo3_r1_1280.jpg)

![BinSq](https://67.media.tumblr.com/ebd5fe5213cae5e1600e85b6241cc0e5/tumblr_o69npgOlsG1rgerafo4_r1_1280.jpg)

This is a rudimentary implementation of BinSq in processing-java for release alongside our publication. Processing (see [http://www.processing.org](http://www.processing.org)) is required to compile this version. Files with *.java* extension will be part of a larger geotools package to be released in the near future.

![Key processes of the BinSq algorithm](https://36.media.tumblr.com/2ae4bd947951140213d6563e2ff8e1d4/tumblr_o69npgOlsG1rgerafo1_500h.jpg)

The key components of the technique are illustrated in the image above. Steps 1 to 4 depict the transformation from a geographically accurate but cluttered representation, to a visual outcome optimal for comparing categorical and density differences. 

    1. Data visualised with geographically accurate dot map.
    2. Data is binned to a density approximating grid.
    3. Data is equalised.
    4. The resulting gridded map.

Please read our paper for complete description of the algorithm. A copy maybe obtained at [http://www.tandfonline.com/doi/full/10.1080/15230406.2016.1174623](http://www.tandfonline.com/doi/full/10.1080/15230406.2016.1174623). Contact me if you are interested in our work do not have access to the journal. 

Do cite the paper if you find it useful.

    // Bibtex
    @article{chua2016binsq,
        title={BinSq: visualizing geographic dot density patterns with gridded maps},
        author={Chua, Alvin and Vande Moere, Andrew},
        journal={Cartography and Geographic Information Science},
        pages={1--20},
        year={2016},
        publisher={Taylor \& Francis}
    }