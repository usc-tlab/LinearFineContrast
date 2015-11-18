function err=BRMonitorGammaError(p,xr,xb,y,brratio)
% err=MonitorGammaError(p,xr,xb,y)
% Returns mean squared error of fit of y data by MonitorGamma function of xr and xb. The
% MonitorGamma parameters are x0=p(1), gamma=p(2). We constrain 0<=x0<=255 (not <1) and
% gamma>=0, and augment the error when they are out of bounds, so that minimization
% will always settle on in-bound values.
%
% Modified from Denis Pelli 5/26/96 by BT
% 12/5/2007 BT fixed a bug: 0<=x0<=255 (not <1)
% 9/20/2008 BT: the bug fix on 12/5/2007 was incomplete.  This is now full
% fixed. See the 'if p(1)>254' section. Fortunately, this condition is never
% reached.

d=0;
if p(1)<-0
	d=p(1).^2;
	p(1)=-0;
end
if p(1)>254
	d=(p(1)-254)^.2;
	p(1)=254;
end
if p(2)<0
	d=d+p(2).^2;
	p(2)=0;
end
% if p(3)<0
% 	d=d+log(p(3).^2);
% 	p(3)=Inf;
% end

% if max(xr) > 0
% 	x = (255-p(1))*y.^(1/p(2))+p(1);
% 	brratio = (x-xb)\xr;
% 	if brratio < 0
% 		brratio = Inf;
% 	elseif brratio <= 1
% 		brratio = brratio0;
% 	end
% else
% 	brratio = 0.5;
% end

err=BRMonitorGamma(xr/brratio+xb,p(1),p(2))-y;
err=mean(mean(err.^2))+d;
%err=mean(mean(err.^2));
