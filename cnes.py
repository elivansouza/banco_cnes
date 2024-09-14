import logging
import os
import re
import zipfile
from datetime import datetime
from ftplib import FTP, error_perm, all_errors
from typing import List, Tuple

# Configuração do logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constantes
FTP_HOST = 'ftp.datasus.gov.br'
FTP_DIRECTORY = 'cnes'
FILE_PATTERN = r'^BASE_DE_DADOS_CNES_(\d{6})\.ZIP$'
DOWNLOAD_DIRECTORY = os.path.join(os.getcwd(), 'Downloads')  # Diretório para salvar o arquivo baixado
EXTRACT_DIRECTORY = os.path.join(os.getcwd(), 'CNES')        # Diretório para extrair os arquivos

def get_matching_files(ftp: FTP, pattern: str) -> List[Tuple[str, datetime]]:
    """
    Recupera e retorna uma lista de arquivos que correspondem ao padrão fornecido do servidor FTP.

    Args:
        ftp (FTP): Uma conexão FTP ativa.
        pattern (str): Um padrão regex para corresponder a nomes de arquivo.

    Returns:
        List[Tuple[str, datetime]]: Uma lista de tuplas contendo o nome do arquivo e sua data correspondente.
    """
    try:
        files = ftp.nlst()
    except error_perm as e:
        logger.error(f"Erro de permissão FTP: {e}")
        return []
    except all_errors as e:
        logger.error(f"Erro FTP: {e}")
        return []
    
    regex = re.compile(pattern)
    matched_files = []
    for file_name in files:
        match = regex.match(file_name)
        if match:
            date_str = match.group(1)
            try:
                date_obj = datetime.strptime(date_str, '%Y%m')
                matched_files.append((file_name, date_obj))
            except ValueError as e:
                logger.warning(f"Falha ao analisar a data do arquivo {file_name}: {e}")
    return matched_files

def download_file(ftp: FTP, file_name: str, local_path: str) -> bool:
    """
    Baixa um arquivo do servidor FTP para um caminho local.

    Args:
        ftp (FTP): Uma conexão FTP ativa.
        file_name (str): O nome do arquivo para download.
        local_path (str): O caminho local onde o arquivo será salvo.

    Returns:
        bool: True se o download foi bem-sucedido, False caso contrário.
    """
    try:
        with open(local_path, 'wb') as fp:
            ftp.retrbinary(f'RETR {file_name}', fp.write)
        logger.info(f"Download do {file_name} concluído com sucesso.")
        return True
    except error_perm as e:
        logger.error(f"Erro de permissão FTP: {e}")
    except all_errors as e:
        logger.error(f"Erro FTP: {e}")
    except Exception as ex:
        logger.error(f"Ocorreu um erro durante o download: {ex}")
    return False

def extract_zip_file(file_path: str, extract_directory: str) -> bool:
    """
    Extrai o conteúdo de um arquivo ZIP para um diretório especificado.

    Args:
        file_path (str): O caminho para o arquivo ZIP.
        extract_directory (str): O diretório onde o conteúdo será extraído.

    Returns:
        bool: True se a extração foi bem-sucedida, False caso contrário.
    """
    if not os.path.exists(file_path):
        logger.error(f"O arquivo {file_path} não foi encontrado.")
        return False

    try:
        os.makedirs(extract_directory, exist_ok=True)
        with zipfile.ZipFile(file_path, 'r') as zip_ref:
            zip_ref.extractall(extract_directory)
        logger.info(f"Arquivos extraídos para: {extract_directory}")
        return True
    except zipfile.BadZipFile as e:
        logger.error(f"Arquivo ZIP corrompido: {e}")
    except Exception as e:
        logger.error(f"Ocorreu um erro durante a extração: {e}")
    return False

def main():
    ftp = FTP()
    try:
        ftp.connect(FTP_HOST)
        ftp.login()  # Login sem necessidade de nome ou senha
        ftp.cwd(FTP_DIRECTORY)  # Navegação para o diretório do CNES

        matched_files = get_matching_files(ftp, FILE_PATTERN)
        if not matched_files:
            logger.info("Nenhum arquivo correspondente encontrado.")
            return

        # Ordena os arquivos por data decrescente
        matched_files.sort(key=lambda x: x[1], reverse=True)
        most_recent_file, _ = matched_files[0]

        user_input = input(f"Você deseja fazer download do arquivo {most_recent_file}? (Y/N): ").strip().upper()
        if user_input == 'Y':
            # Garante que o diretório de download exista
            os.makedirs(DOWNLOAD_DIRECTORY, exist_ok=True)
            local_file_path = os.path.join(DOWNLOAD_DIRECTORY, most_recent_file)

            if download_file(ftp, most_recent_file, local_file_path):
                logger.info("Arquivo baixado com sucesso.")
                # Procede para extrair o arquivo ZIP
                if extract_zip_file(local_file_path, EXTRACT_DIRECTORY):
                    logger.info("Arquivo extraído com sucesso.")
                else:
                    logger.error("Falha na extração do arquivo.")
            else:
                logger.error("Falha no download do arquivo.")
        else:
            logger.info("Operação cancelada pelo usuário.")
    except error_perm as e:
        logger.error(f"Erro de permissão FTP: {e}")
    except all_errors as e:
        logger.error(f"Erro FTP: {e}")
    except Exception as ex:
        logger.error(f"Ocorreu um erro: {ex}")
    finally:
        ftp.quit()
        logger.info("Conexão FTP encerrada.")

if __name__ == "__main__":
    main()

