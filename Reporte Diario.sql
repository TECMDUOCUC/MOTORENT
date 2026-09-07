DROP TABLE reporte_diario_cliente CASCADE CONSTRAINTS;
DROP TABLE reporte_diario_empleado CASCADE CONSTRAINTS;

CREATE TABLE reporte_diario_cliente (
    fecha_reporte    DATE DEFAULT SYSDATE,
    numrun_cli       NUMBER(10),
    total_multas     NUMBER,
    total_arriendos  NUMBER
);

CREATE TABLE reporte_diario_empleado (
    numrun_emp       NUMBER(10),
    motos_emp        NUMBER
);

CREATE OR REPLACE PROCEDURE prc_reporte_diario
IS  
    v_cursor_cli                SYS_REFCURSOR;
    v_rut_cli                   cliente.numrun_cli%TYPE;
    v_multas_cli                NUMBER;
    v_arriendos_cli             NUMBER;

    v_rut_emp                   empleado.numrun_emp%type;
    v_ventas_emp                NUMBER;

    v_cursor_emp                SYS_REFCURSOR;
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE reporte_diario_cliente';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE reporte_diario_empleado';

    pkg_gestion_arriendos.prc_get_multas_clientes(v_cursor_cli);

    LOOP
        FETCH v_cursor_cli INTO v_rut_cli, v_multas_cli, v_arriendos_cli;
        EXIT WHEN v_cursor_cli%NOTFOUND;

        INSERT INTO reporte_diario_cliente (
            numrun_cli, 
            total_multas, 
            total_arriendos
        ) VALUES (
            v_rut_cli, 
            v_multas_cli, 
            v_arriendos_cli
        );
    END LOOP;
    CLOSE v_cursor_cli;


    pkg_gestion_arriendos.prc_get_motos_emp(v_cursor_emp);

    LOOP
        FETCH v_cursor_emp INTO v_rut_emp, v_ventas_emp;
        EXIT WHEN v_cursor_emp%NOTFOUND;

        INSERT INTO reporte_diario_empleado (
            numrun_emp, 
            motos_emp 
        ) VALUES (
            v_rut_emp, 
            v_ventas_emp 
        );
    END LOOP;
    CLOSE v_cursor_emp;
    DBMS_OUTPUT.PUT_LINE('Reporte diario terminado.');
    COMMIT;
END;
/


BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_REPORTAJE_DIARIO',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'PRC_REPORTE_DIARIO',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=18; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 
            'Realiza un reportaje de las motos registradas 
            por empleado y compras por cliente y sus deudas, a las 6 PM.'
    );
END;
/

/*
BEGIN
    DBMS_SCHEDULER.RUN_JOB('JOB_REPORTAJE_DIARIO');
END;
/

BEGIN
    DBMS_SCHEDULER.DISABLE('JOB_REPORTAJE_DIARIO');
END;
/

BEGIN
    DBMS_SCHEDULER.DROP_JOB('JOB_REPORTAJE_DIARIO');
END;
/
*/