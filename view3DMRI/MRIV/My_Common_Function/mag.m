function magni = mag(data)

if isreal(data)
    magni = data;
    neg = (data<0);
    magni(neg) = -data(neg);
else
    magni = sqrt(real(data).^2+imag(data).^2);
end

