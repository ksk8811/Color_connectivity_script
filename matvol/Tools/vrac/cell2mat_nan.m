function X = cell2mat_nan(c)

smax = 0;

for k = 1:length(c)
  ss = length(c{k});
  if ss>smax
    smax=ss;
  end
end

Xnan = ones(smax,1)*NaN;

for k = 1:length(c)
  ss = length(c{k});
  Xnew = Xnan;
  Xnew(1:ss,1) = c{k};
  X(:,k) = Xnew;
end
