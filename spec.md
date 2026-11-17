# Especificação de negócio — Gerenciador de links

## Objetivo

Permitir criar e gerenciar links curtos cujo destino possa ser atualizado sem alterar o endereço já compartilhado.

A aplicação será voltada ao uso pessoal e de poucos usuários, com cadastro público e baixo volume inicial de acessos externos. As tecnologias serão definidas após a validação das regras de negócio.

## Conceitos

- **Proprietário:** usuário que criou o link e tem permissão para gerenciá-lo.
- **Visitante:** pessoa que acessa um endereço curto, sem precisar de conta.
- **Código:** parte que identifica o link no domínio, como `contato` em `https://dominio/contato`.
- **Destino:** URL para a qual o visitante será redirecionado.
- **Link ativo:** link que permite redirecionamento.
- **Link desativado:** link temporariamente indisponível, que pode ser reativado pelo proprietário.
- **Código reservado:** código indisponível para atribuição, por ser utilizado pela aplicação ou por já ter pertencido a um link.

Cada link terá seu próprio destino. Links que apontem para a mesma URL serão independentes; não haverá um cadastro de destino compartilhado entre eles.

## Regras de negócio

### Usuários e acesso

- Qualquer pessoa poderá criar uma conta.
- O gerenciamento de links exigirá autenticação.
- Cada usuário poderá criar links e listar, consultar, editar, desativar, reativar e excluir apenas seus próprios links.
- O redirecionamento será público e não exigirá autenticação.
- Conhecer o endereço curto não dará acesso ao gerenciamento nem aos dados privados do proprietário.

### Criação e identificação

- O usuário deverá informar uma URL de destino completa com protocolo `http://` ou `https://`.
- O usuário poderá escolher um código amigável ou solicitar um código gerado automaticamente.
- Códigos amigáveis usarão letras minúsculas, números e hífens. Letras maiúsculas informadas no cadastro ou na edição serão convertidas para minúsculas antes da verificação de disponibilidade.
- Cada código deverá ser único em todo o domínio da aplicação, independentemente do proprietário.
- Códigos atuais, anteriores e reservados ao funcionamento da aplicação não poderão ser atribuídos a outro link.
- Links diferentes poderão apontar para a mesma URL, inclusive quando pertencerem ao mesmo usuário.
- Novos links serão criados ativos.
- O painel exibirá o endereço curto, o destino, o estado e as datas de criação e última alteração de cada link.

### Edição de destino

- O proprietário poderá alterar o destino de links ativos ou desativados.
- Alterar apenas o destino preservará o código, o endereço curto e o estado do link.
- Alterar um link não modificará outros links, mesmo que apontem para a mesma URL.
- Após a confirmação de uma alteração, novos acessos deverão utilizar o destino atualizado, inclusive para visitantes que já acessaram o link anteriormente.
- Se o novo destino for inválido ou a alteração falhar, os dados anteriores serão preservados.

### Troca de código

- O proprietário poderá trocar o código de um link, escolhendo outro disponível ou solicitando geração automática.
- Antes da confirmação, o sistema avisará que o endereço anterior deixará de funcionar.
- Após a troca, apenas o novo endereço poderá redirecionar para o destino. O estado e o destino do link serão preservados.
- O código anterior ficará permanentemente reservado e não poderá ser reutilizado, inclusive pelo proprietário original.
- Se o novo código for inválido, estiver indisponível ou a alteração falhar, o código e os dados anteriores serão preservados.

### Desativação e reativação

- Desativar um link interromperá seu redirecionamento, preservando seus dados e sua presença no painel.
- O proprietário poderá reativar um link desativado, mantendo o mesmo endereço curto.
- A reativação utilizará o destino atualmente cadastrado, incluindo alterações feitas durante a desativação.
- A desativação deverá valer para novos acessos, inclusive de visitantes que já acessaram o link anteriormente.

### Exclusão

- A exclusão será definitiva e exigirá confirmação explícita do proprietário, com aviso de que o endereço deixará de funcionar.
- O link excluído deixará de aparecer no gerenciamento e não poderá ser restaurado pelo produto.
- Todos os códigos utilizados pelo link excluído continuarão permanentemente reservados.
- Após a confirmação da exclusão, novos acessos não deverão redirecionar, inclusive de visitantes que já acessaram o link anteriormente.

### Redirecionamento e validação do destino

- Um código atual de um link ativo redirecionará diretamente para o destino cadastrado.
- Códigos inexistentes, anteriores, desativados ou excluídos exibirão uma mensagem de indisponibilidade, sem divulgar dados do proprietário.
- A URL de destino será preservada, incluindo caminho, parâmetros e fragmento.
- Parâmetros acrescentados pelo visitante ao endereço curto não serão incorporados ao destino.
- Não serão aceitos destinos que sejam outros links curtos do próprio serviço, evitando cadeias e ciclos de redirecionamento internos.
- As mesmas regras de validação do destino serão aplicadas na criação e na edição.

## Cenários de aceitação

| Cenário | Resultado esperado |
| --- | --- |
| Criar um link com código automático | Receber um endereço curto único e ativo que redirecione para o destino informado. |
| Criar um link com código amigável disponível | Receber o endereço com o código escolhido, normalizado para minúsculas. |
| Escolher um código já usado por outro usuário | A operação ser recusada, sem alterar o link existente. |
| Escolher um código anterior, excluído ou reservado pela aplicação | A operação ser recusada, inclusive para o antigo proprietário. |
| Informar um destino inválido, um protocolo não permitido ou outro link curto do serviço | A criação ou edição ser recusada; na edição, os dados anteriores serem preservados. |
| Acessar o gerenciamento sem autenticação | O acesso ser negado. |
| Tentar consultar ou modificar um link de outro usuário | O acesso ser negado, sem expor seus dados privados ou modificar o link. |
| Criar dois links para a mesma URL e editar o destino de apenas um | Somente o link editado passar a apontar para o novo destino. |
| Alterar o destino de um link já compartilhado | O mesmo endereço curto levar ao novo destino, inclusive para quem já o acessou. |
| Trocar o código após confirmar o aviso | O novo endereço funcionar conforme o estado atual; o antigo exibir indisponibilidade e não poder ser reutilizado. |
| Tentar trocar para um código indisponível | O endereço, o estado e o destino anteriores permanecerem inalterados. |
| Desativar um link ativo | Novos acessos exibirem indisponibilidade e o link permanecer no painel. |
| Alterar o destino de um link desativado e reativá-lo | O endereço curto ser preservado e redirecionar para o destino atualizado. |
| Cancelar a confirmação de exclusão | O link permanecer no gerenciamento com seus dados e estado anteriores. |
| Confirmar a exclusão | O link sair do gerenciamento, deixar de redirecionar e seus códigos permanecerem reservados. |
| Acessar um código inexistente ou indisponível sem conta | Receber a mensagem de indisponibilidade, sem dados do proprietário. |
| Acessar um link com destino que contém caminho, parâmetros e fragmento | Ser redirecionado para o destino completo cadastrado. |
| Acrescentar parâmetros ao endereço curto | Ser redirecionado para o destino cadastrado, sem incorporar os parâmetros acrescentados. |

## Premissas e limites da primeira versão

- A aplicação utilizará um único domínio para os links curtos.
- O cadastro será público, mas cada usuário gerenciará apenas os próprios links.
- Códigos anteriores e excluídos nunca serão reutilizados, para evitar que endereços já distribuídos passem a apontar para links de outra pessoa.
- Não haverá analytics, expiração, senha por link, domínios por usuário ou compartilhamento de gerenciamento entre usuários nesta versão.
- A escolha de tecnologias, APIs, mecanismos de cache e infraestrutura ficará para a etapa técnica. O requisito de negócio é que redirecionamentos respeitem as alterações confirmadas.
- O cadastro público permite uso indevido do serviço; controles operacionais contra abuso deverão ser considerados na etapa de definição técnica.

## Evoluções futuras

### Analytics

Possibilidades fora do escopo inicial:

- Contagem de acessos por link.
- Estatísticas por período e horário.
- País, tipo de dispositivo, navegador e sistema operacional.
- Painel de estatísticas por link.

A inclusão de analytics exigirá definir o significado das métricas, os dados coletados, a retenção e as regras de privacidade. Contagem de acessos não deverá ser apresentada como contagem de visitantes únicos sem uma regra específica para essa distinção.
