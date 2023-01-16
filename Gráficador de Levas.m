clear
clc

while true
    tipoSeguidor = input('Tipo de seguidor:\n    1) lineal\n    2) Radial\n');
    if (tipoSeguidor == 1) || (tipoSeguidor == 2)
        break
    end
end

Dmin = input('Diametro mínimo de la leva en mm:\n');
Drod = input('Diametro del rodillo del seguidor en mm:\n');
if tipoSeguidor == 2
    rmayor = input('Distancia del centro de la leva al centro de giro del seguidor en mm:\n');
    Lseguidor = input('Longitud del brazo del seguidor en mm:\n');
end

altura = [0];
continuar = 's';
while continuar == 's'

    while true
        direccion = input('\n¿1) Ascenso o 2) Descenso?\n');
        if (direccion == 1) || (direccion == 2)
            break
        end
    end

    %Desplazamiento
    while true
        tipo = input('Tipo de movimiento:\n    1) Armónico simple\n    2) Cicloidal\n    3) Polinomial\n');
        if (tipo == 1) || (tipo == 2) || (tipo == 3)
            break
        end
    end
    if tipoSeguidor == 1
        L = input('Desplazamiento en mm:\n');
    else
        L = input('Desplazamiento en grados:\n');
    end
    grados = input('Grados de rotación que tomará el desplazamiento:\n');
    
    alturaSeccion = funcionAltura(L, grados, tipo, direccion);
    if direccion == 1
        alturaSeccion = alturaSeccion + altura(end);
    else
        alturaSeccion = alturaSeccion + altura(end) - alturaSeccion(1);
    end
    altura = [altura alturaSeccion];

    %Reposo
    gradosEnReposo = input('Grados de rotación en reposo:\n');
    reposo = ones(1, gradosEnReposo)*altura(end);
   
    %Siguiente desplazamiento
    continuar = input('¿Quiere otro desplazamiento? s/n\n','s');
end
    
disp('    (☞ﾟヮﾟ)☞ FIN ☜(ﾟヮﾟ☜)');
    
% Terminar leva y gráficar
longvectoraltura = size(altura);
if  longvectoraltura < 361
    restante = 360 - longvectoraltura(1,2);
    altura = [altura zeros(1,restante)];

    % Seguidor angular
    if tipoSeguidor == 2
        syms phi alpha
        [solphi,solalpha] = solve(rmayor*sind(phi) == Dmin/2 + Lseguidor*sind(alpha), ...
            rmayor*cosd(phi) == Lseguidor*cosd(alpha));
        for i=1:360
            altura(i) = Lseguidor*sind(altura(i))*cosd(solalpha(1));
        end
    end

    % Restar radio del rodillo del seguidor
    altura = altura - Drod/2;

    % Gráficar
    altura(361) = altura(1);
    altura = altura + Dmin/2;
    longvectoraltura = size(altura);
    theta = 1:longvectoraltura(1,2);

    figure('name', 'Contorno de la Leva');
    plot(theta, altura, 'LineWidth', 2);
    pos1 = get(gcf,'Position');
    set(gcf,'Position', pos1 - [pos1(3)/2,0,0,0]);
    title('Contorno de la Leva');
    axis([0 360 0 (max(altura))]);
    xlabel('Ángulo [°]');
    ylabel('Altura [mm]');

    figure('name', 'Leva');
    thetaRadianes = deg2rad(theta);
    polarplot(thetaRadianes, altura, 'LineWidth', 2);
    pos2 = get(gcf,'Position');
    set(gcf,'Position', pos2 + [pos1(3)/2,0,0,0]);
    title('Leva');

else
    disp('ERROR: No puede exceder los 360°, intentelo nuevamente.')
end




%% Funciones

function altura = funcionAltura(L, grados, tipo, direccion)
    switch tipo
        case 1 %Armónico simple
            for i=1:grados
                if i<(grados/2)
                    altura(i) = L/2 - (L/2)*cosd(180/grados*i);
                elseif i==3
                    altura(i) = L/2;
                else
                    altura(i) = L/2 - (L/2)*cosd(180/grados*i);
                end
            end
            
        case 2 %Cicloidal
            for i=1:grados
                altura(i) = L/pi*(pi*i/grados - .5*sin(2*pi*deg2rad(i)/deg2rad(grados)));
            end
            
        case 3 %Polinomial
            for i=1:grados
                altura(i) = L*(10*(i/grados)^3 - 15*(i/grados)^4 + 6*(i/grados)^5);
            end
    end

    if direccion == 2
                alturainv = fliplr(altura);
                altura = [alturainv];
            end
end
