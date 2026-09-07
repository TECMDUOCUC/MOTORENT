DECLARE
    v_cur                SYS_REFCURSOR;
    v_rut                cliente.numrun_cli%TYPE;
    v_multas             NUMBER;
    v_arriendos          NUMBER;

    TYPE t_rango_descuento IS RECORD (
        min_arriendos NUMBER,
        max_arriendos NUMBER,
        pct_descuento NUMBER(4,2)
    );

    TYPE t_lista_rangos IS VARRAY(4) OF t_rango_descuento;
    v_escalas t_lista_rangos := t_lista_rangos(
        t_rango_descuento(0, 5, 0.05),
        t_rango_descuento(6, 10, 0.15),
        t_rango_descuento(11, 15, 0.20),
        t_rango_descuento(16, 9999, 0.25)
    );

    v_descuento_aplicado NUMBER(4,2);
BEGIN
    pkg_gestion_arriendos.prc_get_multas_clientes(v_cur);

    DBMS_OUTPUT.PUT_LINE('################################################');
    LOOP
        FETCH v_cur INTO v_rut, v_multas, v_arriendos;
        EXIT WHEN v_cur%NOTFOUND;

        v_descuento_aplicado := 0;

        FOR i IN 1..v_escalas.COUNT LOOP
            IF v_arriendos BETWEEN v_escalas(i).min_arriendos AND v_escalas(i).max_arriendos THEN
                v_descuento_aplicado := v_escalas(i).pct_descuento;
                EXIT;
            END IF;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('RUT: ' || v_rut 
            || CHR(10) || 'Multas: ' || v_multas 
            || CHR(10) || 'Total Arriendos: ' || v_arriendos
            || CHR(10) || 'Descuento Aplicado: ' || (v_descuento_aplicado * 100) || '%');

        DBMS_OUTPUT.PUT_LINE('################################################');
    END LOOP;

    CLOSE v_cur;
END;
/