function G_Markov_est=FCOR1(y,e,L)
ne=size(e,1);ny=size(y,1);G_Markov_est=zeros(ny,ne,L);
for i=1:L
    E((i-1)*ne+1:i*ne,:)=e(:,L+1-i:end+1-i);
end
Y=y(:,L:end);
Coff=Y*E'/(E*E');
for i=1:L
    G_Markov_est(:,:,i)=Coff(:,(i-1)*ne+1:i*ne);
end
end
