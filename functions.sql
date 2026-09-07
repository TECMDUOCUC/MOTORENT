CREATE OR REPLACE PACKAGE pkg_gestion_arriendos
IS
    e_nombre_sesion_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nombre_sesion_invalido, -20000);

    e_empleado_no_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_empleado_no_encontrado, -20001);

    e_cliente_no_encontrado  EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cliente_no_encontrado, -20002);

    e_parametro_nulo         EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_parametro_nulo, -20003);

    FUNCTION fn_get_empleado_from_user RETURN empleado.numrun_emp%TYPE;
    
    FUNCTION fn_get_empleado_fecha_contrato(p_numrun_emp IN empleado.numrun_emp%TYPE) 
        RETURN empleado.fecha_contrato%TYPE;
        
    FUNCTION fn_get_region_from_emp(p_numrun_emp IN empleado.numrun_emp%TYPE) 
        RETURN empleado.id_region%TYPE;

    FUNCTION fn_get_cliente_region(p_numrun_cli IN cliente.numrun_cli%TYPE) 
        RETURN cliente.id_region%TYPE;

    PROCEDURE prc_get_multas_clientes(p_cursor OUT SYS_REFCURSOR);

    PROCEDURE prc_get_motos_emp(p_cursor OUT SYS_REFCURSOR);
END pkg_gestion_arriendos;
/

CREATE OR REPLACE PACKAGE BODY pkg_gestion_arriendos
IS
    FUNCTION fn_get_empleado_from_user
    RETURN empleado.numrun_emp%TYPE
    IS
        v_numrun_emp empleado.numrun_emp%TYPE;
    BEGIN
        IF USER NOT LIKE 'EMP%' THEN
            RAISE e_nombre_sesion_invalido;
        END IF;

        v_numrun_emp := TO_NUMBER(SUBSTR(USER, 4));
        RETURN v_numrun_emp;
    EXCEPTION
        WHEN e_nombre_sesion_invalido THEN
            DBMS_OUTPUT.PUT_LINE('Su nombre de sesión no es válido');
            RETURN NULL;
        WHEN VALUE_ERROR THEN
            RETURN NULL;


    END fn_get_empleado_from_user;

    FUNCTION fn_get_empleado_fecha_contrato(
        p_numrun_emp IN empleado.numrun_emp%TYPE
    )
    RETURN empleado.fecha_contrato%TYPE
    IS
        v_fecha_contrato empleado.fecha_contrato%TYPE;
    BEGIN
        IF p_numrun_emp IS NULL THEN
            RAISE e_parametro_nulo;
        END IF;

        BEGIN
            SELECT fecha_contrato
              INTO v_fecha_contrato
              FROM empleado
             WHERE numrun_emp = p_numrun_emp;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE e_empleado_no_encontrado;
        END;

        RETURN v_fecha_contrato;
    EXCEPTION
        WHEN e_parametro_nulo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El RUN del empleado no puede ser nulo.');
            RETURN NULL;
        WHEN e_empleado_no_encontrado THEN
            DBMS_OUTPUT.PUT_LINE('Error: El empleado con RUN ' || p_numrun_emp || ' no existe.');
            RETURN NULL;
    END fn_get_empleado_fecha_contrato;

    FUNCTION fn_get_region_from_emp(
        p_numrun_emp IN empleado.numrun_emp%TYPE
    )
    RETURN empleado.id_region%TYPE
    IS
        v_id_region_emp empleado.id_region%TYPE;
    BEGIN
        IF p_numrun_emp IS NULL THEN
            RAISE e_parametro_nulo;
        END IF;

        BEGIN
            SELECT id_region
              INTO v_id_region_emp
              FROM empleado
             WHERE numrun_emp = p_numrun_emp;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE e_empleado_no_encontrado;
        END;

        RETURN v_id_region_emp;
    EXCEPTION
        WHEN e_parametro_nulo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El RUN del empleado no puede ser nulo.');
            RETURN NULL;
        WHEN e_empleado_no_encontrado THEN
            DBMS_OUTPUT.PUT_LINE('Error: El empleado con RUN ' || p_numrun_emp || ' no existe.');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al consultar la región del empleado.');
            RETURN NULL;
    END fn_get_region_from_emp;

    FUNCTION fn_get_cliente_region(
        p_numrun_cli IN cliente.numrun_cli%TYPE
    )
    RETURN cliente.id_region%TYPE
    IS
        v_id_region cliente.id_region%TYPE;
    BEGIN
        IF p_numrun_cli IS NULL THEN
            RAISE e_parametro_nulo;
        END IF;

        BEGIN
            SELECT id_region
              INTO v_id_region
              FROM cliente
             WHERE numrun_cli = p_numrun_cli;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                RAISE e_cliente_no_encontrado;
        END;

        RETURN v_id_region;
    EXCEPTION
        WHEN e_parametro_nulo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El RUN del cliente no puede ser nulo.');
            RETURN NULL;
        WHEN e_cliente_no_encontrado THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente con RUN ' || p_numrun_cli || ' no existe.');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al consultar la región del cliente.');
            RETURN NULL;
    END fn_get_cliente_region;

    PROCEDURE prc_get_multas_clientes(
        p_cursor OUT SYS_REFCURSOR
    )
    IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                c.numrun_cli AS rut,
                COUNT(
                    CASE 
                        WHEN (a.fecha_devolucion IS NOT NULL 
                              AND a.fecha_devolucion > (a.fecha_ini_arriendo + a.dias_solicitados))
                          OR (a.fecha_devolucion IS NULL 
                              AND SYSDATE > (a.fecha_ini_arriendo + a.dias_solicitados))
                        THEN 1 
                    END
                ) AS total_multas,
                COUNT(a.id_arriendo) AS total_arriendos
            FROM cliente c
            LEFT JOIN arriendo_moto a 
              ON a.numrun_cli = c.numrun_cli
            GROUP BY c.numrun_cli;
    END prc_get_multas_clientes;

    PROCEDURE prc_get_motos_emp(
        p_cursor OUT SYS_REFCURSOR
    )
    IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                e.numrun_emp,
                COUNT(m.placa) AS motos_emp
            FROM empleado e
            LEFT JOIN motocicleta m 
              ON m.numrun_emp = e.numrun_emp
            GROUP BY e.numrun_emp;
    END prc_get_motos_emp;

END pkg_gestion_arriendos;
/