%<<<<<<< HEAD
function X = get_subsampled_shape( dir, id, N, ssType ) 
%Read already subsampled file, if it exists
%If it doesnt or it does not have enough points, read original off file, subsample, save the subsampled file, and return subsample


if ischar(N)
    N = str2double(N);
end

%sub_off_fn = [ dir 'subsampled' filesep num2str(id,'%.3d') '.off' ];
%off_fn     = [ dir 'original' filesep num2str(id,'%.3d') '.off' ];

%if exist( sub_off_fn, 'file' )
%    [ X, tmp ]       = read_off( sub_off_fn );
%=======
%function X = get_subsampled_shape( dir , id , N ) 
% Read already subsampled file, if it exists
% If it doesnt or it does not have enough points, read original off file, subsample, save the subsampled file, and return subsample
% Arguments:
%   dir: path to file
%   id: shape number
%   N: number of subsampled points

sub_off_fn = fullfile(dir, 'subsampled', [num2str(id), '.off']);
off_fn     = fullfile(dir, 'original', [num2str(id), '.off']);

if exist( sub_off_fn , 'file' )
    [X, ~]       = read_off( sub_off_fn );
%>>>>>>> d0dddb3294f936c1d498fdc04e0fae58610afc62
    n_subsampled_pts = size(X, 2);
else
    X                = [];
    n_subsampled_pts = 0;
end

%<<<<<<< HEAD
if ( n_subsampled_pts < N )
    disp(['Reading ' off_fn '...']);
    [V,F] = read_off( off_fn );
    disp('DONE');
    if strcmpi(ssType, 'fps')
        ind = subsample(V, N, X);
    elseif strcmpi(ssType, 'gpr')
        ind = gplmk(V, F, N, X);
    else
        error('unknown subsample type!');
    end
%=======
%if n_subsampled_pts < N
%    [V, ~] = read_off( off_fn ); 
%    ind   = subsample( V , N, X);
%>>>>>>> d0dddb3294f936c1d498fdc04e0fae58610afc62
    X     = V ( :, ind );
    if ~exist(fullfile(dir, 'subsampled'), 'dir')
        mkdir(fullfile(dir, 'subsampled'));
    end
    write_off( sub_off_fn, X, [1 2 3]'); %write_off breaks if there are no faces
end

end
