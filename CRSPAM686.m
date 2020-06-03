function F = CSPAM686(ColorIMG)
% -------------------------------------------------------------------------
% Copyright (c) 2017 VIPP Lab, University of Siena, Siena, ITALY.
% -------------------------------------------------------------------------
% Contact: ehsan.nowroozi65@gmail.com | barni@dii.unisi.it | April 2017
% -------------------------------------------------------------------------
% Extracts Spatial domin features, 2nd order, T=3. Dimentionality for color
% image is 686. Each channels are seperated in the first step then
% calculated L C R for each layer thus we have L1 L2 L3 C1 ..., then L1 L2
% L3 are calculated by co-occurrence (7,7,7). At the end each co-occurrence
% such as L Cooc, C Cooc, R Cooc are merged.
% -------------------------------------------------------------------------
% Input: ColorIMG ... input Color images.
% Output: F .... resulting CSPAM686 features.
% -------------------------------------------------------------------------

F = Cspam_Extract(double(imread(ColorIMG)),3);

function F = Cspam_Extract(X,T)

three = 3;   % Color Image Channels (R,G,B)

%--------------------------------------------------------------------------
% C-SPAM686 (First Component): This Component similar to the first component, 
% but the formed across the three channels.
%--------------------------------------------------------------------------
% C-SPAM (horizontal left-right)
for i=1:three 
    D{i} = X(:,1:end-1,i) - X(:,2:end,i);
        C{i} = D{i}(:,2:end-1);
end
       Mh1 = GetM3(C{1},C{2},C{3},T);          
%-----------------------------------------------                
% C-SPAM (horizontal right-left)
for i=1:three
    D{i} = -D{i};
        C{i} = D{i}(:,2:end-1);
end
       Mh2 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------
% C-SPAM (vertical bottom top)
for i=1:three
    D{i} = X(1:end-1,:,i) - X(2:end,:,i);
        C{i} = D{i}(2:end-1,:);
end
       Mv1 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------                   
% C-SPAM (vertical top bottom)
for i=1:three 
    D{i} = -D{i}; 
        C{i} = D{i}(2:end-1,:); 
end
       Mv2 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------                   
% C-SPAM (diagonal left-right)
for i=1:three
    D{i} = X(1:end-1,1:end-1,i) - X(2:end,2:end,i); 
        C{i} = D{i}(2:end-1,2:end-1); 
end 
       Md1 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------                   
% C-SPAM (diagonal right-left)
for i=1:three
    D{i} = -D{i};
        C{i} = D{i}(2:end-1,2:end-1);           
end
       Md2 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------                  
% C-SPAM (minor diagonal left-right)
for i=1:three 
    D{i} = X(2:end,1:end-1,i) - X(1:end-1,2:end,i); 
        C{i} = D{i}(2:end-1,2:end-1); 
end 
       Mm1 = GetM3(C{1},C{2},C{3},T);
%-----------------------------------------------                    
% C-SPAM (minor diagonal right-left)
for i=1:three 
    D{i} = -D{i}; 
        C{i} = D{i}(2:end-1,2:end-1); 
end
       Mm2 = GetM3(C{1},C{2},C{3},T);

%-----------------------------------------------
% Reduced Dimensionality of Features (C-SPAM)
% The Feature dimention is 686
 F1 = (Mh1+Mh2+Mv1+Mv2)/4;
 F2 = (Md1+Md2+Mm1+Mm2)/4;
F = [F1;F2];
%----------------------------------------------- 
 
function M = GetM3(M1,M2,M3,T)
% marginalization into borders
M1 = M1(:); 
     M1(M1<-T) = -T; 
     M1(M1>T) = T;

M2 = M2(:); 
     M2(M2<-T) = -T; 
     M2(M2>T) = T;

M3 = M3(:); 
     M3(M3<-T) = -T; 
     M3(M3>T) = T;

% get cooccurences [-T...T]
% M = (2T+1)^3
M = zeros(2*T+1,2*T+1,2*T+1);
for i=-T:T
    C2 = M2(M1==i);
    R2 = M3(M1==i);
    for j=-T:T
        R3 = R2(C2==j);
        for k=-T:T
            M(i+T+1,j+T+1,k+T+1) = sum(R3==k);
        end
    end
end

% normalization
M = M(:)/sum(M(:));