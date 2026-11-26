# Emissão em directo BTV
Página pública: /directo/ . Administração: /studio/ (mantém autenticação e autorização existentes).
No Studio, criar conteúdo do tipo Em directo, inserir URL HTTPS pública de reprodução HLS (.m3u8), YouTube ou Vimeo e publicar. MP4/WebM também são aceites como fontes de vídeo. Apenas publicar uma emissão principal de cada vez, ou usar a ordem para definir a prioridade.
O leitor usa HLS nativo quando disponível, caso contrário hls.js por CDN. A origem HLS deve permitir CORS para o domínio da plataforma, incluindo playlists e segmentos, e servir HTTPS. A página consulta a disponibilidade a cada 30 segundos.
Esta página não recebe directamente RTMP/SRT nem transcodifica vídeo. Configurar servidor de ingestão/encoder, distribuição HLS/CDN e variáveis Supabase no Coolify antes de testar emissão real. Não partilhar chaves de ingestão no código ou nas tabelas públicas. A grelha horária não foi incluída porque os horários oficiais não foram fornecidos.
