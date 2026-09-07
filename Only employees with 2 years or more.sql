CREATE OR REPLACE TRIGGER trg_antiguedad_motocicleta
BEFORE INSERT OR DELETE ON MOTOCICLETA
DECLARE
    v_numrun_emp      empleado.numrun_emp%TYPE;
    v_fecha_contrato  empleado.fecha_contrato%TYPE;
BEGIN
    --SOLO FUNCIONA SI SE LLAMA EMP[NUMERO]... POR EJEMPLO:
    --EMP38882712
    v_numrun_emp := pkg_gestion_arriendos.fn_get_empleado_from_user();
    v_fecha_contrato := pkg_gestion_arriendos.fn_get_empleado_fecha_contrato(v_numrun_emp);

    if v_numrun_emp is NULL or v_fecha_contrato is NULL then
        RAISE_APPLICATION_ERROR(
            -20010,
            'Acceso Denegado. Su perfil no pudo ser conectado a un empleado existente en la Base de Datos.'
        );
    end if;

    --Solo permitir acceso si tiene 2 años o más de contrato
    IF MONTHS_BETWEEN(SYSDATE, v_fecha_contrato) < 24 THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'Acceso Denegado: Su cuenta debe tener al menos 2
            años de antiguedad para modificar las Motocicletas'
        );
    END IF;
END;
/


