
# Monitoramento de Estabelecimentos de Saúde - CNES

Este projeto foi desenvolvido para automatizar o processo de extração e monitoramento de dados do **Cadastro Nacional de Estabelecimentos de Saúde (CNES)**. Através da combinação de várias bases de dados, é possível realizar o planejamento estratégico e acompanhar a integração de estabelecimentos de saúde com o SUS Digital. Os dados extraídos também são utilizados para alimentar painéis de monitoramento no **Power BI**.

## Estrutura do Projeto

- **cnes.py**: Script Python que realiza o download e extração de arquivos do CNES a partir de um servidor FTP.
- **QueryMontagemBancoCNES.sql**: Conjunto de queries SQL utilizado para criar e preparar o banco de dados no **PostgreSQL**, incluindo os tratamentos necessários.
- **QueryExtraçãoPainel.sql**: Query SQL que extrai os dados necessários em formato CSV para serem utilizados no painel de monitoramento no **Power BI**.
- **CNES.csv**: Amostra do arquivo CSV gerado pela query `QueryExtraçãoPainel.sql`, utilizado para alimentar o painel de monitoramento.

### Arquivos Utilizados para Montagem do CNES
Os seguintes arquivos são extraídos e processados para alimentar o banco de dados e o painel de monitoramento:

- rlEstabEquipeProf202407.csv
- tbAtividade202407.csv
- tbAtividadeProfissional202407.csv
- tbConselhoClasse202407.csv
- tbDadosProfissionalSus202407.csv
- tbEstabelecimento202407.csv
- tbGestao202407.csv
- tbGrupoAtividade202407.csv
- tbGrupoEquipe202407.csv
- tbSubTipo202407.csv
- tbTipoEquipe202407.csv
- tbTipoEstabelecimento202407.csv
- tbTipoUnidade202407.csv
- tbTurnoAtendimento202407.csv

## Requisitos

- Python 3.6+
- PostgreSQL
- Pacotes Python:
  - `ftplib`
  - `logging`
  - `zipfile`

## Como Utilizar

### 1. Extração dos Dados CNES

O script **cnes.py** faz o download e a extração dos dados do **FTP** do Datasus:

```bash
python cnes.py
```

Isso irá baixar o arquivo ZIP mais recente que contém os dados do CNES e extrair seu conteúdo para um diretório local.

### 2. Montagem do Banco de Dados

Utilize as queries do arquivo **QueryMontagemBancoCNES.sql** para criar o banco de dados no **PostgreSQL**. Essas queries fazem todos os ajustes, tratamentos e complementações dos dados para uso posterior no painel de monitoramento.

### 3. Extração para o Painel

Após o banco de dados estar configurado, execute a query presente em **QueryExtraçãoPainel.sql** para gerar o arquivo CSV que será utilizado no painel de monitoramento.

### 4. Painel de Monitoramento

O arquivo **CNES.csv** gerado pela query de extração é utilizado no Power BI para a visualização do monitoramento de estabelecimentos de saúde integrados ao SUS Digital.

## Pontos de Evolução

- Automatizar a criação das tabelas no PostgreSQL e todos os tratamentos de forma completa dentro do script Python.
- Integrar a extração diretamente com o Power BI para atualização automática do painel.

## Contribuindo

Se você deseja contribuir com o projeto, sinta-se à vontade para abrir uma **issue** ou enviar um **pull request**.
