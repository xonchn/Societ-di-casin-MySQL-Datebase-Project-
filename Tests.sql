############################## TEST #################################

/* Per evitare di aggiungere codice superfluo, 
non ho ripristinato lo stato iniziale del database al termine di ogni test. 
Si consiglia di rigenerare il database alla fine di ogni serie di test correlati. */

/*
Procedura 1. AnnullaIscrizione
Risultato:
- Iscrizione 1: annullata, pagamento e fattura sono eliminati.
- Iscrizione 2: annullata, pagamento e fattura sono eliminati.
- Iscrizione 3: annullata, pagamento e fattura sono eliminati.
*/
SELECT * FROM Iscrizione;
CALL AnnullaIscrizione(1);
CALL AnnullaIscrizione(2);
CALL AnnullaIscrizione(3);

/* 
Procedura 2. AssegnaCroupier (Passaporto, Sala, Tavolo)
Risultato:
1. Il responsabile del tavolo 1 nella sala 1 diventa PDEU1004.
2. Error: Il dipendente PDEU1006 non è un Croupier.
*/
SELECT * FROM Tavolo;
CALL AssegnaCroupier('PDEU1004', 1, 1);
CALL AssegnaCroupier('PDEU1006', 1, 2);

/*
Procedura 3. ElencareSaleLibre (Licenza di Casino)
Risultato atteso:
- CASINO FRA001: 1/2/3
- CASINO PRT001: 201/204
- CASINO PRT002: 301/302/304
- CASINO ITA001: 402/404
- CASINO MCO001: 501/502
*/
SELECT * FROM Sala;
CALL ElencareSaleLibre('FRA001');
CALL ElencareSaleLibre('PRT001');
CALL ElencareSaleLibre('PRT002');
CALL ElencareSaleLibre('ITA001');
CALL ElencareSaleLibre('MCO001');

/*
Procedura 4. ImpostaVincitore (EdizioneID, PassaportoDiGiocatore)
*/
# Test 1. Edizione ID: 4, Passaporto: CI69653287
CALL ImpostaVincitore(4, 'CI69653287');
# Risultato: CI69653287 è il vincitore di 'Baccarat Elite Challenge', la sala diventa libera.

# Test 2. Edizione ID: 3, Passaporto: P92832764
CALL ImpostaVincitore(3, 'P92832764');
# Risultato: Error Code: 1644. Error: Il giocatore non ha partecipato al torneo o non è iscritto.

# Test 3. Edizione ID: 5, Passaporto: P18736954
CALL ImpostaVincitore(5, 'P18736954');
# Risultato: Error Code: 1644. Error: Il giocatore non ha completato il torneo.

/*
Procedura 5. IscrivereTorneo (GiocatorePassaporto, EdizioneID, Sconto)
*/
# Test 1. GiocatorePassaporto: CI69653287, EdizioneID: 6, Sconto: 20
CALL IscrivereTorneo('CI69653287', 6, 20);
# Risultato: Le informazioni di registrazione di CI69653287 sono state inserite con successo ed è stato generato un pagamento.

# Test 2. GiocatorePassaporto: P18736954, EdizioneID: 5, Sconto: 50
CALL IscrivereTorneo('P18736954', 5, 50);
# Risultato: Errore: Il torneo non è in stato Pianificato. Impossibile iscriversi.

# Test 3. GiocatorePassaporto: P10122691, EdizioneID: 5, Sconto: 20
CALL IscrivereTorneo('P10122691', 5, 20);
# Risultato: Errore: Il giocatore non è registrato nel casino dell'edizione torneo.

/*
Procedura 6. MostraRegistrazioni (GiocatorePassaporto)
*/
# Test 1. GiocatorePassaporto: P23511615
CALL MostraRegistrazioni('P23511615');
# Risultato: Mostra registrazioni per MCO001 e ITA001.

# Test 2. GiocatorePassaporto: P46283109
CALL MostraRegistrazioni('P46283109');
# Risultato: Mostra registrazione per DEU001.

/*
Procedura 7. PagareTassa (IscrizioneID, MetodoPagamento)
*/
# Test 1. IscrizioneID: 10, MetodoPagamento: Cash
CALL PagareTasse(10, 'Cash');
# Risultato: Il pagamento è già stato effettuato e la fattura è già stata emessa.

# Test 2. IscrizioneID: 11, MetodoPagamento: Cash
CALL PagareTasse(11, 'Cash');
# Risultato: Il pagamento è già stato effettuato e la fattura è già stata emessa.

# Test 3. IscrizioneID: 17, MetodoPagamento: Cash
CALL PagareTasse(17, 'Cash');
# Risultato: Error Code: 1644. Errore: Nessun pagamento associato a questo IscrizioneID.

# Test 4. IscrizioneID: 7, MetodoPagamento: Cash
CALL PagareTasse(7, 'Cash');
# Risultato: Errore: Il pagamento non è in stato InAttesa. Impossibile completare.

/*
Trigger 1. AfterDipendenteDelete
*/
# Passaggio 1: Inserire dati di test nella tabella Dipendente
INSERT INTO Dipendente (Passaporto, Cognome, Nome, NumeroDiTelefono, Nazionalita, DataNascita, Posizione, Casino, DataDiAssunzione)  
VALUES  
('P12345678', 'Rossi', 'Mario', '1234567890', 'ITA', '1990-05-15', 'Croupier', 'DEU001', '2023-01-01');

# Passaggio 2: Eliminare i dati di test
DELETE FROM Dipendente WHERE Passaporto = 'P12345678';

# Passaggio 3: Controllare la tabella ImpiegoPassato
SELECT * FROM ImpiegoPassato WHERE Passaporto = 'P12345678';

/*
Trigger 2. PagamentoFallito
*/
# Test 1. Aggiornare lo stato di pagamento per IscrizioneID = 10
UPDATE Pagamento SET StatoPagamento = 'Fallito' WHERE IscrizioneID = 10;
SELECT * FROM Pagamento;
SELECT * FROM Iscrizione;

# Test 2. Aggiornare lo stato di pagamento per IscrizioneID = 2
UPDATE Pagamento SET StatoPagamento = 'Fallito' WHERE IscrizioneID = 2;
SELECT * FROM Pagamento;
SELECT * FROM Iscrizione;

# Test 3. Aggiornare lo stato di pagamento per IscrizioneID = 3
UPDATE Pagamento SET StatoPagamento = 'Fallito' WHERE IscrizioneID = 3;
SELECT * FROM Pagamento;
SELECT * FROM Iscrizione;



