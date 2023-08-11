--[[
	CensusPlusWotlk for World of Warcraft(tm).
	
	Copyright 2005 - 2012 Cooper Sellers and WarcraftRealms.com
	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		You should have received a copy of the GNU General Public License
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

-- WARNING: Phrase keys "CensusPlus_Found", "CensusPlus_FOUND" evaluate to the same lua identifier "CENSUSPLUS_FOUND". Only the value of "CensusPlus_FOUND" will be used. To fix this, rename one or more of the phrase keys.
-- translations provided by AxellSlade@CurseForge  marked reviewed by AxellSlade@CurseForge
if ( GetLocale() == "ptBR" ) then
	CENSUSPLUS_ACCOUNT_WIDE = "Ligado à conta"
	CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS = "Somente opções Ligado à Conta "
	CENSUSPLUS_AND = "e"
	CENSUSPLUS_AUTOCENSUSOFF = "Modo AutoCensus: DESLIGADO"
	CENSUSPLUS_AUTOCENSUSON = "Modo AutoCensus: LIGADO"
	CENSUSPLUS_AUTOCENSUSTEXT = "Inicia Census após atraso inicial"
	CENSUSPLUS_AUTOCENSUS_DELAYTIME = "Atraso em minutos"
	CENSUSPLUS_AUTOCLOSEWHO = "Fechar Quem Automaticamente"
	CENSUSPLUS_AUTOSTARTTEXT = "Auto iniciar no login quando temporizador menor que"
	CENSUSPLUS_BADLOCAL_1 = "Você parece ter uma versão do Censo dos EUA, mas sua localização está definida para francês, alemão, espanhol, italiano, coreano ou russo (foda-se Putin)."
	CENSUSPLUS_BADLOCAL_2 = "Por favor, não envie dados para WoWClassicPop.com até que isso seja resolvido."
	CENSUSPLUS_BADLOCAL_3 = "Se isso estiver incorreto, informe a Scarecr0w12 em wowclassicpop.com sobre sua situação para que eles possam fazer correções."
	CENSUSPLUS_BUTTON_CHARACTERS = "Mostrar personagens"
	CENSUSPLUS_BUTTON_OPTIONS = "Opções"
	CENSUSPLUS_CCO_OPTIONOVERRIDES = "Substituição de opção para esta personagem somente"
	CENSUSPLUS_CENSUSBUTTONANIMIOFF = "Animações BotãoCenso : DESLIGADO"
	CENSUSPLUS_CENSUSBUTTONANIMION = "Animações BotãoCenso : LIGADO"
	CENSUSPLUS_CENSUSBUTTONANIMITEXT = "Botão de animação Censo"
	CENSUSPLUS_CENSUSBUTTONSHOWNOFF = "Modo BotãoCenso : DESLIGADO"
	CENSUSPLUS_CENSUSBUTTONSHOWNON = "Modo BotãoCenso : LIGADO"
	CENSUSPLUS_CHARACTERS = "Personagens"
	CENSUSPLUS_CLASS = "Classes"
	CENSUSPLUS_CMDERR_WHO2 = "Comandos Who devem ser: who nome nível _ nenhum nome encontrado, nível é opcional"
	CENSUSPLUS_CMDERR_WHO2NUM = "Comandos Quem podem ser: who name _sem números no nome"
	CENSUSPLUS_CONSECUTIVE		= "Recenseamento Consecutivo: %d";
	CENSUSPLUS_CONSECUTIVE_0	= "Recenseamento Consecutivo: 0";
	CENSUSPLUS_FACTION = "Facção: %s"
	CENSUSPLUS_FACTIONUNKNOWN = "Facção: Desconhecida"
	CENSUSPLUS_FINISHED = "Terminou de juntar dados. Encontrado(s) %s novos personagens e visto(s) %s. Levou %s."
	CENSUSPLUS_FOUND = "encontrado"
	CENSUSPLUS_FOUND_CAP = "Encontrado"
	CENSUSPLUS_GETGUILD = "Clique Reino para dados da Guilda"
	CENSUSPLUS_HELP_0 = "seguintes comandos como mostrados abaixo"
	CENSUSPLUS_HELP_1 = "_ Alterna modo Verbose ligado/desligado"
	CENSUSPLUS_HELP_10 = "_ Atualiza dados Censo do jogador somente... Isto é feito automaticamente quando /CensusPlusWotlk take termina."
	CENSUSPLUS_HELP_11 = "_ Alterna modo furgivo desligado/ligado - desativa Verbose e todos as mensagens de bate-papo CensusPlusWotlk"
	CENSUSPLUS_HELP_2 = "_ Mostra a tela de Opções"
	CENSUSPLUS_HELP_3 = "_ Inicia uma imagem Censo"
	CENSUSPLUS_HELP_4 = "_ Pára uma imagem Censo"
	CENSUSPLUS_HELP_5 = "X _ Suprime a base de dados removendo personagens não vistos em X dias - padrão X = 30"
	CENSUSPLUS_HELP_6 = "X _ Suprime a base de dados removendo todos os personagens não vistos em X dias em ser servidores que não sejam aquele em que está atualmente. padrão X = 0"
	CENSUSPLUS_HELP_7 = "_ Mostrará informações que correspondem aos nomes."
	CENSUSPLUS_HELP_8 = "_ Listará personagens sem guilda daquele nível."
	CENSUSPLUS_HELP_9 = "_ Ajustará o tempo de autocenso (para X minutos)."
	CENSUSPLUS_ISINBG = "Você está atualmente em um Campo de Batalha portanto um Censo não pode ser feito"
	CENSUSPLUS_ISINPROGRESS = "Um CensoPlus está em progresso, tente novamente mais tarde"
	CENSUSPLUS_LANGUAGECHANGED = "Idioma do cliente alterada, Base de Dados limpa."
	CENSUSPLUS_LASTSEEN = "última atividade"
	CENSUSPLUS_LASTSEEN_COLON = "Última atividade:"
	CENSUSPLUS_LEVEL = "Níveis"
	CENSUSPLUS_LOCALE = "Idioma: %s"
	CENSUSPLUS_LOCALEUNKNOWN    = "Locale : Desconhecido";
	CENSUSPLUS_MAXXED = "MAXIMIZADO!"
	CENSUSPLUS_MSG1 = "Carregado - digite /censusplus ou /CensusPlusWotlk ou /census para comandos válidos"
	CENSUSPLUS_NOCENSUS = "Um Censo não está em progresso atualmente"
	CENSUSPLUS_NOTINFACTION = "Facção neutra - censo não permitido"
	CENSUSPLUS_NOW = "agora"
	CENSUSPLUS_OBSOLETEDATAFORMATTEXT = "Formato de Base de Dados antigo encontrado, Base de Dados limpa."
	CENSUSPLUS_OPTIONS_HEADER = "Opções CensusPlusWotlk"
	CENSUSPLUS_OPTIONS_OVERRIDE = "Anular"
	CENSUSPLUS_OR = "ou"
	CENSUSPLUS_PAUSE = "Pausar"
	CENSUSPLUS_PAUSECENSUS = "Pausar o censo atual"
	CENSUSPLUS_PLAYERS = "jogadores."
	CENSUSPLUS_PLAYFINISHSOUNDNUM = "número SomFinal"
	CENSUSPLUS_PLAYFINISHSOUNDOFF = "Modo TocarSomFinal: DESLIGADO"
	CENSUSPLUS_PLAYFINISHSOUNDON = "Modo TocarSomFinal: LIGADO"
	CENSUSPLUS_PROBLEMNAME = "Este nome é problemático =>"
	CENSUSPLUS_PROBLEMNAME_ACTION = ", nome pulado. Esta mensagem será mostrada somente uma vez."
	CENSUSPLUS_PROCESSING = "Processando %s personagens."
	CENSUSPLUS_PRUNE = "Suprimir"
	CENSUSPLUS_PRUNECENSUS = "Suprimir o banco de dados removendo personagens não vistos em 30 dias."
	CENSUSPLUS_PRUNEINFO = "Suprimidos %d personagens."
	CENSUSPLUS_PURGE = "Limpar"
	CENSUSPLUS_PURGEDALL = "Todos dados Census limpos"
	CENSUSPLUS_PURGEDATABASE = "Limpar o banco de dados de todos dados."
	CENSUSPLUS_PURGEMSG = "Banco de dados de personagens limpo."
	CENSUSPLUS_PURGE_LOCAL_CONFIRM = "Tem certeza que deseja LIMPAR sua base de dados local?"
	CENSUSPLUS_RACE = "Raças"
	CENSUSPLUS_REALM = "Reino"
	CENSUSPLUS_REALMNAME = "Reino: %s"
	CENSUSPLUS_REALMUNKNOWN = "Reino: Desconhecido"
	CENSUSPLUS_SCAN_PROGRESS = "Progresso da busca: %d consultas na fila - %s"
	CENSUSPLUS_SCAN_PROGRESS_0 = "Nenhum Busca em progresso"
	CENSUSPLUS_SENDING = "Enviando /who %s"
	CENSUSPLUS_STEALTHOFF = "Modo Furtivo : DESLIGADO"
	CENSUSPLUS_STEALTHON = "Modo Furtivo : LIGADO"
	CENSUSPLUS_STOP = "Parar"
	CENSUSPLUS_STOPCENSUS_TOOLTIP = "Parar o CensusPlusWotlk ativo atualmente"
	CENSUSPLUS_TAKE = "Tomar"
	CENSUSPLUS_TAKECENSUS = "Tomar um censo de jogadores\natualmente online neste servidor\ne nesta  facção"
	CENSUSPLUS_TAKINGONLINE = "Tomando censo de personagens online..."
	CENSUSPLUS_TEXT = "CensusPlusWotlk"
	CENSUSPLUS_TOOMANY = "AVISO: Muitos personagens correspondendo: %s"
	CENSUSPLUS_TOOSLOW = "Atualização muito lenta! Computador sobrecarregado? Problemas de conexão?"
	CENSUSPLUS_TOPGUILD = "Melhores Guildas por XP"
	CENSUSPLUS_TOTALCHAR = "Total de personagens: %d"
	CENSUSPLUS_TOTALCHAR_0 = "Total de personagens: 0"
	CENSUSPLUS_TRANSPARENCY = "Transparência de janela Census"
	CENSUSPLUS_UNGUILDED = "(Sem guilda)"
	CENSUSPLUS_UNKNOWNRACE = "Descoberta raça desconhecida ("
	CENSUSPLUS_UNKNOWNRACE_ACTION = "), por favor informe christophrus em WowClassicPop.com"
	CENSUSPLUS_UNPAUSE = "Continuar"
	CENSUSPLUS_UNPAUSECENSUS = "Continuar o censo atual"
	CENSUSPLUS_UPLOAD = "Certifique-se de enviar seus dados do CensusPlusClassic para WoWClassicPop.com!"
	CENSUSPLUS_USAGE = "Uso"
	CENSUSPLUS_USING_WHOLIB = "Usando WhoLib"
	CENSUSPLUS_VERBOSEOFF = "Modo Verbose: DESLIGADO"
	CENSUSPLUS_VERBOSEON = "Modo Verbose: LIGADO"
	CENSUSPLUS_VERBOSE_TOOLTIP = "Desmarque para parar o spam!"
	CENSUSPLUS_WAITING = "Esperando para enviar solicitação quem..."
	CENSUSPLUS_WAS = "era"
	CENSUSPLUS_WHOQUERY = "Consulta quem:"
	CENSUSPLUS_WRONGLOCAL_PURGE = "Idioma difere de definição anterior, limpando banco de dados."
	CENSUS_BUTTON_TOOLTIP = "Abrir CensusPlusWotlk"
	CENSUS_OPTIONS_AUTOCENSUS = "Auto-Census"
	CENSUS_OPTIONS_AUTOSTART = "Auto-Iniciar"
	CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP = "Transparência de fundo - dez passos"
	CENSUS_OPTIONS_BUTSHOW = "Mostrar botão Census"
	CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE = "Remover Anular"
	CENSUS_OPTIONS_LOG_BARS = "Níveis de Barras Logarítmicas"
	CENSUS_OPTIONS_LOG_BARSTEXT = "Habilita a ampliação logarítmica em barras de exibição"
	CENSUS_OPTIONS_SOUNDFILE = "Selecionar número de Arquivo de Som provido pelo usuário"
	CENSUS_OPTIONS_SOUNDFILETEXT = "Selecione arquivo de som .mp3 ou .OGG desejado"
	CENSUS_OPTIONS_SOUND_ON_COMPLETE = "Tocar som quando terminar"
	CENSUS_OPTIONS_SOUND_TOOLTIP = "Habilitar Som e depois selecionar Arquivo de Som"
	CENSUS_OPTIONS_STEALTH = "Furtivo"
	CENSUS_OPTIONS_STEALTH_TOOLTIP = "Modo Furtivo - sem mensagens de chat, desabilita Verbose"
	CENSUS_OPTIONS_TIMER_TOOLTIP = "Define o atraso em minutos a partir do último final do Censo."
	CENSUS_OPTIONS_VERBOSE = "Verboso"
	CENSUS_OPTIONS_VERBOSE_TOOLTIP = "Habilita texto verbose na janela de bate-papo, desabilita modo Furtivo"
end
