# BTV Play — Site público + Studio para Coolify

Projecto estático Docker/Nginx preparado para alojamento próprio. O site público (`/`) e o gestor editorial (`/studio/`) utilizam o **mesmo** Supabase.

## Instalação no servidor (Coolify)

1. Criar um repositório GitHub chamado `btv-play` na conta `Dev-Ruco`, caso ainda não exista. Enviar **todos** os ficheiros desta pasta para a branch `main` (Dockerfile na raiz). O repositório encontra-se na conta Dev-Ruco.
2. No Coolify: **New Resource → Application → Git Repository**. Seleccionar `Dev-Ruco/btv-play`, branch `main`, opção **Dockerfile** e porta interna **80**. Associar o domínio ou subdomínio desejado e activar HTTPS.
3. Definir variáveis de ambiente em Coolify (Environment Variables): `BTV_SUPABASE_URL` = URL do Supabase acessível por HTTPS a partir do browser; `BTV_SUPABASE_ANON_KEY` = chave pública anon/publishable do mesmo projecto. **Nunca utilizar a chave service_role.**
4. No projecto Supabase, executar `deploy/schema.sql` no SQL Editor. O script cria tabelas `public.btv_contents` e `public.btv_admins`, políticas RLS e buckets públicos. Rever os nomes/políticas se existirem tabelas anteriores.
5. Em **Supabase Authentication**, criar o administrador e executar `insert into public.btv_admins(user_id) values ('UUID-DO-ADMIN');` na consola SQL (substituir o UUID). O acesso ao Studio depende da autenticação **e da autorização na base de dados**.
6. Confirmar que o URL do site, o login em `/studio/`, a criação de um vídeo de teste e o aparecimento desse conteúdo na página principal funcionam. Publicar um vídeo numa categoria; os visitantes passam a vê-lo automaticamente.

## Rotas

- `/` — TV pública, programas e biblioteca, com os vídeos publicados no Studio.
- `/studio/` — gestão de conteúdos (login, upload, edição, publicação, destaques e ordenação).
- `/health` — verificação de disponibilidade do servidor.

## Atenção

- Ficheiros do Storage são públicos mesmo depois de ocultar um conteúdo; ocultar afecta a listagem, não revoga o URL de um vídeo público.
- Os uploads simples no Studio têm limite de 100 MB e dependem também do limite do Supabase/Proxy. Para conteúdos de longa duração recomenda-se object storage com upload retomável e HLS.
- YouTube/Vimeo funcionam no leitor integrado; MP4/WebM e outros formatos compatíveis com o navegador usam o leitor nativo. HLS `.m3u8` requer suporte do browser (ou hls.js, ainda não incluído).
- O site utiliza Supabase JS por CDN. Se desejar operação sem dependências de CDN, adicione o bundle local.
- A variável anon é pública por natureza; a segurança das publicações é garantida por RLS.
- Este pacote contém uma nova interface pública baseada nas secções do BTV Play encontrado na Vercel, mas **não é uma cópia byte-a-byte do website original**, porque não foi possível recuperar integralmente todos os ficheiros originais. Rever visualmente antes de substituir o site actual no domínio principal.
- O Coolify pode construir a aplicação a partir deste Dockerfile. Para `docker compose` externo, utilizar `docker compose up -d --build` após preencher `.env`.