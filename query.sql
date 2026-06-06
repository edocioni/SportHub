-- ============================================================
-- QUERY 1
-- Frequentatori con certificato medico in scadenza entro 30 giorni
-- che hanno prenotazioni future confermate, con dettaglio abbonamento
-- ============================================================

SELECT
    DISTINCT F.CF,
    F.Nome,
    F.Cognome,
    DATEDIFF(CM.DataScadenza, CURDATE()) AS GiorniAllaScadenza,
    TA.Nome AS TipoAbbonamento,
    A.DataScadenza AS ScadenzaAbbonamento
FROM Frequentatore AS F
INNER JOIN Certificato_Medico AS CM
    ON F.CF = CM.CF_Frequentatore
INNER JOIN Prenotazione AS P
    ON F.CF = P.CF_Frequentatore
INNER JOIN Lezione AS L
    ON P.ID_Lezione = L.ID_Lezione
INNER JOIN Abbonamento AS A
    ON F.CF = A.CF_Frequentatore
INNER JOIN Tipo_Abbonamento AS TA
    ON A.ID_Tipo = TA.ID_Tipo
WHERE
    CM.DataScadenza <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
    AND P.Stato = 'Confermato'
    AND L.DataOra > NOW()
    AND A.Stato = 'Attivo'
ORDER BY GiorniAllaScadenza;



-- ============================================================
-- QUERY 2
-- Classifica degli istruttori per lezioni tenute nell'ultimo trimestre,
-- con media partecipanti, ore totali e tasso di riempimento medio delle sale
-- ============================================================

SELECT
    I.Nome,
    I.Cognome,
    COUNT(DISTINCT L.ID_Lezione) AS N_Lezioni,
    ROUND(SUM(L.Durata_Minuti) / 60.0, 1) AS Ore_Totali,
    ROUND(COUNT(P.ID_Prenotazione) * 1.0 / COUNT(DISTINCT L.ID_Lezione), 1) AS Media_Partecipanti,
    ROUND(
        AVG(
            (
                SELECT COUNT(*)
                FROM Prenotazione AS P2
                WHERE P2.ID_Lezione = L.ID_Lezione
                  AND P2.Stato = 'Confermato'
            ) / S.Capienza * 100
        ),
    1) AS Riempimento_Medio
FROM Istruttore AS I
INNER JOIN Lezione AS L
    ON I.ID_Istruttore = L.ID_Istruttore
INNER JOIN Sala AS S
    ON L.ID_Sala = S.ID_Sala
LEFT JOIN Prenotazione AS P
    ON L.ID_Lezione = P.ID_Lezione
    AND P.Stato = 'Confermato'
WHERE L.DataOra BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND CURDATE()
GROUP BY I.ID_Istruttore, I.Nome, I.Cognome
ORDER BY N_Lezioni DESC;



-- ============================================================
-- QUERY 3
-- Discipline con più di 10 prenotazioni confermate nell'ultimo mese,
-- raggruppate per edificio, con dettaglio sala più utilizzata
-- ============================================================

SELECT
    C.Disciplina,
    E.ID_Edificio,
    COUNT(P.ID_Prenotazione) AS TotalePrenotazioni,
    (
        SELECT S2.Nome
        FROM Lezione AS L2
        INNER JOIN Sala AS S2
            ON L2.ID_Sala = S2.ID_Sala
        INNER JOIN Corso AS C2
            ON L2.ID_Corso = C2.ID_Corso
        INNER JOIN Prenotazione AS P2
            ON L2.ID_Lezione = P2.ID_Lezione
        WHERE C2.Disciplina = C.Disciplina
          AND S2.ID_Edificio = E.ID_Edificio
          AND P2.Stato = 'Confermato'
          AND L2.DataOra >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
        GROUP BY L2.ID_Sala, S2.Nome
        ORDER BY COUNT(P2.ID_Prenotazione) DESC
        LIMIT 1
    ) AS SalaPiuUsata
FROM Corso AS C
INNER JOIN Lezione AS L
    ON C.ID_Corso = L.ID_Corso
INNER JOIN Prenotazione AS P
    ON L.ID_Lezione = P.ID_Lezione
INNER JOIN Sala AS S
    ON L.ID_Sala = S.ID_Sala
INNER JOIN Edificio AS E
    ON S.ID_Edificio = E.ID_Edificio
WHERE P.Stato = 'Confermato'
  AND P.DataPrenotazione >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY S.ID_Edificio, C.Disciplina
HAVING COUNT(P.ID_Prenotazione) > 10
ORDER BY E.ID_Edificio, TotalePrenotazioni DESC;

-- ============================================================
-- QUERY 4
-- Frequentatori "a rischio": abbonamento attivo ma che hanno
-- saltato più di 3 lezioni prenotate nell'ultimo mese,
-- e che non hanno effettuato accessi negli ultimi 14 giorni
-- ============================================================

SELECT
    F.CF,
    F.Nome,
    F.Cognome,
    (
        SELECT COUNT(*)
        FROM Prenotazione AS P2
        WHERE P2.CF_Frequentatore = F.CF
          AND P2.Stato = 'Cancellato'
          AND P2.ID_Lezione IN (
              SELECT ID_Lezione
              FROM Lezione
              WHERE DataOra >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
          )
    ) AS LezioniSaltate
FROM Frequentatore AS F
INNER JOIN Abbonamento AS A
    ON F.CF = A.CF_Frequentatore
WHERE A.Stato = 'Attivo'
  AND (
      SELECT COUNT(*)
      FROM Prenotazione AS P1
      WHERE F.CF = P1.CF_Frequentatore
        AND P1.Stato = 'Cancellato'
        AND P1.ID_Lezione IN (
            SELECT ID_Lezione
            FROM Lezione AS L
            WHERE L.DataOra >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
        )
  ) > 3
  AND NOT EXISTS (
      SELECT *
      FROM Accesso AS AC
      WHERE F.CF = AC.CF_Frequentatore
        AND AC.DataOra >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)
  )
ORDER BY LezioniSaltate DESC;

-- ============================================================
-- QUERY 5
-- Frequentatori che hanno prenotato (almeno una volta, confermata)
-- TUTTE le discipline attualmente offerte dal centro
-- ============================================================

SELECT
    F.CF,
    F.Nome,
    F.Cognome,
    F.Email,
    (
        SELECT COUNT(DISTINCT C2.Disciplina)
        FROM Corso AS C2
    ) AS TotaleDisciplineOfferte
FROM Frequentatore AS F
WHERE NOT EXISTS (
    SELECT DISTINCT C.Disciplina
    FROM Corso AS C
    WHERE NOT EXISTS (
        SELECT *
        FROM Prenotazione AS P
        INNER JOIN Lezione AS L
            ON P.ID_Lezione = L.ID_Lezione
        INNER JOIN Corso AS C1
            ON L.ID_Corso = C1.ID_Corso
        WHERE P.CF_Frequentatore = F.CF
          AND P.Stato = 'Confermato'
          AND C1.Disciplina = C.Disciplina
    )
)
ORDER BY F.Cognome, F.Nome;

-- ============================================================
-- QUERY PER PUNTO 4
-- ============================================================

-- ============================================================
-- QUERY 6
-- Visualizzazione delle lezioni disponibili in un determinato
-- giorno con stato di riempimento delle sale
-- ============================================================

SELECT
    L.ID_Lezione,
    TIME(L.DataOra) AS Ora,
    DATE(L.DataOra) AS Data,
    L.Durata_Minuti,
    C.Nome,
    S.Nome,
    CONCAT(I.Nome, ' ', I.Cognome) AS Istruttore,
    COUNT(P.ID_Prenotazione) AS PostiOccupati,
    (S.Capienza - COUNT(P.ID_Prenotazione)) AS PostiLiberi,
    ROUND(COUNT(P.ID_Prenotazione) / S.Capienza * 100, 1) AS PercentualeRiempimento
FROM Lezione AS L
INNER JOIN Sala AS S
    ON L.ID_Sala = S.ID_Sala
INNER JOIN Istruttore AS I
    ON L.ID_Istruttore = I.ID_Istruttore
INNER JOIN Corso AS C
    ON L.ID_Corso = C.ID_Corso
LEFT JOIN Prenotazione AS P
    ON L.ID_Lezione = P.ID_Lezione
    AND P.Stato = 'Confermato'
WHERE DATE(L.DataOra) = '2026-05-16'
  AND L.DataOra > NOW()
GROUP BY L.ID_Lezione, S.Capienza
HAVING COUNT(ID_Prenotazione) < S.Capienza
ORDER BY L.DataOra;

-- ============================================================
-- QUERY 7
-- Riepilogo delle prenotazioni effettuate e dell'ultimo 
-- accesso registrato ai varchi per un singolo frequentatore
-- ============================================================

SELECT
    P.ID_Prenotazione,
    P.DataPrenotazione,
    P.Stato,
    L.ID_Lezione,
    L.DataOra,
    L.Durata_Minuti,
    CONCAT(I.Nome, ' ', I.Cognome) AS Istruttore,
    (
        SELECT A.DataOra
        FROM Accesso AS A
        WHERE A.CF_Frequentatore = F.CF
        ORDER BY A.DataOra DESC
        LIMIT 1
    ) AS `Ultimo Accesso`
FROM Frequentatore AS F
INNER JOIN Prenotazione AS P
    ON F.CF = P.CF_Frequentatore
INNER JOIN Lezione AS L
    ON P.ID_Lezione = L.ID_Lezione
INNER JOIN Istruttore AS I
    ON L.ID_Istruttore = I.ID_Istruttore
WHERE F.CF = 'CSRLNZ99C09G843X'
ORDER BY L.DataOra DESC;

-- ============================================================
-- QUERY VALUTAZIONI
-- Analisi delle valutazioni per corso e istruttore:
-- media punteggio, numero recensioni, distribuzione voti,
-- ultimi 3 mesi vs mese precedente (trend)
-- ============================================================

SELECT
    C.Nome AS NomeCorso,
    C.Disciplina,
    CONCAT(I.Nome, ' ', I.Cognome) AS Istruttore,
    COUNT(V.ID_Valutazione) AS NumeroValutazioni,
    ROUND(AVG(V.Punteggio), 2) AS MediaPunteggio,
    SUM(CASE WHEN V.Punteggio = 5 THEN 1 ELSE 0 END) AS Voti5,
    SUM(CASE WHEN V.Punteggio = 4 THEN 1 ELSE 0 END) AS Voti4,
    SUM(CASE WHEN V.Punteggio = 3 THEN 1 ELSE 0 END) AS Voti3,
    SUM(CASE WHEN V.Punteggio <= 2 THEN 1 ELSE 0 END) AS VotiNegativi,
    ROUND(
        AVG(
            CASE
                WHEN V.DataValutazione >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
                THEN V.Punteggio
            END
        ),
    2) AS MediaUltimoMese
FROM Corso AS C
INNER JOIN Lezione AS L
    ON C.ID_Corso = L.ID_Corso
INNER JOIN Istruttore AS I
    ON L.ID_Istruttore = I.ID_Istruttore
INNER JOIN Valutazione AS V
    ON L.ID_Lezione = V.ID_Lezione
WHERE V.DataValutazione >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY C.ID_Corso, C.Nome, C.Disciplina, I.ID_Istruttore, I.Nome, I.Cognome
HAVING COUNT(V.ID_Valutazione) >= 3
ORDER BY MediaPunteggio DESC, NumeroValutazioni DESC;