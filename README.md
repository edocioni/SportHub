# SportHub — Progetto di Informatica A.S. 2025/2026

Sistema informativo completo per la gestione di un centro sportivo multidisciplinare su tre edifici (A, B, C).  
Il progetto copre l'intera infrastruttura: rete fisica, database relazionale e applicazione web in PHP.

**Classe:** 5Di - Ferraris Brunelleschi
**Autori:** Edoardo Cioni · Giacomo Scarpellini · Riccardo Bonciolini · Sukhjinder Singh

---

## Struttura della repository

| File / Cartella | Contenuto |
|---|---|
| `schema.pkt` | Topologia di rete completa (Cisco Packet Tracer) |
| `Schema Rete.png` | Immagine esportata dello schema di rete |
| `Schema ER.png` | Diagramma Entità-Relazione del database |
| `Schema Logico.md` | Schema logico delle 11 tabelle |
| `database.sql` | DDL completo — creazione tabelle e vincoli |
| `query.sql` | 7 query SQL (Q1–Q5 analisi + Q6–Q7 PHP) |
| `piano di indirizzamento.pdf` | Piano IP e VLAN (blocco 172.20.0.0/16) |
| `gestione_guasti` | Scenari di guasto e soluzioni (wireless, VPN, backup) |
| `php/` | Applicazione web PHP con prepared statement |
| `images/` | Immagini e risorse grafiche del progetto |
| `SportHub.pdf` | Documentazione completa del progetto |

---

## Come aprire i file

- **`schema.pkt`** → Cisco Packet Tracer
- **`database.sql` / `query.sql`** → MySQL Workbench o qualsiasi client MySQL
- **`php/`** → server con PHP + MySQL (es. XAMPP); configurare la connessione in `db_connection.php`
- **`.pdf` e `.png`** → qualsiasi visualizzatore

---

## Panoramica tecnica

**Rete** — Architettura gerarchica a tre livelli, 6 VLAN (blocco 172.20.0.0/16), routing inter-VLAN via SVI, firewall ASA 5506-X con DMZ, VPN IPsec IKEv2 AES-256, AAA/RADIUS, backup 3-2-1-0.

**Database** — Schema MySQL con 11 tabelle, normalizzazione, query con JOIN multipli, subquery correlate, NOT EXISTS e divisione relazionale.

**Applicazione** — PHP con MySQLi e prepared statement (prevenzione SQL injection); due funzionalità principali: ricerca lezioni disponibili per data e storico prenotazioni per codice fiscale.
