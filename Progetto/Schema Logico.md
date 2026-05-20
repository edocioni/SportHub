FREQUENTATORE (<u>CF</u>, Nome, Cognome, DataNascita, Email, Telefono, Indirizzo)<br>
CERTIFICATO_MEDICO (<u>ID_Certificato</u>, DataRilascio, DataScadenza, TipoSport, CF*)<br>
TIPO_ABBONAMENTO (<u>ID_Tipo</u>, Nome, Durata_Mesi, Prezzo)<br>
ABBONAMENTO (<u>ID_Abbonamento</u>, DataInizio, DataScadenza, Stato, CF_Frequentatore, ID_Tipo*)<br>
EDIFICIO (<u>ID_Edificio</u>, Descrizione)<br>
ACCESSO (<u>ID_Accesso</u>, DataOra, Tipo, CF*, ID_Edificio*)<br>
SALA (<u>ID_Sala</u>, Nome, Capienza, ID_Edificio*)<br>
ISTRUTTORE (<u>ID_Istruttore</u>, Nome, Cognome, Specializzazione, Email)<br>
CORSO (<u>ID_Corso</u>, Nome, Disciplina, MaxPartecipanti)<br>
LEZIONE (<u>ID_Lezione</u>, DataOra, Durata_Minuti, ID_Corso*, ID_Sala*, ID_Istruttore*)<br>
PRENOTAZIONE (<u>ID_Prenotazione</u>, DataPrenotazione, Stato, CF*, ID_Lezione*)<br>