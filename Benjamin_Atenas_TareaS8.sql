CREATE TABLE PAIS (
    id_pais NUMBER(3) NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 9 INCREMENT BY 3),
    nom_pais VARCHAR2 (30) NOT NULL CONSTRAINT pais_unico_un UNIQUE,
    
    CONSTRAINT PAIS_PK PRIMARY KEY(id_pais)
);

CREATE TABLE CIUDAD (
    id_ciudad NUMBER(3) NOT NULL,
    nom_ciudad VARCHAR2(30) NOT NULL UNIQUE,
    cod_pais NUMBER(3) NOT NULL,
    
    CONSTRAINT CIUDAD_PK PRIMARY KEY (id_ciudad),
    CONSTRAINT CIUDAD_FK_PAIS FOREIGN KEY (cod_pais) REFERENCES PAIS(id_pais)
);

CREATE TABLE TIPO_AUTOMOVIL (
    id_tipo CHAR(3) NOT NULL,
    descripcion VARCHAR2(20) NOT NULL,
    
    CONSTRAINT TIPO_AUTOMOVIL_PK PRIMARY KEY (id_tipo)
);

CREATE TABLE MARCA (
    id_marca NUMBER(2) NOT NULL,
    descripcion VARCHAR2(20) NOT NULL,
    
    CONSTRAINT MARCA_PK PRIMARY KEY (id_marca)
);

CREATE TABLE MODELO (
    id_modelo NUMBER(5) NOT NULL,
    marca_id NUMBER(2) NOT NULL,
    descripcion VARCHAR2(20) NOT NULL,
    
    CONSTRAINT MODELO_PK PRIMARY KEY (id_modelo, marca_id),
    CONSTRAINT MODELO_FK_MARCA FOREIGN KEY (marca_id) REFERENCES MARCA (id_marca)
);

CREATE TABLE SERVICIO (
    id_servicio NUMBER(3) NOT NULL,
    descripcion VARCHAR2(100) NOT NULL,
    costo NUMBER(7) NOT NULL CONSTRAINT ck_costo_min_servicio CHECK (costo > 0),
    
    CONSTRAINT SERVICIO_PK PRIMARY KEY (id_servicio)
);

CREATE TABLE SUCURSAL (
    id_sucursal CHAR(3) NOT NULL,
    nom_sucursal VARCHAR2(20) NOT NULL UNIQUE,
    calle VARCHAR2(20) NOT NULL,
    num_calle NUMBER(4) NOT NULL,
    cod_ciudad NUMBER(3) NOT NULL,
    
    CONSTRAINT SUCURSAL_PK PRIMARY KEY (id_sucursal),
    CONSTRAINT SUCURSAL_FK_CIUDAD FOREIGN KEY (cod_ciudad) REFERENCES CIUDAD(id_ciudad)
);

CREATE TABLE MECANICO (
    cod_mecanico NUMBER(5) NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 460 INCREMENT BY 7),
    pnombre VARCHAR2(20) NOT NULL,
    snombre VARCHAR2(20) NOT NULL,
    apaterno VARCHAR2(20) NOT NULL,
    amaterno VARCHAR2(20) NOT NULL,
    bono_jefatura NUMBER(10),
    sueldo NUMBER(10) NOT NULL,
    monto_impuestos NUMBER(10) NOT NULL,
    cod_supervisor NUMBER(5),
    
    CONSTRAINT MECANICO_PK PRIMARY KEY (cod_mecanico),
    CONSTRAINT MECANICO_FK_MECANICO FOREIGN KEY (cod_supervisor) REFERENCES MECANICO(cod_mecanico)
);

CREATE TABLE CLIENTE(
    rut NUMBER(8) NOT NULL,
    dv CHAR(1) NOT NULL,
    pnombre VARCHAR2(20) NOT NULL,
    snombre VARCHAR2(20),
    apaterno VARCHAR2(20) NOT NULL,
    amaterno VARCHAR2(20) NOT NULL,
    telefono VARCHAR2(12),
    email VARCHAR2(40),
    tipo_cli CHAR(1) NOT NULL CONSTRAINT tipo_ck CHECK(tipo_cli IN('E','P')),
    
    CONSTRAINT CLIENTE_PK PRIMARY KEY (rut)
);

CREATE TABLE ESTANDAR(
    cl_rut NUMBER(8) NOT NULL,
    puntaje_fidelidad NUMBER(10) NOT NULL,
    
    CONSTRAINT NORMAL_PK PRIMARY KEY(cl_rut),
    CONSTRAINT NORMAL_FK_CLIENTE FOREIGN KEY (cl_rut) REFERENCES CLIENTE(rut) 
);

CREATE TABLE PREMIUM(
    cl_rut NUMBER(8) NOT NULL,
    pesos_clientes NUMBER(10) NOT NULL,
    monto_credito NUMBER(10),
    
    CONSTRAINT PREMIUN_PK PRIMARY KEY (cl_rut),
    CONSTRAINT PREMIUM_FK_CLIENTE FOREIGN KEY (cl_rut) REFERENCES CLIENTE(rut)
);

CREATE TABLE AUTOMOVIL (
    patente CHAR(8) NOT NULL,
    annio NUMBER (4) NOT NULL,
    cant_puertas NUMBER(1) NOT NULL,
    km NUMBER(6) NOT NULL,
    color VARCHAR2(30) NOT NULL,
    cod_tipo_auto CHAR(3) NOT NULL,
    cod_modelo NUMBER(5) NOT NULL,
    cod_marca NUMBER(2) NOT NULL,
    cl_rut NUMBER(8) NOT NULL,
    
CONSTRAINT AUTOMOVIL_PK PRIMARY KEY (patente),
    CONSTRAINT AUTOMOVIL_FK_CLIENTE FOREIGN KEY (cl_rut) REFERENCES CLIENTE(rut),
    CONSTRAINT AUTOMOVIL_FK_MODELO FOREIGN KEY (cod_modelo, cod_marca) REFERENCES MODELO(id_modelo, marca_id),
    CONSTRAINT AUTOMOVIL_FK_TIPO FOREIGN KEY (cod_tipo_auto) REFERENCES TIPO_AUTOMOVIL(id_tipo)
);

CREATE TABLE MANTENCION (
    num_mantencion NUMBER(4) NOT NULL,
    cod_sucursal CHAR(3) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_salida DATE CONSTRAINT verificacion_fecha_ck CHECK (fecha_salida >= fecha_ingreso),
    patente_auto CHAR(8) NOT NULL,
    cod_mecanico NUMBER(5) NOT NULL,
    costo_total NUMBER(7) NOT NULL CONSTRAINT costo_min_mantencion_ck CHECK (costo_total > 0),
    estado VARCHAR2(15),
    
    CONSTRAINT MANTENCION_PK PRIMARY KEY (num_mantencion),
    CONSTRAINT MANT_FK_AUTOMOVIL FOREIGN KEY (patente_auto) REFERENCES AUTOMOVIL (patente),
    CONSTRAINT MANT_FK_MECANICO FOREIGN KEY (cod_mecanico) REFERENCES MECANICO (cod_mecanico),
    CONSTRAINT MANT_FK_SUCURSAL FOREIGN KEY (cod_sucursal) REFERENCES SUCURSAL (id_sucursal)
);

CREATE TABLE DETALLE_SERVICIO (
    mantencion_num NUMBER(4) NOT NULL,
    cod_servicio NUMBER(3) NOT NULL,
    descuento_serv NUMBER(4,3) CONSTRAINT verificacion_descuento_ck CHECK (descuento_serv >= 0),
    cantidad NUMBER(3) NOT NULL CONSTRAINT verificacion_cantidad_ck CHECK (cantidad > 0),
    
    CONSTRAINT DETALLE_SERVICIO_PK PRIMARY KEY (mantencion_num, cod_servicio),
    CONSTRAINT DET_SERV_FK_MANTENCION FOREIGN KEY (mantencion_num) REFERENCES MANTENCION (num_mantencion),
    CONSTRAINT DET_SERV_FK_SERIVICIO FOREIGN KEY (cod_servicio) REFERENCES SERVICIO (id_servicio)
);

--Caso 2

ALTER TABLE MANTENCION DROP COLUMN costo_total;

ALTER TABLE DETALLE_SERVICIO DROP CONSTRAINT DET_SERV_FK_MANTENCION;

ALTER TABLE MANTENCION DROP CONSTRAINT MANTENCION_PK;

ALTER TABLE MANTENCION ADD CONSTRAINT MANTENCION_PK PRIMARY KEY (num_mantencion, cod_sucursal);

ALTER TABLE DETALLE_SERVICIO ADD cod_sucursal CHAR(3) NOT NULL;

ALTER TABLE DETALLE_SERVICIO ADD CONSTRAINT DET_SERV_FK_MANTENCION FOREIGN KEY (mantencion_num, cod_sucursal) 
REFERENCES MANTENCION (num_mantencion, cod_sucursal);

ALTER TABLE CLIENTE ADD CONSTRAINT email_un UNIQUE(email);

ALTER TABLE CLIENTE ADD CONSTRAINT listado_dv_ck CHECK (dv IN('0','1','2','3','4','5','6','7','8','9','K','k'));

ALTER TABLE MECANICO ADD CONSTRAINT sueldo_minimo_ck CHECK (sueldo >= 510000);

ALTER TABLE MANTENCION ADD CONSTRAINT estado_ck CHECK (estado IN('Reserva', 'Ingresado', 'Entregado', 'Anulado'));

--Caso 3

CREATE SEQUENCE SEQ_SERVICIO 
    START WITH 400 
    INCREMENT BY 2 
    NOCACHE 
    NOCYCLE;

CREATE SEQUENCE SEQ_CIUDAD 
    START WITH 165 
    INCREMENT BY 5 
    NOCACHE 
    NOCYCLE;
    
--Poblamiento de la base de datos
    
INSERT INTO PAIS (nom_pais) VALUES ('Chile');
INSERT INTO PAIS (nom_pais) VALUES ('Argentina');

INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Antofagasta', 9);
INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Iquique', 9);
INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Calama', 9);

INSERT INTO TIPO_AUTOMOVIL (id_tipo, descripcion) VALUES ('SED', 'Sedan');
INSERT INTO TIPO_AUTOMOVIL (id_tipo, descripcion) VALUES ('SUV', 'SUV');

INSERT INTO MARCA (id_marca, descripcion) VALUES (1, 'Toyota');
INSERT INTO MARCA (id_marca, descripcion) VALUES (2, 'Hyundai');

INSERT INTO MODELO (id_modelo, marca_id, descripcion) VALUES (10, 1, 'Yaris');
INSERT INTO MODELO (id_modelo, marca_id, descripcion) VALUES (20, 2, 'Tucson');

INSERT INTO SERVICIO (id_servicio, descripcion, costo) VALUES (SEQ_SERVICIO.NEXTVAL, 'Cambio de Aceite', 35000);
INSERT INTO SERVICIO (id_servicio, descripcion, costo) VALUES (SEQ_SERVICIO.NEXTVAL, 'Alineación y Balanceo', 25000);
INSERT INTO SERVICIO (id_servicio, descripcion, costo) VALUES (SEQ_SERVICIO.NEXTVAL, 'Diagnóstico de Motor', 45000);

INSERT INTO SUCURSAL (id_sucursal, nom_sucursal, calle, num_calle, cod_ciudad) VALUES ('S01', 'Sucursal Antofagasta', 'Baquedano', 123, 165);
INSERT INTO SUCURSAL (id_sucursal, nom_sucursal, calle, num_calle, cod_ciudad) VALUES ('S02', 'Sucursal Iquique', 'Tarapacá', 456, 170);

INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor) 
VALUES ('Pedro', 'Peter', 'Perez', 'Paredes', 100000, 850000, 45000, NULL);

INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor) 
VALUES ('Max', 'Steel', 'Pérez', 'Soto', NULL, 650000, 35000, 460);

INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor) 
VALUES ('Kratos', 'Alberto', 'Perez', 'Diaz', NULL, 550000, 25000, 460);

INSERT INTO CLIENTE (rut, dv, pnombre, snombre, apaterno, amaterno, telefono, email, tipo_cli) 
VALUES (12345678, '9', 'Juan', 'Pedro', 'Perez', 'Silva', '987654321', 'juancho@email.com', 'E');

INSERT INTO AUTOMOVIL (patente, annio, cant_puertas, km, color, cod_tipo_auto, cod_modelo, cod_marca, cl_rut) 
VALUES ('DUOC26', 2020, 4, 45000, 'Rojo', 'SED', 10, 1, 12345678);

INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado) 
VALUES (1, 'S01', SYSDATE, NULL, 'DUOC26', 460, 'Ingresado');

INSERT INTO DETALLE_SERVICIO (mantencion_num, cod_servicio, descuento_serv, cantidad, cod_sucursal) 
VALUES (1, 400, 0.000, 1, 'S01');

COMMIT;

--Caso 4

SELECT 
    cod_mecanico AS "ID MECANICO",
    pnombre || ' ' || apaterno AS "NOMBRE MECANICO",
    sueldo AS "SALARIO",
    monto_impuestos AS "IMPUESTO ACTUAL",
    monto_impuestos * 0.80 AS "IMPUESTO REBAJADO",
    sueldo - (monto_impuestos * 0.80) AS "SUELDO CON REBAJA IMPUESTOS"
    
FROM MECANICO

WHERE bono_jefatura IS NULL 
  AND monto_impuestos < 40000
  
ORDER BY 
    monto_impuestos DESC, 
    apaterno ASC;
    
--Informe 2

SELECT 
    cod_mecanico AS "IDENTIFICADOR",
    pnombre || ' ' || snombre || ' ' || apaterno AS "MECANICO",
    sueldo AS "SALARIO ACTUAL",
    sueldo * 0.05 AS "AJUSTE",
    sueldo * 1.05 AS "SUELDO_REAJUSTADO"
    
FROM MECANICO

WHERE (sueldo BETWEEN 600000 AND 900000) 
   OR cod_supervisor IS NULL
   
ORDER BY 
    sueldo ASC, 
    pnombre || ' ' || snombre || ' ' || apaterno DESC;


