CREATE TABLE `FREQUENTATORE` (
  `CF` varchar(255) PRIMARY KEY,
  `Nome` varchar(255),
  `Cognome` varchar(255),
  `DataNascita` date,
  `Email` varchar(255),
  `Telefono` varchar(255),
  `Indirizzo` varchar(255)
);

CREATE TABLE `CERTIFICATO_MEDICO` (
  `ID_Certificato` int PRIMARY KEY AUTO_INCREMENT,
  `DataRilascio` date,
  `DataScadenza` date,
  `TipoSport` varchar(255),
  `CF_Frequentatore` varchar(255)
);

CREATE TABLE `TIPO_ABBONAMENTO` (
  `ID_Tipo` int PRIMARY KEY AUTO_INCREMENT,
  `Nome` varchar(255),
  `Durata_Mesi` int,
  `Prezzo` decimal
);

CREATE TABLE `ABBONAMENTO` (
  `ID_Abbonamento` int PRIMARY KEY AUTO_INCREMENT,
  `DataInizio` date,
  `DataScadenza` date,
  `Stato` varchar(255),
  `CF_Frequentatore` varchar(255),
  `ID_Tipo` int
);

CREATE TABLE `EDIFICIO` (
  `ID_Edificio` char PRIMARY KEY,
  `Descrizione` varchar(255)
);

CREATE TABLE `SALA` (
  `ID_Sala` int PRIMARY KEY AUTO_INCREMENT,
  `Nome` varchar(255),
  `Capienza` int,
  `ID_Edificio` char
);

CREATE TABLE `ACCESSO` (
  `ID_Accesso` int PRIMARY KEY AUTO_INCREMENT,
  `DataOra` datetime,
  `Tipo` varchar(255),
  `CF_Frequentatore` varchar(255),
  `ID_Edificio` char
);

CREATE TABLE `ISTRUTTORE` (
  `ID_Istruttore` int PRIMARY KEY AUTO_INCREMENT,
  `Nome` varchar(255),
  `Cognome` varchar(255),
  `Specializzazione` varchar(255),
  `Email` varchar(255)
);

CREATE TABLE `CORSO` (
  `ID_Corso` int PRIMARY KEY AUTO_INCREMENT,
  `Nome` varchar(255),
  `Disciplina` varchar(255),
  `MaxPartecipanti` int
);

CREATE TABLE `LEZIONE` (
  `ID_Lezione` int PRIMARY KEY AUTO_INCREMENT,
  `DataOra` datetime,
  `Durata_Minuti` int,
  `ID_Corso` int,
  `ID_Sala` int,
  `ID_Istruttore` int
);

CREATE TABLE `PRENOTAZIONE` (
  `ID_Prenotazione` int PRIMARY KEY AUTO_INCREMENT,
  `DataPrenotazione` datetime,
  `Stato` varchar(255),
  `CF_Frequentatore` varchar(255),
  `ID_Lezione` int
);

ALTER TABLE `CERTIFICATO_MEDICO` ADD FOREIGN KEY (`CF_Frequentatore`) REFERENCES `FREQUENTATORE` (`CF`);

ALTER TABLE `ABBONAMENTO` ADD FOREIGN KEY (`CF_Frequentatore`) REFERENCES `FREQUENTATORE` (`CF`);

ALTER TABLE `ABBONAMENTO` ADD FOREIGN KEY (`ID_Tipo`) REFERENCES `TIPO_ABBONAMENTO` (`ID_Tipo`);

ALTER TABLE `SALA` ADD FOREIGN KEY (`ID_Edificio`) REFERENCES `EDIFICIO` (`ID_Edificio`);

ALTER TABLE `ACCESSO` ADD FOREIGN KEY (`CF_Frequentatore`) REFERENCES `FREQUENTATORE` (`CF`);

ALTER TABLE `ACCESSO` ADD FOREIGN KEY (`ID_Edificio`) REFERENCES `EDIFICIO` (`ID_Edificio`);

ALTER TABLE `LEZIONE` ADD FOREIGN KEY (`ID_Corso`) REFERENCES `CORSO` (`ID_Corso`);

ALTER TABLE `LEZIONE` ADD FOREIGN KEY (`ID_Sala`) REFERENCES `SALA` (`ID_Sala`);

ALTER TABLE `LEZIONE` ADD FOREIGN KEY (`ID_Istruttore`) REFERENCES `ISTRUTTORE` (`ID_Istruttore`);

ALTER TABLE `PRENOTAZIONE` ADD FOREIGN KEY (`CF_Frequentatore`) REFERENCES `FREQUENTATORE` (`CF`);

ALTER TABLE `PRENOTAZIONE` ADD FOREIGN KEY (`ID_Lezione`) REFERENCES `LEZIONE` (`ID_Lezione`);
