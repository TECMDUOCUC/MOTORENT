CREATE OR REPLACE TRIGGER trg_admin_only_cliente
BEFORE INSERT OR UPDATE OR DELETE ON cliente
BEGIN
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) NOT BETWEEN 8 AND 18 THEN
         RAISE_APPLICATION_ERROR(
            -20001, 
            'Acceso no permitido. No es posible modificar la tabla fuera de horarios de trabajo.'
        );
    END IF;
END;
/


