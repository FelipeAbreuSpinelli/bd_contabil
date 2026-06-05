-- Banco de dados para um escritório de contabilidade fictício
-- Linguagem: MySQl
-- Modelagem: DBdesigner.net

-- criação da tabela CLIENTES
CREATE TABLE IF NOT EXISTS `clientes` (
	`id_cliente` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_cliente` varchar(50) NOT NULL,
	`email` varchar(100) NOT NULL,
	`CNPJ` varchar(20),  -- Número de registro para identificação de uma EMPRESA
	`telefone_celular` varchar(22) NOT NULL,
	`CPF` varchar(14) NOT NULL UNIQUE,  -- Número de registro para identificação de uma PESSOA
	`cidade` varchar(100) NOT NULL,
	`estado` char(2) NOT NULL,
	`logradouro` varchar(80) NOT NULL,
	`bairro` varchar(80) NOT NULL,
	`numero` int NOT NULL,
	`CEP` varchar(9) NOT NULL, -- Criado pelos correios para facilitar a entrega de produtos/correspondências em todo o brasil
	`data_cadastro` timestamp NOT NULL,
    PRIMARY KEY (`id_cliente`),
    FOREIGN KEY (`CNPJ`) REFERENCES `empresas`(`CNPJ`)
);
CREATE TABLE IF NOT EXISTS `empresas` (
	`id_empresa` int AUTO_INCREMENT NOT NULL UNIQUE,
	`CNPJ` varchar(20) NOT NULL UNIQUE,
	`razao_social` varchar(100) NOT NULL, -- Nome oficial da empresa
	`nome_fantasia` varchar(100) NOT NULL, -- "Apelido" da empresa
	`email` varchar(100) NOT NULL UNIQUE,
	`endereco` varchar (600)  NOT NULL,
	`telefone_celular` varchar(22) NOT NULL,
	`telefone_fixo` varchar(14),
	`cliente_id` int NOT NULL,
	PRIMARY KEY (`id_empresa`),
    FOREIGN KEY (`cliente_id`) REFERENCES `clientes`(`id_cliente`) -- Para identificar que essa empresa pertence a tal cliente
    -- Relação N:1 (Várias empresas podem ter 1 cliente)
	);
CREATE TABLE IF NOT EXISTS `funcionarios` (
	`id_funcionario` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_funcionario` varchar(50) NOT NULL,
	`cpf_funcionario` varchar(14) NOT NULL UNIQUE,
	`cargo` varchar(100) NOT NULL,
	`salario` decimal(9,2) NOT NULL,
	`carga_horaria` decimal(5,2) NOT NULL,
	`horas_extras` decimal(4,2) NOT NULL,
	`data_admissao` timestamp NOT NULL, -- data e hora que ele entrou na empresa
	`beneficios` varchar(60) NOT NULL, -- Ex: Vale-transporte, Vale-alimentação, etc.
	`dias_ferias` int NOT NULL,
	`INSS` decimal(9,2) NOT NULL,-- Valor descontado mensalmente do nosso salário, esse valor vai para os aposentados e pensionistas atuais, varia de 7,5% a 14%
	`FGTS` decimal(9,2) NOT NULL,-- Valor depositado mensalmente pela empresa para o trabalhador, o valor pode ser 8% ou 2%(Jovem aprendiz) do seu salário
	`empresa_id` int NOT NULL,
	PRIMARY KEY (`id_funcionario`),
    FOREIGN KEY (`empresa_id`) REFERENCES `empresas`(`id_empresa`) --Para identificar que o funcionários pertence a tal empresa
	-- Relação N:1 (Vários funcionários trabalham em uma empresa)
);
CREATE TABLE IF NOT EXISTS `demissoes` (
	`id_demissao` int AUTO_INCREMENT NOT NULL UNIQUE,
	`data_demissao` date NOT NULL,
	`motivo_demissao` text NOT NULL,
	`valor_rescisao` decimal(9,2) NOT NULL,
	`funcionario_id` int NOT NULL UNIQUE,
	PRIMARY KEY (`id_demissao`),
    FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios`(`id_funcionario`) --Para identificar a qual funcionário essa demissão pertence
    -- Relação 1:1 (Uma demissão pertence a 1 funcionário)
);
CREATE TABLE IF NOT EXISTS `socios` (
	`id_socios` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_socio` varchar(50) NOT NULL,
	`CPF` varchar(14) NOT NULL UNIQUE,
	`cargo` varchar(50) NOT NULL,
	`empresa_id` int NOT NULL,
	PRIMARY KEY (`id_socios`),
	FOREIGN KEY (`empresa_id`) REFERENCES `empresas`(`id_empresa`) --Para identificar a quais empresas esse sócio pertence
    --Relação 1:N (1 sócio podem ter várias empresas)
);
CREATE TABLE IF NOT EXISTS `notas_fiscais` (
	`id_nota` int AUTO_INCREMENT NOT NULL UNIQUE,
	`numero_nota` varchar(50) NOT NULL,
	`data_emissao` timestamp NOT NULL,
	`desc_produto` text NOT NULL, -- descrição do produto
	`quant_produto` int NOT NULL, -- quantidade do produto
	`valor_nota` decimal(9,2) NOT NULL,
	`serie_nota` int NOT NULL, -- Ex: série 1 para vendas físicas e série 2 para vendas online
	`valor_imposto` decimal(9,2) NOT NULL,
	`forma_pagamento` varchar(40) NOT NULL,
	`empresa_id` int NOT NULL,
	PRIMARY KEY (`id_nota`),
	FOREIGN KEY (`empresa_id`) REFERENCES `empresas`(`id_empresa`) --Muitas notas fiscais podem ser emitidas por 1 empresa
    -- Relação 1:N
);
CREATE TABLE IF NOT EXISTS `Impostos` (
	`id_imposto` int AUTO_INCREMENT NOT NULL UNIQUE,
	`sigla_imposto` varchar(10) NOT NULL, 
	`aliquota` decimal(5,2) NOT NULL, -- A porcentagem que o governo cobra 
	`valor_tributado` decimal(10,2) NOT NULL, -- Valor total que será pago de imposto
	`data_competencia` date NOT NULL, -- mês e o ano que a cobrança pertence
	`notafiscal_id` int NOT NULL,
	PRIMARY KEY (`id_imposto`),
    FOREIGN KEY (`notafiscal_id`) REFERENCES `notas_fiscais`(`id_nota`) --Uma nota pode gerar vários impostos
    -- Relação N:1
);
CREATE TABLE IF NOT EXISTS `categoria_financeira` (
	`id_categoria` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_categoria` varchar(50) NOT NULL, -- nome do que foi gasto (ex: Luz, água, aluguel)
	`tipo` varchar(20) NOT NULL, -- Ex: Conta corrente, poupança
	`criacao` timestamp NOT NULL, -- Data e hora que o registro foi feito no sistema
	PRIMARY KEY (`id_categoria`)
);
CREATE TABLE IF NOT EXISTS `conta_bancaria` (
	`id_conta` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_banco` varchar(50) NOT NULL, -- Ex; Itaú, Nubank
	`tipo_conta` varchar(50) NOT NULL, -- Ex: Conta corrente, poupança
	`saldo_inicial` decimal(9,2) NOT NULL, -- Quantidade de dinheiro que tinha no banco antes de usar o sistema
	`criacao` timestamp NOT NULL, -- Data e hora do cadastro no sistema bancário
	PRIMARY KEY (`id_conta`)
);
CREATE TABLE IF NOT EXISTS `lancamentos_financeiros` (
	`id_lancamento` int AUTO_INCREMENT NOT NULL UNIQUE,
	`descricao` text NOT NULL,
	`valor_monetario` decimal(9,2) NOT NULL, -- O valor em dinheiro da movimentação
	`tipo_lancamento` varchar(50) NOT NULL, -- Ex: Receita ou despesa
	`status` ENUM('Pendente','Pago') NOT NULL, --Duas opções para selecionar apenas
	`criacao` timestamp NOT NULL, -- Data e hora da movimentação
	`categoria_id` int NOT NULL,
	`conta_id` int NOT NULL,
	PRIMARY KEY (`id_lancamento`),
	FOREIGN KEY (`categoria_id`) REFERENCES `categoria_financeira`(`id_categoria`), -- Um lançamento possui uma categoria
	-- Relação 1:1
	FOREIGN KEY (`conta_id`) REFERENCES `conta_bancaria`(`id_conta`) -- Um lançamento possui uma conta bancária
	-- Relação 1:1
);
