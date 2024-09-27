-- Active: 1716856021564@@127.0.0.1@5432@BD_PI_012024_G6
-- Create a new database called 'DatabaseName'
CREATE DATABASE BD_PI_G6;

-- tabela tipo projeto
DROP TABLE IF EXISTS tipo_projeto;
CREATE TABLE tipo_projeto
(
    id_tipo_projeto serial PRIMARY KEY,
    setor varchar(20) NOT NULL,
    tipo_projeto varchar(20) NOT NULL
    CONSTRAINT chck_tipo_proj_setor
        CHECK (UPPER(setor) 
        IN (
            'PPP', 
            'PUBLICO', 
            'PRIVADO')
            ),
    CONSTRAINT chck_tipo_projeto
        CHECK (UPPER(tipo_projeto)
        IN (
            'RESIDENCIAL',
            'COMERCIAL',
            'REAL STATE',
            'INDUSTRIA',
            'TRANSPORTE',
            'AEROPORTO',
            'INSTITUCIONAL')
        )
);

-- tabela cliente
DROP TABLE IF EXISTS cliente;
CREATE TABLE cliente
(
    id_cliente serial PRIMARY KEY,
    cnpj numeric(14, 0) UNIQUE NOT NULL,
    nome_fantasia varchar(50) NOT NULL,
    endereco varchar(50) NOT NULL,
    contato_supri numeric(13, 0) NOT NULL,
    email_supri varchar(50) UNIQUE NOT NULL,
    nome_respons varchar(35) NOT NULL
);

-- tabela proposta
DROP TABLE IF EXISTS proposta;
CREATE TABLE proposta
(
    id_proposta serial PRIMARY KEY,
    id_tipo_projeto integer NOT NULL,
    id_cliente integer NOT NULL,
    area_projeto_m2 numeric NOT NULL,
    localizacao_uf char(2) NOT NULL,
    localizacao_cidade varchar(25) NOT NULL,
    endereco varchar(100) NOT NULL,
    CONSTRAINT pp_id_cliente_fkey 
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT pp_id_projeto_fkey 
        FOREIGN KEY (id_tipo_projeto)
        REFERENCES tipo_projeto (id_tipo_projeto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- tabela subcontratados
DROP TABLE IF EXISTS subcontratados;
CREATE TABLE subcontratados
(
    id_subcontratado serial PRIMARY KEY,
    cnpj numeric(14, 0) NOT NULL,
    cidade varchar(30) NOT NULL,
    email_com varchar(50) UNIQUE NOT NULL,
    respons_tec varchar(30) NOT NULL,
    tel_comercial numeric(13, 0) NOT NULL,
    atuacao varchar(30) NOT NULL,
    CONSTRAINT chck_atuacao
        CHECK (UPPER(atuacao)
        IN (
            'PAISAGISMO',
            'LUMINOTECNICO',
            'ESTRUTURA',
            'INSTALAÇÕES',
            'INTERIORES'
        )
        )
);

-- tabela etapa
DROP TABLE IF EXISTS etapa;
CREATE TABLE etapa
(
    id_etapa VARCHAR(50) NOT NULL,
    id_proposta INTEGER NOT NULL,
    id_subcontratado INTEGER NOT NULL,
    PRIMARY KEY (id_etapa, id_proposta),
    CONSTRAINT et_id_proposta_fkey  
        FOREIGN KEY (id_proposta)
        REFERENCES proposta (id_proposta) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT et_id_subcontratado_fkey
        FOREIGN KEY (id_subcontratado)
        REFERENCES subcontratados (id_subcontratado) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- tabela status proposta
DROP TABLE IF EXISTS status_proposta;
CREATE TABLE status_proposta
(
    tipo_status VARCHAR(20),
    id_proposta INTEGER NOT NULL,
    dt_atualizacao TIMESTAMP NOT NULL,
    valor DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (id_proposta, dt_atualizacao),
    CONSTRAINT status_pp_id_proposta_fkey 
        FOREIGN KEY (id_proposta)
        REFERENCES proposta (id_proposta) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_tipo_status 
        CHECK (LOWER(tipo_status) 
        IN (
            'solicitada', 
            'em desenvolvimento', 
            'enviada', 
            'em analise', 
            'aprovada', 
            'cancelada', 
            'interrompida')
            )
);
