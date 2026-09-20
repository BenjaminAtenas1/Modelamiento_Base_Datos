--Recuerda incluir antes de terminar los drop tables de cada una (instrucciones de borrado)

DROP TABLE PACIENTE CASCADE CONSTRAINTS;
DROP TABLE DIAGNOSTICO CASCADE CONSTRAINTS;
DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS;
DROP TABLE MEDICO CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE RECETA CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO_RECETA CASCADE CONSTRAINTS;
DROP TABLE DOSIS CASCADE CONSTRAINTS;
DROP TABLE DIGITADOR CASCADE CONSTRAINTS;
DROP TABLE PAGO CASCADE CONSTRAINTS;
DROP TABLE BANCO CASCADE CONSTRAINTS;


CREATE TABLE PACIENTE(
    rut_pac VARCHAR2(25) CONSTRAINT paciente_pk PRIMARY KEY,
    dv_pac CHAR(1)NOT NULL CONSTRAINT lista_dv CHECK(dv_pac IN ('0','1','2','3','4','5','6','7','8','9','K','k')),
    pnombre VARCHAR2(25) NOT NULL,
    snombre VARCHAR2(25),
    edad DATE NOT NULL,
    telefono NUMBER(11) NOT NULL,
    calle VARCHAR2(25) NOT NULL,
    numeracion NUMBER(5) NOT NULL,
    comuna NUMBER(5)GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 99999 START WITH 1101 INCREMENT BY 1,
    ciudad NUMBER(5) NOT NULL,
    region NUMBER(5) NOT NULL
);

CREATE TABLE DIAGNOSTICO(
    cod_diagnostico NUMBER(3) CONSTRAINT diagnostico_pk PRIMARY KEY,
    nombre VARCHAR2 (25) NOT NULL   
);

CREATE TABLE ESPECIALIDAD( --Tabla creada por especifipación de reglas de negocio
    id_especialidad NUMBER (3) GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 999 START WITH 100 INCREMENT BY 1, --Id comenzará desde 100 para que todos los IDs tengan 3 digitos.
    especialidad VARCHAR2(25) NOT NULL,
    
    CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad)
);

CREATE TABLE MEDICO(
    rut_med NUMBER(8) CONSTRAINT medico_pk PRIMARY KEY,
    dv_med CHAR (1) NOT NULL CONSTRAINT listado_dv CHECK(dv_med IN('0','1','2','3','4','5','6','7','8','9','K','k')),
    pnombre VARCHAR2(25) NOT NULL,
    snombre VARCHAR2(25),
    papellido VARCHAR2(25) NOT NULL,
    sapellido VARCHAR2(25),
    --especialidad VARCHAR2(25) NOT NULL,--A pesar de estar en el modelo relacional, se elimina ya que estará referenciado con el id de ESPECIALIDAD
    telefono NUMBER(11) NOT NULL UNIQUE, --Columna agregada por especificación de reglas del negocio
    --Llaves foraneas
    id_especialidad NUMBER (3) NOT NULL,
    
    CONSTRAINT medico_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD (id_especialidad)
);

CREATE TABLE MEDICAMENTO (
    cod_medicamento NUMBER(7) CONSTRAINT medicamento_pk PRIMARY KEY,
    nombre VARCHAR2(25) NOT NULL,
    tipo_medicamento NUMBER(3) NOT NULL,
    via_administrativa NUMBER(3) NOT NULL,
    dosis_recomendada VARCHAR2(25) NOT NULL, --Columna agregada por especificación de reglas del negocio
    stock_disponible NUMERIC(4) NOT NULL CONSTRAINT stock_minimo CHECK (stock_disponible > -1) --Columna agregada por especificación de reglas del negocio
);

CREATE TABLE RECETA(
    cod_receta NUMBER(7) CONSTRAINT receta_pk PRIMARY KEY,
    observaciones VARCHAR2(500),
    fecha_emision NUMBER(5) NOT NULL,
    fecha_vencimiento VARCHAR2(25),
    id_digitador NUMBER NOT NULL,
    id_tipo_receta NUMBER(3) NOT NULL,
    --Llaves foraneas
    pac_rut VARCHAR2(25) NOT NULL,
    id_diagnostico NUMBER(3) NOT NULL,
    med_rut NUMBER(8) NOT NULL,
    cod_medicamento NUMBER(7) NOT NULL, --Columna agregada por especificación de reglas del negocio
    
    CONSTRAINT receta_diagnostico_fk FOREIGN KEY (id_diagnostico) REFERENCES DIAGNOSTICO (cod_diagnostico),
    CONSTRAINT receta_medico_fk FOREIGN KEY (med_rut) REFERENCES MEDICO (rut_med),
    CONSTRAINT receta_paciente_fk FOREIGN KEY (pac_rut) REFERENCES PACIENTE (rut_pac),
    CONSTRAINT receta_medicamento_fk FOREIGN KEY (cod_medicamento) REFERENCES MEDICAMENTO (cod_medicamento)
);

CREATE TABLE MEDICAMENTO_RECETA ( --Tabla creada para establecer relación M:N según reglas de negocio
    cod_medicamento NUMBER(7) NOT NULL,
    cod_receta NUMBER(7) NOT NULL,
    
    CONSTRAINT medicamento_receta_pk PRIMARY KEY (cod_medicamento, cod_receta),
    CONSTRAINT id_medicamento_fk FOREIGN KEY (cod_medicamento) REFERENCES MEDICAMENTO (cod_medicamento),
    CONSTRAINT id_receta_fk FOREIGN KEY (cod_receta) REFERENCES RECETA (cod_receta)
);

CREATE TABLE DOSIS (
    descripcion_dosis VARCHAR2(25) NOT NULL,
    --Llaves foraneas
    id_medicamento NUMBER(7) NOT NULL,
    id_receta NUMBER(7) NOT NULL,
    
    CONSTRAINT dosis_pk PRIMARY KEY(id_medicamento,id_receta),
    CONSTRAINT dosis_medicamento_fk FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO (cod_medicamento)
);

CREATE TABLE DIGITADOR(
    id_digitador NUMBER(20) CONSTRAINT digitador_pK PRIMARY KEY,
    pnombre VARCHAR2(25) NOT NULL,
    papellido VARCHAR2(25) NOT NULL
);

CREATE TABLE BANCO(
    cod_banco NUMBER(2) CONSTRAINT banco_pk PRIMARY KEY,
    nombre VARCHAR2(2) NOT NULL
);

CREATE TABLE PAGO(
    cod_boleta NUMBER(6) CONSTRAINT boleta_pk PRIMARY KEY,
    id_receta NUMBER(7) NOT NULL,
    fecha_pago DATE NOT NULL,
    monto_total VARCHAR2(25) NOT NULL,
    metodo_pago NUMBER(4) NOT NULL,
    --Llaves foraneas
    id_banco NUMBER(2) NOT NULL,
    
    CONSTRAINT pago_banco_fk FOREIGN KEY (id_banco) REFERENCES BANCO (cod_banco)
);

--Acá comienzan los ajustes del Caso 2
ALTER TABLE MEDICAMENTO ADD precio_unitario NUMBER(7) NOT NULL CONSTRAINT rango_precios CHECK(precio_unitario >= 1000 AND precio_unitario <= 2000000);
ALTER TABLE PAGO MODIFY metodo_pago VARCHAR2(13)CONSTRAINT tipo_pago CHECK(metodo_pago IN('EFECTIVO','TARJETA','TRANSFERENCIA'));
ALTER TABLE PACIENTE DROP COLUMN edad;
ALTER TABLE PACIENTE ADD fecha_nacimiento DATE NOT NULL;


