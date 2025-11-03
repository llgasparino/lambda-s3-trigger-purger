import json
import os
import urllib3
import urllib.parse

def lambda_handler(event, context):
    
    # Obter segredos direto do ambiente
    api_token   = os.environ.get('CLOUDFLARE_API_TOKEN')
    zone_id     = os.environ.get('CLOUDFLARE_ZONE_ID')
    domain_name = os.environ.get('CLOUDFLARE_DOMAIN')

    if not all([api_token, zone_id, domain_name]):
        print("ERRO: Variáveis de ambiente CLOUDFLARE_* não configuradas. Abortando.")
        return {'statusCode': 500, 'body': 'Variáveis de ambiente não configuradas.'}

    http = urllib3.PoolManager()
    api_endpoint = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/purge_cache"
    headers = {
        "Authorization": f"Bearer {api_token}", 
        "Content-Type": "application/json"
    }

    try:
        # Processar cada arquivo no evento S3
        urls_to_purge = []
        for s3_record in event.get('Records', []):
            event_name = s3_record.get('eventName', '')
            object_key = s3_record.get('s3', {}).get('object', {}).get('key')
            
            if not object_key:
                print(f"AVISO: Registro S3 sem 'object.key'. Pulando: {s3_record}")
                continue

            # Decodificar caracteres especiais no nome do arquivo (ex: espaços %20)
            object_key_decoded = urllib.parse.unquote_plus(object_key, encoding='utf-8')
            url_to_purge = f"https://{domain_name}/{object_key_decoded}"
            
            print(f"Evento S3: {event_name}. Arquivo: {object_key_decoded}. URL: {url_to_purge}")
            urls_to_purge.append(url_to_purge)

        if not urls_to_purge:
            print("Nenhuma URL para limpar encontrada no evento.")
            return {'statusCode': 200, 'body': 'Nenhuma URL para limpar.'}
            
        # Chamar a API da Cloudflare
        payload = json.dumps({"files": urls_to_purge})
        
        print(f"Iniciando purge no Cloudflare para {len(urls_to_purge)} arquivo(s)...")
        response = http.request('POST', api_endpoint, body=payload, headers=headers)
        response_data = json.loads(response.data.decode('utf-8'))

        # Verificar o sucesso
        if response.status != 200 or not response_data.get("success"):
            print(f"ERRO: Falha no purge do Cloudflare (HTTP {response.status}). Resposta: {response_data}")
            raise Exception(f"Falha no purge do Cloudflare: {response_data.get('errors')}")
        
        print("Solicitação de purge para o Cloudflare enviada com sucesso.")
        return {'statusCode': 200, 'body': 'Processo de limpeza de cache concluído.'}

    except Exception as e:
        print(f"ERRO GERAL NA EXECUÇÃO: {str(e)}")
        raise e