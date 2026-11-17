# Especificação do produto — Gerenciador de links

## Objetivo

Permitir criar e gerenciar links curtos cujo destino possa ser atualizado sem alterar o endereço já compartilhado.

A aplicação será voltada ao uso pessoal e de poucos usuários, com contas criadas pelo Google e baixo volume inicial de acessos externos. Criar e gerenciar links exigirá autenticação e conta ativa; apenas o redirecionamento será público. As tecnologias e decisões de implementação da primeira versão estão descritas em [tech-spec.md](tech-spec.md).

## Conceitos

- **Proprietário:** usuário que criou o link e tem permissão para gerenciá-lo.
- **Visitante:** pessoa que acessa um endereço curto, sem precisar de conta.
- **Conta ativa:** conta criada na aplicação pelo Google e habilitada para criar e gerenciar seus próprios links.
- **Código:** parte que identifica o link no domínio, como `contato` em `https://dominio/contato`.
- **Destino:** URL para a qual o visitante será redirecionado.
- **Link ativo:** link que permite redirecionamento.
- **Link desativado:** link temporariamente indisponível, que pode ser reativado pelo proprietário.
- **Código reservado:** código indisponível para atribuição, por ser utilizado pela aplicação ou por já ter pertencido a um link.

Cada link terá seu próprio destino. Links que apontem para a mesma URL serão independentes; não haverá um cadastro de destino compartilhado entre eles.

## Regras de negócio

### Usuários e acesso

- Qualquer pessoa poderá criar uma conta utilizando sua conta Google.
- O Google será a única forma de cadastro e acesso nesta versão; não haverá cadastro ou acesso por senha na aplicação.
- O primeiro acesso pelo Google criará uma conta ativa na aplicação, sem aprovação manual. Acessos posteriores com a mesma identidade Google utilizarão a mesma conta, sem duplicação.
- Criar e gerenciar links exigirá autenticação e conta ativa. Visitantes e contas sem estado ativo não poderão realizar essas operações.
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

### Exclusão de link

- A exclusão será definitiva e exigirá confirmação explícita do proprietário, com aviso de que o endereço deixará de funcionar.
- O link excluído deixará de aparecer no gerenciamento e não poderá ser restaurado pelo produto.
- Todos os códigos utilizados pelo link excluído continuarão permanentemente reservados.
- Após a confirmação da exclusão, novos acessos não deverão redirecionar, inclusive de visitantes que já acessaram o link anteriormente.

### Exclusão de conta

- O usuário autenticado poderá excluir apenas sua própria conta na aplicação, mediante confirmação explícita.
- Antes da confirmação, o sistema informará que a exclusão será definitiva, removerá todos os links da conta e interromperá os endereços já compartilhados.
- Cancelar a confirmação preservará a conta e todos os links, sem alterações.
- A exclusão removerá os dados da conta e de seus links, preservando apenas os códigos reservados necessários para impedir reutilização, sem vínculo com o antigo proprietário.
- Ao concluir a exclusão, todas as sessões da conta serão invalidadas. Não será mais possível gerenciar a conta excluída nem redirecionar pelos seus links, inclusive para visitantes que já os acessaram.
- A exclusão afetará somente a conta na aplicação; a conta Google não será excluída.
- Um novo cadastro com a mesma conta Google criará uma conta independente, sem recuperar links ou códigos anteriores.
- Se a exclusão falhar, o sistema informará que a operação não foi concluída e permitirá nova tentativa. Uma exclusão parcial não será apresentada como concluída.

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
| Acessar pela primeira vez com Google | Criar uma conta ativa na aplicação, sem aprovação manual. |
| Acessar novamente com a mesma identidade Google | Acessar a mesma conta, sem criar duplicatas. |
| Criar um link com código automático, autenticado e com conta ativa | Receber um endereço curto único e ativo que redirecione para o destino informado. |
| Criar um link com código amigável disponível, autenticado e com conta ativa | Receber o endereço com o código escolhido, normalizado para minúsculas. |
| Escolher um código já usado por outro usuário | A operação ser recusada, sem alterar o link existente. |
| Escolher um código anterior, excluído ou reservado pela aplicação | A operação ser recusada, inclusive para o antigo proprietário. |
| Informar um destino inválido, um protocolo não permitido ou outro link curto do serviço | A criação ou edição ser recusada; na edição, os dados anteriores serem preservados. |
| Tentar criar ou gerenciar links sem autenticação ou sem conta ativa | O acesso ser negado. |
| Acessar um link ativo sem conta ou autenticação | Ser redirecionado para o destino cadastrado. |
| Tentar consultar ou modificar um link de outro usuário | O acesso ser negado, sem expor seus dados privados ou modificar o link. |
| Criar dois links para a mesma URL e editar o destino de apenas um | Somente o link editado passar a apontar para o novo destino. |
| Alterar o destino de um link já compartilhado | O mesmo endereço curto levar ao novo destino, inclusive para quem já o acessou. |
| Trocar o código após confirmar o aviso | O novo endereço funcionar conforme o estado atual; o antigo exibir indisponibilidade e não poder ser reutilizado. |
| Tentar trocar para um código indisponível | O endereço, o estado e o destino anteriores permanecerem inalterados. |
| Desativar um link ativo | Novos acessos exibirem indisponibilidade e o link permanecer no painel. |
| Alterar o destino de um link desativado e reativá-lo | O endereço curto ser preservado e redirecionar para o destino atualizado. |
| Cancelar a confirmação de exclusão | O link permanecer no gerenciamento com seus dados e estado anteriores. |
| Confirmar a exclusão | O link sair do gerenciamento, deixar de redirecionar e seus códigos permanecerem reservados. |
| Cancelar a confirmação de exclusão da conta | A conta e todos os links permanecerem inalterados. |
| Confirmar a exclusão da própria conta | Os dados da conta e de seus links serem removidos, as sessões serem invalidadas e os endereços deixarem de redirecionar; apenas os códigos permanecerem reservados, sem vínculo com o antigo proprietário. |
| Tentar usar uma sessão da conta após a exclusão | O acesso ao gerenciamento ser negado. |
| Tentar excluir a conta ou os links de outro usuário | A operação ser negada, sem alterar os dados de terceiros. |
| Cadastrar-se novamente com a mesma conta Google após a exclusão | Criar uma conta independente, sem recuperar links ou códigos anteriores e sem afetar a conta Google. |
| Ocorrer uma falha na exclusão da conta | Informar que a exclusão não foi concluída e permitir nova tentativa, sem apresentar sucesso parcial como conclusão. |
| Acessar um código inexistente ou indisponível sem conta | Receber a mensagem de indisponibilidade, sem dados do proprietário. |
| Acessar um link com destino que contém caminho, parâmetros e fragmento | Ser redirecionado para o destino completo cadastrado. |
| Acrescentar parâmetros ao endereço curto | Ser redirecionado para o destino cadastrado, sem incorporar os parâmetros acrescentados. |

## Premissas e limites da primeira versão

- A aplicação utilizará um único domínio para os links curtos.
- O cadastro de contas será aberto a qualquer pessoa com conta Google. A criação e o gerenciamento de links exigirão autenticação e conta ativa, com acesso restrito aos próprios links.
- Não haverá aprovação manual de contas nem fluxos administrativos de suspensão nesta versão.
- Códigos liberados por troca de endereço, exclusão de link ou exclusão de conta permanecerão reservados permanentemente e não poderão ser atribuídos novamente, mesmo ao proprietário original. Isso evita que endereços já compartilhados passem a apontar para um novo link.
- Não haverá analytics, expiração de links, senha por link, domínios por usuário ou compartilhamento de gerenciamento entre usuários nesta versão.
- O ambiente inicial será local; hospedagem e backups de produção serão definidos posteriormente. Redirecionamentos deverão respeitar as alterações confirmadas, independentemente da infraestrutura.
- A abertura de contas pelo Google não elimina o risco de uso indevido do serviço; os controles básicos estão descritos em [tech-spec.md](tech-spec.md).

## Evoluções futuras

### Analytics

Possibilidades fora do escopo inicial:

- Contagem de acessos por link.
- Estatísticas por período e horário.
- País, tipo de dispositivo, navegador e sistema operacional.
- Painel de estatísticas por link.

A inclusão de analytics exigirá definir o significado das métricas, os dados coletados, a retenção e as regras de privacidade. Contagem de acessos não deverá ser apresentada como contagem de visitantes únicos sem uma regra específica para essa distinção.
