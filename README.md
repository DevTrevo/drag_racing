# drag_racing

# Corrida GTA V - Script de Corrida com Suporte Multiplayer

Este é um script para criar e gerenciar corridas em GTA V usando FiveM. Ele suporta múltiplos jogadores e salva os tempos de corrida no banco de dados.

## Funcionalidades

- Iniciar e parar corridas
- Contagem regressiva para o início da corrida
- Monitoramento de checkpoints
- Suporte para múltiplos jogadores
- Salvamento de tempos de corrida no banco de dados
- Reinício de corridas

## Requisitos

- **FiveM Server**: Para executar o script.
- **oxmysql**: Biblioteca para interação com o banco de dados.
- **Lua 5.4**: Interpretador Lua para executar os scripts.

## Instalação

1. **Clone o repositório**:
    ```bash
    git clone https://github.com/seu_usuario/seu_repositorio.git
    ```

2. **Navegue até o diretório do projeto**:
    ```bash
    cd seu_repositorio
    ```

3. **Configure o banco de dados**:
    - Certifique-se de que o `oxmysql` está instalado e configurado corretamente no seu servidor.
    - Crie a tabela `race_times` no seu banco de dados:
        ```sql
        CREATE TABLE race_times (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_id VARCHAR(255) NOT NULL,
            time INT NOT NULL
        );
        ```

4. **Edite as configurações do banco de dados** (se necessário) no arquivo `server.lua`.

5. **Inicie o servidor FiveM**:
    - Adicione o recurso no `server.cfg`:
        ```cfg
        ensure seu_repositorio
        ```

## Uso

### Comandos

- **Iniciar Corrida**: Dirija-se ao ponto de início da corrida e pressione a tecla configurada (E por padrão).
- **Reiniciar Corrida**: Após terminar a corrida, volte ao ponto de início e pressione a tecla configurada (E por padrão).
- **Parar Corrida**: Use o comando `/race stop` para parar a corrida manualmente.

### Eventos

- **race:start**: Inicia a corrida.
- **race:stop**: Para a corrida.
- **race:checkpoint**: Verifica os checkpoints.
- **race:finished**: Marca o final da corrida e salva o tempo no banco de dados.

## Contribuição

Se você quiser contribuir para o projeto, siga estes passos:

1. **Fork o repositório**.
2. **Crie uma nova branch**:
    ```bash
    git checkout -b minha_nova_funcionalidade
    ```
3. **Faça suas mudanças e commit**:
    ```bash
    git commit -m 'Adiciona nova funcionalidade'
    ```
4. **Push para a branch**:
    ```bash
    git push origin minha_nova_funcionalidade
    ```
5. **Abra um Pull Request**.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

Esse `README.md` cobre todas as partes essenciais do seu projeto, incluindo instalação, uso e contribuição. Se precisar de mais alguma coisa, estarei aqui para ajudar! 🚗💨
