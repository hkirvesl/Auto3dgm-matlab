function [Area,TriArea] = compute_surface_area(V,F)

L1 = sqrt(sum((V(F(:,2),:)-V(F(:,3),:)).^2,2));
L2 = sqrt(sum((V(F(:,1),:)-V(F(:,3),:)).^2,2));
L3 = sqrt(sum((V(F(:,1),:)-V(F(:,2),:)).^2,2));
S=(L1+L2+L3)/2;
TriArea=sqrt(abs(S.*(S-L1).*(S-L2).*(S-L3)));
Area=sum(TriArea);

end