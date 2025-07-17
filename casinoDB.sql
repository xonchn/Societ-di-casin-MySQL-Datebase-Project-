######################### Creazione basi di dati #########################
DROP DATABASE IF EXISTS CasinoDB;
CREATE DATABASE CasinoDB;
USE CasinoDB;
########################## Creazione tabelle #############################
DROP TABLE IF EXISTS Giocatore;
CREATE TABLE IF NOT EXISTS Giocatore (
	Passaporto VARCHAR(15)  PRIMARY KEY,
    DataDiNascita DATE,
    Nome VARCHAR(50) ,
    Cognome VARCHAR(50),
    Nazionalita CHAR(3),
    NumeroDiTelefono VARCHAR(255)
)ENGINE = INNODB;

DROP TABLE IF EXISTS Casino;
CREATE TABLE IF NOT EXISTS Casino (
	Licenza CHAR(6) PRIMARY KEY,
    Nome VARCHAR(255),
    CodicePaese CHAR(3) NOT NULL,
    NumeroDiTelefono VARCHAR(255),
    Citta VARCHAR(15),
    CAP VARCHAR(8),
    Via VARCHAR(70)
)ENGINE = INNODB;

DROP TABLE IF EXISTS Registrazione;
CREATE TABLE IF NOT EXISTS Registrazione (
	RegistrazioneID INT PRIMARY KEY,
    DataRegistrazione DATE,
    Casino CHAR(6),
    Giocatore VARCHAR(15),
	FOREIGN KEY (Casino)
		REFERENCES Casino (Licenza)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	FOREIGN KEY (Giocatore)
		REFERENCES Giocatore (Passaporto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE = INNODB;

DROP TABLE IF EXISTS Dipendente;
CREATE TABLE IF NOT EXISTS Dipendente (
	Passaporto VARCHAR(15)  PRIMARY KEY,
    Cognome VARCHAR(50),
    Nome VARCHAR(50),
    NumeroDiTelefono VARCHAR(15),
    Nazionalita CHAR(3),
    DataNascita DATE,
    Posizione ENUM('Manager', 'Croupier', 'Receptionist', 'Security', 'Cleaner'),
    Casino CHAR(6),
    DataDiAssunzione DATE,
    FOREIGN KEY (Casino)
		REFERENCES Casino (Licenza)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE = INNODB;

DROP TABLE IF EXISTS Sala;
CREATE TABLE IF NOT EXISTS Sala (
    SalaID INT,
    Casino CHAR(6) NOT NULL,
    Superficie DECIMAL(10, 2) NOT NULL,
    Stato ENUM('Libera', 'Occupata') NOT NULL,
    PRIMARY KEY (SalaID, Casino),
    FOREIGN KEY (Casino)
        REFERENCES Casino(Licenza)
        ON DELETE CASCADE
) ENGINE=INNODB;

DROP TABLE IF EXISTS Tavolo;
CREATE TABLE IF NOT EXISTS Tavolo(
	TavoloID INT ,
    TipoGioco VARCHAR(20),
    PuntataMinima INT,
    MaxDiGiocatori INT CHECK (MaxDiGiocatori > 0 AND MaxDiGiocatori <= 10),
    SalaID INT,
    Casino CHAR(6),
    PRIMARY KEY (TavoloID,SalaID, Casino),
     FOREIGN KEY (SalaID, Casino)
        REFERENCES Sala(SalaID, Casino)
        ON DELETE CASCADE,
	Responsabile VARCHAR(15) NULL,
    FOREIGN KEY(Responsabile)
		REFERENCES Dipendente(passaporto)
)ENGINE = INNODB;

DROP TABLE IF EXISTS Torneo;
CREATE TABLE IF NOT EXISTS Torneo (
    Nome VARCHAR(100) PRIMARY KEY,
    TipoDiGioco VARCHAR(255),
    Capacita INT,
    MontePremi DECIMAL(10, 2) CHECK (MontePremi >= 0),
    Descrizione TEXT
)ENGINE = INNODB;

DROP TABLE IF EXISTS EdizioneTorneo;
CREATE TABLE IF NOT EXISTS EdizioneTorneo (
    NomeTorneo VARCHAR(100),
    DataInizio DATETIME,
    Vincitore CHAR(16) NULL,
    NumeroPartecipanti INT,
    PRIMARY KEY (NomeTorneo, DataInizio),
    FOREIGN KEY (Vincitore) REFERENCES Giocatore(Passaporto),
    SalaID INT,
    Casino CHAR(6),
    TassaIscrizione DECIMAL(9,2),
    FOREIGN KEY (SalaID, Casino) REFERENCES Sala(SalaID, Casino) ON DELETE CASCADE,
    FOREIGN KEY (NomeTorneo) REFERENCES Torneo(Nome) ON DELETE CASCADE,
    StatoTorneo ENUM('Pianificato', 'InCorso', 'Completato') DEFAULT 'Pianificato',
    Organizzatore VARCHAR(15) NOT NULL, 
    FOREIGN KEY (Organizzatore) REFERENCES Dipendente(Passaporto)
)ENGINE = INNODB;

DROP TABLE IF EXISTS ImpiegoPassato;
CREATE TABLE IF NOT EXISTS ImpiegoPassato (
    Passaporto VARCHAR(15),
    Cognome VARCHAR(50),
    Nome VARCHAR(50),
    NumeroDiTelefono VARCHAR(15),
    DataDiAssunzione DATE,
    DataDiCessazione DATE,
    Casino CHAR(6),
    Posizione ENUM('Manager', 'Croupier', 'Receptionist', 'Security', 'Cleaner'),
    FOREIGN KEY (Casino) REFERENCES Casino (Licenza)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE = INNODB;
DROP TABLE IF EXISTS Iscrizione;
CREATE TABLE IF NOT EXISTS Iscrizione (
    IscrizioneID INT AUTO_INCREMENT PRIMARY KEY,
    GiocatoreID VARCHAR(15),
    NomeTorneo VARCHAR(100),
    DataInizio DATETIME,
    DataIscrizione DATETIME,
    Sconto DECIMAL(9,2) DEFAULT 0.00,
    StatoIscrizione ENUM('Attiva', 'Annullata', 'Completata') DEFAULT 'Attiva',
    FOREIGN KEY (GiocatoreID) 
		REFERENCES Giocatore(Passaporto),
	FOREIGN KEY (NomeTorneo, DataInizio)
		REFERENCES EdizioneTorneo(NomeTorneo, DataInizio)
)ENGINE = INNODB;

DROP TABLE IF EXISTS Pagamento;
CREATE TABLE IF NOT EXISTS Pagamento(
    GiocatoreID VARCHAR(15),
    IscrizioneID INT,
    PRIMARY KEY(GiocatoreID, IscrizioneID),
    FOREIGN KEY(GiocatoreID) 
		REFERENCES Iscrizione(GiocatoreID),
    FOREIGN KEY(IscrizioneID) 
		REFERENCES Iscrizione(IscrizioneID),
    DataPagamento DATETIME,
    ImportoPagato DECIMAL(9,2) CHECK (ImportoPagato >= 0),
	StatoPagamento ENUM('Completato', 'Fallito', 'InAttesa') DEFAULT 'InAttesa'
)ENGINE = INNODB;

DROP TABLE IF EXISTS Fattura;
CREATE TABLE IF NOT EXISTS Fattura(
    TransazioneID INT AUTO_INCREMENT PRIMARY KEY,
    IscrizioneID INT,
    DataFattura DATETIME,
    MetodoPagamento VARCHAR(100),
    FOREIGN KEY(IscrizioneID) REFERENCES Iscrizione(IscrizioneID)
)ENGINE = INNODB;
######################### Popolamento tabelle ############################
INSERT INTO Casino (Licenza, Nome, CodicePaese, NumeroDiTelefono, Citta, CAP, Via) VALUES
('MCO001', 'Casino de Monte-Carlo', 'MCO', '+377 98 06 21 21', 'Monte Carlo', '98000', 'Place du Casino, Monte Carlo, Monaco'),
('DEU001', 'Casino Baden-Baden', 'DEU', '+49 7221 30240', 'Baden-Baden', '76530', 'Kaiserallee 1, 76530 Baden-Baden, Germany'),
('ITA001', 'Casinò di Venezia - Ca Vendramin Calergi', 'ITA', '+39 041 529 7111', 'Venice', '30121', 'Cannaregio, 2040, 30121 Venice, Italy'),
('PRT001', 'Casino Estoril', 'PRT', '+351 21 466 7700', 'Estoril', '2765-190', 'Av. Dr. Stanley Ho, 2765-190 Estoril, Portugal'),
('FRA001', 'Casino Barrière Deauville', 'FRA', '+33 2 31 98 66 00', 'Deauville', '14800', '2 Rue Edmond Blanc, 14800 Deauville, France'),
('PRT002', 'Casino Lisboa', 'PRT', '+351 218 929 000', 'Lisbon', '1990-204', 'Alameda dos Oceanos');

LOAD DATA LOCAL INFILE 'PopolamentoGiocatore.txt' INTO TABLE Giocatore 
FIELDS TERMINATED BY ", "
LINES TERMINATED BY "\r\n"
IGNORE 2 ROWS;

INSERT INTO Registrazione (RegistrazioneID, DataRegistrazione, Casino, Giocatore) VALUES
(1, '2024-10-26', 'MCO001', 'P23511615'),
(2, '2023-04-24', 'ITA001', 'P74539281'),
(3, '2024-08-06', 'DEU001', 'P92832764'),
(4, '2022-10-27', 'FRA001', 'P92832764'),
(5, '2023-04-07', 'PRT001', 'P92832764'),
(6, '2024-01-15', 'ITA001', 'P10122691'),
(7, '2023-11-20', 'DEU001', 'P30642819'),
(8, '2023-07-08', 'FRA001', 'P10122691'),
(9, '2023-03-13', 'MCO001', 'CI69653287'),
(10, '2022-09-10', 'PRT002', 'CI69653287'),
(11, '2023-05-20', 'PRT002', 'P51826473'),
(12, '2024-03-17', 'MCO001', 'P48963834'),
(13, '2024-04-22', 'PRT001', 'P18736954'),
(14, '2023-02-11', 'DEU001', 'P46283109');

LOAD DATA LOCAL INFILE 'PopolamentDipendente.txt' INTO TABLE Dipendente 
FIELDS TERMINATED BY ", "
LINES TERMINATED BY "\r\n"
IGNORE 2 ROWS;

INSERT INTO Sala (SalaID, Casino, Superficie, Stato)
VALUES
(001, 'DEU001', 100.50, 'Libera'),
(002, 'DEU001', 150.75, 'Libera'),
(003, 'DEU001', 200.00, 'Libera'),
(001, 'FRA001', 120.30, 'Libera'),
(002, 'FRA001', 130.40, 'Libera'),
(003, 'FRA001', 140.50, 'Libera'),
(001, 'ITA001', 110.25, 'Libera'),
(002, 'ITA001', 210.55, 'Libera'),
(003, 'ITA001', 310.80, 'Libera'),
(001, 'MCO001', 90.00, 'Libera'),
(002, 'MCO001', 150.45, 'Occupata'),
(003, 'MCO001', 230.65, 'Libera'),
(001, 'PRT001', 80.50, 'Libera'),
(002, 'PRT001', 180.75, 'Libera'),
(003, 'PRT001', 280.00, 'Libera'),
(001, 'PRT002', 120.00, 'Libera'),
(002, 'PRT002', 220.50, 'Libera'),
(003, 'PRT002', 320.75, 'Libera');

INSERT INTO Tavolo (TavoloID, TipoGioco, PuntataMinima, MaxDiGiocatori, SalaID, Casino, Responsabile)
VALUES
(001, 'Roulette', 10, 5, 001, 'DEU001',NULL),
(002, 'Blackjack', 20, 6, 001,'DEU001', 'PDEU1003'),
(003, 'Poker', 50, 8, 001, 'DEU001',NULL),
(001, 'Roulette', 10, 5, 002,'DEU001', 'PDEU1002'),
(002, 'Blackjack', 25, 6, 002, 'DEU001',NULL),
(001, 'Poker', 50, 8, 003,'DEU001', NULL),
(002, 'Roulette', 15, 5, 003,'DEU001', NULL),
(003, 'Baccarat', 100, 4, 003,'DEU001', NULL),
(001, 'Blackjack', 20, 6, 001, 'FRA001',NULL),
(002, 'Roulette', 10, 5, 001, 'FRA001',NULL),
(001, 'Poker', 50, 8, 002, 'FRA001',NULL),
(002, 'Baccarat', 100, 4, 002,'FRA001', NULL),
(001, 'Roulette', 15, 5, 003, 'FRA001',NULL),
(002, 'Blackjack', 25, 6, 003,'FRA001', NULL),
(001, 'Roulette', 20, 5, 001,'ITA001' ,NULL),
(002, 'Poker', 100, 8, 001,'ITA001', NULL),
(001, 'Blackjack', 30, 6, 002, 'ITA001',NULL),
(002, 'Baccarat', 50, 4, 002, 'ITA001',NULL),
(003,'Roulette', 10, 5, 002,'ITA001', NULL),
(001, 'Poker', 75, 8, 003, 'ITA001',NULL),
(002, 'Roulette', 25, 5, 003,'ITA001', NULL),
(001, 'Blackjack', 15, 6, 001, 'MCO001',NULL),
(002, 'Roulette', 20, 5, 001,'MCO001', NULL),
(001, 'Poker', 75, 8, 002, 'MCO001',NULL),
(002, 'Roulette', 30, 5, 002, 'MCO001',NULL),
(001, 'Baccarat', 100, 4, 003, 'MCO001',NULL),
(002, 'Roulette', 10, 5, 003, 'MCO001',NULL),
(001, 'Roulette', 10, 5, 001, 'PRT001',NULL),
(002, 'Poker', 50, 8, 001, 'PRT001',NULL),
(001, 'Blackjack', 25, 6, 002, 'PRT001',NULL),
(002, 'Baccarat', 75, 4, 002, 'PRT001',NULL),
(001, 'Roulette', 15, 5, 003, 'PRT001',NULL),
(002, 'Poker', 100, 8, 003, 'PRT001',NULL),
(001, 'Roulette', 20, 5, 001,'PRT002', NULL),
(002, 'Poker', 50, 8, 001, 'PRT002',NULL),
(001, 'Blackjack', 30, 6, 002,'PRT002', NULL),
(002, 'Roulette', 10, 5, 002,'PRT002', NULL),
(001, 'Baccarat', 75, 4, 003, 'PRT002',NULL),
(002, 'Roulette', 25, 5, 003, 'PRT002',NULL);

INSERT INTO Torneo (Nome, TipoDiGioco, Capacita, MontePremi, Descrizione)
VALUES
('Grand Poker Championship', 'Poker', 100, 50000.00, 'A prestigious poker tournament attracting the best players worldwide.'),
('Roulette Masters', 'Roulette', 50, 20000.00, 'An exciting roulette tournament with high stakes and elite competitors.'),
('Blackjack Battle Royale', 'Blackjack', 75, 30000.00, 'A competitive blackjack event where skill meets strategy.'),
('Baccarat Elite Challenge', 'Baccarat', 30, 10000.00, 'An exclusive baccarat tournament for top-tier players.'),
('Casino Open Championship', 'Multiple Games', 200, 100000.00, 'A multi-game event featuring poker, roulette, blackjack, and baccarat.'),
('Weekend Roulette Frenzy', 'Roulette', 20, 5000.00, 'A fast-paced weekend roulette event with great rewards for the winners.');

INSERT INTO EdizioneTorneo (NomeTorneo, DataInizio, Vincitore, NumeroPartecipanti, SalaID, Casino, StatoTorneo,TassaIscrizione, Organizzatore)
VALUES
('Grand Poker Championship', '2024-05-15 14:00:00', 'P92832764', 4, 002,'DEU001', 'Completato',100.00, 'PDEU1001'),
('Blackjack Battle Royale', '2024-06-20 16:00:00', 'P92832764', 2, 002,'FRA001', 'Completato', 150.00, 'PFRA1001'),
('Roulette Masters', '2024-07-10 18:00:00', 'CI69653287', 1, 002, 'ITA001','Completato', 120.00, 'PITA1001'),
('Baccarat Elite Challenge', '2025-01-06 12:00:00', NULL, 2, 002,'MCO001' ,'InCorso', 200.00, 'PDEU1001'),
('Casino Open Championship', '2025-02-15 10:00:00', NULL, 0, 002, 'PRT001','Pianificato', 180.00, 'PITA1001'),
('Weekend Roulette Frenzy', '2025-03-20 14:30:00', NULL, 0, 002, 'PRT002','Pianificato', 220.00, 'PITA1001');

INSERT INTO Iscrizione (IscrizioneID, GiocatoreID, NomeTorneo, DataInizio, DataIscrizione, Sconto,StatoIscrizione)
VALUES
(1, 'P92832764', 'Grand Poker Championship', '2024-05-15 14:00:00', '2024-04-27 10:00:00',  10.00 , 'Completata'),
(2, 'P46283109', 'Grand Poker Championship', '2024-05-15 14:00:00', '2025-05-01 11:00:00',  0.00,'Completata'),
(3, 'P92832764', 'Roulette Masters', '2024-07-10 18:00:00', '2024-05-20 15:00:00', 15.00, 'Completata'),
(4, 'P10122691', 'Grand Poker Championship', '2024-05-15 14:00:00', '2024-05-15 09:00:00',  0.00, 'Completata'),
(5, 'P23511615', 'Grand Poker Championship', '2024-05-15 14:00:00', '2024-05-23 14:30:00', 5.00,  'Annullata'),
(6, 'P10122691', 'Roulette Masters', '2024-07-10 18:00:00', '2024-06-23 13:00:00',  0.00, 'Completata'),
(7, 'CI69653287', 'Blackjack Battle Royale', '2024-06-20 16:00:00', '2024-01-01 10:30:00', 20.00, 'Completata'),
(8, 'P48963834', 'Baccarat Elite Challenge', '2025-01-06 12:00:00', '2025-01-02 11:45:00',  0.00, 'Completata'),
(9, 'P92832764', 'Baccarat Elite Challenge', '2025-01-06 12:00:00', '2025-01-04 12:00:00', 10.00, 'Attiva');

INSERT INTO Pagamento (GiocatoreID, IscrizioneID, DataPagamento, ImportoPagato, StatoPagamento)
VALUES
('P92832764', 1, '2024-04-28 10:00:00', 90.00, 'Completato'),
('P46283109', 2, '2024-05-02 11:00:00', 100.00, 'Completato'),
('P92832764', 3, '2024-05-21 15:00:00', 135.00, 'Completato'),
('P10122691', 4, '2024-05-16 16:00:00', 100.00, 'Completato'),
('CI69653287', 7, '2024-06-20 16:00:00', 200.00, 'Completato'),
('P48963834', 8, '2025-01-05 11:45:00', 200.00, 'Completato'),
('P92832764', 9, '2025-01-08 12:30:00', 180.00, 'InAttesa');

INSERT INTO Fattura (IDtransazione, IscrizioneID, DataFattura, MetodoPagamento)
VALUES
(1, 1, '2024-04-28 10:15:00', 'Cash'),
(2, 2, '2024-05-02 11:15:00', 'Credit Card'),
(3, 3, '2024-05-21 15:30:00', 'Paypal'),
(4, 4, '2024-05-16 16:30:00', 'Wire Transfer'),
(5, 7, '2024-06-20 16:15:00', 'Credit Card'),
(6, 8, '2025-01-05 12:00:00', 'Cash'),
(7, 9, '2025-01-09 13:00:00', 'Paypal');

INSERT INTO ImpiegoPassato (Passaporto, Cognome, Nome, NumeroDiTelefono, DataDiAssunzione, DataDiCessazione, Casino,Posizione)
VALUES
('PDEU2001', 'Schneider', 'Michael', '491987654321', '2010-03-15', '2015-07-20', 'DEU001','Manager'),
('PFRA3001', 'Dubois', 'Sophie', '331765432189', '2012-01-10', '2019-11-30', 'FRA001','Croupier'),
('PITA4002', 'Bianchi', 'Marco', '390765432112', '2014-06-05', '2020-03-15', 'ITA001', 'Receptionist'),
('PMCO5003', 'Lemoine', 'Pauline', '377876543210', '2016-09-01', '2023-06-20', 'MCO001','Security'),
('PPRT6004', 'Martins', 'Joana', '351987123654', '2018-02-12', '2024-01-01', 'PRT002','Cleaner');

############################## Procedure #################################
DROP PROCEDURE IF EXISTS AnnullaIscrizione;

DELIMITER $$

CREATE PROCEDURE AnnullaIscrizione (IN inputIscrizioneID INT)
BEGIN      
    DELETE FROM Fattura
    WHERE IscrizioneID = inputIscrizioneID;

    DELETE FROM Pagamento
    WHERE IscrizioneID = inputIscrizioneID;

    UPDATE Iscrizione
    SET StatoIscrizione = 'Annullata'
    WHERE IscrizioneID = inputIscrizioneID;
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS MostraRegistrazioni;

DELIMITER $$

CREATE PROCEDURE MostraRegistrazioni (IN inputPassaporto VARCHAR(15))
BEGIN      
    SELECT 
        R.RegistrazioneID,
        R.DataRegistrazione,
        R.Casino,
        C.Nome AS NomeCasino
    FROM 
        Registrazione R
    INNER JOIN 
        Casino C ON R.Casino = C.Licenza
    WHERE 
        R.Giocatore = inputPassaporto;
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS ElencaSaleLibre;

DELIMITER $$

CREATE PROCEDURE ElencaSaleLibre (IN inputCasino CHAR(6))
BEGIN      
    SELECT 
        SalaID,
        Superficie,
        Stato
    FROM 
        Sala
    WHERE 
        Casino = inputCasino
        AND Stato = 'Libera';
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS AssegnaCroupier;

DELIMITER $$

CREATE PROCEDURE AssegnaCroupier (IN PassaportoDipendente VARCHAR(15),
    IN inputSalaID INT,
    IN inputTavoloID INT)
BEGIN      
    DECLARE PosizioneDipendente ENUM('Manager', 'Croupier', 'Receptionist', 'Security', 'Cleaner');
    DECLARE CasinoDipendente CHAR(6);

    SELECT Posizione, Casino
    INTO PosizioneDipendente, CasinoDipendente
    FROM Dipendente
    WHERE Passaporto = PassaportoDipendente;

    IF PosizioneDipendente IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il dipendente non esiste.';
    END IF;

    IF PosizioneDipendente != 'Croupier' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il dipendente non è un Croupier.';
    END IF;

    UPDATE Tavolo
    SET Responsabile = NULL
    WHERE Responsabile = PassaportoDipendente;

    UPDATE Tavolo
    SET Responsabile = PassaportoDipendente
    WHERE TavoloID = inputTavoloID AND SalaID = inputSalaID AND Casino = CasinoDipendente;

END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS IscrizioneTorneo;

DELIMITER $$

CREATE PROCEDURE IscrizioneTorneo ( IN GiocatorePassaporto VARCHAR(15),
    IN InputEdizioneID INT,
    IN Sconto DECIMAL(5, 2))
BEGIN      
   DECLARE CasinoEdizione CHAR(6);
    DECLARE StatoEdizione ENUM('Pianificato', 'InCorso', 'Completato');
    DECLARE TassaIscrizione DECIMAL(9, 2);
    DECLARE IsRegistered INT;
    DECLARE CurrentTime DATETIME;

    SET CurrentTime = NOW();

    SELECT Casino, StatoTorneo, TassaIscrizione
    INTO CasinoEdizione, StatoEdizione, TassaIscrizione
    FROM EdizioneTorneo
    WHERE NomeTorneo = InputEdizioneID
    LIMIT 1;  

    IF CasinoEdizione IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: EdizioneTorneo non esiste.';
    END IF;

    SELECT COUNT(*)
    INTO IsRegistered
    FROM Registrazione
    WHERE Giocatore = GiocatorePassaporto AND Casino = CasinoEdizione;

    IF IsRegistered = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il giocatore non è registrato nel casino dell`edizione torneo.';
    END IF;

    IF StatoEdizione != 'Pianificato' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il torneo non è in stato Pianificato. Impossibile iscriversi.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Iscrizione
        WHERE GiocatoreID = GiocatorePassaporto AND NomeTorneo = InputEdizioneID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il giocatore è già iscritto a questo torneo.';
    END IF;

    INSERT INTO Iscrizione (GiocatoreID, NomeTorneo, DataIscrizione, Sconto, StatoIscrizione)
    VALUES (GiocatorePassaporto, InputEdizioneID, CurrentTime, Sconto, 'Attiva');

    SET @LastIscrizioneID = LAST_INSERT_ID();

    SET @ImportoPagato = TassaIscrizione * (1 - Sconto / 100);

    INSERT INTO Pagamento (GiocatoreID, IscrizioneID, DataPagamento, ImportoPagato, StatoPagamento)
    VALUES (GiocatorePassaporto, @LastIscrizioneID, CurrentTime, @ImportoPagato, 'InAttesa');

END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS PagamentoTassa;

DELIMITER $$

CREATE PROCEDURE PagamentoTassa (IN InputIscrizioneID INT,
    IN MetodoPagamento VARCHAR(100))
BEGIN      
   DECLARE inputPagamentoID INT;
    DECLARE inputStatoPagamento ENUM('Completato', 'Fallito', 'InAttesa');
    DECLARE TorneoID INT;
    DECLARE CurrentTime DATETIME;

    SET CurrentTime = NOW();

    SELECT GiocatoreID, StatoPagamento
    INTO inputPagamentoID, inputStatoPagamento
    FROM Pagamento
    WHERE IscrizioneID = InputIscrizioneID;

    IF inputPagamentoID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Nessun pagamento associato a questo IscrizioneID.';
    END IF;

    IF inputStatoPagamento != 'InAttesa' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il pagamento non è in stato InAttesa. Impossibile completare.';
    END IF;

    UPDATE Pagamento
    SET StatoPagamento = 'Completato'
    WHERE GiocatoreID = inputPagamentoID;

    UPDATE Iscrizione
    SET StatoIscrizione = 'Completata'
    WHERE IscrizioneID = InputIscrizioneID;

    INSERT INTO Fattura (IscrizioneID, DataFattura, MetodoPagamento)
    VALUES (inputPagamentoID, CurrentTime, MetodoPagamento);

    UPDATE EdizioneTorneo
    SET NumeroPartecipanti = NumeroPartecipanti + 1
    WHERE NomeTorneo = (SELECT NomeTorneo FROM Iscrizione WHERE IscrizioneID = InputIscrizioneID);
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS ImpostaVincitore;

DELIMITER $$

CREATE PROCEDURE ImpostaVincitore (IN InputEdizioneID INT,
    IN InputPassaporto VARCHAR(15))
BEGIN      
   DECLARE IsParticipated INT;
   DECLARE IsCompletata INT;

    SELECT COUNT(*)
    INTO IsParticipated
    FROM Iscrizione
    WHERE GiocatoreID = InputPassaporto
      AND NomeTorneo = InputEdizioneID;

    IF IsParticipated = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il giocatore non ha partecipato al torneo o non è iscritto.';
    END IF;

    SELECT COUNT(*)
    INTO IsCompletata
    FROM Iscrizione
    WHERE GiocatoreID = InputPassaporto
      AND NomeTorneo = InputEdizioneID
      AND StatoIscrizione = 'Completata';

    IF IsCompletata = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: Il giocatore non ha completato il torneo.';
    END IF;

    UPDATE EdizioneTorneo
    SET Vincitore = InputPassaporto, StatoTorneo = 'Completato'
    WHERE NomeTorneo = InputEdizioneID;

END $$

DELIMITER ;

############################## Trigger #################################
DROP TRIGGER IF EXISTS AfterDipendenteDelete;

DELIMITER $$

CREATE TRIGGER AfterDipendenteDelete
AFTER DELETE ON Dipendente
FOR EACH ROW
BEGIN
    INSERT INTO ImpiegoPassato (
        Passaporto, 
        Cognome, 
        Nome, 
        NumeroDiTelefono, 
        DataDiAssunzione, 
        DataDiCessazione, 
        Casino, 
        Posizione
    )
    VALUES (
        OLD.Passaporto,
        OLD.Cognome,
        OLD.Nome,
        OLD.NumeroDiTelefono,
        OLD.DataDiAssunzione,
        NOW(), 
        OLD.Casino,
        OLD.Posizione
    );
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS PagamentoFallito;
DELIMITER $$

CREATE TRIGGER PagamentoFallito
AFTER UPDATE ON Pagamento
FOR EACH ROW
BEGIN
    IF OLD.StatoPagamento != 'Fallito' AND NEW.StatoPagamento = 'Fallito' THEN
        UPDATE Iscrizione
        SET StatoIscrizione = 'Annullata'
        WHERE IscrizioneID = NEW.IscrizioneID;
    END IF;
END $$

DELIMITER ;

############################## Viste #################################
CREATE OR REPLACE VIEW CapacitaCasino AS
SELECT 
    c.Licenza AS CasinoID,
    c.Nome AS CasinoName,
    c.Citta AS City,
    c.Via AS Address,
    COALESCE(SUM(t.MaxDiGiocatori), 0) AS CapacitaTotale
FROM 
    Casino c
LEFT JOIN Sala s ON c.Licenza = s.Casino
LEFT JOIN Tavolo t ON s.SalaID = t.SalaID AND s.Casino = t.Casino
GROUP BY 
    c.Licenza, c.Nome, c.Citta, c.Via;

CREATE OR REPLACE VIEW TorneiAttivi AS
SELECT 
    NomeTorneo,
    DataInizio AS DataInizioTorneo,
    NumeroPartecipanti,
    TassaIscrizione,
    StatoTorneo,
    SalaID,
    Casino
FROM 
    EdizioneTorneo
WHERE 
    StatoTorneo IN ('Pianificato', 'InCorso');
