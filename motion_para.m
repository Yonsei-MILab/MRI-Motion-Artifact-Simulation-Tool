function motion = motion_para(az, m_scen, tr, scantime)
global motion
motion = zeros(scantime,6);

if m_scen.ap.type == "Periodic (Continuous)"
    motion(:,1) = c_periodic(tr, scantime, m_scen.ap.strength);
elseif m_scen.ap.type == "Linear (Continuous)"
    motion(:,1) = c_linear(scantime, m_scen.ap.strength);
elseif m_scen.ap.type == "Nonlinear (Continuous)"
    motion(:,1) = c_nonlinear(scantime, m_scen.ap.strength);
elseif m_scen.ap.type == "Sudden"
    motion(:,1) = sudden(az, scantime, m_scen.ap.strength); 
end
disp(1)
if m_scen.rl.type == "Periodic (Continuous)"
    motion(:,2) = c_periodic(tr, scantime, m_scen.rl.strength);
elseif m_scen.rl.type == "Linear (Continuous)"
    motion(:,2) = c_linear(scantime, m_scen.rl.strength);
elseif m_scen.rl.type == "Nonlinear (Continuous)"
    motion(:,2) = c_nonlinear(scantime, m_scen.rl.strength);
elseif m_scen.rl.type == "Sudden"
    motion(:,2) = sudden(az, scantime, m_scen.rl.strength); 
end
disp(2)
if m_scen.is.type == "Periodic (Continuous)"
    motion(:,3) = c_periodic(tr, scantime, m_scen.is.strength);
elseif m_scen.is.type == "Linear (Continuous)"
    motion(:,3) = c_linear(scantime, m_scen.is.strength);
elseif m_scen.is.type == "Nonlinear (Continuous)"
    motion(:,3) = c_nonlinear(scantime, m_scen.is.strength);
elseif m_scen.is.type == "Sudden"
    motion(:,3) = sudden(az, scantime, m_scen.is.strength); 
end
disp(3)
if m_scen.yaw.type == "Periodic (Continuous)"
    motion(:,4) = c_periodic(tr, scantime, m_scen.yaw.strength);
elseif m_scen.yaw.type == "Linear (Continuous)"
    motion(:,4) = c_linear(scantime, m_scen.yaw.strength);
elseif m_scen.yaw.type == "Nonlinear (Continuous)"
    motion(:,4) = c_nonlinear(scantime, m_scen.yaw.strength);
elseif m_scen.yaw.type == "Sudden"
    motion(:,4) = sudden(az, scantime, m_scen.yaw.strength); 
end
disp(4)
if m_scen.pitch.type == "Periodic (Continuous)"
    motion(:,5) = c_periodic(tr, scantime, m_scen.pitch.strength);
elseif m_scen.pitch.type == "Linear (Continuous)"
    motion(:,5) = c_linear(scantime, m_scen.pitch.strength);
elseif m_scen.pitch.type == "Nonlinear (Continuous)"
    motion(:,5) = c_nonlinear(scantime, m_scen.pitch.strength);
elseif m_scen.pitch.type == "Sudden"
    motion(:,5) = sudden(az, scantime, m_scen.pitch.strength); 
end
disp(5)
if m_scen.roll.type == "Periodic (Continuous)"
    motion(:,6) = c_periodic(tr, scantime, m_scen.roll.strength);
elseif m_scen.roll.type == "Linear (Continuous)"
    motion(:,6) = c_linear(scantime, m_scen.roll.strength);
elseif m_scen.roll.type == "Nonlinear (Continuous)"
    motion(:,6) = c_nonlinear(scantime, m_scen.roll.strength);
elseif m_scen.roll.type == "Sudden"
    motion(:,6) = sudden(az, scantime, m_scen.roll.strength); 
end
disp(6)




    
end


function res = c_periodic(tr, scantime, strength)

res = zeros(scantime,1);
if strength == 'X'
else
    if strength == "Moderate"
        amp = 2;
        hz = 0.03*tr*6;
    elseif strength == "Severe"
        amp = 3;
        hz = 0.07*tr*6;
    end
    
    t = double((1:scantime)).' .* (tr/1000);
    res = amp*sin(2*pi*hz*t);
        
end

end

function res = c_linear(scantime, strength)

if strength == 'X'
    res = zeros(scantime,1);
else
    if strength == "Moderate"
        x1 = randi([-8 8], 1); 
    elseif strength == "Severe"
        x1 = 0;
        while(abs(x1)<=6)
            x1 = randi([-16 16],1);
        end
    end
    res = [0];
    i=1;
    while( i < scantime)
        a = randi([1 round(scantime/5)], 1); % ¹üÀ§
        for j = 1:a
            i = i+1;
            if i > scantime
                break
            end
            ind1 = random('Normal',0,0.03); % noise
            res = [res; res(i-1)+ind1];
        end
    end
    ori = linspace(0,x1*0.3,size(res,1));
    ori = reshape(ori, [size(ori,2) size(ori,1)]);
    res = ori+res;
    res = res * 3;
end

end

function res = c_nonlinear(scantime, strength)

if strength == 'X'
    res = zeros(scantime,1);
else
    res = [0];
    i = 1;
    while( i < scantime)
        i = i+1;
        new = random('Normal',0,0.5); 
        res = [res; new];
        a = randi([1 round(scantime/5)], 1);
        for j = 1:a
            i = i+1;
            if i > scantime
                break;
            end
            ind1 = random('Normal',0,0.1);
            res = [res; new+ind1]; 
        end
        if i >= scantime
            break;
        end
    end
    if strength == "Severe"
        res = 6*res;  %severe
    else 
        res = 3*res;
    end
end

end

function res = sudden(az, scantime, strength)

res = zeros(scantime,1);
if strength == 'X'
else
    gae = randi([2 az], 1);
    whe = randi([5 scantime],1,gae);
    for i = 1:gae
        ho = randi([1 4], 1);
        if whe(i)+ho > scantime
            ho = scantime-whe(i);
        end
        for j = 1:ho
            res(whe(i)+j-1) = res(whe(i)+j-2)+random('Normal',0,0.5);
        end
    end
    if strength == "Severe"
        res = 5*res;  %severe
    end
end
end