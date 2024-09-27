import PySimpleGUI as sg
import psycopg2

# inicialização Banco de Dados
conexaoBD = psycopg2.connect(host="localhost", database="bd_pi_g6", user="postgres", password="123456")

# carregar a imagem da logo
#logo = sg.Image(filename='logo1.png', size=(936, 111))

# função para inserir dados na tabela proposta e atualizar um 1o status_proposta (tipo_status = 'solicitada', dt_atualizacao = CURRENTE_TIMESTAMP, valor = 0)
def inserir_proposta(conexaoBD, id_tipo_projeto, id_cliente, area_projeto_m2, localizacao_uf, localizacao_cidade, endereco):
    cursor = conexaoBD.cursor()
    cursor.execute(
        """
        INSERT INTO proposta (id_tipo_projeto, id_cliente, area_projeto_m2, localizacao_uf, localizacao_cidade, endereco)
        VALUES (%s, %s, %s, %s, %s, %s)
        RETURNING id_proposta;
        """,
        (id_tipo_projeto, id_cliente, area_projeto_m2, localizacao_uf, localizacao_cidade, endereco)
    )
    id_proposta = cursor.fetchone()[0]
    cursor.execute(
        """
        INSERT INTO status_proposta (id_proposta, tipo_status, dt_atualizacao, valor)
        VALUES (%s, 'solicitada', CURRENT_TIMESTAMP, 0);
        """,
        (id_proposta,)
    )
    conexaoBD.commit()
    cursor.close()
    return id_proposta

# função para inserir dados na tabela status_proposta
def inserir_status_proposta(conexaoBD, id_proposta, tipo_status, valor):
    cursor = conexaoBD.cursor()
    cursor.execute(
        """
        INSERT INTO status_proposta (id_proposta, tipo_status, dt_atualizacao, valor)
        VALUES (%s, %s, CURRENT_TIMESTAMP, %s);
        """,
        (id_proposta, tipo_status, valor)
    )
    conexaoBD.commit()
    cursor.close()
    return True

# função para buscar propostas
def buscar_propostas(conexaoBD, id_proposta=None):
    cursor = conexaoBD.cursor()
    if id_proposta:
        query = """
        SELECT p.id_proposta, 
               tp.tipo_projeto,
               tp.setor,  
               p.area_projeto_m2, 
               p.localizacao_uf, 
               p.localizacao_cidade, 
               sp.tipo_status,
               TO_CHAR(sp.dt_atualizacao, 'DD/MM/YYYY') AS dt_atualizacao, 
               TO_CHAR(sp.valor, 'FM"R$ "9G999G999G999G999') AS valor_total_orcado
        FROM proposta p
        JOIN tipo_projeto tp ON tp.id_tipo_projeto = p.id_tipo_projeto
        JOIN status_proposta sp ON p.id_proposta = sp.id_proposta
        WHERE p.id_proposta = %s;
        """
        cursor.execute(query, (id_proposta,))
    else:
        query = """
        SELECT p.id_proposta, 
               tp.tipo_projeto,
               tp.setor, 
               p.area_projeto_m2, 
               p.localizacao_uf, 
               p.localizacao_cidade, 
               sp.tipo_status,
               TO_CHAR(sp.dt_atualizacao, 'DD/MM/YYYY') AS dt_atualizacao, 
               TO_CHAR(sp.valor, 'FM"R$ "9G999G999G999G999') AS valor_total_orcado
        FROM proposta p
        JOIN tipo_projeto tp ON tp.id_tipo_projeto = p.id_tipo_projeto
        JOIN status_proposta sp ON p.id_proposta = sp.id_proposta;
        """
        cursor.execute(query)
    resultados = cursor.fetchall()
    cursor.close()
    return resultados

# lista de tipos de status
tipos_status = [ 
    'em desenvolvimento',
    'enviada',
    'em analise',
    'aprovada',
    'cancelada',
    'interrompida'
]

# lista de tipos de projetos
tipos_projeto = [
    'PPP - RESIDENCIAL',
    'PPP - COMERCIAL',
    'PPP - REAL STATE',
    'PPP - INDUSTRIA',
    'PPP - TRANSPORTE',
    'PPP - AEROPORTO',
    'PPP - INSTITUCIONAL',
    'PUBLICO - RESIDENCIAL',
    'PUBLICO - COMERCIAL',
    'PUBLICO - REAL STATE',
    'PUBLICO - INDUSTRIA',
    'PUBLICO - TRANSPORTE',
    'PUBLICO - AEROPORTO',
    'PUBLICO - INSTITUCIONAL',
    'PRIVADO - RESIDENCIAL',
    'PRIVADO - COMERCIAL',
    'PRIVADO - REAL STATE',
    'PRIVADO - INDUSTRIA',
    'PRIVADO - TRANSPORTE',
    'PRIVADO - AEROPORTO',
    'PRIVADO - INSTITUCIONAL'
]

# lista de clientes
tipos_clientes = [
    'Aeroforte Construções', 
    'Instituto Urbano', 
    'Construtora Horizonte Azul', 
    'Aeroconstruir', 
    'Institucionalis', 
    'Aeroportos do Brasil', 
    'Construtora Nacional', 
    'Instituto do Progresso',
    'Construções Céu Aberto',
    'Aeroportuária Brasileira'
]

# interface gráfica
layout = [
    #[sg.Column([[logo]], justification='center', pad=(0, 0))],  
    [sg.Text("Proposta", background_color='white', text_color='#004d80', font=('Helvetica', 12, 'bold'))],
    [sg.Text("Tipo Projeto", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.Combo(tipos_projeto, key='tipo_projeto', size=(115, 1))],
    [sg.Text("Cliente", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.Combo(tipos_clientes, key='id_cliente', size=(120, 1))],
    [sg.Text("Área Projeto m²", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='area_projeto_m2', size=(113, 1))],
    [sg.Text("Localização UF", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='localizacao_uf', size=(113, 1))],
    [sg.Text("Localização Cidade", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='localizacao_cidade', size=(109, 1))],
    [sg.Text("Endereço", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='endereco', size=(120, 1))],
    [sg.Button("Inserir dados proposta SOLICITADA", font=('Helvetica', 12, 'bold'), button_color=('white', '#004d80'), size=(92, 1))],
    [sg.Text("Status Proposta", background_color='white', text_color='#004d80', font=('Helvetica', 12, 'bold'))],
    [sg.Text("ID Proposta", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='status_id_proposta', size=(118, 1))],
    [sg.Text("Tipo Status", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.Combo(tipos_status, key='tipo_status', size=(117, 1))],
    [sg.Text("Valor", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='valor', size=(125, 1))],
    [sg.Button("Atualizar status proposta", font=('Helvetica', 12, 'bold'), button_color=('white', '#004d80'), size=(92, 1))],
    [sg.Text("Buscar Propostas", background_color='white', text_color='#004d80', font=('Helvetica', 12, 'bold'))],
    [sg.Text("ID Proposta", background_color='white', text_color='#004d80', font=('Helvetica', 12)), sg.InputText(key='id_proposta', size=(118, 1))],
    [sg.Button("Buscar proposta", font=('Helvetica', 12, 'bold'), button_color=('white', '#004d80'), size=(92, 1))],
    [sg.Table(
        values=[],
        headings=[
            "ID",
            "Tipo Projeto",
            "Setor",
            "Área m²",
            "UF",
            "Cidade",
            "Status",
            "Dt Status",
            "Valor Total"
        ],
        col_widths=[5, 15, 10, 10, 5, 15, 15, 10, 17],  
        key='tabela_resultados',
        auto_size_columns=False,
        display_row_numbers=False,
        justification='center',
        num_rows=10
    )]
]

window = sg.Window('Gestão de Propostas e Status de Proposta', layout, background_color='white')

while True:
    event, values = window.read()
    if event == sg.WIN_CLOSED:
        break

    if event == "Inserir dados proposta SOLICITADA":
        tipo_projeto_str = values['tipo_projeto']
        id_tipo_projeto = tipos_projeto.index(tipo_projeto_str) + 1
        tipo_cliente_str = values['id_cliente']
        id_tipo_cliente = tipos_clientes.index(tipo_cliente_str) + 1
        area_projeto_m2 = values['area_projeto_m2']
        localizacao_uf = values['localizacao_uf']
        localizacao_cidade = values['localizacao_cidade']
        endereco = values['endereco']

        id_proposta = inserir_proposta(conexaoBD, id_tipo_projeto, id_tipo_cliente, area_projeto_m2, localizacao_uf, localizacao_cidade, endereco)
        sg.popup(f"Proposta inserida com sucesso! ID Proposta: {id_proposta}")

    if event == "Atualizar status proposta":
        id_proposta = values['status_id_proposta']
        tipo_status = values['tipo_status']
        valor = values['valor']

        inserir_status_proposta(conexaoBD, id_proposta, tipo_status, valor)
        sg.popup("Status da proposta inserido com sucesso!")
    
    if event == "Buscar proposta":
        id_proposta = values['id_proposta']
        resultados = buscar_propostas(conexaoBD, id_proposta)
        window['tabela_resultados'].update(values=resultados)

# fechar a conexão e a janela
conexaoBD.close()
window.close()
