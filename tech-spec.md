# Especificação técnica — Gerenciador de links

Este documento reúne as tecnologias e decisões de implementação da primeira versão. O objetivo, as regras de negócio e os cenários de aceitação estão em [spec.md](spec.md).

## Tecnologias e arquitetura da primeira versão

### Stack e organização

Os projetos serão criados nas pastas `frontend` e `backend`, na raiz do mesmo repositório Git. Ambos utilizarão TypeScript e serão projetos npm independentes, cada um com seu próprio `package.json`, `package-lock.json` e `node_modules/`. Não haverá manifesto npm nem instalação compartilhada na raiz.

| Área | Tecnologia | Responsabilidade |
| --- | --- | --- |
| Runtime | Node.js 24 LTS | Executar os dois projetos. |
| Frontend | Next.js 16 com App Router | Interface e navegação. |
| Estilos | Tailwind CSS 4 | Estilização dos componentes. |
| Backend | Express 5 com módulos ESM | API, autenticação, regras de negócio e redirecionamentos. |
| Banco | PostgreSQL 18 | Persistência, restrições de unicidade e transações. |
| Persistência | Prisma ORM 7 e Prisma Migrate | Consultas tipadas, modelo de dados e migrations. |
| Driver PostgreSQL | `pg` e `@prisma/adapter-pg` | Conectar o Prisma ao banco. |
| Login Google | `google-auth-library` | Executar o fluxo Google OAuth 2.0 com OpenID Connect. |
| JWT da aplicação | `jsonwebtoken` e `@types/jsonwebtoken` como dependência de desenvolvimento | Assinar e verificar os tokens de sessão, com tipagem para TypeScript. |
| Cliente HTTP | Axios | Chamadas HTTP implementadas pelo frontend e pelo backend. |
| Validação | Zod | Validar entradas da API e configuração do ambiente. |
| Documentação da API | OpenAPI 3.1.0 e `swagger-ui-express` | Descrever e disponibilizar o contrato HTTP. |
| Testes de frontend | Jest e Testing Library | Testar componentes e interações. |
| Testes de backend | Jest e Supertest | Testar regras e endpoints HTTP. |
| Qualidade | ESLint, Prettier e `tsc` | Análise estática, formatação e verificação de tipos. |
| Desenvolvimento do backend | `tsx` | Executar TypeScript durante o desenvolvimento; compilar com `tsc` para execução normal. |
| Banco local | Docker Compose | Executar o PostgreSQL com volume persistente. |

Usar versões estáveis compatíveis com essas versões principais e registrar as versões exatas no lockfile de cada projeto na criação. Instalar e executar dependências a partir da pasta do projeto correspondente. As bibliotecas de autenticação serão executadas no backend, sem contratação de um serviço de autenticação. A aplicação será responsável pela implementação e manutenção de usuários e sessões.

### Responsabilidades e comunicação

- Apenas o Express acessará o banco e aplicará autenticação, autorização e regras de negócio. O Next.js ficará responsável pela interface.
- A API será REST, com JSON, sob `/api`; as rotas de autenticação ficarão sob `/api/auth`.
- O Next.js encaminhará `/api` ao Express e utilizará uma regra de fallback para encaminhar `/:code`, preservando as rotas da interface e os caminhos internos do framework. Os caminhos usados pela aplicação serão reservados.
- O frontend utilizará uma instância Axios com endereço base `/api`, timeout e tratamento de erros. As chamadas autenticadas utilizarão os cookies enviados pelo navegador.
- No backend, Axios será usado quando houver chamadas HTTP próprias para outros serviços. As chamadas internas da biblioteca Google manterão seu transporte oficial, sem reimplementar OAuth com Axios.
- Redirecionar um visitante não exigirá buscar o conteúdo da URL de destino. A resposta será um redirecionamento temporário `302` com `Cache-Control: no-store`.
- Códigos automáticos serão gerados com `node:crypto`, sem biblioteca adicional apenas para geração.

### Login Google

Usar o fluxo Authorization Code com OpenID Connect, processado no Express:

1. O navegador acessará `/api/auth/google`.
2. O backend iniciará o fluxo com `state`, `nonce` e PKCE, solicitando somente os escopos `openid`, `email` e `profile`.
3. O Google retornará para `/api/auth/google/callback`.
4. O backend conferirá os dados da tentativa, trocará o código pelos tokens e validará o ID token com `google-auth-library`, incluindo assinatura, emissor, audiência, expiração e correspondência do `nonce`.
5. A aplicação localizará ou criará o usuário pela identidade Google (`sub`), sem usar o e-mail como identificador dessa associação, e emitirá seu próprio JWT de sessão.

Os dados temporários do login serão mantidos no backend, com expiração, uso único e vínculo com o navegador que iniciou o fluxo. Não será solicitado acesso offline nem serão armazenados tokens Google para chamadas futuras. O ID token Google comprovará a identidade; o token de sessão será emitido pela própria aplicação.

Referência: [Google Auth Library para Node.js](https://docs.cloud.google.com/nodejs/docs/reference/google-auth-library/latest).

### Sessões JWT

- Usar `jsonwebtoken` para assinatura e verificação dos JWTs com algoritmo `HS256` e segredo aleatório de pelo menos 256 bits, mantido somente no backend.
- Emitir os tokens com `jwt.sign`, especificando `algorithm: 'HS256'` e `expiresIn: '8h'`.
- Verificar os tokens com `jwt.verify`, especificando `algorithms: ['HS256']`, emissor e audiência esperados, sem desabilitar a verificação de expiração. Não utilizar `jwt.decode` para autorizar acessos, pois decodificar não verifica a assinatura.
- O JWT conterá o identificador interno do usuário, o identificador da sessão, emissão, expiração, emissor e audiência. Nas rotas protegidas, validar assinatura, algoritmo permitido e os dados obrigatórios do token.
- Armazenar o JWT em cookie `HttpOnly`, `SameSite=Lax` e `Secure` em produção. Não armazenar tokens em `localStorage` nem transmiti-los em URLs.
- A sessão terá duração de 8 horas, sem refresh token nesta versão. Após a expiração, o usuário deverá entrar novamente pelo Google.
- Registrar cada sessão no PostgreSQL e verificar sua validade e a conta ativa em toda chamada autenticada. A validade do cookie e do registro de sessão deverá acompanhar a expiração do JWT.
- O logout revogará a sessão atual e removerá o cookie. Excluir a conta invalidará todas as sessões, inclusive tokens que ainda não tenham expirado.
- A verificação de assinatura do JWT não substituirá a consulta ao estado da sessão no banco, necessária para cumprir a invalidação imediata.

Referências: [padrão JWT](https://www.jwt.io/) e [biblioteca jsonwebtoken](https://github.com/auth0/node-jsonwebtoken).

### Persistência e proteção

- Manter os códigos reservados separados dos dados pessoais, para que a exclusão de uma conta preserve somente os códigos necessários para impedir reutilização, sem vínculo com o antigo proprietário.
- Garantir unicidade dos códigos com restrições no PostgreSQL; a consulta prévia de disponibilidade não será suficiente em operações concorrentes.
- Usar transações Prisma para troca de código e exclusão de conta, incluindo os vínculos Google, sessões e links. Em caso de falha, desfazer as alterações e não confirmar sucesso.
- Validar entradas com Zod e verificar proprietário e conta ativa no backend.
- Aplicar proteção contra CSRF nas operações autenticadas que alterem dados, cabeçalhos de segurança com Helmet e limites básicos de autenticação e criação de links com `express-rate-limit`.
- Não registrar cookies, JWTs, tokens Google, segredos ou URLs de destino completas nos logs.

### Documentação da API

- Manter o contrato em `backend/openapi.json`, usando OpenAPI 3.1.0, e disponibilizá-lo em `/api/openapi.json`.
- Servir Swagger UI em `/api/docs`, com `swagger-ui-express`. A documentação utilizará a mesma origem da aplicação no navegador.
- Documentar login, callback, consulta da sessão, logout, exclusão de conta, gerenciamento de links e redirecionamento público, incluindo entradas, respostas, erros, exemplos e requisitos de autenticação.
- Descrever a autenticação real por cookie. Para testar rotas protegidas no Swagger UI, o usuário fará login normalmente na aplicação; o navegador enviará o cookie, sem exigir copiar o JWT para um campo de autorização.
- Usar OpenAPI 3.1.0 como base de compatibilidade, sem depender dos recursos de OpenAPI 3.2 nesta versão.

Referência: [OpenAPI Specification e ferramentas Swagger](https://swagger.io/specification/).

### Estratégia de testes

- **Frontend:** Jest com `next/jest`, `jest-environment-jsdom`, React Testing Library, DOM Testing Library, `jest-dom` e `user-event`. Cobrir formulários, mensagens de erro, carregamento, confirmações, cancelamentos e sessão expirada; simular respostas Axios com mocks do Jest.
- **Backend:** Jest em ambiente Node, com execução ESM e TypeScript compilado antes dos testes; Supertest para endpoints e PostgreSQL separado para testes de integração, com as mesmas migrations do desenvolvimento.
- **Autenticação:** simular o Google nos testes automatizados e validar o login real manualmente. Cobrir criação e identificação recorrente da conta, identidade inválida, `state` ou `nonce` incorreto, JWT inválido ou expirado, algoritmo inesperado, emissor ou audiência incorretos, campos obrigatórios ausentes ou inválidos, sessão revogada e conta excluída.
- **Regras e persistência:** cobrir isolamento entre usuários, concorrência por códigos, preservação de códigos antigos, atualização de destino, desativação e exclusão transacional da conta, incluindo rollback em caso de falha.
- **Contrato HTTP:** verificar a disponibilidade da documentação e a correspondência entre os contratos documentados e as respostas testadas.
- **Limites:** Testing Library será usada na interface; Supertest atenderá ao backend. Server Components assíncronos e fluxos completos serão verificados manualmente nesta versão, devido à limitação atual do Jest para esses componentes. Não haverá testes E2E automatizados inicialmente.

### Ambiente local e itens adiados

- Executar Next.js na porta `3000`, Express na porta `3001` e PostgreSQL na porta `5432`.
- Rodar somente o PostgreSQL em Docker; frontend e backend serão executados diretamente na máquina.
- Manter `.env.example` por projeto, sem segredos, e arquivos de credenciais ignorados pelo Git. Cadastrar credenciais OAuth e callback específicos para o desenvolvimento local.
- O volume Docker preservará os dados locais, mas não substituirá um backup.
- Adiar hospedagem, backups de produção, Redis, filas, analytics, refresh tokens e testes E2E automatizados.
- Não adicionar ferramentas extras de monorepo, gerenciador de estado global ou bibliotecas de formulários e componentes nesta versão.
