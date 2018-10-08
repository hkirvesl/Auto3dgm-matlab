jadd_path;

%<<<<<<< HEAD
%disp(['Loading saved workspace from ' outputPath 'session_low.mat...']);
%load([outputPath 'session_low.mat']);
%disp('Loaded!');

%jadd_path;

%ds.msc.output_dir = outputPath;
%ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];
%=======
if (restart == 1)
    system(['rm -rf ' outputPath]);
    system(['mkdir ' outputPath]);
end

touch(fullfile(outputPath, 'original', filesep));
touch(fullfile(outputPath, 'subsampled', filesep));
touch(fullfile(outputPath, 'aligned', filesep));
touch(fullfile(outputPath, 'jobs', filesep));

set(0,'RecursionLimit',1500);
rng('shuffle');

%% information and parameters
ds.N       = [iniNumPts, finNumPts];  % Number of points to spread
ds.dataset = ''; % Used for pulling the files containing the meshes
ds.run     = '';     % Used for writing output and intermediate files
[ds.names, suffix] = getFileNames(meshesPath);
ds.ids     = arrayfun(@(x) sprintf('%03d', x), 1:length(ds.names), 'UniformOutput', 0);
cellfun(@(a,b) copyfile(a,b),...
    cellfun(@(x) fullfile(meshesPath, [x suffix]), ds.names, 'UniformOutput', 0),...
    cellfun(@(x) fullfile(outputPath, 'original', [x suffix]), ds.ids, 'UniformOutput', 0));

%% paths to be passed as global constants
ds.n                = length( ds.ids ); %Number of shapes
ds.K                = length( ds.N ); %Number of levels
[ds.base, ds.refAlign]  = ref_align_params( align_to, strcat(ds.names, suffix));
ds.msc.mesh_dir     = meshesPath;
ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = fullfile(outputPath, 'aligned', filesep);
%>>>>>>> d0dddb3294f936c1d498fdc04e0fae58610afc62

%% Initialization
% 1. Fill in X with subsampled shapes
% 2. Center and standardize them
% 3. Compute Singular Value Decompositions and other useful quantities
center = @(X) X-repmat(mean(X,2),1,size(X,2));
scale  = @(X) norm(center(X),'fro') ;

ds.shape = cell ( 1, ds.n );
for ii = 1 : ds.n
%<<<<<<< HEAD
%    [ds.shape{ ii }.origV, ds.shape{ ii }.origF] = read_off([meshesPath ds.names{ii} suffix]);
%=======
    fprintf('Subsampling %s......', ds.names{ii});
    [ds.shape{ ii }.origV, ds.shape{ ii }.origF] = ...
        read_off(fullfile(meshesPath, [ds.names{ii} suffix]));
%>>>>>>> d0dddb3294f936c1d498fdc04e0fae58610afc62
    ds.shape{ ii }.X              = cell( 1, ds.K );
    fprintf('Getting Subsampled Mesh %s......', ds.names{ii});
    ds.shape{ ii }.X{ ds.K }      = get_subsampled_shape( outputPath, ds.ids{ii}, ds.N( ds.K ), ssType );
    fprintf('DONE\n');
    ds.shape{ ii }.center         = mean(  ds.shape{ ii }.X{ ds.K }, 2 );
    ds.shape{ ii }.scale          = scale( ds.shape{ ii }.X{ ds.K } );
    ds.shape{ ii }.epsilon        = zeros( 1, ds.K );
    for kk = 1 : ds.K
        ds.shape{ ii }.X{kk}     = ds.shape{ii}.X{ ds.K }(:, 1:ds.N( kk ) );
        ds.shape{ ii }.X{kk}     = center(  ds.shape{ii}.X{kk} ) / scale(  ds.shape{ii}.X{kk} ) ;
        [ ds.shape{ ii }.U_X{kk} , tmpD_X , tmpV_X ] = svd( ds.shape{ii}.X{kk} );
        ds.shape{ ii }.D_X{kk}   = diag( tmpD_X );
        ds.shape{ ii }.V_X{kk}   = tmpV_X(:,1:3);
    end
    for kk = 2 : ds.K
       ds.shape{ ii }.epsilon(kk) = 1.0001*hausdorff( ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} );
       ds.shape{ ii }.neigh{ kk } = jrangesearch(ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} , ds.shape{ii}.epsilon(kk));
    end
end

%% Read the low resolution files, these are used for display puposes only
for ii = 1:ds.n
    %Read the files
    lowres_off_fn = fullfile(outputPath, 'subsampled', [ds.ids{ii}, '.off']);
    if exist( lowres_off_fn , 'file' )
        [ds.shape{ ii }.lowres.V ,ds.shape{ ii }.lowres.F] = read_off(lowres_off_fn);
    else
        error(['Cannot find low resolution file ' lowres_off_fn ]);
    end
    %Scale according to highest resolution point cloud
    ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V-repmat(ds.shape{ii}.center,1,size(ds.shape{ii}.lowres.V,2));
    ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V / ( ds.shape{ii}.scale / sqrt( ds.N( ds.K ) ) );
end

%% Alignment
% 'pa' stands for pairwise alignment
% 1. Compute a pairwise alignment of all pairs, then compute minimum
%    spanning tree
k = 1;
pa.A          = upper_triangle( ds.n ); % a 1 entry in this matrix indicates the pairwise distance should be computed
% pa.L          = 8; % Number of positions to test, the first 8 are the 8 possibilities for aligning the principal axes
pa.max_iter   = max_iter;
pa.allow_reflection = allow_reflection;
f             = @( ii , jj ) gpd( ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.max_iter, pa.allow_reflection );
pa.pfj        = fullfile(ds.msc.output_dir, 'jobs', 'low', filesep); % 'pfj' stands for path for jobs
pa.codePath   = codePath;
pa.email_notification = email_notification;

% Break up all the pairwise distances into a a bunch of parallel tasks,
% to be computed either in the same machine or in different ones
% Remember to remove all previous jobs in the output/jobs folder!
touch(pa.pfj);
pa = compute_alignment( pa, f, n_jobs, use_cluster );

%<<<<<<< HEAD
%disp(['Saving current workspace at ' outputPath 'session_low.mat...']);
%save([outputPath 'session_low.mat'], '-v7.3');
%=======
disp('Saving current workspace...');
save(fullfile(outputPath, 'session_low.mat'), '-v7.3');
%>>>>>>> d0dddb3294f936c1d498fdc04e0fae58610afc62
disp('Saved!');

