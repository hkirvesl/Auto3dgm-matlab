# Puente Alignment
Orignally written for the MST-based Generalized Dataset Procrustes Distance by Jesús Puente; this current version contains experimental features involving two synchronization-based alignment algorithms (spectral/SDP relaxation).

MATLAB Code originally written by Jesús Puente (jparrubarrena@gmail.com); currently maintained by Tingran Gao (trgao10@math.duke.edu) and Julie Winchester (julia.m.winchester@gmail.com). This code has also been ported to R by Christopher Glynn (glynn@stat.duke.edu) under the name [*auto3dgm*](https://stat.duke.edu/~sayan/auto3dgm/).

-----------
#### Sequential Execution
The entry point is the script `code/main.m`; see comments at the top of that script for a quick introduction. 

-----------
#### Parallel Execution
The current version of PuenteAlignment supports parallel computations on a cluster managed by Sun Grid Engine (SGE). To enable parallel execution, follow the steps 1 to 6 below.

1. Get the current version of PuenteAlignment. Simply `cd` into your desired path, then type

        git clone https://github.com/trgao10/PuenteAlignment/
        
2. Find script `jadd_path.m` in the folder *PuenteAlignment/code/*, and set paths and parameters there. If you assign an email address to the varialbe `email_notification`, a notification will be sent automatically to that email address whenever a cluster job completes or aborts.
3. Launch `MATLAB`, `cd` into the folder *PuenteAlignment/code/*, type in `clusterPreprocess` and press `ENTER`. All jobs should then be submitted to the cluster. Use `qstat` to monitor job status.
4. After all jobs are completed, type in `clusterMapLowRes` and press `ENTER`.
5. After all jobs are completed, type in `clusterReduceLowRes` and press `ENTER`. This generates low-resolution alignment results in the `output` folder you specified in `jadd_path.m`.
6. Type in `clusterMapHighRes` and press `ENTER` to submit high-resolution alignment jobs to the cluster. Use `qstat` to monitor job status.
7. After all jobs are completed, type in `clusterReduceHighRes` and press `ENTER`. This generates high-resolution alignment results in the `output` folder you specified in ```jadd_path.m```.

-----------
#### WebGL-based Alignment Visualization
After the alignment process is completed, the result can be visualized using a javascript-based viewer located under the folder *viewer/*. See [here](http://www.math.duke.edu/~trgao10/research/auto3dgm.html) for an online demo.

1. Move all output files ending with "_aligned.obj" from the subfolder *aligned/* (under your output folder) to the subfolder *viewer/aligned_meshes/*.
2. Set up an HTTP server under the folder *viewer/*. (If you already placed the folder *viewer/* somewhere with HTTP services, feel free to skip this step.) For instance, you can `cd viewer/` and type into the terminal `python -m SimpleHTTPServer 8000` if you are using Python 2.x, or equivalently `python -m http.server 8000` if you have Python 3.x.
3. Launch your browser and direct it to `http://localhost:8000/auto3dgm.html`.

-----------
#### Mosek License File
You will need a mosek license for using the fast linear programming routine for pairwise alignments. If you have an academic/institutional email address, you are eligible for a [free academic license](https://www.mosek.com/resources/academic-license) from [mosek.com](https://www.mosek.com/). Upon receiving the mosek license, simply drop it under the folder `PuenteAlignment/software/mosek/`.

-----------
#### Please Cite:

Boyer, Doug M., et al. *A New Fully Automated Approach for Aligning and Comparing Shapes.* The Anatomical Record 298.1 (2015): 249-276.

Puente, Jesús. *Distances and Algorithms to Compare Sets of Shapes for Automated Biological Morphometrics.* PhD Thesis, Princeton University, 2013.
