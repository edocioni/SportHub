<?php
    require "db_connection.php";
    $CF = $_POST["CF"];
    $query = "
        SELECT  P.ID_Prenotazione, P.DataPrenotazione, P.Stato, 
        L.ID_Lezione, L.DataOra, L.Durata_Minuti, 
        CONCAT(I.Nome,' ',I.Cognome), 
        (
            SELECT A.DataOra
            FROM Accesso A
            WHERE A.CF_Frequentatore=F.CF
            GROUP BY A.DataOra DESC
            LIMIT 1
        ) AS Ultimo Accesso
        FROM Frequentatore F
        INNER JOIN Prenotazione P ON F.CF=P.CF_Frequentatore
        INNER JOIN Lezione L ON P.ID_Lezione=L.ID_Lezione
        INNER JOIN Istruttore ON L.ID_Istruttore=I.ID_Istruttore
        WHERE F.CF= ?
        ORDER BY L.DataOra DESC;
    ";
    $stmt = $connection->prepare($query);
    $stmt->bind_param("s", $CF);
    $stmt->execute();
    $result = $stmt->get_result();
?>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lezioni Disponibili - SportHub</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #000000;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            padding-top: 180px;
        }
        
        .welcome-section {
            text-align: center;
            position: fixed;
            top: 24px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 999;
            pointer-events: none;
        }
        
        .welcome-section h2 {
            color: #ffffff;
            font-size: 20px;
            margin-bottom: 8px;
            font-weight: 300;
            letter-spacing: 1px;
            pointer-events: auto;
        }
        
        .logo {
            max-width: 260px;
            width: 100%;
            height: auto;
            display: block;
            margin: 0 auto;
            pointer-events: auto;
        }
        
        .container {
            background: #2a2a2a;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
            padding: 40px;
            max-width: 900px;
            width: 100%;
        }
        
        h1 {
            color: #ffffff;
            margin-bottom: 30px;
            font-size: 24px;
            text-align: center;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            border: 2px solid #ff8c00;
            border-radius: 6px;
            overflow: hidden;
        }
        
        thead {
            background: #1a1a1a;
            border-bottom: 2px solid #ff8c00;
        }
        
        th {
            color: #ff8c00;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            border-right: 1px solid #ff8c00;
        }
        
        th:last-child {
            border-right: none;
        }
        
        td {
            color: #ffffff;
            padding: 12px 16px;
            border-right: 1px solid #444444;
        }
        
        td:last-child {
            border-right: none;
        }
        
        tbody tr {
            border-bottom: 1px solid #444444;
            transition: background-color 0.3s ease;
        }
        
        tbody tr:hover {
            background-color: #333333;
        }
        
        tbody tr:last-child {
            border-bottom: none;
        }
        
        .no-data {
            text-align: center;
            padding: 40px 20px;
            color: #ff8c00;
            font-size: 18px;
        }
        
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            border: 2px solid #ff8c00;
            color: #ffffff;
            background: #000000;
            border-radius: 6px;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .back-link:hover {
            background: #1a1a1a;
            box-shadow: 0 5px 15px rgba(255, 140, 0, 0.4);
        }
    </style>
</head>
<body>
    <div class="welcome-section">
        <h2>Benvenuti in</h2>
        <img src="../images/logo nero.png" alt="SportHub Logo" class="logo">
    </div>
    
    <div class="container">
        <h1>Lezioni Disponibili</h1>
    <?php
    if ($result->num_rows > 0) {
        echo "<table><thead><tr>
              <th>ID</th><th>Data</th><th>Ora</th><th>Durata</th><th>Istruttore</th>
              <th>Ultimo Accesso</th>
              </tr></thead><tbody>";
        while ($row = $result->fetch_assoc()) {
            echo "<tr>
                  <td>{$row['ID_Prenotazione']}</td>
                  <td>{$row['DataPrenotazione']}</td>
                  <td>{$row['DataOra']}</td>
                  <td>{$row['Durata_Minuti']}</td>
                  <td>{$row['Nome']} {$row['Cognome']}</td>
                  <td>{$row['Ultimo Accesso']}</td>
                  </tr>";
        }
        echo "</tbody></table>";
    } else {
        echo "<p class='no-data'>Nessuna lezione disponibile per questa data.</p>";
    }
    ?>
    
    <div style="text-align: center;">
        <a href="form1.html" class="back-link">← Torna al form</a>
    </div>
    </div>
</body>
</html>