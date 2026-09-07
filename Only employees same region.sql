create or replace trigger trg_empleado_same_region_only
before insert or delete or update on ARRIENDO_MOTO
FOR EACH ROW
DECLARE
    v_numrun_emp      empleado.numrun_emp%TYPE;
    v_region_emp      empleado.ID_REGION%TYPE;
    v_region_cli      cliente.ID_REGION%TYPE;
    v_numrun_cli      cliente.NUMRUN_CLI%TYPE;
BEGIN
    v_numrun_emp := pkg_gestion_arriendos.fn_get_empleado_from_user();
    v_region_emp := pkg_gestion_arriendos.fn_get_region_from_emp(v_numrun_emp);
        
    if v_numrun_emp is NULL or v_region_emp is NULL then
        RAISE_APPLICATION_ERROR(
            -20010,
            'Acceso Denegado. Su perfil no pudo ser conectado a un empleado 
            existente en la Base de Datos.'
        );
    end if;
    
    IF deleting then
        v_numrun_cli := :OLD.NUMRUN_CLI;
    else
        v_numrun_cli := :NEW.NUMRUN_CLI;
    END IF;

    v_region_cli := pkg_gestion_arriendos.fn_get_cliente_region(
        v_numrun_cli
    );

    if v_region_cli is NULL then
        RAISE_APPLICATION_ERROR(
            -20014,
            'Acceso Denegado. La venta no tiene un cliente definido, 
            o el cliente no registró su región.'
        );
    else
        if v_region_cli!= v_region_emp then
            RAISE_APPLICATION_ERROR(
                -20013,
                'Acceso Denegado. Usted no puede modificar 
                ventas con clientes FUERA de su región.'
            );
        end if;
    end if;
end;
/