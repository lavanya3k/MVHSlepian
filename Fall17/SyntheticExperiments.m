function varargout=SyntheticExperiments(myCase, dom, dom2, Ls)
% []=SYNTHETICEXPERIMENTS(Case)
%
% This function runs one of several synthetic experiments to recover a 
% mass loss trend in the presence of noise, estimated from GRACE data
%
% INPUT:
%
% Case    Which case you want to run.
%           A - 
%           B - 
%           C -
% Dom     The region
% Ls      The L values eg [60]
%
% OUTPUT: none
% 
% SEE ALSO: SYNTHETICCASEA
%
% Modified by charig-at-princeton.edu on 6/25/2012
% Last modified by maxvonhippel-at-email.arizona.edu on 11/04/2017

%%%
% INITIALIZE
%%%

defval('myCase','A');
defval('xver',0);
defval('dom','iceland');
defval('dom2','greenland');
defval('Pcenter','CSR');
defval('Rlevel','RL05');
defval('Ldata',60);
defval('Signal',200); % Gt/yr
defval('pars',10);
defval('wantnoise',0);
defval('Ls',[50 55 60 65]);
defval('thebuffers',[0.5]);
defval('truncations',[0]); % [-2 -1 0 1 2]

% Get the original data
[potcoffs,calerrors,thedates] = grace2plmt(Pcenter,Rlevel,'SD',0);
% Get the fitted results

[ESTresid,thedates,ESTsignal,~,~,varet] = plmt2resid(potcoffs(:,:,1:4),...
    thedates,[1 1 181.0 365.0]);

% Use both to make a plot
% clf
% resid2plot(ESTresid,thedates,ESTsignal,20,20,varet,calerrors);

[Clmlmp,Clmlmpr,Clmlmpd,EL,EM] = plmresid2cov(ESTresid,Ldata,[]);

%%%
% RUN THE CASES
%%%

if ~isempty(getCurrentTask())
  % We should run this in parallel to make it faster.  The parallel part here
  % is done in plm2avgp where we calculate Slepian function integrals.
  % Delete any existing pool before launching a new one to avoid errors.
  disp('Starting parpool');
  parpool;
end

tic;
switch myCase
    case 'A'
      % Geoboxcap for dom (eg Iceland), run recovery, see what we get
      disp('Synthetic Experiment A running now.');
      allslopes = SyntheticCase(Clmlmp,thedates,Ls,thebuffers,...
                                 truncations,dom,[],0,1);
    case 'AA'
      % A but with synthetic noise
      disp('Synthetic Experiment AA running now.');
      allslopes = SyntheticCase(Clmlmp,thedates,Ls,thebuffers,...
                                 truncations,dom,[],0,1);
    case 'B'
      % Use uniform mass on dom2 (eg Greenland), recover dom (eg Iceland)
      disp('Synthetic Experiment B running now');
      allslopes = SyntheticCase(Clmlmp,thedates,Ls,thebuffers,...
                                 truncations,dom,dom2,0,1);
    case 'BB'
      % Use uniform mass on dom2 (eg Greenland), recover dom (eg Iceland)
      disp('Synthetic Experiment B running now');
      allslopes = SyntheticCase(Clmlmp,thedates,Ls,thebuffers,...
                                 truncations,dom,dom2,1,1);
    case 'C'
      % Use actual mass from dom2 (eg Greenland) to recover dom (eg Iceland)
      disp('Synthetic Experiment C running now');
      allslopes = SyntheticCase(Clmlmp,thedates,Ls,thebuffers,...
                                 truncations,dom,dom2,1,0);
    otherwise
      disp('Invalid case name. Try A, B, C, or D.');
end
casetime = toc;
disp(['Elapsed time for case ' myCase ' was ' num2str(casetime) ' seconds']);

% Is it advantageous to just leave the parpool open?
% disp('Closing parpool.');
% Close the parpool
% delete(gcp('nocreate'));

%%%
% PLOTTING - need to define allslopes for following code to do anything
%%%
% keyboard
% i=thebuffers;
% j=Ls;
% slopessize=size(allslopes);
% allslopes2 = reshape(allslopes{1},length(i),length(j));
% figure
% realslopes=real(allslopes{1});
% contour(real(j),real(i),real(allslopes{:}),real(-1*[150 160 170 180 190 200 210 220]));
% colorbar
% xlabel('Bandlimit L');
% ylabel('Region buffer, in degrees');
% title('Contour of mass loss slope (counter level 10Gt/yr)');

  
% Save relevant data for use in something like GMT

% for h = 1:length(truncations)
%    mydata = reshape(allslopes{h},length(i),length(j));
    
%    [m,n] = size(mydata);

%    theL = repmat(j,m,1);
%    theXYBuf = repmat(i,1,n);
%    theL = reshape(theL,m*n,1);
%    theXYBuf = reshape(theXYBuf,m*n,1);
%    mydata = reshape(mydata,m*n,1);

%    tosave1 = [theL theXYBuf mydata]';
%    fp1 = fopen(['figures/figdata/SyntheticSignalContourCASE' myCase ...
%                '_N' num2str(truncations(h),'%+i') '.dat'],'wt');
%    fprintf(fp1,'%.5f %.5f %.5e\n',tosave1);
%    fclose(fp1);
% end