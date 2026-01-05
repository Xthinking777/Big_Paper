% sim('JJZB');
% y1=ans.yjj;
% sim('JJZB');
% u1=ans.yjj1;
fn=0.7490;
KZQFZ=[0.8401 -1.415 0.6173];
KZQFM=[1 -1];
KZQFZ=[0.3769   -0.7008    0.3250];
KZQFM=[1 -1.9 0.9];

sim('JJZB2');
y1=ans.yjj;
sim('JJZB2');
u1=ans.yjj1;
y1=y1(40000:50001);
u1=u1(40000:50001);
my=mean(y1);
mu=mean(u1);
vy=var(y1);
vu=var(u1);
[my mu vy vu]
figure(1)
subplot(2,1,1)
plot(y1);
axis([0 10000 0.4 1.2])
xlabel('Times(Ts)','fontsize',10);
ylabel('output','fontsize',10);
set(0,'defaultfigurecolor','w')
subplot(2,1,2)
plot(u1);
axis([0 10000 0.6 1])
xlabel('Times(Ts)','fontsize',10);
ylabel('input','fontsize',10);
set(0,'defaultfigurecolor','w')


yn=0;
un=0;
for i=1:1:10001
    if abs(y1(i))>1
        yn=yn+1;
    end
end
for i=1:1:10001
    if abs(u1(i))>0.85
        un=un+1;
    end
end
% [yn un]
